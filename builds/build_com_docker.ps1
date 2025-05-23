# Altere o runtime para "windows", "linux" ou "switch"
# param($runtime = "windows", $lang = "pt")

# Instala o módulo "PsIni" que permite manipular o arquivo Ini
Install-Module -Scope CurrentUser PsIni
Import-Module PsIni

Set-Location $PSScriptRoot

function Main {
    $runtime = ReadHostMultipleChoice -message "Compilar para qual plataforma?" -choices @("windows", "linux", "switch")
    $lang = ReadHostMultipleChoice -message "Qual idioma? (Deixe em branco para inglês)" -acceptEmpty $true -choices @("us", "de", "fr", "fr-c", "en", "es", "pl", "pt", "redux", "nl", "sv")
    # $extendedAspectRatio = ReadHostMultipleChoice -message "Resolução em 16:9? (Deixe em branco para não)" -acceptEmpty $true -choices @("S", "N")
    # $turnWhileDashing = ReadHostMultipleChoice -message "Permite virar enquanto corre? (Deixe em branco para não)" -acceptEmpty $true -choices @("S", "N")
    # $itemSwitchLR = ReadHostMultipleChoice -message "Alternador de itens com as teclas L/R e atribuir item ao botão X? (Deixe em branco para não)" -acceptEmpty $true -choices @("S", "N")
    # $carryMoreRupees = ReadHostMultipleChoice -message "Aumentar o limite de rúpias de 999 para 9999? (Deixe em branco para não)" -acceptEmpty $true -choices @("S", "N")
    # $disableLowHealthBeep = ReadHostMultipleChoice -message "Desabilitar sinal sonoro de baixa saúde? (Deixe em branco para não)" -acceptEmpty $true -choices @("S", "N")
    # $linkSkinMinishCap = ReadHostMultipleChoice -message "Link com a aparencia do Minish Cap? (Deixe em branco para não)" -acceptEmpty $true -choices @("S", "N")

    $volume = "${PSScriptRoot}/../:/snes-build"
    
    BuildContainer
    
    $iniFile = "";
    $buildFolder = "";
    if ($runtime -eq "switch") {
        docker run --rm -v $volume -e DEVKITPRO=/opt/devkitpro snes-build sh -c 'cd src/platform/switch && make'
        docker run --rm -v $volume snes-build make -f builds/Makefile RUNTIME=$runtime LANGUAGE=$lang TARGET_EXEC=''

        New-Item -ItemType Directory -Force -Path "switch/smw"
        Copy-Item "../src/platform/switch/smw.ini" "switch/smw/smw.ini" -Force
        Move-Item "../src/platform/switch/smw.nro" "switch/smw/smw.nro" -Force
        Move-Item "switch/smw_assets.dat" "switch/smw/smw_assets.dat" -Force
        Remove-Item "switch/smw.ini" -Force

        echo "Copie a pasta smw para dentro da pasta `"/switch`" do Cartão SD do Switch" > "switch/README.txt"

        $iniFile = "switch/smw/smw.ini";
        $buildFolder = "switch/smw";
    } else {
        docker run --rm -v $volume snes-build make -f builds/Makefile RUNTIME=$runtime LANGUAGE=$lang
        
        $iniFile = "$runtime/smw.ini";
        $buildFolder = "$runtime";
    }

    $FileContent = Get-IniContent $iniFile 

    # Alterando o ini conforme as configurações fornecidas
    if ($lang -ne "") {
        $FileContent["General"]["Language"] = $lang
    }
    # if ($extendedAspectRatio -eq "S") {
    #     $FileContent["General"]["ExtendedAspectRatio"] = "extend_y,16:9"
    # }
    # if ($itemSwitchLR -eq "S") {
    #     $FileContent["Features"]["ItemSwitchLR"] = "1"
    # }
    # if ($turnWhileDashing -eq "S") {
    #     $FileContent["Features"]["TurnWhileDashing"] = "1"
    # }
    # if ($disableLowHealthBeep -eq "S") {
    #     $FileContent["Features"]["DisableLowHealthBeep"] = "0"
    # }
    # if ($carryMoreRupees -eq "S") {
    #     $FileContent["Features"]["CarryMoreRupees"] = "0"
    # }
    # if ($linkSkinMinishCap -eq "S") {
    #     $FileContent["Graphics"]["LinkGraphics"] = "minishcaplink.3.zspr"
    #     Copy-Item "../other/minishcaplink.3.zspr" "$buildFolder/minishcaplink.3.zspr" -Force
    # }
    
    Out-IniFile -InputObject $FileContent -FilePath $iniFile -Force
}
  
function BuildContainer {
    docker build . -t snes-build
}


function ReadHostMultipleChoice( $message, [string[]]$choices, $acceptEmpty, $hideChoices = $false ) {
    if (-not $hideChoices) {
        $message += " ($($choices -join ", "))"
    }

    $choice = Read-Host $message

    if ($acceptEmpty -and $choice -eq "") {
        return $choice
    }

    while ($choices -notcontains $choice) {
        $choice = Read-Host "Escolha inválida. $message ($choices)"
    }
    return $choice
}
Main
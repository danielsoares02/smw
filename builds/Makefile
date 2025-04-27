RUNTIME:=$(if $(RUNTIME),$(RUNTIME),linux)
ROM:=/snes-build/extras/smw.sfc
SMB1_FOLDER:=/snes-build/smb1
SMBLL_FOLDER:=/snes-build/smbll
SRC_FOLDER:=/snes-build/src
GL_CORE_FOLDER:=/snes-build/third_party/gl_core
BUILDS_FOLDER:=/snes-build/builds/$(RUNTIME)
ASSETS_FOLDER:=/snes-build/assets
TARGET_EXEC:=$(BUILDS_FOLDER)/smw

SRCS:=$(wildcard $(SMB1_FOLDER)/*.c $(SMBLL_FOLDER)/*.c $(SRC_FOLDER)/*.c $(SRC_FOLDER)/snes/*.c) $(GL_CORE_FOLDER)/gl_core_3_1.c
OBJS:=$(SRCS:%.c=%.o)

PYTHON:=/usr/bin/env python3
CFLAGS:=$(if $(CFLAGS),$(CFLAGS),-O2 -fno-strict-aliasing -Werror ) -I .
CFLAGS2:=$(shell sdl2-config --cflags) -DSYSTEM_VOLUME_MIXER_AVAILABLE=0

ifeq (${RUNTIME},windows)
	RES:=$(ASSETS_FOLDER)/smw.res
	TARGET_EXEC:=$(TARGET_EXEC).exe

#	Se estivermos no Linux usa o cross-compiler para Windows
	SDL2_DLL:=$(BUILDS_FOLDER)/SDL2.dll
	SDLFOLDER:=/snes-build/extras/SDL2
	MINGW32:=x86_64-w64-mingw32
	CFLAGS2:=-I$(SDLFOLDER)/include/SDL2 -Dmain=SDL_main -DSYSTEM_VOLUME_MIXER_AVAILABLE=0
	WINDRES:=$(MINGW32)-windres
	CC:=$(MINGW32)-gcc-9
	SDLFLAGS:=-static-libgcc -static-libstdc++ -Wl,-Bstatic -L$(SDLFOLDER)/lib -lSDL2 -I$(SDLFOLDER)/include/SDL2 -lSDL2main $(SDLFOLDER)/lib/libSDL2.a -lmingw32 -mwindows -lm -lkernel32 -luser32 -lgdi32 -lwinmm -limm32 -lole32 -loleaut32 -lversion -luuid -ladvapi32 -lsetupapi -lshell32 -ldinput8
else
# 	Configura o destino para Linux
	SDLFLAGS:=-lSDL2 -lm
endif

.PHONY: all clean clean_obj

all: $(BUILDS_FOLDER)/smw_assets.dat $(TARGET_EXEC) $(SDL2_DLL) $(BUILDS_FOLDER)/smw.ini

$(TARGET_EXEC): $(OBJS) $(RES)
	$(CC) $^ -o $@ $(LDFLAGS) $(SDLFLAGS)

%.o : %.c
	$(CC) -c $(CFLAGS) $(CFLAGS2) $< -o $@

$(RES): $(SRC_FOLDER)/platform/win32/smw.rc
	@echo "Generating Windows resources"
	@$(WINDRES) $< -O coff -o $@

$(BUILDS_FOLDER)/smw_assets.dat:
	@echo "Extracting game resources"
	$(PYTHON) $(ASSETS_FOLDER)/restool.py -r ${ROM} --dat-path=$(BUILDS_FOLDER)

$(SDL2_DLL): ${SDLFOLDER}/bin/SDL2.dll
	@echo "Copiando o SDL2.dll"
	cp ${SDLFOLDER}/bin/SDL2.dll $(BUILDS_FOLDER)

$(BUILDS_FOLDER)/smw.ini: smw.ini
	@echo "Copiando o smw.ini"
	cp /snes-build/smw.ini $(BUILDS_FOLDER)

clean: clean_obj clean_gen
clean_obj:
	@$(RM) $(OBJS) $(TARGET_EXEC)
clean_gen:
	@$(RM) $(RES) /snes-build/smw_assets.dat
	@rm -rf $(ASSETS_FOLDER)/__pycache__

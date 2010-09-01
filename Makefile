# Make file for LexLPeg external lexer for Scintilla.
# Copyright 2010 Mitchell mitchell<att>caladbolg.net

.SUFFIXES: .cxx .c .o .h .a

ifdef WIN32
CC = i486-mingw32-gcc -mno-cygwin
CPP = i486-mingw32-g++ -mno-cygwin
DLLWRAP = $(CPP) -shared
PLAT_FLAGS =
LUA_CFLAGS = -D_WIN32 -DWIN32
LEXLPEG = lexers/LexLPeg.dll
SO_FLAGS = -static -mwindows --relocatable -s LexLPeg.def \
  -Wl,--enable-stdcall-fixup
else
CC = gcc -fPIC
CPP = g++ -fPIC
DLLWRAP = $(CPP) -shared
PLAT_FLAGS = -DGTK
LUA_CFLAGS = -DLUA_USE_LINUX
LEXLPEG = lexers/liblexlpeg.so
SO_FLAGS = -g -Wl,-soname,$(LEXLPEG).0 -Wl,-fvisibility=hidden
endif

INCLUDEDIRS = -I scintilla/include -I scintilla/lexlib -I scite/lua/include

# Lua
vpath %.c scite/lua/src scite/lua/src/lib
LUA_OBJS = lapi.o lcode.o ldebug.o ldo.o ldump.o lfunc.o lgc.o llex.o lmem.o \
  lobject.o lopcodes.o lparser.o lstate.o lstring.o ltable.o ltm.o lundump.o \
  lvm.o lzio.o \
  lauxlib.o lbaselib.o ldblib.o liolib.o lmathlib.o ltablib.o lstrlib.o \
  loadlib.o loslib.o linit.o \
  lpeg.o

# Scintilla
SCI_CXXFLAGS = -g -pedantic $(PLAT_FLAGS) $(INCLUDEDIRS) -DSCI_LEXER \
  -Wall -Wno-missing-braces -Wno-char-subscripts
vpath %.cxx scintilla/lexlib
LEX_OBJS = PropSetSimple.o WordList.o LexerModule.o LexerSimple.o LexerBase.o \
  Accessor.o

all: $(LEXLPEG)

$(LEXLPEG): LexLPeg.o $(LUA_OBJS) $(LEX_OBJS)
	$(DLLWRAP) $(SO_FLAGS) LexLPeg.o $(LUA_OBJS) $(LEX_OBJS) -o $(LEXLPEG)
LexLPeg.o: LexLPeg.cxx
	$(CPP) $(SCI_CXXFLAGS) $(LUA_CFLAGS) -DLPEG_LEXER_EXTERNAL -c $<
.c.o:
	$(CC) $(INCLUDEDIRS) $(LUA_CFLAGS) -c $<
.cxx.o:
	$(CPP) $(SCI_CXXFLAGS) -c $<
clean:
	rm *.o $(LEXLPEG)
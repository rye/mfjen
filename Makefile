COMPILER=gcc

PROJECTFLAGS:=
FLAGS:=$(PROJECTFLAGS) -lm -I. -ggdb -std=c11

COMPILEFLAGS=$(FLAGS) -fPIC
LINKFLAGS=$(FLAGS)

HEADERS=$(wildcard src/*.h) $(wildcard src/*/*.h)
PROGRAMOBJECTS=$(patsubst src/%.c,obj/%.o,$(wildcard src/*.c)) $(patsubst src/%.c,obj/%.o,$(wildcard src/*/*.c))

# Just change value of PROGRAMNAME when good name is found
PROGRAMNAME=
PROGRAMFILE=$(if $(PROGRAMNAME),bin/$(PROGRAMNAME).$(shell arch),bin/$(notdir $(shell pwd)).$(shell arch))

all: $(PROGRAMFILE)

obj/%.o: src/%.c $(HEADERS)
	$(COMPILER) -c -o $@ $< $(COMPILEFLAGS) -fPIC

$(PROGRAMFILE): $(PROGRAMOBJECTS)
	$(COMPILER) -o $(PROGRAMFILE) $(PROGRAMOBJECTS) $(LINKFLAGS)

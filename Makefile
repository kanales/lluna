.POSIX: 
.SUFFIXES:


LUAJIT_INCLUDE =	/usr/local/include/luajit-2.0/
LUAJIT_LIB    	= /usr/local/Cellar/luajit/2.0.5/lib
CFLAGS					= -Wall -I$(LUAJIT_INCLUDE) -O3
LDFLAGS 				= -L$(LUAJIT_LIB) 
LDLIBS 					= -lluajit -lreadline
PREFIX 					= $(HOME)/.local

REPL_SRC        = $(wildcard deps/repl*.c)
REPL_OBJ				= $(REPL_SRC:.c=.o)

.PHONY: all clean install bench
all: lluna

bench: lluna bench/main
	./bench/main 1000

install: all
	@echo "Installing lluna to '$(DESTDIR)$(PREFIX)/bin'"
	@mkdir -p 		$(DESTDIR)$(PREFIX)/bin
	@cp -f lluna	$(DESTDIR)$(PREFIX)/bin
	@$(MAKE) -C lluna-std install

clean: 
	$(RM) lluna **/*.o **/*.so 

bench/main: bench/main.o
	$(CC) $(LDFLAGS) -o $@ $^

# Requires luajit, libcurl and readline
lluna: deps/lluna.o deps/lluna.o $(REPL_OBJ)
	$(CC) $(LDFLAGS) $(LDLIBS) -pagezero_size 10000 -o lluna $^
src/std/termios.so: deps/lua_termios.o
	$(CC) $(LDFLAGS) $(LDLIBS) -fPIC --shared -o $@ $^ 

deps/lluna.lua: lluna-std/lua/lluna.lua
	cp $^ $@

%.lua.h: %.lua
	luajit -b $^ $@

%.o: %.c deps/repl.lua.h deps/lluna.lua.h
	$(CC) $(CFLAGS) -c -o $@ $<


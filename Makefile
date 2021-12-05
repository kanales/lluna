CFLAGS= -I/usr/local/include/luajit-2.0/
LDFLAGS= -lluajit -lreadline

# Requires luajit, libcurl and readline
lluna: deps/lluna.o deps/repl.o
	$(CC) $(LDFLAGS) -pagezero_size 10000 -o lluna $^
src/std/termios.so: deps/lua_termios.o
	$(CC) $(LDFLAGS) -fPIC --shared -o $@ $^ 

deps/%.o: deps/%.c
	$(CC) $(CFLAGS) -c -o $@ $^

.PHONY: install
install: lluna src/std/termios.so
	-rm -rf $(HOME)/.lluna
	-mkdir $(HOME)/.lluna
	-cp -r src/std $(HOME)/.lluna
	-cp lluna /usr/local/bin/lluna

.PHONY: clean
clean:
	$(RM) lluna **/*.o **/*.so
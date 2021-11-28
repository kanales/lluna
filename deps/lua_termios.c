#include <stdlib.h>
#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include "lua_termios.h"

void die(const char *s)
{
    perror(s);
    exit(1);
}

struct termios orig_termios;
void _disable_raw_mode()
{
    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios) == -1)
        die("tcsetattr");
}

int disable_raw_mode(lua_State *L)
{
    _disable_raw_mode();
    return 0;
}

int enable_raw_mode(lua_State *L)
{
    if (tcgetattr(STDIN_FILENO, &orig_termios) == -1)
        die("tcgetattr");
    atexit(_disable_raw_mode);
    struct termios raw = orig_termios;
    raw.c_iflag &= ~(ICRNL | IXON | INPCK | ISTRIP | IXON);
    raw.c_oflag &= ~(OPOST);
    raw.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
    raw.c_cc[VMIN] = 0;
    raw.c_cc[VTIME] = 1;

    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) == -1)
        die("tcsetattr");
    return 0;
}

int luaopen_termios(lua_State *L)
{
    lua_newtable(L);

    lua_pushcfunction(L, enable_raw_mode);
    lua_setfield(L, -2, "enable_raw_mode");

    lua_pushcfunction(L, disable_raw_mode);
    lua_setfield(L, -2, "disable_raw_mode");

    return 1;
}
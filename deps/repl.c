#include "repl.h"

#include <lauxlib.h>
#include <stdio.h>
#include <string.h>

void print_all(lua_State *L)
{
    for (int nres = lua_gettop(L); nres > 0; nres--)
    {
        const char *s = lua_tostring(L, 1);
        lua_remove(L, 1);
        fprintf(stderr, "%s\t", s);
    }
    fputc('\n', stderr);
}

void repl_loop(lua_State *L)
{
    char buff[256];
    int error;
    fputs("> ", stderr);
    while (fgets(buff, sizeof(buff), stdin) != NULL)
    {
        switch (error = luaL_loadbuffer(L, buff, strlen(buff), "line"))
        {
        case 0:
            switch (lua_pcall(L, 0, LUA_MULTRET, 0))
            {
            case 0:
                print_all(L);
                break;
            case LUA_ERRRUN:
                fprintf(stderr, "Execution Error: %s\n", lua_tostring(L, -1));
                lua_pop(L, 1); /* pop error message from the stack */
                break;
            case LUA_ERRMEM:
                fprintf(stderr, "Memory Error: %s\n", lua_tostring(L, -1));
                lua_pop(L, 1); /* pop error message from the stack */
                break;
            case LUA_ERRERR:
                fprintf(stderr, "Error: %s\n", lua_tostring(L, -1));
                lua_pop(L, 1); /* pop error message from the stack */
                break;

            default:
                fprintf(stderr, "Unknown Error: (2) %d %s\n", error, lua_tostring(L, -1));
                lua_pop(L, 1); /* pop error message from the stack */
                break;
            }
            break;
        case LUA_ERRMEM:
            fprintf(stderr, "Memory Error: %s\n", lua_tostring(L, -1));
            lua_pop(L, 1); /* pop error message from the stack */
            break;
        case LUA_ERRSYNTAX:
            fprintf(stderr, "Syntax Error: %s\n", lua_tostring(L, -1));
            lua_pop(L, 1); /* pop error message from the stack */
            break;

        default:
            fprintf(stderr, "Unknown Error: (1) %d %s\n", error, lua_tostring(L, -1));
            lua_pop(L, 1); /* pop error message from the stack */
            break;
        }

        fputs("> ", stderr);
    }
}
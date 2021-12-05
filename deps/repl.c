#include "repl.h"

#include <lauxlib.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <readline/readline.h>
#include <readline/history.h>

const char *KW[] = {
    "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if",
    "in", "local", "nil", "not", "or",
    "repeat", "return", "then", "true", "until", "while"};
const int KW_LEN = 21;

char **command_completion(const char *stem_text, int start, int end);
char *intersection_name_generator(const char *stem_text, int state);
void print_all(lua_State *L);
void handle_line(lua_State *L, char *line);

void repl_loop(lua_State *L)
{
    rl_bind_key('\t', rl_complete);
    rl_attempted_completion_function = command_completion;
    rl_completer_quote_characters = strdup("\"\'");

    char *buf;
    while ((buf = readline("> ")) != NULL)
    {
        if (strcmp(buf, "") != 0)
        {
            add_history(buf);
        }

        handle_line(L, buf);

        free(buf);
        buf = NULL;
    }

    free(buf);
}

void handle_line(lua_State *L, char *line)
{
    int error;
    switch (error = luaL_loadbuffer(L, line, strlen(line), "line"))
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
}

void print_all(lua_State *L)
{
    int printed = 0;
    for (int nres = lua_gettop(L); nres > 0; nres--)
    {
        if (lua_type(L, 1) != LUA_TNIL)
        {
            const char *s = lua_tostring(L, 1);
            fprintf(stderr, "%s\t", s);
            printed |= 1;
        }

        lua_remove(L, 1);
    }
    if (printed)
        fputc('\n', stderr);
}

char **command_completion(const char *stem_text, int start, int end)
{
    char **matches = NULL;
    if (start != end)
    {
        matches = rl_completion_matches(stem_text, intersection_name_generator);
    }

    return matches;
}

char *intersection_name_generator(const char *stem_text, int state)
{
    static int count;
    if (state == 0)
    {
        count = -1;
    }

    int len = strlen(stem_text);
    while (count < KW_LEN - 1)
    {
        count++;
        if (strncmp(KW[count], stem_text, len) == 0)
        {
            return strdup(KW[count]);
        }
    }

    return NULL;
}
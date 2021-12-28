#include "lua_re.h"
#include "regex.h"
#include <luajit.h>

int compile(lua_State *L)
{
    const char *s = lua_tostring(L, -1);
    regex_t *regex = lua_newuserdata(L, sizeof(regex_t));
    regcomp(regex, s, 0);
    return 1;
}

int match(lua_State *L)
{
    const char *s = lua_tostring(L, -1);

    return 1;
}

int luaopen_regex(lua_State *L)
{

    return 1;
}

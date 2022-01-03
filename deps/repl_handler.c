#include "repl_handler.h"

#include <lauxlib.h>

#define DEF_LUA_FUNCTION(name)                                                 \
  const char *name(lua_State *L, const char *input) {                          \
    lua_getglobal(L, "repl");                                                  \
    lua_getfield(L, -1, #name);                                                \
    lua_pushstring(L, input);                                                  \
    lua_call(L, 1, 1);                                                         \
    return lua_tostring(L, -1);                                                \
  }

DEF_LUA_FUNCTION(before_print);
DEF_LUA_FUNCTION(execute);
DEF_LUA_FUNCTION(complete);

int lua_before_print(lua_State *L) {
  const char *s = luaL_checkstring(L, 1);

  lua_pushstring(L, s);

  return 1;
}
int lua_execute(lua_State *L) {
  const char *s;
  s = luaL_checkstring(L, 1);
  luaL_dostring(L, s);
  s = lua_tostring(L, -1);
  lua_pushstring(L, s);

  return 1;
}

int lua_complete(lua_State *L) {
  const char *s = luaL_checkstring(L, 1);

  lua_pushstring(L, s);

  return 1;
}

int handler_init(lua_State *L) {
  lua_newtable(L);

  lua_pushcfunction(L, lua_before_print);
  lua_setfield(L, -2, "before_print");
  lua_pushcfunction(L, lua_execute);
  lua_setfield(L, -2, "execute");
  lua_pushcfunction(L, lua_before_print);
  lua_setfield(L, -2, "before_print");

  lua_setglobal(L, "repl");
  return 0;
}

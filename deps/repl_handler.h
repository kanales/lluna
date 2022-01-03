#ifndef _REPL_HANDLER_H_
#define _REPL_HANDLER_H_

#include <luajit.h>
int handler_init(lua_State *L);
const char *before_print(lua_State *L, const char *input);
const char *execute(lua_State *L, const char *input);
const char *complete(lua_State *L, const char *input);

#endif // !_HANDLER_H_

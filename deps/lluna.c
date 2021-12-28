#include "repl.h"
#include <lauxlib.h>
#include <luajit.h>
#include <lualib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define EXIT_FAILURE 1

static const char *program_name;

void usage() {
  fprintf(stderr, "usage: %s [options] [FILE]\n", program_name);
  fputs("Avaliable options are:", stderr);
  fputs("  -v\tShow version information.", stderr);
  fputs("  -h\tShow this message.", stderr);
  fputs("\n", stderr);
}
void error(lua_State *L, const char *fmt, ...) {
  va_list argp;
  va_start(argp, fmt);
  vfprintf(stderr, fmt, argp);
  va_end(argp);
  lua_close(L);
}

int set_luapath(lua_State *L, const char *path) {
  char dst[4096];

  lua_getglobal(L, "package");
  lua_getfield(L, -1,
               "path"); // get field "path" from table at top of stack (-1)
  const char *p = lua_tostring(L, -1);

  strcpy(dst, path);
  strcat(dst, ";");
  strcat(dst, p);

  lua_pop(L, 1); // get rid of the string on the stack we just pushed on line 5
  lua_pushstring(L, dst); // push the new one
  lua_setfield(
      L, -2,
      "path"); // set the field "path" in table at -2 with value at top of stack
  lua_pop(L, 1); // get rid of package table from top of stack
  return 0;      // all done!
}

int set_luacpath(lua_State *L, const char *path) {
  char dst[4096];

  lua_getglobal(L, "package");
  lua_getfield(L, -1,
               "path"); // get field "path" from table at top of stack (-1)
  const char *p = lua_tostring(L, -1);

  strcpy(dst, path);
  strcat(dst, ";");
  strcat(dst, p);

  lua_pop(L, 1); // get rid of the string on the stack we just pushed on line 5
  lua_pushstring(L, dst);       // push the new one
  lua_setfield(L, -2, "cpath"); // set the field "path" in table at -2 with
                                // value at top of stack
  lua_pop(L, 1);                // get rid of package table from top of stack
  return 0;                     // all done!
}

#ifdef _WIN32
#define PATH_SEP "\\"
#else
#define PATH_SEP "/"
#endif

int lua_global_module(lua_State *L, const char *s) {
  lua_getglobal(L, "require");
  lua_pushstring(L, s);
  lua_call(L, 1, 1);
  lua_setglobal(L, s);
  return 1;
}

int lua_require(lua_State *L, const char *modname) {
  lua_getglobal(L, "require");
  lua_pushstring(L, modname);
  lua_call(L, 1, -2);
  return 1;
}

int init(lua_State *L) {
  // TODO: optimize
  const char *HOME = getenv("HOME");
  const char _LUA_PATH[] = "/.local/share/lluna/lua/?.lua;;";
  const char _LUA_CPATH[] = "/.local/share/lluna/c/?.so;;";

  char *buffer = (char *)malloc(strlen(HOME) + sizeof(_LUA_PATH) + 1);
  buffer[0] = 0;

  stpcpy(stpcpy(buffer, HOME), _LUA_CPATH);
  set_luacpath(L, buffer);

  buffer[0] = 0;

  stpcpy(stpcpy(buffer, HOME), _LUA_PATH);
  set_luapath(L, buffer);

  lua_getglobal(L, "require");
  lua_pushstring(L, "lluna");
  lua_call(L, 1, 1);
  lua_call(L, 0, 0);

  if (buffer != NULL)
    free(buffer);

  return 0;
}

int main(const int argc, char *const argv[]) {
  int err;
  lua_State *L = lua_open();
  luaL_openlibs(L);

  program_name = argv[0];

  int option;
  while ((option = getopt(argc, argv, "hv")) != -1) {
    switch (option) {
    case 'h':
      usage();
      exit(0);
      break;
    case 'v':
      // version
      printf("%s 0.1.0\n", program_name);
      exit(0);
      break;
    default:
      break;
    }
  }
  init(L);

  if (optind == argc) {
    repl_loop(L);
    exit(0);
  }

  err = luaL_dofile(L, argv[1]);
  if (err) {
    error(L, "%s", lua_tostring(L, -1));
  }

  lua_close(L);
  return err;
}

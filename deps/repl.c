#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>

#include <lauxlib.h>
#include <lualib.h>

#include "repl.lua.h"
#include "repl_definitions.h"
#include "repl_handler.h"
#include "repl_linebuffer.h"

void die(const char *msg) {
  perror(msg);
  exit(1);
}

#define DEBUG(...)                                                             \
  fputs(UP(1), stderr);                                                        \
  fputs(LEFT(999), stderr);                                                    \
  fprintf(stderr, __VA_ARGS__);                                                \
  fputs(DOWN(1), stderr);                                                      \
  fprintf(stderr, "\x1b[%dC", cursor);

///
struct termios og_termios;

void disable_raw() {
  if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &og_termios) == -1) {
    die("tcsetattr");
  }
}
void enable_raw() {
  if (tcgetattr(0, &og_termios) == -1)
    die("tcgetattr");
  atexit(disable_raw);

  struct termios raw = og_termios;
  raw.c_lflag &= ~(ECHO | ICANON | ISIG);
  raw.c_oflag &= ~(OPOST);
  if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) == -1)
    die("tcsetattr");
}

///

char read_key() {
  int nread;
  char c;
  while ((nread = read(0, &c, 1)) != 1) {
    if (nread == -1 && errno != EAGAIN)
      die("read");
  }
  return c;
}

void display(lua_State *L) {
  fputs(LEFT(999), stderr);
  fputs(CLEAR_ALL, stderr);
  fputs(prompt, stderr);
  const char *line_buffer = buffer_get();

  line_buffer = before_print(L, line_buffer);
  fprintf(stderr, "%s", line_buffer);
  fputs(LEFT(999), stderr);
  fprintf(stderr, "\x1b[%dC", cursor() + prompt_len);
}

void handle_newline(lua_State *L) {
  display(L);
  const char *line_buffer;
  fputs("\r\n", stderr);
  line_buffer = buffer_get();
  history_add(line_buffer);
  line_buffer = execute(L, line_buffer);
  if (strlen(line_buffer) > 0)
    fprintf(stderr, "%s\r\n", line_buffer);
  cursor_reset();
  buffer_clear();
}

void process_keypress(lua_State *L) {
  char c = read_key(), a, b;

  if (!iscntrl(c)) {
    buffer_write(c);
    display(L);
    return;
  }

  switch (c) {
  case 17:
  case CTRL_KEY('d'):
    exit(0);
    break;
  case 127:
  case CTRL_KEY('h'):
    buffer_delete();
    display(L);
    break;
  case 10:
  case 13:
    handle_newline(L);
    /* newline */
    break;
  case 27:
    /* escape sequence */
    a = read_key(), b = read_key();
    if (a == 91 && b == 68) {
      /* left */
      cursor_left();
    }
    if (a == 91 && b == 67) {
      /* right */
      cursor_right();
    }

    if (a == 91 && b == 66) {
      cursor_down();
    }

    if (a == 91 && b == 65) {
      cursor_up();
    }
  }
}

/**
 * TODO
 * define lua `repl` object with the following methods:
 * - before_print: string -> string
 * - execute: string -> string
 * - complete: string -> string
 * If the output of before_print is (visually) a different length
 * than its input it might show as broken
 */
int repl(lua_State *L) {
  handler_init(L);

  luaL_loadbuffer(L, luaJIT_BC_repl, luaJIT_BC_repl_SIZE, NULL);
  lua_call(L, 0, 0);

  enable_raw();
  buffer_init();
  display(L);
  while (1) {
    process_keypress(L);
    display(L);
    fflush(stderr);
  }

  return 0;
}

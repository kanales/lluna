#ifndef _REPL_LINEBUFFER_H_
#define _REPL_LINEBUFFER_H_
#include "repl_definitions.h"

static const char prompt[] = ">>> ";
static const int prompt_len = sizeof(prompt) - 1;

void buffer_init();
void cleanup();
int cursor();
void cursor_left();
void cursor_right();
void cursor_up();
void cursor_down();
void cursor_reset();

void history_add(const char *s);

void buffer_write(char c);
const char *buffer_get();
void buffer_delete();
void buffer_clear();

#endif

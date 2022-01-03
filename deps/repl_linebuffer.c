#include "repl_linebuffer.h"

#include "repl_definitions.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFSIZE 4096

#define HISTLEN 64
static char *history[HISTLEN];
static int last_hist = 0;
static int hist_ptr = 0;

static char line_buffer[BUFSIZE];
static int _cursor = 0;

void buffer_init() {
  memset(line_buffer, '\0', BUFSIZE);
  memset(history, 0, HISTLEN);
  fputs("Press Ctrl+D to exit\n", stderr);
}

void reset() {
  for (int i = 0; i < HISTLEN; i++) {
    if (history[i] != NULL)
      free(history[i]);
  }
}

int cursor() { return _cursor; }

void cursor_left() {
  if (_cursor > 0) {
    _cursor -= 1;
    fputs(LEFT(1), stderr);
  }
}
void cursor_right() {
  int max = strlen(line_buffer);
  if (_cursor < max) {
    _cursor += 1;
    fputs(RIGHT(1), stderr);
  }
}

void cursor_up() {
  const char *ptr = history[hist_ptr];
  if (ptr != NULL) {

    memccpy(line_buffer, ptr, '\0', BUFSIZE);
    hist_ptr = (hist_ptr - 1) % HISTLEN;
  }
}

void cursor_down() {
  const char *ptr = history[hist_ptr];
  if (ptr != NULL) {
    memccpy(line_buffer, ptr, '\0', BUFSIZE);
    hist_ptr = (hist_ptr + 1) % HISTLEN;
  }
}
void history_add(const char *s) {
  if (strlen(s) == 0)
    return;
  history[last_hist] = strdup(line_buffer);
  hist_ptr = last_hist;
  last_hist = (last_hist + 1) % HISTLEN;
}

void cursor_reset() { _cursor = 0; }

void buffer_write(char c) {
  char *ptr = &line_buffer[_cursor];
  char tmp;
  do {
    tmp = *ptr;
    *ptr = c;
    c = tmp;
  } while (*(++ptr) != '\0');
  *ptr = tmp;

  cursor_right();
}

const char *buffer_get() { return (const char *)line_buffer; }
void buffer_delete() {
  for (char *ptr = &line_buffer[_cursor - 1]; *ptr != '\0'; ptr++) {
    *ptr = *(ptr + 1);
  }
  cursor_left();
}

void buffer_clear() { memset(line_buffer, '\0', strlen(line_buffer)); }

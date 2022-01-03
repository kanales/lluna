#ifndef _REPL_DEFINITIONS_H_
#define _REPL_DEFINITIONS_H_

#define CTRL_KEY(k) ((k)&0x1f)
#define UP(n) "\x1b[" #n "A"
#define DOWN(n) "\x1b[" #n "B"
#define RIGHT(n) "\x1b[" #n "C"
#define LEFT(n) "\x1b[" #n "D"

#define CLEAR_ALL "\x1b[2K"

#endif // !_DEFINITIONS_H_

local KEY = {
    ENTER = 13,
    TAB = 9,
    BACKSPACE = 127,
    CTRL_A = 1,
    CTRL_B = 2,
    CTRL_C = 3,
    CTRL_H = 8,
    CTRL_D = 4,
    CTRL_T = 20,
    UP = '\027[A',
    DOWN = '\027[B',
    RIGHT = '\027[C',
    LEFT = '\027[D'
}

local ffi = require "ffi"

ffi.cdef [[


struct termios {
	tcflag_t c_iflag;
	tcflag_t c_oflag;
	tcflag_t c_cflag;
	tcflag_t c_lflag;
	cc_t c_cc[NCCS];
	speed_t c_ispeed;
	speed_t c_ospeed;
};

    int tcgetattr(int fd, struct termios *termios_p);
    int tcsetattr(int fd, int optional_actions,
              const struct termios *termios_p);
]]

local C = ffi.C

local raw = ffi.new("struct termios")

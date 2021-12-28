# 🌝 Lluna

[LuaJIT](https://luajit.org/) wrapper for a nicer scripting experience.

## What is Lluna

Lluna is a thin wrapper around LuaJIT providing convenience modules (through [lluna-std](https://github.com/kanales/lluna-std)) and a repl.

It is intended to improve user scripting experience in lua to be more comparable to Python, while keeping the startup time short and the performance high.

It is **not** intended to:
- replace Lua(JIT);
- provide a huge standard library, lluna is conceived for "one-off" to medium complexity scripts;
- be embedded (if you want to embed lluna you should consider embedding lua(JIT) and requiring the modules from [lluna-std](https://github.com/kanales/lluna-std));
- be production ready (for now).

## Installation

Only installation from source from now. Note that installation requires `libluajit` and `libcurl`.

```sh
git clone https://github.com/kanales/lluna/ && cd lluna
make
make install
```

## Improvements

- [ ] force installation of stdlib instead of relying on it being installed

## 🚧 Work In Progress 🚧

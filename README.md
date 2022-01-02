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

Only installation from source from now. It is recommended you use the provided `install.sh` that will handle the installation of the standard library for you. _Note: installation requires `libluajit` and `libcurl`._

```sh
. install.sh
```

## Improvements

- [ ] force installation of stdlib instead of relying on it being installed

## 🚧 Work In Progress 🚧

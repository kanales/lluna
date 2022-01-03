#!/bin/sh
set -eu

log() {
  echo "$@" 1>&2
}

BUILD="./build"
PREFIX="$HOME/.local"

log "🏗️  " "Creating destination folders"

mkdir -p "$PREFIX"
mkdir -p "$PREFIX/.local/share/lluna"

log "⬇️  " "Updating submodules..."
git submodule update --init --recursive
log "\x1b[7mOK\x1b[27m"

# log "🚚 " "Updating \x1b[1mlluna-std\x1b[22m\t\t" "\c"
# if [ ! -d "$BUILD/lluna-std" ]
# then
#   git  clone --quiet "$STD_URL" "$BUILD/lluna-std"
# else 
#   cd "$BUILD/lluna-std"
#   git pull --quiet "$STD_URL"
#   cd - 1>/dev/null 2>&1
# fi
# log "\x1b[7mOK\x1b[27m"

# cd "$BUILD/lluna-std"

# log "⚙️  " "Building standard libs\t" "\c"
# make 1>/dev/null 2>&1
# log "\x1b[7mOK\x1b[27m"

# log "📦️ " "Packaging standard libs\t" "\c"
# make install 1>/dev/null 2>&1
# log "\x1b[7mOK\x1b[27m"

cd - 1>/dev/null 2>&1

log "⚙️ " " Building \x1b[1mlluna\x1b[22m executable\t" "\c"
make 1>/dev/null 2>&1
log "\x1b[7mOK\x1b[27m"

log "📦️ " "Packaging executable\t" "\c"
make install 1>/dev/null 2>&1
log "\x1b[7mOK\x1b[27m"
log "🗑️  " "Cleaning up..."
rm -rf "$BUILD"

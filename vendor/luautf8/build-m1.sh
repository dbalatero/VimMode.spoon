#!/usr/bin/env bash

echo "Building for M1..."

rm -fr lutf8lib.o

env MACOSX_DEPLOYMENT_TARGET=11.0 \
  gcc -O2 -fPIC \
  -arch arm64 \
  -mmacosx-version-min=11 \
  -target arm64-apple-macos11 \
  -I$HOME/Downloads/lua-5.4.3/install/include \
  -c lutf8lib.c \
  -o lutf8lib.o

env MACOSX_DEPLOYMENT_TARGET=11.0 \
  gcc -bundle \
  -target arm64-apple-macos11 \
  -mmacosx-version-min=11 \
  -undefined dynamic_lookup \
  -all_load \
  -o lua-utf8.so \
  lutf8lib.o

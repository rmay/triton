#!/bin/sh
set -eu

if ! command -v emacs >/dev/null 2>&1; then
    pkg install -y emacs
fi

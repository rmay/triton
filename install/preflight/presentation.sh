#!/bin/sh

if ! pkg info -e py311-pipx; then
    pkg install -y py311-pipx
fi

if ! pipx list 2>/dev/null | grep -q '^  package terminaltexteffects'; then
    pipx install terminaltexteffects
fi


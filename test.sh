#!/bin/bash

docker build --build-arg=TMUX_VERSION=3.1b   -t tmux-kitty-colors-bug:3.1b .
docker build --build-arg=TMUX_VERSION=3.2-rc -t tmux-kitty-colors-bug:3.2-rc2 .

# This works fine and displays neat colors.
docker run -it --rm \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e "DISPLAY=unix${DISPLAY}" \
    tmux-kitty-colors-bug:3.1b

# This does not...
docker run -it --rm \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e "DISPLAY=unix${DISPLAY}" \
    tmux-kitty-colors-bug:3.2-rc2

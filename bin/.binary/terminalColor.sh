#!/bin/bash

sequences=$'\033]4;0;{color0.hex}\033\\\033]4;1;{color1.hex}\033\\\033]4;2;{color2.hex}\033\\\033]4;3;{color3.hex}\033\\\033]4;4;{color4.hex}\033\\\033]4;5;{color5.hex}\033\\\033]4;6;{color6.hex}\033\\\033]4;7;{color7.hex}\033\\\033]4;8;{color8.hex}\033\\\033]4;9;{color9.hex}\033\\\033]4;10;{color10.hex}\033\\\033]4;11;{color11.hex}\033\\\033]4;12;{color12.hex}\033\\\033]4;13;{color13.hex}\033\\\033]4;14;{color14.hex}\033\\\033]4;15;{color15.hex}\033\\
'
for term in /dev/pts/*; do
  if [ -w "$term" ]; then
    printf '%s' "$sequences" >"$term"
  fi
done

#!/bin/bash

wd="$(dirname "$0")"
export LD_LIBRARY_PATH=$wd/../rupypy/dependencies/z3/build
xterm -e $wd/../rupypy/bin/topaz-z3 $wd/bmp_streamer.rb $wd/video 2>/dev/null >/dev/null & 

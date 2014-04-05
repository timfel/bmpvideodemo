#!/bin/bash

wd="$(dirname "$0")"
export LD_LIBRARY_PATH=$wd/../babelsberg-r/dependencies/z3/build
$wd/../babelsberg-r/bin/topaz-z3 $wd/bmp_streamer.rb $wd/video 2>/dev/null >/dev/null

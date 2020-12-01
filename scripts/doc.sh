#!/bin/bash
#
# To be run from a Meson run target:
#
# $ meson compile doc

set -e

cd "${MESON_SOURCE_ROOT}"
mkdir -p doc
cp scripts/screen.css doc/
./sml-buildscripts/mlb-expand test-sml.mlb > .docfiles
smldoc --nowarn --windowtitle=Bisquay --header=Bisquay --charset=UTF-8 --stylesheet=screen.css -d doc -a .docfiles 

#!/bin/bash
#
# To be run from a Meson run target:
#
# $ meson compile -C build doc

set -e

cd "${MESON_SOURCE_ROOT}"
mkdir -p doc
cp resources/screen.css resources/bisquay.svg doc/
./sml-buildscripts/mlb-expand test-sml.mlb > .docfiles
smldoc --nowarn --overview=resources/doc-overview.html --windowtitle=Bisquay --header=Bisquay --charset=UTF-8 --stylesheet=screen.css -d doc -a .docfiles 

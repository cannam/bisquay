#!/bin/bash
#
# To be run from a Meson run target:
#
# $ meson compile -C build doc

set -e

cd "${MESON_SOURCE_ROOT}"
rm -rf doc
mkdir -p doc
if [ ! -x ext/smldoc/src/mlton/smldoc ]; then 
    ( cd ext/smldoc ; make -f Makefile.mlton )
fi
cp resources/screen.css resources/bisquay.svg doc/
./sml-buildscripts/mlb-expand test-sml.mlb | grep -v '/test[-.]' > .docfiles
ext/smldoc/src/mlton/smldoc --nowarn --markdown --overview=resources/doc-overview.html --windowtitle=Bisquay --header=Bisquay --charset=UTF-8 --stylesheet=screen.css -d doc -a .docfiles 

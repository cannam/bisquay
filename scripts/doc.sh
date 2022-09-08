#!/bin/bash
#
# To be run from a Meson run target:
#
# $ meson compile -C build doc

set -e

cd "${MESON_SOURCE_ROOT}"

set -u

if [ ! -f scripts/doc.sh ]; then
    echo "This script must be run from the Bisquay source root"
    exit 1
fi

rm -rf doc
mkdir -p doc
if [ ! -x ext/smldoc/src/mlton/smldoc ]; then 
    ( cd ext/smldoc ; make -f Makefile.mlton )
fi
cp resources/screen.css resources/bisquay.svg doc/
./sml-buildscripts/mlb-expand test-sml.mlb | grep -v '/test[-.]' > .docfiles
ext/smldoc/src/mlton/smldoc --nowarn --markdown --overview=resources/doc-overview.html --windowtitle=Bisquay --header=Bisquay --charset=UTF-8 --stylesheet=screen.css -d doc -a .docfiles 

./scripts/write-contents.sh > CONTENTS.md

#!/bin/bash

# Bisquay has top-level mlb files that list everything "included in
# the compendium". However, we want to make sure that the individual
# directories are compilable too, so we know that they document
# properly what their dependencies are. This script checks that, as
# well as it can, which is not perfectly.

set -eu
set -o pipefail

tmpfile=$(mktemp /tmp/bisquay-log-XXXXXXXX.txt)
trap "rm -f $tmpfile" 0

fail() {
    text="$1"
    if [ -s "$tmpfile" ]; then
        cat "$tmpfile"
    fi
    echo
    echo "!!! Error: $text"
    exit 1
}

sml="mlton"
sml_args="-disable-pass deepFlatten"

for dir in sml-* bsq-* ; do
    if [ "$dir" = "sml-buildscripts" ]; then
        continue
    fi
    echo
    echo "+++ Checking directory $dir..."
    ( cd "$dir"
      name=${dir##*-}
      if [ -f Makefile ]; then
          if grep -q '^test:' Makefile ; then
              ( make clean test ) > "$tmpfile" 2>&1 ||
                  fail "Build-and-test failed using Makefile"
          else 
              ( make clean && make ) > "$tmpfile" 2>&1 ||
                  fail "Build failed using Makefile"
          fi
      elif [ -f test.mlb ]; then
          ( "$sml" $sml_args test.mlb && ./test ) > "$tmpfile" 2>&1 ||
              fail "Build-and-test failed using test.mlb"
      elif [ -f "$dir".mlb ]; then
          ( "$sml" $sml_args "$dir".mlb ) > "$tmpfile" 2>&1 ||
              fail "Build failed using $dir.mlb"
      elif [ -f "$name".mlb ]; then
          ( "$sml" $sml_args "$name".mlb ) > "$tmpfile" 2>&1 ||
              fail "Build failed using $name.mlb"
      elif [ -f "$dir"-sml.mlb ]; then # sometimes in opposition to $dir-ffi.mlb
          ( "$sml" $sml_args "$dir"-sml.mlb ) > "$tmpfile" 2>&1 ||
              fail "Build failed using $dir-sml.mlb"
      elif [ -f "$name"-sml.mlb ]; then
          ( "$sml" $sml_args "$name"-sml.mlb ) > "$tmpfile" 2>&1 ||
              fail "Build failed using $name-sml.mlb"
      else
          echo > "$tmpfile"
          fail "No way to build in directory $dir"
      fi
    )
    echo "--- OK"
done

echo
echo "--- All passed"


#!/bin/bash

set -eu
if [ ! -f scripts/run-perftests.sh ] ; then
    echo "This must be run from the project root directory"
    exit 1
fi
infile=bsq-perftest/audio/50ft.wav
if [ ! -f "$infile" ]; then
   echo "Unable to find input audio file $infile"
   exit 1
fi

buildtypes="polyml mlton_release"

for b in $buildtypes; do
    if [ -d "tmp_perfbuild_$b" ]; then
        meson "tmp_perfbuild_$b" -D"sml_buildtype=$b" --reconfigure
    else 
        meson "tmp_perfbuild_$b" -D"sml_buildtype=$b"
    fi
    ninja -C "tmp_perfbuild_$b"
done

tests=$(tmp_perfbuild_polyml/bsq_perftest |
            grep 'one of' |
            sed 's/^.*one of: //' |
            sed 's/,//g')
echo "Tests are: $tests"

echo
hg id
hg log -r$(hg id | sed 's/+//' | awk '{ print $1; }') |
    grep '^date:' |
    sed 's/^date: */Commit date: /'

echo
echo -ne "\t\t\t"
for b in $buildtypes; do
    echo -ne "$b\t\t"
done
echo

for test in $tests; do
    echo -ne "   $test\t\t"
    for b in $buildtypes; do
        args=""
        case "$b" in
            polyml) args="--minheap 500M";;
            *) ;;
        esac
        elapsed=$(/usr/bin/time "tmp_perfbuild_$b/bsq_perftest" \
                                $args "$test" "$infile" 2>&1 |
                      fmt -1 |
                      grep elapsed |
                      sed 's/elapsed//')
        echo -ne "$elapsed\t\t"
    done
    echo
done

echo

for b in $buildtypes; do
    rm -rf "tmp_perfbuild_$b"
done



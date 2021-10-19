#!/bin/bash

set -eu
set -o pipefail

if [ ! -f scripts/run-perftests.sh ] ; then
    echo "This must be run from the project root directory"
    exit 1
fi
infile=bsq-perftest/audio/50ft.wav
if [ ! -f "$infile" ]; then
   echo "Unable to find input audio file $infile"
   exit 1
fi

# Not mlton_profile for general repeated testing - it just takes too
# long to build (even longer than mlton_release)
buildtypes="polyml mlton_noffi mlton_release"

for b in $buildtypes; do
    if [ -f "tmp_perfbuild_$b/build.ninja" ]; then
        meson "tmp_perfbuild_$b" -D"sml_buildtype=$b" --reconfigure
    else 
        meson "tmp_perfbuild_$b" -D"sml_buildtype=$b"
    fi
    time ninja -C "tmp_perfbuild_$b" bsq_perftest
    echo
    echo "Built $b"
    echo
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

for counter in 1 2; do

echo
echo -ne "\t\t\t"
for b in $buildtypes; do
    case "$b" in
        polyml) echo -ne "$b\t\t" ;; # shorter text, two tabs
        *) echo -ne "$b\t" ;; # longer text, one tab
    esac
done
echo -e "mem/polyml\tmem/release"

for test in $tests; do
    mem_polyml=
    mem_release=
    echo -ne "   $test\t\t"
    for b in $buildtypes; do
        args=""
        case "$b" in
            polyml) args="--minheap 500M";;
            *) ;;
        esac
        mem="(n/a)"
	if [ -d /Applications ]; then
            elapsed=$(/usr/bin/time "tmp_perfbuild_$b/bsq_perftest" \
                                    $args "$test" "$infile" 2>&1 >/dev/null |
			  grep 'real' |
			  awk '{ print $1; }')
	else 
            measurements=$(/usr/bin/time -f '\n%E %M' \
                                         "tmp_perfbuild_$b/bsq_perftest" \
                                         $args "$test" "$infile" 2>&1 |
			       tail -1)
            elapsed=$(echo "$measurements" | awk '{ print $1; }')
            mem=$(echo "$measurements" | awk '{ print $2; }')
            mem=$(($mem / 1024))
            mem="$mem"M
	fi
        case "$b" in
            polyml) mem_polyml="$mem";;
            mlton_release) mem_release="$mem";;
            *) ;;
        esac
        echo -ne "$elapsed\t\t"
    done
    echo -e "$mem_polyml\t\t$mem_release"
done

done

echo

for b in $buildtypes; do
    rm -rf "tmp_perfbuild_$b"
done



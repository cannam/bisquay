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

configs="default default-fixedheap default-maxheap copygen10-fixedheap copygen10-maxheap"

for c in $configs; do
    dir="tmp_perfbuild_${c}"
    sml_buildtype="mlton_release"
    extra_args="[]"
    case "$c" in
        copygen10-*)
            extra_args="['-runtime','copy-generational-ratio 10.0']";;
        *)
        ;;
    esac
    if [ -f "$dir/build.ninja" ]; then
        meson "$dir" -D"sml_buildtype=mlton_release" -Dmlton_extra_args="$extra_args" --reconfigure --wipe
    else 
        meson "$dir" -D"sml_buildtype=mlton_release" -Dmlton_extra_args="$extra_args"
    fi
    echo "Configured for $c"
done

for c in $configs; do
    dir="tmp_perfbuild_${c}"
    time ninja -C "$dir" bsq_perftest
    echo
    echo "Built for $c"
    echo
done

tests=$(tmp_perfbuild_default/bsq_perftest |
            grep 'waveform' |
            sed 's/^ *//' |
            sed 's/,//g')
echo "Tests are: $tests"

echo
hg id
hg log -r$(hg id | sed 's/+//' | awk '{ print $1; }') |
    grep '^date:' |
    sed 's/^date: */Commit date: /'

for counter in 1; do

echo
echo -ne "\t\t\t"
for b in $buildtypes; do
    echo -ne "$b\t" ;; # longer text, one tab
done

for test in $tests; do
    echo -ne "   $test\t\t"
    for c in $configs; do
        extra_args=""
        case "$c" in
            *-fixedheap)
                extra_args="@MLton fixed-heap 600m --" ;;
            *-maxheap)
                extra_args="@MLton max-heap 600m --" ;;
            *) ;;
        esac
	dir="tmp_perfbuild_${c}"
	if [ -d /Applications ]; then
	    elapsed=$(/usr/bin/time "$dir/bsq_perftest" \
				    $extra_args "$test" "$infile" 2>&1 >/dev/null |
			  grep 'real' |
			  awk '{ print $1; }')
	else 
	    measurements=$(/usr/bin/time -f '\n%E %M' \
                                         "$dir/bsq_perftest" \
                                         $extra_args "$test" "$infile" 2>&1 |
			       tail -1)
	    elapsed=$(echo "$measurements" | awk '{ print $1; }')
	fi
        echo -ne "$elapsed\t\t"
    done
done
done

echo

for c in $configs; do
    rm -rf "tmp_perfbuild_${c}_*"
done



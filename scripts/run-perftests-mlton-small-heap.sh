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

configs="default-default default-max gen10-default gen10-max"

for c in $configs; do
    dir="tmp_perfbuild_${c}"
    sml_buildtype="mlton_release"
    extra_args="[]"
    case "$c" in
        gen10-*)
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

tests=$(tmp_perfbuild_default-default/bsq_perftest |
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
for c in $configs; do
    echo -ne "$c\t"
done
echo

for test in $tests; do
    echo -ne "   $test\t\t"
    for c in $configs; do

        small_heap=100m
        case "$test" in
            reassigning) small_heap=1000m ;;
            *-max*) small_heap=200m ;;
        esac
        
        extra_args=""
        case "$c" in
            *-fixed)
                extra_args="@MLton fixed-heap $small_heap --" ;;
            *-max)
                extra_args="@MLton max-heap $small_heap --" ;;
            *) ;;
        esac
	dir="tmp_perfbuild_${c}"
        mem="?"
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
	    mem=$(echo "$measurements" | awk '{ print $2; }')
	    mem=$(($mem / 1024))
	    mem="$mem"M
	fi
        echo -ne "$elapsed/$mem\t"
    done
    echo
done
done

echo

for c in $configs; do
    rm -rf "tmp_perfbuild_${c}_*"
done



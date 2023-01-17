#!/bin/bash

set -eu
set -o pipefail

if [ ! -f scripts/run-perftests.sh ] ; then
    echo "This must be run from the project root directory"
    exit 1
fi
infile=bsq-perftest/audio/50ft.wav
#infile="/data/Datasets/alignment/Going Home/wav/04-My Little Airport-Going Home.wav"
if [ ! -f "$infile" ]; then
   echo "Unable to find input audio file $infile"
   exit 1
fi

configs="default-default default-max gen10-default gen10-max gen10-lr4-max gen12-lr6-max gen20-max nogen-max"

#configs="compact-max"

for c in $configs; do
    dir="tmp_perfbuild_${c}"
    sml_buildtype="mlton_release"
    extra_args="[]"
    case "$c" in
        compact-*)
            extra_args="['-runtime','ram-slop 0.0625','-runtime','mark-compact-ratio 1.2','-runtime','copy-generational-ratio 8.0','-runtime','copy-ratio 4.0','-runtime','live-ratio 4.0','-runtime','may-page-heap false']";;
        gen10-lr4-*)
            extra_args="['-runtime','copy-generational-ratio 10.0','-runtime','copy-ratio 4.0','-runtime','live-ratio 4.0']";;
        gen12-lr6-*)
            extra_args="['-runtime','copy-generational-ratio 12.0','-runtime','copy-ratio 4.0','-runtime','live-ratio 6.0']";;
        gen10-*)
            extra_args="['-runtime','copy-generational-ratio 10.0']";;
        gen20-*)
            extra_args="['-runtime','copy-generational-ratio 20.0']";;
        nogen-*)
            extra_args="['-mark-cards','false']";;
        *)
        ;;
    esac
    if [ -f "$dir/build.ninja" ]; then
        meson "$dir" -D"sml_buildtype=mlton_release" -Dmlton_extra_args="$extra_args" --reconfigure
        #--wipe
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
echo "Values reported are: <total> <max-pause> <max-heap>"
echo "where:"
echo "   <total>     - total execution time in milliseconds"
echo "   <max-pause> - maximum GC pause time in milliseconds"
echo "   <max-heap>  - maximum size of heap in megabytes"
echo

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
        measurements=$("$dir/bsq_perftest" @MLton gc-summary -- $extra_args "$test" "$infile" 2>&1 >/tmp/tmp.out.txt | grep ': ')
        elapsed=$(echo "$measurements" | grep '^total time: ' | sed 's/^.*: //' | sed 's/[ ,]//g' | sed 's/ms//')
        mem=$(echo "$measurements" | grep '^max heap size: ' | sed 's/^.*: //' | sed 's/ bytes//' | sed 's/,//g')
	mem=$(($mem / 1048576))
	mem="$mem"m
        max_pause=$(echo "$measurements" | grep '^max pause time: ' | sed 's/^.*: //' | sed 's/[ ,]//g' | sed 's/ms//')
        echo -ne "$elapsed $max_pause $mem\t"
    done
    echo
done
done

echo

for c in $configs; do
    rm -rf "tmp_perfbuild_${c}_*"
done



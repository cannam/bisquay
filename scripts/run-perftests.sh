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

arches="native"
if [ -d /Applications ]; then
    arches="arm64 amd64"
fi

ippdir=/opt/intel/ipp
if [ -d "$ippdir" ]; then
    buildtypes="$buildtypes mlton_ipp"
fi

for b in $buildtypes; do
    arches_here="$arches"
    if [ "$b" = "polyml" ]; then
	arches_here="native"
    fi
    for a in $arches_here; do
	dir="tmp_perfbuild_${b}_$a"
	sml_buildtype="$b"
	extra_args=""
	if [ "$a" = "native" ]; then
	    if [ "$b" = "mlton_ipp" ]; then
		sml_buildtype="mlton_release"
		extra_args="-Dipp_path=$ippdir"
	    fi
	else
	    extra_args="--cross-file cross/cross_$a.txt"
	fi
	if [ -f "$dir/build.ninja" ]; then
            meson "$dir" -D"sml_buildtype=$sml_buildtype" $extra_args --reconfigure --wipe
	else 
            meson "$dir" -D"sml_buildtype=$sml_buildtype" $extra_args
	fi
	echo "Configured $b for $a arch"
    done
done

for b in $buildtypes; do
    arches_here="$arches"
    if [ "$b" = "polyml" ]; then
	arches_here="native"
    fi
    for a in $arches_here; do
	dir="tmp_perfbuild_${b}_$a"
	time ninja -C "$dir" bsq_perftest
	echo
	echo "Built $b for $a arch"
	echo
    done
done

tests=$(tmp_perfbuild_polyml_native/bsq_perftest |
            grep 'waveform' |
            sed 's/^ *//' |
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

for a in $arches; do
    if [ "$a" != "native" ]; then
	echo "   [$a]"
    fi
    for test in $tests; do
	mem_polyml=
	mem_release=
	echo -ne "   $test\t\t"
	for b in $buildtypes; do
	    if [ "$b" = "polyml" ]; then
		dir="tmp_perfbuild_${b}_native"
	    else
		dir="tmp_perfbuild_${b}_$a"
	    fi
            args=""
            case "$b" in
		polyml) args="--minheap 200M";;
		*) ;;
            esac
            mem="(n/a)"
	    if [ -d /Applications ]; then
		elapsed=$(/usr/bin/time "$dir/bsq_perftest" \
					$args "$test" "$infile" 2>&1 >/dev/null |
			      grep 'real' |
			      awk '{ print $1; }')
	    else 
		measurements=$(/usr/bin/time -f '\n%E %M' \
                                             "$dir/bsq_perftest" \
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
done

echo

for b in $buildtypes; do
    rm -rf "tmp_perfbuild_${b}_*"
done



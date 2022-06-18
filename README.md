
# Bisquay

A quixotic compendium of code for audio-processing applications
written in the [Standard ML](https://smlfamily.github.io/) programming
language.

 * Bisquay is *quixotic* because SML is not an obvious choice of
language for this purpose and there is no existing library of
applicable code to build on. As much as anything, it is an effort to
escape the rat race.

 * Bisquay is a *compendium* because this repository contains (almost)
no code, just a [Repoint](https://github.com/cannam/repoint) manifest
that defines a multitude of modules to pull in as
subdirectories. Several of these modules are third-party, or were
originally written for other purposes, while others (with names
beginning `bsq`) were written specifically for this.

All Bisquay code is licensed under a BSD/MIT or equivalent licence.

## To build

Requires the Meson build system and either MLton or Poly/ML SML
compiler (or both).

The default build uses Poly/ML, producing a development build with the
quickest compile time and turnaround, using pure SML code only:

1. Run `./repoint install` to bring in all the code
2. Run `meson build` and `ninja -C build`

The output will be a file called `bsq_test` in the `build` directory
that just runs some unit tests.

For a release-level build with C code via FFI for the fast bits, use
the `mlton_release` build option:

1. Run `./repoint install` to bring in all the code
2. Run `meson build -Dsml_buildtype=mlton_release` and `ninja -C build`

The `sml_buildtype` Meson option accepts the following values:

 * `polyml` - the default - pure SML with no additional C/C++ FFI
    support, compiled using Poly/ML
 * `mlton_noffi` - pure SML compiled using MLton
 * `mlton_debug` - SML + C/C++ FFI compiled using MLton with extra
    debug logging output
 * `mlton_profile` - SML + C/C++ FFI compiled using MLton with
    profiling support
 * `mlton_release` - SML + C/C++ FFI compiled using MLton in
    release mode

To build the documentation, run `meson compile -C build doc` after the
build directory has been configured; then open doc/index.html in a
browser.

## Author and copyright

The Bisquay code and the `bsq` modules were written by Chris Cannam
and are Copyright 2020-2022 Particular Programs Ltd, published under
the MIT/X11 licence. See the file `COPYING` for details.

See the individual directories for copyright notes on the other
modules.

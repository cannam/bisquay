
# Bisquay

## To build

Requires the Meson build system and either MLton or Poly/ML SML
compiler (or both).

The default build uses Poly/ML, for a development build with the
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

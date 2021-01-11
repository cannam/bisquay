
# Bisquay

## To build

Requires the Meson build system and either MLton or Poly/ML SML
compiler (or both).

1. Run Repoint to bring in all the code
2. Copy `meson_options.txt.in` to `meson_options.txt` and edit to
select the proper SML compiler and build type
3. Run `meson build` and `ninja -C build`

The output will be a file called `bsq_test` in the `build` directory
that just runs some unit tests.

For a development build with the quickest compile time and turnaround,
using SML code only, set `sml_buildtype` to `polyml` in
`meson_options.txt`.

For a release build, with C code via FFI for the fast bits, set
`sml_buildtype` to `mlton_release` in `meson_options.txt` and provide
the `--buildtype release` option when running `meson`.

Remember you need to delete the whole `build` directory and re-run
`meson` if you change `meson_options.txt`.


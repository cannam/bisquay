# Bisquay Contents

The following libraries are included in
[Bisquay](https://hg.sr.ht/~cannam/bisquay).

The `repoint-project.json` file in the Bisquay repository tells the
included Repoint utility how to find these; run `./repoint install` to
pull in the necessary code before you build or use Bisquay.

 * [sml-buildscripts](https://hg.sr.ht/~cannam/sml-buildscripts)
   SML build scripts
 * [ext/mlton-cutdown](https://hg.sr.ht/~cannam/mlton-cutdown)
   Build and run scripts for cut-down MLton runtimes
 * [sml-csv](https://hg.sr.ht/~cannam/sml-csv)
   Reader for comma-separated (CSV) files and related formats in Standard
 * [sml-stringinterpolate](https://hg.sr.ht/~cannam/sml-stringinterpolate)
   Value interpolation into string templates
 * [sml-smlnj-base64](https://hg.sr.ht/~cannam/sml-smlnj-base64)
   Base-64 encoder and decoder extracted from the SML/NJ library
 * [sml-smlnj-containers](https://hg.sr.ht/~cannam/sml-smlnj-containers)
   Container data structures extracted from the SML/NJ library
 * [sml-log](https://hg.sr.ht/~cannam/sml-log)
   A simple logging module 
 * [sml-timing](https://hg.sr.ht/~cannam/sml-timing)
   Standard ML functions to time other functions and report how long they take
 * [sml-i18n](https://hg.sr.ht/~cannam/sml-i18n)
   A sketch of a system for loading and interpolating translation strings
 * [sml-trie](https://hg.sr.ht/~cannam/sml-trie)
   Trie and persistent trie-based containers 
 * [sml-utf8](https://hg.sr.ht/~cannam/sml-utf8)
   UTF-8 encoder and decoder
 * [sml-ttl](https://hg.sr.ht/~cannam/sml-ttl)
   Simple RDF store and RDF/Turtle parser/serialiser 
 * [sml-svg](https://hg.sr.ht/~cannam/sml-svg)
   A writer for SVG files 
 * [sml-simplejson](https://hg.sr.ht/~cannam/sml-simplejson)
   Simple Standard ML JSON parser
 * [sml-subxml](https://hg.sr.ht/~cannam/sml-subxml)
   SubXml - A parser for a subset of XML
 * [sml-wavefile](https://hg.sr.ht/~cannam/sml-wavefile)
   Reader and writer for RIFF/WAV audio files 
 * [sml-fft](https://hg.sr.ht/~cannam/sml-fft)
   A Fast Fourier Transform implementation 
 * [bsq-signalbits](https://hg.sr.ht/~cannam/bsq-signalbits)
   Basic tools for use in signal processing 
 * [bsq-json](https://hg.sr.ht/~cannam/bsq-json)
   Extends our Simple JSON library to use a map for object fields
 * [bsq-test](https://hg.sr.ht/~cannam/bsq-test)
   Supporting code for unit tests 
 * [bsq-resampler](https://hg.sr.ht/~cannam/bsq-resampler)
   A high-quality (but slow) audio resampler 
 * [bsq-complex](https://hg.sr.ht/~cannam/bsq-complex)
   Complex numbers
 * [bsq-matrix](https://hg.sr.ht/~cannam/bsq-matrix)
   Matrix and (sort of) tensor implementation 
 * [bsq-bq](https://hg.sr.ht/~cannam/bsq-bq)
   Modules that wrap the bq libraries for audio programming (in C++) into Standard ML
 * [bsq-samplestreams](https://hg.sr.ht/~cannam/bsq-samplestreams)
   Sample streams and block streams 
 * [bsq-randomaccess](https://hg.sr.ht/~cannam/bsq-randomaccess)
   A means of obtaining a subset of data from a time series in matrix form
 * [bsq-component](https://hg.sr.ht/~cannam/bsq-component)
   Component blockstreams
 * [bsq-cqt](https://hg.sr.ht/~cannam/bsq-cqt)
   Complex-Q transform after Schörkhuber and Klapuri 2010
 * [bsq-waveform](https://hg.sr.ht/~cannam/bsq-waveform)
   Audio waveform renderer to SVG
 * [bsq-hmm](https://hg.sr.ht/~cannam/bsq-hmm)
   Hidden Markov models and related state models
 * [bsq-pitchtrack](https://hg.sr.ht/~cannam/bsq-pitchtrack)
   Audio pitch-tracking variants using cepstral features and HMMs
 * [bsq-dtw](https://hg.sr.ht/~cannam/bsq-dtw)
   Currently very simplistic dynamic time-warping implementation
 * [bsq-image](https://hg.sr.ht/~cannam/bsq-image)
   An incredibly simple image-data reader and writer
 * [bsq-windowsshim](https://hg.sr.ht/~cannam/bsq-windowsshim)
   Tiny module used for Windows compiler compatibility
 * [bsq-perftest](https://hg.sr.ht/~cannam/bsq-perftest)
   Performance tests for Bisquay
 * [bsq-plot](https://hg.sr.ht/~cannam/bsq-plot)
   Rudimentary plotting library for displaying a limited set of data structures
 * [bsq-rrloop](https://hg.sr.ht/~cannam/bsq-rrloop)
   Request-response loop for certain simple types of service application

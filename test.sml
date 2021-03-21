
val all_tests =
    [("string-interpolate", string_interpolate_tests)] @
    trie_tests @
    [("csv", csv_tests)] @
    [("i18n", i18n_tests)] @
    bq_non_audioio_tests @
    signalbits_tests @
    matrix_tests @
    resampler_tests @
    samplestreams_tests @
    cqt_tests

fun main () =
    (Log.resetElapsedTime ();
     if (foldl (fn (t, acc) => if TestRunner.run t
                               then acc
                               else false)
               true
               all_tests)
     then OS.Process.exit OS.Process.success
     else OS.Process.exit OS.Process.failure)



fun prefixed prefix tests =
    map (fn (name, test) => (prefix ^ "-" ^ name, test)) tests

fun all_tests () =
    [("string-interpolate", string_interpolate_tests)] @
    prefixed "trie" trie_tests @
    [("csv", csv_tests)] @
    [("i18n", i18n_tests)] @
    prefixed "ttl" (ttl_tests ()) @
    prefixed "resampler" resampler_tests @
    bq_non_audioio_tests @
    prefixed "signalbits" signalbits_tests @
    prefixed "complex" complex_tests @
    prefixed "matrix" matrix_tests @
    prefixed "samplestreams" samplestreams_tests @
    prefixed "randomaccess" randomaccess_tests @
    prefixed "component" component_tests @
    prefixed "cqt" cqt_tests

fun main () =
    (Log.resetElapsedTime ();
     if (foldl (fn (t, acc) => if TestRunner.run t
                               then acc
                               else false)
               true
               (all_tests ()))
     then OS.Process.exit OS.Process.success
     else OS.Process.exit OS.Process.failure)


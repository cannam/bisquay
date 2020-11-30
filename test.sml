
val all_tests =
    bq_non_audioio_tests @
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


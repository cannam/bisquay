
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
    prefixed "cqt" cqt_tests @
    prefixed "dtw" dtw_tests @
    prefixed "hmm" hmm_tests

fun usage () =
    (print ("Usage: " ^ CommandLine.name () ^ " [prefix]\n");
     print ("If prefix is provided, run testsuites whose names start with that prefix.\n");
     print ("The default is to run all tests.\n");
     OS.Process.exit OS.Process.failure)    
             
fun main () =
    let val tests = all_tests ()
        val () = Log.resetElapsedTime ()
    in
        case CommandLine.arguments () of
            [prefix] =>
            (case foldl (fn ((name, tests), (found, succeeded)) =>
                            if String.isPrefix prefix name
                            then (true, TestRunner.run (name, tests) andalso
                                        succeeded)
                            else (found, succeeded))
                        (false, true)
                        tests of
                 (false, _) => (print ("No testsuites match prefix \"" ^
                                       prefix ^ "\"\n");
                                usage ())
               | (_, false) => OS.Process.exit OS.Process.failure
               | _ => OS.Process.exit OS.Process.success)
          | [] =>
            if (foldl (fn (t, acc) => if TestRunner.run t
                                      then acc
                                      else false)
                      true
                      tests)
            then OS.Process.exit OS.Process.success
            else (print "Some tests failed\n";
                  OS.Process.exit OS.Process.failure)
          | _ => usage ()
    end
    handle ex =>
           (TextIO.output (TextIO.stdErr,
                           "Exception caught at top level: " ^ exnMessage ex ^
                           "\n");
            OS.Process.exit OS.Process.failure)
                                          


let () =
  Rope.run_unit_tests ();
  Scrollmap.run_unit_tests ();
  Test.report_results ()

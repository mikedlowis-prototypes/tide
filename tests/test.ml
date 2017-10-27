let passed = ref 0
let failed = ref 0

let test name testfn =
  try
    (testfn ());
    passed := !passed + 1
  with e ->
    Printf.printf "FAIL: %s\n    %s\n" name (Printexc.to_string e);
    failed := !failed + 1

let report_results () =
  Printf.printf "%d tests, %d passed, %d failed\n"
    (!passed + !failed) !passed !failed;
  if (!failed > 0) then (exit 1) else (exit 0)

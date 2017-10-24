type t = {
  index : int;
  map : int array
}

let make buf =
  let bol = (Rope.to_bol (Buf.rope buf) (Buf.start buf)) in
  { index = 0; map = [||] }

(* Unit Tests** ***************************************************************)

let run_unit_tests () = ()

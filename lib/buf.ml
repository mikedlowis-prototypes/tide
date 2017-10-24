type cursor = { start : int; stop : int }

type t = {
  start : int;
  path : string;
  rope : Rope.t
}

let font = X11.font_load "Verdana:size=11:antialias=true:autohint=true"

let empty =
  { start = 0; path = ""; rope = Rope.empty }

let load path =
  { start = 0; path = path; rope = Rope.from_string (Misc.load_file path) }

let rope buf =
  buf.rope

let iter_from fn buf i =
  Rope.iter_from fn buf.rope i



(*

let make_cursor buf start stop =
  { start = (Rope.limit_index buf.rope start);
    stop = (Rope.limit_index buf.rope stop) }

let move_rune count csr buf ext =
  let newstop = csr.stop + count in
  let newstart = if ext then csr.start else newstop in
  make_cursor buf newstart newstop

let move_word count csr buf ext =
  ()

let move_line count csr buf ext =
  ()

*)
(* Unit Tests *****************************************************************)

let run_unit_tests () =
  let open Test in
  ()


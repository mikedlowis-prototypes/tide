type t = {
  index : int;
  map : int array
}

let make buf width height off =
  let bol = (Rope.to_bol (Buf.rope buf) off) in
  let lines = ref [bol] in
  let csr = Draw.Cursor.make (width, 0) 0 0 in
  let process_glyph i c =
    let open Draw.Cursor in
    next_glyph csr c false;
    (*if csr.startx == csr.x then
      lines := i :: !lines;*)
    ((Rope.is_eol (Buf.rope buf) i) == false)
  in
  Buf.iteri_from process_glyph buf off;
  List.iter (fun n -> Printf.printf "%d " n) !lines;
  print_endline "";
  { index = 0; map = [||] }

(* Unit Tests *****************************************************************)

let run_unit_tests () = ()

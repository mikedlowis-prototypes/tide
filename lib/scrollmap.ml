type t = {
  width : int;
  index : int;
  lines : int array
}

let rec find_line lines off idx =
  if idx > 0 && lines.(idx) > off then
    find_line lines off (idx - 1)
  else
    idx

let make buf width off =
  let csr = Draw.Cursor.make (width, 0) 0 0 in
  let bol = (Rope.to_bol (Buf.rope buf) off) in
  let lines = ref [bol] in
  let csr = Draw.Cursor.make (width, 0) 0 0 in
  let process_glyph i c =
    if (Draw.Cursor.next_glyph csr c) then
      lines := i :: !lines;
      ((Rope.is_eol (Buf.rope buf) i) == false)
  in
  Buf.iteri_from process_glyph buf off;
  let lines = (Array.of_list (List.rev !lines)) in
  let index = (find_line lines off ((Array.length lines) - 1)) in
  { width = width; lines = lines; index = index }

let first map =
  (*
  Printf.printf "%d: %d" map.index map.lines.(map.index);
  print_endline "";
  *)
  map.lines.(map.index)

let bopl buf off =
  let next = ((Rope.to_bol (Buf.rope buf) off) - 2) in
  Rope.limit_index (Buf.rope buf) next

let bonl buf off =
  let next = ((Rope.to_eol (Buf.rope buf) off) + 2) in
  Rope.limit_index (Buf.rope buf) next

let scroll_up map buf =
  let next = map.index - 1 in
  if (next >= 0) then
    { map with index = next }
  else
    make buf map.width (bopl buf map.lines.(0))

let scroll_dn map buf =
  let next = map.index + 1 in
  if (next < (Array.length map.lines)) then
    { map with index = next }
  else
    make buf map.width (bonl buf map.lines.((Array.length map.lines) - 1))

let resize map buf width =
  if map.width == width then map
  else (make buf width (first map))

(* Unit Tests *****************************************************************)

let run_unit_tests () = ()

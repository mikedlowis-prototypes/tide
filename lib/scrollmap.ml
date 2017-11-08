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
  let bcsr = Buf.Cursor.make buf off in
  let dcsr = Draw.Cursor.make (width, 0) 0 0 in
  let lines = ref [Buf.Cursor.to_bol buf bcsr] in
  let process_glyph i c =
    let not_eol = ((Buf.is_eol buf i) == false) in
    if (Draw.Cursor.next_glyph dcsr c) && not_eol then
      lines := i :: !lines;
    not_eol
  in
  Buf.iteri process_glyph buf off;
  let lines = (Array.of_list (List.rev !lines)) in
  print_string "map: ";
  Array.iter (fun x -> Printf.printf "%d " x) lines;
  print_endline "";
  let index = (find_line lines off ((Array.length lines) - 1)) in
  { width = width; lines = lines; index = index }

let first map =
  Printf.printf "first: %d\n" map.lines.(map.index);
  map.lines.(map.index)

let bopl buf off =
  Buf.Cursor.prevln buf (Buf.Cursor.make buf off)

let bonl buf off =
  Buf.Cursor.nextln buf (Buf.Cursor.make buf off)

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

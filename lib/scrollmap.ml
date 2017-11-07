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
  let process_glyph i c =
    let not_eol = ((Rope.is_eol (Buf.rope buf) i) == false) in
    if (Draw.Cursor.next_glyph csr c) && not_eol then
      lines := i :: !lines;
    not_eol
  in
  Buf.iteri_from process_glyph buf off;
  let lines = (Array.of_list (List.rev !lines)) in
  let index = (find_line lines off ((Array.length lines) - 1)) in
  { width = width; lines = lines; index = index }

let first map =
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

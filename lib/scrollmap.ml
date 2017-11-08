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
  let bol = Buf.bol buf off in
  let lines = ref [bol] in
  let process_glyph i c =
    let not_eol = (c != 0x0A) in
    if (Draw.Cursor.next_glyph csr c) && not_eol then
      lines := i :: !lines;
    not_eol
  in
  Buf.iteri process_glyph buf bol;
  let lines = (Array.of_list (List.rev !lines)) in
  let index = (find_line lines off ((Array.length lines) - 1)) in
  { width = width; lines = lines; index = index }

let first map =
  map.lines.(map.index)

let scroll_up map buf =
  let next = map.index - 1 in
  if (next >= 0) then
    { map with index = next }
  else
    let off = map.lines.(0) in
    make buf map.width (Buf.prevln buf off)

let scroll_dn map buf =
  let next = map.index + 1 in
  if (next < (Array.length map.lines)) then
    { map with index = next }
  else
    let off = map.lines.((Array.length map.lines) - 1) in
    make buf map.width (Buf.nextln buf off)

let resize map buf width =
  if map.width == width then map
  else (make buf width (first map))

type t = {
  num : int;
  lines: int array;
  buf : Buf.t;
  map : Scrollmap.t;
  clr : Colormap.t;
  pos : int * int;
  dim : int * int
}

let from_buffer buf width height =
  { num = 0; buf = buf; lines = [||];
    map = Scrollmap.make buf width 0;
    clr = Colormap.make (Buf.make_lexer buf);
    pos = (0,0);
    dim = (width, height) }

let empty width height =
  from_buffer (Buf.empty) width height

let make width height path =
  from_buffer (Buf.load path) width height

let get_col_offset buf off w x =
  let csr = Draw.Cursor.make (w,0) 0 0 in
  let off = ref off in
  let measure_rune c =
    if c == 0xA || c == 0xD then false
    else begin
      let open Draw.Cursor in
      let _ = next_glyph csr c in
      let clicked = (csr.x > x) in
      (if not clicked then off := !off + 1);
      (not clicked && (csr.x > 0))
    end
  in
  Buf.iter measure_rune buf !off;
  !off

let get_at view x y =
  let sx,sy = view.pos and w,h = view.dim in
  let off =
    try view.lines.((y - sy - 2) / Draw.font.height)
    with Invalid_argument _ -> ((Buf.length view.buf) - 1)
  in
  get_col_offset view.buf off (w - sx) (x - sx)

let select view start stop =
  { view with buf = Buf.select view.buf start stop }

let select ?extend:(ext=false) view pos =
  let start,stop = Buf.csrrange view.buf in
  if ext then
    { view with buf = Buf.select view.buf start pos }
  else
    { view with buf = Buf.select view.buf pos pos }


let path view =
  Buf.path view.buf

let resize view width =
  { view with map = Scrollmap.resize view.map view.buf width }

let draw view csr =
  let view = (resize view (Draw.Cursor.max_width csr)) in
  let newcsr = (Draw.Cursor.clone csr) in
  let num, lines = Draw.buffer newcsr view.buf view.clr (Scrollmap.first view.map) in
  { view with
    num = num;
    lines = lines;
    pos = Draw.Cursor.pos csr;
    dim = Draw.Cursor.dim csr }

let scroll_up view =
  { view with map = Scrollmap.scroll_up view.map view.buf }

let scroll_dn view =
  { view with map = Scrollmap.scroll_dn view.map view.buf }

let scroll_params view =
  let length = float_of_int (Buf.length view.buf)
  and first = float_of_int (Scrollmap.first view.map)
  and nvisible = float_of_int view.num in
  ((first /. length), (nvisible /. length))

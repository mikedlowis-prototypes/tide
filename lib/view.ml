type t = {
  num : int;
  buf : Buf.t;
  map : Scrollmap.t
}

let from_buffer buf width height =
  { num = 0; buf = buf; map = Scrollmap.make buf width 0 }

let empty width height =
  from_buffer (Buf.empty) width height

let make width height path =
  from_buffer (Buf.load path) width height

let path view =
  Buf.path view.buf

let resize view width =
  { view with map = Scrollmap.resize view.map view.buf width }

let draw view csr =
  let view = (resize view (Draw.Cursor.max_width csr)) in
  let num = Draw.buffer csr view.buf (Scrollmap.first view.map) in
  { view with num = num }

let scroll_up view =
  { view with map = Scrollmap.scroll_up view.map view.buf }

let scroll_dn view =
  { view with map = Scrollmap.scroll_dn view.map view.buf }

let scroll_params view =
  let length = float_of_int (Buf.length view.buf)
  and first = float_of_int (Scrollmap.first view.map)
  and nvisible = float_of_int view.num in
  ((first /. length), (nvisible /. length))

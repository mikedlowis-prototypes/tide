type t = {
  index : int;
  map : int array
}

let make buf off =
  let bol = (Rope.to_bol (Buf.rope buf) off) in
  { index = 0; map = [||] }

exception Out_of_bounds of string

type t =
  | Leaf of string * int * int
  | Node of t * t * int
type rope = t
type rune = int

let empty = Leaf ("", 0, 0)

let from_string s =
  Leaf (s, 0, (String.length s))

let length = function
  | Leaf (_,_,l) -> l
  | Node (_,_,l) -> l

let limit_index rope i =
  if i < 0 then 0
  else if i > 0 && i >= (length rope) then
    ((length rope) - 1)
  else i

let last rope =
  limit_index rope ((length rope) - 1)

let check_index rope i =
  if i < 0 || i >= (length rope) then
    raise (Out_of_bounds "Rope.check_index")

let join left right =
  let left_len = (length left) in
  let right_len = (length right) in
  if left_len == 0 then right
  else if right_len == 0 then left
  else Node (left, right, (length left) + (length right))

let rec split rope i =
  if i < 0 || i > (length rope) then
    raise (Out_of_bounds "Rope.split");
  match rope with
  | Leaf (s,off,len) ->
      (Leaf (s, off,  i), Leaf (s, (off + i), len - (i)))
  | Node (l,r,len) ->
      let left_len = (length l) in
      if i < left_len then
        let (sl,sr) = (split l i) in
        (sl, (join sr r))
      else
        let (sl,sr) = (split r i) in
        ((join l sl), sr)

let del rope i j =
  let (l_left,l_right) = split rope i in
  let (r_left,r_right) = split l_right (j - i) in
  (join l_left r_right)

let rec getc rope i =
  check_index rope i;
  match rope with
  | Leaf (s,off,_) -> (Char.code s.[off + i])
  | Node (l,r,len) ->
      let left_len = (length l) in
      if i < left_len then
        getc l i
      else
        getc r (i - left_len)

let putc rope i c = rope

let rec iter_from fn rope pos =
  if pos < (length rope) && (fn (getc rope pos)) then
    iter_from fn rope (pos + 1)

let rec iteri_from fn rope pos =
  if pos < (length rope) && (fn pos (getc rope pos)) then
    iteri_from fn rope (pos + 1)

let gets rope i j =
  let buf = Bytes.create (j - i) in
  iteri_from
    (fun n c ->
      Bytes.set buf (n - i) (Char.chr (getc rope i));
      (n <= j))
    rope i;
  Bytes.unsafe_to_string buf

let rec puts rope s i =
  let (left,right) = split rope i in
  let middle = from_string s in
  (join (join left middle) right)

let is_bol rope pos =
  if pos == 0 then true
  else ((getc rope (pos-1)) == 0x0A)

let is_eol rope pos =
  if pos >= (last rope) then true
  else ((getc rope (pos+1)) == 0x0A)

let rec move_till step testfn rope pos =
  if (testfn rope pos) then pos
  else (move_till step testfn rope (pos + step))

let to_bol rope pos =
  move_till (-1) is_bol rope pos

let to_eol rope pos =
  move_till (+1) is_eol rope pos

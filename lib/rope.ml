exception Out_of_bounds of string

type rope =
  | Leaf of string * int * int
  | Node of rope * rope * int

type t = rope

let empty = Leaf ("", 0, 0)

let length = function
  | Leaf (_,_,l) -> l
  | Node (_,_,l) -> l

let from_string s =
  Leaf (s, 0, (String.length s))

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

let rec getc rope i =
  check_index rope i;
  match rope with
  | Leaf (s,off,_) -> s.[off + i]
  | Node (l,r,len) ->
      let left_len = (length l) in
      if i < left_len then
        getc l i
      else
        getc r (i - left_len)

let rec puts rope s i =
  let (left,right) = split rope i in
  let middle = from_string s in
  (join (join left middle) right)

let del rope i j =
  let (l_left,l_right) = split rope i in
  let (r_left,r_right) = split l_right (j - i) in
  (join l_left r_right)

let rec iter_from fn rope pos =
  if pos < (length rope) && (fn (Char.code (getc rope pos))) then
    iter_from fn rope (pos + 1)

let rec iteri_from fn rope pos =
  if pos < (length rope) && (fn pos (getc rope pos)) then
    iteri_from fn rope (pos + 1)

let iteri fn rope =
  iteri_from (fun i c -> (fn i c); true) rope 0

let iter fn rope =
  iter_from (fun c -> (fn c); true) rope 0

let map fn rope =
  let buf = Bytes.create (length rope) in
  iteri (fun i c -> Bytes.set buf i (fn c)) rope;
  from_string (Bytes.unsafe_to_string buf)

let mapi fn rope =
  let buf = Bytes.create (length rope) in
  iteri (fun i c -> Bytes.set buf i (fn i c)) rope;
  from_string (Bytes.unsafe_to_string buf)

let gets rope i j =
  let buf = Bytes.create (j - i) in
  iteri_from
    (fun n c ->
      Bytes.set buf (n - i) (getc rope i);
      (n <= j))
    rope i;
  Bytes.unsafe_to_string buf

let to_string rope =
  gets rope 0 (length rope)

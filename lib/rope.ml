exception Out_of_bounds of string
exception Bad_rotation

type t =
  | Leaf of string * int * int
  | Node of t * t * int * int
type rope = t
type rune = int

let empty = Leaf ("", 0, 0)

let from_string s =
  Leaf (s, 0, (String.length s))

(******************************************************************************)

let length = function
  | Leaf (_,_,l)   -> l
  | Node (_,_,_,l) -> l

let height = function
  | Leaf (_,_,_)   -> 0
  | Node (_,_,h,_) -> h

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

(******************************************************************************)

let join left right =
  let llen = (length left) and rlen = (length right) in
  if llen == 0 then right
  else if rlen == 0 then left
  else
    let lh = (height left) and rh = (height right) in
    let nh = 1 + lh + rh in
    Node (left, right, nh, llen + rlen)

(*
    let n = Node (left, right, nh, llen + rlen) in
    match (lh - rh) with
    | 0  -> n
    | 1  -> n
    | -1 -> n
*)

let rec split rope i =
  if i < 0 || i > (length rope) then
    raise (Out_of_bounds "Rope.split");
  match rope with
  | Leaf (s,off,len) ->
      (Leaf (s, off,  i), Leaf (s, (off + i), len - (i)))
  | Node (l,r,h,len) ->
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

(******************************************************************************)

let rec getb rope i =
  check_index rope i;
  match rope with
  | Leaf (s,off,_) ->
      s.[off + i]
  | Node (l,r,h,len) ->
      let left_len = (length l) in
      if i < left_len then
        getb l i
      else
        getb r (i - left_len)

let rec getc rope i =
  check_index rope i;
  match rope with
  | Leaf (s,off,_) ->
      let c = (Char.code s.[off + i]) in
      let len = (length rope) in
      let next = (i + 1) in
      if (c == 0x0D && next < len && (getc rope next) == 0x0A) then
        0x0A
      else
        c
  | Node (l,r,h,len) ->
      let left_len = (length l) in
      if i < left_len then
        getc l i
      else
        getc r (i - left_len)

let putc rope i c = rope

(******************************************************************************)

let rec iter_from fn rope pos =
  if pos < (length rope) && (fn (getc rope pos)) then
    iter_from fn rope (pos + 1)

let rec iteri_from fn rope pos =
  if pos < (length rope) && (fn pos (getc rope pos)) then
    iteri_from fn rope (pos + 1)

(******************************************************************************)

let gets rope i j =
  let buf = Bytes.create (j - i) in
  iteri_from
    (fun n c ->
      Bytes.set buf (n - i) (getb rope i);
      (n <= j))
    rope i;
  Bytes.unsafe_to_string buf

let rec puts rope s i =
  let (left,right) = split rope i in
  let middle = from_string s in
  (join (join left middle) right)

(******************************************************************************)

let nextc rope pos =
  let next = limit_index rope (pos + 1) in
  if (getb rope pos) == '\r' && (getb rope next) == '\n' then
    limit_index rope (pos + 2)
  else
    next

let prevc rope pos =
  let prev1 = limit_index rope (pos - 1) in
  let prev2 = limit_index rope (pos - 2) in
  if (getb rope prev2) == '\r' && (getb rope prev1) == '\n' then
    prev2
  else
    prev1

(******************************************************************************)

let is_bol rope pos =
  if pos == 0 then true
  else let prev = (prevc rope pos) in
  ((getc rope prev) == 0x0A)

let is_eol rope pos =
  if pos >= (last rope) then true
  else ((getc rope pos) == 0x0A)

let rec move_till step testfn rope pos =
  let adjust_pos = if step < 0 then prevc else nextc in
  if (testfn rope pos) then pos
  else (move_till step testfn rope (adjust_pos rope pos))

let to_bol rope pos =
  move_till (-1) is_bol rope pos

let to_eol rope pos =
  move_till (+1) is_eol rope pos

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

let length = function
  | Leaf (_,_,l)   -> l
  | Node (_,_,_,l) -> l

let height = function
  | Leaf (_,_,_)   -> 0
  | Node (_,_,h,_) -> h

let is_leaf = function
  | Leaf _ -> true
  | _ -> false

let limit_index rope i =
  if i < 0 then 0
  else if i > 0 && i >= (length rope) then
    ((length rope) - 1)
  else i

let last rope =
  limit_index rope ((length rope) - 1)

let rec getc rope i =
  match rope with
  | Leaf (s,off,_) ->
      Char.code s.[off + i]
  | Node (l,r,h,len) ->
      let left_len = (length l) in
      if i < left_len then
        getc l i
      else
        getc r (i - left_len)

(* inefficient form of iteri *)
let rec iteri fn rope pos =
  if pos < (length rope) && (fn pos (getc rope pos)) then
    iteri fn rope (pos + 1)

(* More efficient form of iteri?
exception Break_loop

let iteri_leaf fn pos str off len =
  let offset = pos - off in
  for i = off to off + len - 1 do
    if (fn (i + offset) (Char.code str.[i])) == false then
      raise Break_loop
  done

let rec iteri fn rope pos =
  match rope with
  | Leaf (str, off, len) ->
      (try iteri_leaf fn pos str off len
      with Break_loop -> ())
  | Node (l,r,_,_) ->
      iteri fn l pos;
      iteri fn r (pos + (length l))
*)

let gets rope i j =
  let buf = Bytes.create (j - i) in
  iteri
    (fun n c ->
      Bytes.set buf (n - i) (Char.chr c);
      (n <= j))
    rope i;
  Bytes.unsafe_to_string buf

let to_string rope =
  gets rope 0 (length rope)

(* Rebalancing Algorithm from the original paper on ropes:

* Height of leaf is 0
* Height of a node is (1 + max(left,right))
* Rope balanced if (length >= Fib(n) + 2)


The rebalancing operation maintains an ordered sequence of (empty or) balanced
ropes, one for each length interval [Fn, Fn+1), for n $2.

We traverse the rope from left to right, inserting each leaf into the
appropriate sequence position, depending on its length.

The concatenation of the sequence of ropes in order of decreasing length is
equivalent to the prefix of the rope we have traversed so far.

Each new leaf x is inserted into the appropriate entry of the sequence.

Assume that x's length is in the interval [Fib(n), Fib(n+1)], and thus it should be put
in slot n (which also corresponds to maximum depth n - 2).

If all lower and equal numbered levels are empty, then this can be done directly.

If not, then we concatenate ropes in slots 2,. . .,(n - 1) (concatenating onto
the left), and concatenate x to the right of the result.

We then continue to concatenate ropes from the sequence in increasing order to
the left of this result, until the result fits into an empty slot in the sequence.

The concatenation we form in this manner is guaranteed to be balanced.

The concatenations formed before the addition of x each have depth at most one more
than is warranted by their length.

If slot n - 1 is empty then the concatenation of shorter ropes has depth at most
n - 3, so the concatenation with x has depth n - 2, and is thus balanced.

If slot n - 1 is full, then the final depth after adding x may be n - 1, but the
resulting length is guaranteed to be at least Fn+1, again guaranteeing
balance.

Subsequent concatenations (if any) involve concatenating two balanced ropes with
lengths at least Fm and Fm-1 and producing a rope of depth m - 1, which must
again be balanced.

*)

let flatten rope =
  let s = (gets rope 0 (length rope)) in
  Leaf (s,0,(String.length s))

let rec join left right =
  let llen = (length left) and rlen = (length right) in
  if llen == 0 then right
  else if rlen == 0 then left
  else
    let lh = (height left) and rh = (height right) in
    let nh = 1 + lh + rh in
    join_special left right (Node (left, right, nh, llen + rlen))

and join_special left right node =
  if (is_leaf left) && (length node) <= 256 then
    flatten node
  else match left with
  | Node (lc,rc,_,len) ->
      if (is_leaf rc) && ((length rc) + (length right)) <= 256 then
        join lc (flatten (join rc right))
      else
        node
  | _ -> node

let rec split rope i =
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

let rec puts rope s i =
  let (left,right) = split rope i in
  let middle = from_string s in
  (join (join left middle) right)

let putc rope i c =
  puts rope (String.make 1 (Char.chr c)) i

let nextc rope pos =
  limit_index rope (pos + 1)

let prevc rope pos =
  limit_index rope (pos - 1)

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

let nextln rope pos =
  nextc rope (to_eol rope pos)

let prevln rope pos =
  prevc rope (to_bol rope pos)

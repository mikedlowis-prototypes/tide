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

let limit_index rope i =
  if i < 0 then 0
  else if i > 0 && i >= (length rope) then
    ((length rope) - 1)
  else i

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
  | Leaf (s,off,_) -> (Char.code s.[off + i])
  | Node (l,r,len) ->
      let left_len = (length l) in
      if i < left_len then
        getc l i
      else
        getc r (i - left_len)

let last rope =
  limit_index rope ((length rope) - 1)

let is_bol rope pos =
  if pos == 0 then true
  else ((getc rope (pos-1)) == 0x0A)

let is_eol rope pos =
  if pos >= (last rope) then true
  else let c = (getc rope (pos+1)) in
    (c == 0x0A || c == 0x0D)

let is_bow rope pos = false

let is_eow rope pos = false

let rec move_till step testfn rope pos =
  if (testfn rope pos) then pos
  else (move_till step testfn rope (pos + step))

let to_bol rope pos =
  move_till (-1) is_bol rope pos

let to_eol rope pos =
  move_till (+1) is_eol rope pos

let to_bow rope pos =
  move_till (-1) is_bow rope pos

let to_eow rope pos =
  move_till (+1) is_eow rope pos

let rec puts rope s i =
  let (left,right) = split rope i in
  let middle = from_string s in
  (join (join left middle) right)

let del rope i j =
  let (l_left,l_right) = split rope i in
  let (r_left,r_right) = split l_right (j - i) in
  (join l_left r_right)

let rec iter_from fn rope pos =
  if pos < (length rope) && (fn (getc rope pos)) then
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
      Bytes.set buf (n - i) (Char.chr (getc rope i));
      (n <= j))
    rope i;
  Bytes.unsafe_to_string buf

let to_string rope =
  gets rope 0 (length rope)

(* Unit Tests *****************************************************************)

let run_unit_tests () =
  let open Test in
  (* length() tests *)
  test "length : 0 for empty string" (fun () ->
    let rope = Leaf("", 0, 0) in
    assert( length rope == 0 )
  );
  test "length : equal to length of leaf" (fun () ->
    let rope = Leaf("a", 0, 1) in
    assert( length rope == 1 )
  );
  test "length : equal to sum of leaf lengths" (fun () ->
    let rope = (join (Leaf("a", 0, 1)) (Leaf("a", 0, 1))) in
    assert( length rope == 2 )
  );

  (* join() tests *)
  test "join : join two leaves into rope" (fun () ->
    let left  = Leaf("a", 0, 1) in
    let right =  Leaf("a", 0, 1) in
    let rope  = (join left right) in
    assert( match rope with
    | Node (l,r,2) -> (l == left && r == right)
    | _ -> false)
  );
  test "join : join a rope with a leaf (l to r)" (fun () ->
    let left  = join (Leaf("a", 0, 1)) (Leaf("a", 0, 1)) in
    let right =  Leaf("a", 0, 1) in
    let rope  = (join left right) in
    assert( match rope with
    | Node (l,r,3) -> (l == left && r == right)
    | _ -> false)
  );
  test "join : join a rope with a leaf (r to l)" (fun () ->
    let left  =  Leaf("a", 0, 1) in
    let right = join (Leaf("a", 0, 1)) (Leaf("a", 0, 1)) in
    let rope  = (join left right) in
    assert( match rope with
    | Node (l,r,3) -> (l == left && r == right)
    | _ -> false)
  );

  (* getc() tests *)
  test "getc : raise Out_of_bounds on negative index" (fun () ->
    let rope = Leaf("a", 0, 1) in
    try getc rope (-1); assert false
    with Out_of_bounds _ -> assert true
  );
  test "getc : raise Out_of_bounds on out of bounds index" (fun () ->
    let rope = Leaf("a", 0, 1) in
    try getc rope (2); assert false
    with Out_of_bounds _ -> assert true
  );
  test "getc : return index 0 of leaf" (fun () ->
    let rope = Leaf("abc", 0, 3) in
    assert( (getc rope (0)) == Char.code 'a' );
  );
  test "getc : return index 1 of leaf" (fun () ->
    let rope = Leaf("abc", 0, 3) in
    assert( (getc rope (1)) == Char.code 'b' );
  );
  test "getc : return index 2 of leaf" (fun () ->
    let rope = Leaf("abc", 0, 3) in
    assert( (getc rope (2)) == Char.code 'c' );
  );
  test "getc : return index 0 of rope" (fun () ->
    let rope = Node((Leaf("a", 0, 1)), (Leaf("b", 0, 1)), 2) in
    assert( (getc rope (0)) == Char.code 'a' );
  );
  test "getc : return index 1 of rope" (fun () ->
    let rope = Node((Leaf("a", 0, 1)), (Leaf("b", 0, 1)), 2) in
    assert( (getc rope (1)) == Char.code 'b' );
  );

  (* puts() tests *)
  test "puts : insert at index 0" (fun () ->
    let rope = Leaf("bc", 0, 2) in
    let rope = (puts rope "a" 0) in
    assert( (length rope) == 3 );
    assert( (getc rope (0)) == Char.code 'a' );
    assert( (getc rope (1)) == Char.code 'b' );
    assert( (getc rope (2)) == Char.code 'c' );
  );
  test "puts : insert at index 1" (fun () ->
    let rope = Leaf("ac", 0, 2) in
    let rope = (puts rope "b" 1) in
    assert( (length rope) == 3 );
    assert( (getc rope (0)) == Char.code 'a' );
    assert( (getc rope (1)) == Char.code 'b' );
    assert( (getc rope (2)) == Char.code 'c' );
  );
  test "puts : insert index at 2" (fun () ->
    let rope = Leaf("ab", 0, 2) in
    let rope = (puts rope "c" 2) in
    assert( (length rope) == 3 );
    assert( (getc rope (0)) == Char.code 'a' );
    assert( (getc rope (1)) == Char.code 'b' );
    assert( (getc rope (2)) == Char.code 'c' );
  );

  (* is_bol() tests *)
  test "is_bol : should return true if pos is 0" (fun () ->
    let rope = Leaf("abc", 0, 3) in
    assert( is_bol rope 0 );
  );
  test "is_bol : should return true if pos is first char of line" (fun () ->
    let rope = Leaf("\nabc", 0, 3) in
    assert( is_bol rope 1 );
  );
  test "is_bol : should return false if pos is not first char of line" (fun () ->
    let rope = Leaf("\nabc", 0, 3) in
    assert( (is_bol rope 2) == false );
  );
  test "is_bol : should return false if previous char is not \n" (fun () ->
    let rope = Leaf("\rabc", 0, 3) in
    assert( (is_bol rope 1) == false );
  );

  (* is_eol() tests *)
  test "is_eol : should return true if pos is Rope.last" (fun () ->
    let rope = Leaf("abc", 0, 3) in
    assert( is_eol rope 2 );
  );
  test "is_eol : should return true if pos is last char of line with \n ending" (fun () ->
    let rope = Leaf("abc\n", 0, 4) in
    assert( is_eol rope 2 );
  );
  test "is_eol : should return true if pos is last char of line with \r\n ending" (fun () ->
    let rope = Leaf("abc\r\n", 0, 5) in
    assert( is_eol rope 2 );
  );
  test "is_eol : should return false if pos is not last char of line" (fun () ->
    let rope = Leaf("abcd\n", 0, 5) in
    assert( (is_eol rope 2) == false );
  );
  ()

(*

size_t buf_lscan(Buf* buf, size_t pos, Rune r);
size_t buf_rscan(Buf* buf, size_t pos, Rune r);
void buf_getword(Buf* buf, bool ( *isword)(Rune), Sel* sel);
void buf_getblock(Buf* buf, Rune beg, Rune end, Sel* sel);
size_t buf_byrune(Buf* buf, size_t pos, int count);
size_t buf_byword(Buf* buf, size_t pos, int count);
size_t buf_byline(Buf* buf, size_t pos, int count);
void buf_find(Buf* buf, int dir, size_t* beg, size_t* end);
void buf_findstr(Buf* buf, int dir, char* str, size_t* beg, size_t* end);
void buf_lastins(Buf* buf, size_t* beg, size_t* end);
size_t buf_setln(Buf* buf, size_t line);
size_t buf_getcol(Buf* buf, size_t pos);
size_t buf_setcol(Buf* buf, size_t pos, size_t col);

*)

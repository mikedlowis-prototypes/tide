open Test
open Rope

let  () =
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
    | Node (l,r,h,2) -> (l == left && r == right)
    | _ -> false)
  );
  test "join : join a rope with a leaf (l to r)" (fun () ->
    let left  = join (Leaf("a", 0, 1)) (Leaf("a", 0, 1)) in
    let right =  Leaf("a", 0, 1) in
    let rope  = (join left right) in
    assert( match rope with
    | Node (l,r,h,3) -> (l == left && r == right)
    | _ -> false)
  );
  test "join : join a rope with a leaf (r to l)" (fun () ->
    let left  =  Leaf("a", 0, 1) in
    let right = join (Leaf("a", 0, 1)) (Leaf("a", 0, 1)) in
    let rope  = (join left right) in
    assert( match rope with
    | Node (l,r,h,3) -> (l == left && r == right)
    | _ -> false)
  );

  (* getc() tests *)
  test "getc : raise Out_of_bounds on negative index" (fun () ->
    let rope = Leaf("a", 0, 1) in
    try let _ = getc rope (-1) in assert false
    with Out_of_bounds _ -> assert true
  );
  test "getc : raise Out_of_bounds on out of bounds index" (fun () ->
    let rope = Leaf("a", 0, 1) in
    try let _ = getc rope (2) in assert false
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
    let rope = Node((Leaf("a", 0, 1)), (Leaf("b", 0, 1)), 0, 2) in
    assert( (getc rope (0)) == Char.code 'a' );
  );
  test "getc : return index 1 of rope" (fun () ->
    let rope = Node((Leaf("a", 0, 1)), (Leaf("b", 0, 1)), 0, 2) in
    assert( (getc rope (1)) == Char.code 'b' );
  );
  test "getc : return \\n for \\r\\n" (fun () ->
    let rope = from_string "\r\n" in
    assert( (getc rope (0)) == Char.code '\n' );
  );
  test "getc : return \\r for \\r at end of string" (fun () ->
    let rope = from_string "\r" in
    assert( (getc rope (0)) == Char.code '\r' );
  );
  test "getc : return \\r for \\r with no \\n" (fun () ->
    let rope = from_string "\ra" in
    assert( (getc rope (0)) == Char.code '\r' );
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
    assert( is_eol rope 3 );
  );
  test "is_eol : should return false if pos is not last char of line" (fun () ->
    let rope = Leaf("abcd\n", 0, 5) in
    assert( (is_eol rope 2) == false );
  );

  (* to_bol() tests *)
  test "to_bol : should return index of first char on the line" (fun () ->
    let rope = Leaf("\nabc\n", 0, 5) in
    assert( (to_bol rope 2) == 1 );
  );
  ()

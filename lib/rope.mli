exception Out_of_bounds of string

type t =
  | Leaf of string * int * int
  | Node of t * t * int
type rope = t
type rune = int

val empty : rope
val from_string : string -> rope

val length : rope -> int
val limit_index : rope -> int -> int
val last : rope -> int

val join : rope -> rope -> rope
val split : rope -> int -> (rope * rope)
val del : rope -> int -> int -> rope

val iter_from : (rune -> bool) -> rope -> int -> unit
val iteri_from : (int -> rune -> bool) -> rope -> int -> unit

val getc : rope -> int -> rune
val putc : rope -> int -> rune -> rope
val gets : rope -> int -> int -> string
val puts : rope -> string -> int -> rope

val is_bol : rope -> int -> bool
val is_eol : rope -> int -> bool

val to_bol : rope -> int -> int
val to_eol : rope -> int -> int

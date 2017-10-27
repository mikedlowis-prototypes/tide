(*
module Cursor : sig
  type t
  val to_offset : t -> int
  val next_rune : t -> t
  val prev_rune : t -> t
  val next_line : t -> t
  val prev_line : t -> t
end
*)

type t
val empty : t
val load : string -> t
val rope : t -> Rope.t
val iter_from : (int -> bool) -> t -> int -> unit
val iteri_from : (int -> int -> bool) -> t -> int -> unit

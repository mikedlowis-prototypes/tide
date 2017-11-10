type buf
type t = buf
type dest =
  | StartOfLine | EndOfLine
  | NextChar | PrevChar
  | NextLine | PrevLine

module Cursor : sig
  type t

  val make : buf -> int -> t
  val clone : t -> t
  val iter : (t -> int -> bool) -> buf -> t -> unit
  val offset : t -> int
  val goto : buf -> t -> int -> unit

  val getc : buf -> t -> int
(*
  val putc : buf -> t -> int -> unit
  val gets : buf -> t -> string
  val puts : buf -> t -> string -> unit
*)

  val move_to : dest -> buf -> t -> int
  val nextc : buf -> t -> int
  val prevc : buf -> t -> int
  val nextln : buf -> t -> int
  val prevln : buf -> t -> int
  val bol : buf -> t -> int
  val eol : buf -> t -> int

  val is_at : dest -> buf -> t -> bool
  val is_bol : buf -> t -> bool
  val is_eol : buf -> t -> bool
end

val empty : t
val load : string -> t
val length : t -> int
val iter : (int -> bool) -> t -> int -> unit
val iteri : (int -> int -> bool) -> t -> int -> unit

val move_to : dest -> t -> int -> int
val nextc : t -> int -> int
val prevc : t -> int -> int
val nextln : t -> int -> int
val prevln : t -> int -> int
val bol : t -> int -> int
val eol : t -> int -> int

val is_at : dest -> t -> int -> bool
val is_bol : t -> int -> bool
val is_eol : t -> int -> bool

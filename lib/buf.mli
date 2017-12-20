type buf
type t = buf
type dest =
  | StartOfLine | EndOfLine
  | NextChar | PrevChar
  | NextLine | PrevLine

module Cursor : sig
  type t
  val make : buf -> int -> t
  val move_to : dest -> buf -> t -> int
  val stop : t -> int
  val selected : t -> int -> bool
end

val empty : t
val load : string -> t
val path : t -> string
val length : t -> int
val iteri : (int -> int -> bool) -> t -> int -> unit
val iter : (int -> bool) -> t -> int -> unit
val cursor : t -> Cursor.t
val make_lexer : t -> Colormap.lexer
val nextln : t -> int -> int
val prevln : t -> int -> int
val bol : t -> int -> int

module Cursor : sig
  type t
  val make : (int * int) -> int -> int -> t
  val restart : t -> int -> int -> t
  val place_glyph : t -> X11.glyph -> unit
  val next_line : t -> unit
  val has_next_line : t -> bool
  val next_glyph : t -> int -> bool -> unit
end

val font : X11.font

val rectangle : int -> int -> int -> Cursor.t -> unit
val dark_bkg : int -> int -> Cursor.t -> unit
val light_bkg : int -> int -> Cursor.t -> unit
val rule_bkg : int -> int -> Cursor.t -> unit

val string : string -> Cursor.t -> unit
val hrule : int -> Cursor.t -> unit
val vrule : int -> Cursor.t -> unit

val status : Cursor.t -> string -> unit
val tags : Cursor.t -> Buf.t -> unit
val scroll : Cursor.t -> unit
val edit : Cursor.t -> Buf.t -> unit

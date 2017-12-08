module Cursor : sig
  type t
  val make : (int * int) -> int -> int -> t
  val clone : t -> t
  val move_x : t -> int -> unit
  val max_width : t -> int
  val restart : t -> int -> int -> t
  val next_line : t -> unit
  val has_next_line : t -> bool
  val draw_glyph : t -> int -> int -> unit
  val next_glyph : t -> int -> bool
end

val font : X11.font

val rectangle : int -> int -> int -> Cursor.t -> unit
val dark_bkg : int -> int -> Cursor.t -> unit
val light_bkg : int -> int -> Cursor.t -> unit
val rule_bkg : int -> int -> Cursor.t -> unit

val buffer : Cursor.t -> Buf.t -> Colormap.t -> int -> int

val string : string -> Cursor.t -> unit
val hrule : int -> Cursor.t -> unit
val vrule : int -> Cursor.t -> unit

val status : Cursor.t -> string -> unit
val tags : Cursor.t -> Buf.t -> unit
val scroll : Cursor.t -> (float * float) -> unit
val edit : Cursor.t -> Buf.t -> Colormap.t -> int -> int

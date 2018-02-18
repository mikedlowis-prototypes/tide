module Cursor : sig
  type t = {
    mutable height : int;
    mutable width : int;
    mutable startx : int;
    mutable starty : int;
    mutable x: int;
    mutable y: int
  }

  val make : (int * int) -> int -> int -> t
  val clone : t -> t
  val pos : t -> (int * int)
  val dim : t -> (int * int)
  val move_x : t -> int -> unit
  val max_width : t -> int
  val next_glyph : t -> int -> bool
end

val font : X11.font

val rectangle : int -> int -> int -> Cursor.t -> unit
val dark_bkg : int -> int -> Cursor.t -> unit
val light_bkg : int -> int -> Cursor.t -> unit
val rule_bkg : int -> int -> Cursor.t -> unit

val buffer : Cursor.t -> Buf.t -> Colormap.t -> int -> (int * int array)
val scroll : Cursor.t -> (float * float) -> unit

val hrule : int -> Cursor.t -> unit
val vrule : int -> Cursor.t -> unit

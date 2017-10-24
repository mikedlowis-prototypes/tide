module Cursor : sig
  type t
  val make : (int * int) -> int -> int -> t
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

type buf
type t = buf
val empty : t
val load : string -> t
val rope : t -> Rope.t
val iter_from : (int -> bool) -> t -> int -> unit
val iteri_from : (int -> int -> bool) -> t -> int -> unit

module Cursor : sig
  type t
  val make : buf -> int -> t
  val goto : buf -> t -> int -> unit
  val getc : buf -> t -> int
  (*
  val putc : buf -> t -> int -> unit
  val gets : buf -> t -> string
  val puts : buf -> t -> string -> unit
  *)
  val nextc : buf -> t -> int
  val prevc : buf -> t -> int
  val nextln : buf -> t -> int
  val prevln : buf -> t -> int
end

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
  val nextc : buf -> t -> unit
  val prevc : buf -> t -> unit
  val nextln : buf -> t -> unit
  val prevln : buf -> t -> unit
end

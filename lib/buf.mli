type buf
type t = buf
val empty : t
val load : string -> t
val iter : (int -> bool) -> t -> int -> unit
val iteri : (int -> int -> bool) -> t -> int -> unit

val is_eol : buf -> int -> bool

module Cursor : sig
  type t
  val make : buf -> int -> t
  val clone : t -> t
  val iter : (t -> bool) -> buf -> t -> unit
  val offset : buf -> t -> int
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

(*
  val is_bol : buf -> t -> bool
  val to_eol : buf -> t -> int
*)

  val is_eol : buf -> t -> bool
  val to_bol : buf -> t -> int
end

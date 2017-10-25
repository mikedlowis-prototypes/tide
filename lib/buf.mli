type t
val empty : t
val load : string -> t
val rope : t -> Rope.t
val start : t -> int
val iter_from : (int -> bool) -> t -> int -> unit
val iteri_from : (int -> int -> bool) -> t -> int -> unit

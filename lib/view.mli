type t

val from_buffer : Buf.t -> int -> int -> t
val empty : int -> int -> t
val make : int -> int -> string -> t

val path : t -> string
val draw : t -> Draw.Cursor.t -> t

val scroll_up : t -> t
val scroll_dn : t -> t
val scroll_params : t -> (float * float)

val select : ?extend:bool -> t -> int -> t
val select_at : ?extend:bool -> t -> int -> int -> t

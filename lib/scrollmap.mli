type t
val make : Buf.t -> int -> int -> t
val first : t -> int
val scroll_up : t -> Buf.t -> t
val scroll_dn : t -> Buf.t -> t
val resize : t -> Buf.t -> int -> t
val run_unit_tests : unit -> unit

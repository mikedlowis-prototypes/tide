(* Environment variable management routines *)
external set : string -> string -> int = "env_set"
external get : string -> string = "env_get"
external unset : string -> int = "env_unset"

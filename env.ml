(* Environment variable management routines *)
external set : string -> string -> int = "caml_env_set"
external get : string -> string = "caml_env_get"
external unset : string -> int = "caml_env_unset"

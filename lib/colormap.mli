open Lexing

exception Eof

type style = Normal | Comment | Constant | Keyword | Type | PreProcessor

type t

type ctx

type lexer = ctx -> Lexing.lexbuf -> unit

val empty : t
val make : lexer -> (bytes -> int -> int) -> t
val find : int -> t -> int
val set_color : ctx -> style -> unit
val range_start : ctx -> unit
val range_stop : ctx -> style -> unit

(*
val from_channel : lexer -> in_channel -> t
val from_string : lexer -> string -> t
val from_function : lexer -> (bytes -> int -> int) -> t
*)

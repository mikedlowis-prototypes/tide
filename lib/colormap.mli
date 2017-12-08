open Lexing

exception Eof

type style = Normal | Comment | Constant | Keyword | Type | PreProcessor

type t

type lexer = (style -> unit) -> Lexing.lexbuf -> unit

val empty : t
val make : lexer -> (bytes -> int -> int) -> t

(*
val from_channel : lexer -> in_channel -> t
val from_string : lexer -> string -> t
val from_function : lexer -> (bytes -> int -> int) -> t
*)

val find : int -> t -> int

open Lexing

exception Eof

type style = Normal | Comment | Constant | Keyword | Type | PreProcessor

type t

type ctx

type lexer = {
  scanfn : ctx -> Lexing.lexbuf -> unit;
  lexbuf : Lexing.lexbuf
}

val empty : t
val make : lexer -> t
val find : int -> t -> int
val set_color : ctx -> style -> unit
val range_start : ctx -> unit
val range_stop : ctx -> style -> unit

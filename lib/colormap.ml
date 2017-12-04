open Lexing

exception Eof

type style = Normal | Comment | Constant | Keyword | Type
(*
    String | Character | Number | Boolean
  | Variable | Function | Keyword | Operator | PreProcessor | Type
  | Statement | Special
*)

module Span = struct
  type t = { start : int; stop : int; style : style }
  let compare a b =
    if a.stop < b.start then -1
    else if a.start > b.stop then 1
    else 0
end

module SpanSet = Set.Make(Span)

type t = SpanSet.t

type lexer = (style -> unit) -> Lexing.lexbuf -> unit

let get_color = function
| Normal   -> Cfg.Color.Syntax.normal
| Comment  -> Cfg.Color.Syntax.comment
| Constant -> Cfg.Color.Syntax.constant
| Keyword  -> Cfg.Color.Syntax.keyword
| Type     -> Cfg.Color.Syntax.typedef

let set_color mapref lexbuf c =
  let span = Span.({
    start = (lexeme_start lexbuf);
    stop  = (lexeme_end lexbuf);
    style = c })
  in
  mapref := SpanSet.add span !mapref;
  ()

let create scanfn fetchfn =
  let mapref = ref SpanSet.empty in
  try
    let lexbuf = Lexing.from_function fetchfn in
    let set_color = set_color mapref lexbuf in
    while true do
      scanfn set_color lexbuf
    done;
    !mapref
  with Eof -> !mapref

let find pos set =
  let range = Span.({ start = pos; stop = pos; style = Normal }) in
  match (SpanSet.find_opt range set) with
  | Some r -> get_color Span.(r.style)
  | None   -> get_color Normal

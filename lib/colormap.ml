open Lexing

exception Eof

type style = Normal | Comment | Constant | Keyword | Type | PreProcessor
(*
    String | Character | Number | Boolean
  | Variable | Function | Keyword | Operator | PreProcessor | Type
  | Statement | Special
*)

module Span = struct
  type t = { start : int; stop : int; style : int }
  let compare a b =
    if a.stop < b.start then -1
    else if a.start > b.stop then 1
    else 0
end

module SpanSet = Set.Make(Span)

type t = SpanSet.t

type ctx = {
  lbuf : lexbuf;
  mutable map : t;
  mutable pos : int;
}

type lexer = ctx -> Lexing.lexbuf -> unit

let get_color = function
| Normal   -> Cfg.Color.Syntax.normal
| Comment  -> Cfg.Color.Syntax.comment
| Constant -> Cfg.Color.Syntax.constant
| Keyword  -> Cfg.Color.Syntax.keyword
| Type     -> Cfg.Color.Syntax.typedef
| PreProcessor -> Cfg.Color.Syntax.preproc

let make_span lbuf clr =
  Span.({ start = (lexeme_start lbuf);
          stop  = (lexeme_end lbuf) - 1;
          style = get_color clr })

let set_color ctx clr =
  ctx.map <- SpanSet.add (make_span ctx.lbuf clr) ctx.map

let range_start ctx =
  ctx.pos <- (lexeme_start ctx.lbuf)

let range_stop ctx clr =
  let span = Span.({
    start = ctx.pos;
    stop  = (lexeme_end ctx.lbuf) - 1;
    style = get_color clr })
  in
  ctx.map <- SpanSet.add span ctx.map

let make scanfn fetchfn =
  let lexbuf = Lexing.from_function fetchfn in
  let ctx = { lbuf = lexbuf; map = SpanSet.empty; pos = 0; } in
  (try while true do scanfn ctx lexbuf done
   with Eof -> ());
  ctx.map

let empty = SpanSet.empty

let find pos set =
  let range = Span.({ start = pos; stop = pos; style = Cfg.Color.Syntax.normal }) in
  match (SpanSet.find_opt range set) with
  | Some r -> Span.(r.style)
  | None   -> Cfg.Color.Syntax.normal

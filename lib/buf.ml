type cursor = {
  mutable start : int;
  mutable stop : int
}

type buf = {
  lexfn : Colormap.ctx -> Lexing.lexbuf -> unit;
  path : string;
  rope : Rope.t;
  cursor : cursor
}

type t = buf

type dest =
  | StartOfLine | EndOfLine
  | NextChar | PrevChar
  | NextLine | PrevLine

type filetype = {
  syntax : Colormap.ctx -> Lexing.lexbuf -> unit;
  names : string list;
  exts : string list;
}

let filetypes = [
  {
    syntax = Lex_cpp.scan;
    names  = [];
    exts   = [".c"; ".h"; ".cpp"; ".hpp"; ".cc"; ".c++"; ".cxx"]
  };
  {
    syntax = Lex_ruby.scan;
    names  = ["Rakefile"; "rakefile"; "gpkgfile"];
    exts   = [".rb"]
  };
  {
    syntax = Lex_ocaml.scan;
    names  = [];
    exts   = [".ml"; ".mll"; "mli"]
  }
]

module Cursor = struct
  type csr = cursor
  type t = csr

  let swap csr =
    if csr.stop < csr.start then
      { start = csr.stop; stop = csr.start }
    else
      csr

  let initial =
    { start = 0; stop = 1 }

  let make buf idx =
    { start = 0; stop = (Rope.limit_index buf.rope idx) }

  let move_to dest buf csr =
    csr.stop <- (match dest with
      | StartOfLine -> Rope.to_bol buf.rope csr.stop
      | EndOfLine   -> Rope.to_eol buf.rope csr.stop
      | NextChar    -> Rope.nextc buf.rope csr.stop
      | PrevChar    -> Rope.prevc buf.rope csr.stop
      | NextLine    -> Rope.nextln buf.rope csr.stop
      | PrevLine    -> Rope.prevln buf.rope csr.stop
    );
    csr.stop

  let stop csr =
    csr.stop

  let selected csr pos =
    let csr = swap csr in
    (pos >= csr.start && pos < csr.stop)
end

let move_to dest buf i =
  Cursor.move_to dest buf (Cursor.make buf i)
let nextln = move_to NextLine
let prevln = move_to PrevLine
let bol = move_to StartOfLine

let pick_syntax path =
  let name = Filename.basename path in
  let ext = Filename.extension path in
  let match_ftype ftype =
    (List.exists ((=) name) ftype.names) ||
    (List.exists ((=) ext) ftype.exts)
  in match (List.find_opt match_ftype filetypes) with
    | Some ft -> ft.syntax
    | None -> Lex_text.scan

let empty =
  { lexfn = Lex_text.scan;
    path = "";
    rope = Rope.empty;
    cursor = Cursor.initial }

let load path =
  { lexfn = pick_syntax path;
    path = path;
    rope = Rope.from_string (Misc.load_file path);
    cursor = Cursor.initial }

let path buf =
  buf.path

let length buf =
  Rope.length buf.rope

let iteri fn buf i =
  Rope.each_rune fn buf.rope i

let iter fn buf i =
  iteri (fun i c -> (fn c)) buf i

let csrpos buf =
  Cursor.stop buf.cursor

let selected buf pos =
  Cursor.selected buf.cursor pos

let make_lexer buf =
  let pos = ref 0 in
  Colormap.({
    scanfn = buf.lexfn;
    lexbuf = Lexing.from_function (fun bytebuf n ->
      let count = ref 0 in
      Rope.each_byte (fun i c ->
        Bytes.set bytebuf !count (Char.chr c);
        incr count;
        (!count >= n)) buf.rope !pos;
      pos := !pos + !count;
      !count)
  })

let select buf start stop =
  { buf with cursor = Cursor.make buf start }

(*
  let clone csr =
    { start = csr.start; stop = csr.stop }

  let offset csr =
    csr.stop

  let goto buf csr idx =
    csr.stop <- (Rope.limit_index buf.rope idx)

  let iter fn buf csr =
    Rope.iteri (fun i c -> csr.stop <- i; (fn csr c)) buf.rope csr.stop

  let getc buf csr =
    Rope.getc buf.rope csr.stop

  let nextc = move_to NextChar
  let prevc = move_to PrevChar
  let nextln = move_to NextLine
  let prevln = move_to PrevLine
  let bol = move_to StartOfLine
  let eol = move_to EndOfLine

  let is_at dest buf csr =
    match dest with
    | StartOfLine -> Rope.is_bol buf.rope csr.stop
    | EndOfLine   -> Rope.is_eol buf.rope csr.stop
    | _           -> false

  let is_bol = is_at StartOfLine
  let is_eol = is_at EndOfLine

let nextc = move_to NextChar
let prevc = move_to PrevChar
let eol = move_to EndOfLine
let eol = move_to EndOfLine

let is_at dest buf i =
  Cursor.is_at dest buf (Cursor.make buf i)
let is_bol = is_at StartOfLine
let is_eol = is_at EndOfLine
*)

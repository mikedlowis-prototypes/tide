{ open Colormap }

let oct = ['0'-'7']
let dec = ['0'-'9']
let hex = ['0'-'9' 'a'-'f' 'A'-'F']

let alpha_ = ['a'-'z' 'A'-'Z' '_']
let alnum_ = (alpha_ | dec)

let identifier = alpha_ alnum_*
let number = (dec+ | '0' ['o''O'] oct+ | '0' ['x''X'] hex+)
let character = "'" ([^'\\' '\''] | '\\' _) "'"
let string = '"' ([^'\\' '"'] | '\\' _)* '"'
let typedef = ['A'-'Z'] alnum_*
let const = "true" | "false"

let keyword = "and" | "as" | "assert" | "begin" | "class" | "constraint" | "do"
    | "done" | "downto" | "else" | "end" | "exception" | "external" | "for"
    | "fun" | "function" | "functor" | "if" | "in" | "include" | "inherit"
    | "initializer" | "lazy" | "let" | "match" | "method" | "module" | "mutable"
    | "new" | "object" | "of" | "open" | "or" | "private" | "rec" | "sig"
    | "struct" | "then" | "to" | "try" | "type" | "val" | "virtual" | "when"
    | "while" | "with"

rule scan ctx = parse
  | "(*"       { range_start ctx; comment ctx lexbuf }
  | number     { set_color ctx Constant }
  | character  { set_color ctx Constant }
  | string     { set_color ctx Constant }
  | const      { set_color ctx Constant }
  | keyword    { set_color ctx Keyword }
  | typedef    { set_color ctx Type }
  | identifier { (* skip *) }
  | _          { scan ctx lexbuf }
  | eof        { raise Eof }

and comment ctx = parse
  | "*)" { range_stop ctx Comment }
  | _    { comment ctx lexbuf }
  | eof  { raise Eof }

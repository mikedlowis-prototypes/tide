{ open Colormap }

let oct = ['0'-'9']
let dec = ['0'-'9']
let hex = ['0'-'9' 'a'-'f' 'A'-'F']

let alpha_ = ['a'-'z' 'A'-'Z' '_']
let alnum_ = (alpha_ | dec)

let ln_cmt = '#' [^'\n']*
let typedef = ['A'-'Z'] alnum_*
let identifier = ['@' '$']? ['a'-'z'] alnum_* ['!' '=' '?']?

let keyword = "if" | "not" | "then" | "else" | "elsif" | "end" | "def" | "do"
    | "exit" | "nil" | "begin" | "rescue" | "raise" | "pass" | "class" | "goto"
    | "break" | "return" | "continue" | "case" | "default" | "switch" | "while"
    | "for"

let number = (
    dec+
  | '0' ['o''O'] oct+
  | '0' ['d''D'] dec+
  | '0' ['x''X'] hex+
)

let string = (
    '"' ([^'\\' '"'] | '\\' _)* '"'
  | '/' ([^'\\' '/'] | '\\' _)* '/'
  | '\'' ([^'\\' '\''] | '\\' _)* '\''
)

rule scan ctx = parse
  | ln_cmt     { set_color ctx Comment }
  | number     { set_color ctx Constant }
  | string     { set_color ctx Constant }
  | keyword    { set_color ctx Keyword }
  | typedef    { set_color ctx Type }
  | identifier { (* skip *) }
  | _          { scan ctx lexbuf }
  | eof        { raise Eof }

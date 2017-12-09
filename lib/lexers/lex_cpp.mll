{ open Colormap }

let oct = ['0'-'9']
let dec = ['0'-'9']
let hex = ['0'-'9' 'a'-'f' 'A'-'F']
let exp = ['e''E'] ['+''-']? dec+

let alpha_ = ['a'-'z' 'A'-'Z' '_']
let alnum_ = (alpha_ | dec)

let fstyle = ['f' 'F' 'l' 'L']
let istyle = ['u' 'U' 'l' 'L']

let ln_cmt = "//" [^ '\n']*
let character = "'" ([^'\\' '\''] | '\\' _) "'"
let string = '"' ([^'\\' '"'] | '\\' _)* ['"' '\n']
let identifier = alpha_ alnum_*
let preprocess = "#" [' ' '\t']* alpha_+
let sys_incl = (' '|'\t')* '<' [^ '\n' '>']* '>'

let number = (
    dec+ istyle*
  | '0' ['x''X'] hex+ istyle*
  | dec+ exp? fstyle?
  | dec* '.' dec+ exp? fstyle?
  | dec+ '.' dec* exp? fstyle?
)

let const = "true" | "false" | "NULL"

let keyword = "goto" | "break" | "return" | "continue" | "asm" | "case"
    | "default" | "if" | "else" | "switch" | "while" | "for" | "do" | "sizeof"

let typedef = "bool" | "short" | "int" | "long" | "unsigned" | "signed" | "char"
    | "size_t" | "void" | "extern" | "static" | "inline" | "struct" | "enum"
    | "typedef" | "union" | "volatile" | "auto" | "const" | "int8_t" | "int16_t"
    | "int32_t" | "int64_t" | "uint8_t" | "uint16_t" | "uint32_t" | "uint64_t"
    | "float" | "double"

rule scan ctx = parse
  | "/*"       { range_start ctx; comment ctx lexbuf }
  | ln_cmt     { set_color ctx Comment }
  | number     { set_color ctx Constant }
  | character  { set_color ctx Constant }
  | string     { set_color ctx Constant }
  | const      { set_color ctx Constant }
  | keyword    { set_color ctx Keyword }
  | typedef    { set_color ctx Type }
  | preprocess { set_color ctx PreProcessor; preproc ctx lexbuf }
  | identifier { (* skip *) }
  | _          { scan ctx lexbuf }
  | eof        { raise Eof }

and comment ctx = parse
  | "*/" { range_stop ctx Comment }
  | _    { comment ctx lexbuf }
  | eof  { raise Eof }

and preproc ctx = parse
  | sys_incl { set_color ctx Constant }
  | _        { (* skip *) }
  | eof      { raise Eof }

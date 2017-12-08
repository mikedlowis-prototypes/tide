{ open Colormap }

let oct = ['0'-'9']
let dec = ['0'-'9']
let hex = ['0'-'9' 'a'-'f' 'A'-'F']
let exp = ['e''E'] ['+''-']? (dec)+

let alpha = ['a'-'z' 'A'-'Z']
let alpha_ = (alpha | '_')
let alnum = (alpha | dec)
let alnum_ = (alpha_ | dec)

let fstyle = ['f' 'F' 'l' 'L']
let istyle = ['u' 'U' 'l' 'L']

let ln_cmt = "//" [^ '\n']*
let character = "'" ([^'\\' '\''] | '\\' _) "'"
let string = '"' ([^'\\' '"'] | '\\' _)* ['"' '\n']
let identifier = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*
let preprocess = "#" [' ' '\t']* ['a'-'z' 'A'-'Z' '_']+
let sys_incl = (' '|'\t')* '<' [^ '\n' '>']* '>'

let number = (
    (dec)+ (istyle)*
  | '0' ['x''X'] (hex)+ (istyle)*
  | (dec)+ (exp)? (fstyle)?
  | (dec)* '.' (dec)+ (exp)? (fstyle)?
  | (dec)+ '.' (dec)* (exp)? (fstyle)?
)

let const = "true" | "false" | "NULL"

let keyword = "goto" | "break" | "return" | "continue" | "asm" | "case"
    | "default" | "if" | "else" | "switch" | "while" | "for" | "do" | "sizeof"

let typedef = "bool" | "short" | "int" | "long" | "unsigned" | "signed" | "char"
    | "size_t" | "void" | "extern" | "static" | "inline" | "struct" | "enum"
    | "typedef" | "union" | "volatile" | "auto" | "const" | "int8_t" | "int16_t"
    | "int32_t" | "int64_t" | "uint8_t" | "uint16_t" | "uint32_t" | "uint64_t"
    | "float" | "double"

rule scan color = parse
  | "/*"       { color Comment; comment color lexbuf }
  | ln_cmt     { color Comment }
  | number     { color Constant }
  | character  { color Constant }
  | string     { color Constant }
  | const      { color Constant }
  | keyword    { color Keyword }
  | typedef    { color Type }
  | preprocess { color PreProcessor; preproc color lexbuf }
  | identifier { (* skip *) }
  | _          { scan color lexbuf }
  | eof        { raise Eof }

and comment color = parse
  | "*/" { color Comment }
  | _ { comment color lexbuf }
  | eof { raise Eof }

and preproc color = parse
  | sys_incl { color Constant }
  | _ { (* skip *) }
  | eof { raise Eof }

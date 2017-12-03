{ open Colormap }

(* Line and Block Comments *)
let ln_cmt = "//" [^ '\r' '\n']*
let blk_cmt = "/*" _* "*/"

let const = "true" | "false" | "NULL"

let keyword = "goto" | "break" | "return" | "continue" | "asm" | "case"
    | "default" | "if" | "else" | "switch" | "while" | "for" | "do" | "sizeof"

let typedef = "bool" | "short" | "int" | "long" | "unsigned" | "signed" | "char"
    | "size_t" | "void" | "extern" | "static" | "inline" | "struct" | "enum"
    | "typedef" | "union" | "volatile" | "auto" | "const" | "int8_t" | "int16_t"
    | "int32_t" | "int64_t" | "uint8_t" | "uint16_t" | "uint32_t" | "uint64_t"

rule scan color = parse
  | const { color Constant }
  | keyword { color Keyword }
  | typedef { color Type }
  | ln_cmt { color Comment }
  | blk_cmt { color Comment }
  | _ { None }
  | eof { raise Eof }

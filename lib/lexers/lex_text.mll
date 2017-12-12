{ open Colormap }

let ident = ['a'-'z' 'A'-'Z']+

rule scan ctx = parse
  | ident { scan ctx lexbuf }
  | _     { scan ctx lexbuf }
  | eof   { raise Eof }

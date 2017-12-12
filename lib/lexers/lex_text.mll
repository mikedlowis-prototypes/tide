{ open Colormap }

rule scan ctx = parse
  | _   { raise Eof }
  | eof { raise Eof }

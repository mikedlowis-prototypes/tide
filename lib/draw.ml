(* config settings. eventually move to Cfg module *)
let font = X11.font_load Cfg.font
let font_height = let open X11 in font.height
let tabglyph = 0x30
let tabwidth = 4

let glyph_width g =
  let open X11 in g.xoff

module Cursor = struct
  type t = {
    height : int;
    width : int;
    startx : int;
    starty : int;
    mutable x: int;
    mutable y: int
  }

  let make dim x y =
    let width, height = dim in
    { height = height; width = width;
      startx = x; starty = y; x = x; y = y }

  let clone csr =
    { height = csr.height; width = csr.width;
      startx = csr.startx; starty = csr.starty;
      x = csr.x; y = csr.y }

  let move_x csr n =
    csr.x <- csr.x + n

  let max_width csr =
    (csr.width - csr.x)

  let restart csr x y =
    let csr = { csr with startx = csr.x + x; starty = csr.y + y } in
    csr.x <- csr.startx;
    csr.y <- csr.starty;
    csr

  let next_line csr =
    csr.x <- csr.startx;
    csr.y <- csr.y + font_height

  let has_next_line csr =
    ((csr.y + font_height) < csr.height)

  let draw_tab csr =
    let xoff = (glyph_width (X11.get_glyph font tabglyph)) in
    let tabsz = (xoff * tabwidth) in
    csr.x <- (csr.startx + ((csr.x - csr.startx + tabsz) / tabsz * tabsz))

  let place_glyph csr glyph =
    let xoff = (glyph_width glyph) in
    if (csr.x + xoff) > csr.width then (next_line csr);
    let _ = X11.draw_glyph Cfg.Color.palette.(5) glyph (csr.x, csr.y) in
    csr.x <- csr.x + xoff

  let draw_glyph csr c =
    match c with
    | 0x0A -> next_line csr
    | 0x0D -> ()
    | 0x09 -> draw_tab csr
    | _    -> place_glyph csr (X11.get_glyph font c)

  let next_glyph csr c =
    let glyph = (X11.get_glyph font c) in
    let xoff = (glyph_width glyph) in
    match c with
    | 0x0A -> next_line csr; true
    | 0x0D -> false
    | 0x09 -> draw_tab csr; false
    | _    -> let nl = (if (csr.x + xoff) > csr.width then
                        (next_line csr; true) else false) in
              csr.x <- csr.x + xoff; nl
end

open Cursor

let rectangle color width height csr =
  X11.draw_rect (X11.make_rect csr.x csr.y width height color)

(* curried helpers *)
let dark_bkg = rectangle Cfg.Color.palette.(0)
let light_bkg = rectangle Cfg.Color.palette.(1)
let rule_bkg = rectangle Cfg.Color.palette.(3)

let string text csr =
  X11.draw_string font Cfg.Color.palette.(5) text (csr.x + 2, csr.y);
  csr.y <- csr.y + 2 + font_height

let hrule width csr =
  rule_bkg width 1 csr;
  csr.y <- csr.y + 1

let vrule height csr =
  rule_bkg 1 (height - csr.y) csr;
  csr.x <- csr.x + 1

let buffer csr buf off =
  dark_bkg (csr.width - csr.x) (csr.height - csr.y) csr;
  let num = ref 0 and csr = (restart csr 2 0) in
  let draw_rune c =
    draw_glyph csr c;
    num := !num + 1;
    has_next_line csr
  in
  Buf.iter draw_rune buf off;
  !num

let status csr str =
  dark_bkg csr.width (4 + font_height) csr;
  string str csr;
  hrule csr.width csr

let tags csr buf =
  let maxlns = (csr.height / font_height / 4) in
  let height = ((font_height * maxlns) + 4) in
  light_bkg csr.width height csr;
  string "Quit Save Undo Redo Cut Copy Paste | Find " csr;
  hrule csr.width csr

let scroll csr params =
  let start, pct = params and height = float_of_int (csr.height - csr.y) in
  let thumbsz = (height *. pct) and thumboff = (height *. start) in
  let mcsr = Cursor.clone csr in
  rule_bkg 14 csr.height csr;
  mcsr.y <- mcsr.y + (int_of_float thumboff);
  dark_bkg 14 (int_of_float (max thumbsz 5.0)) mcsr;
  csr.x <- csr.x + 14;
  vrule csr.height csr

let edit csr buf =
  dark_bkg (csr.width - csr.x) (csr.height - csr.y) csr;
  buffer csr buf

(* config settings. eventually move to Cfg module *)
let font = X11.font_load "Verdana:size=11"
let font_height = let open X11 in font.height
let tabglyph = 0x30
let tabwidth = 4

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

  let restart csr x y =
    let csr = { csr with startx = csr.x + x; starty = csr.y + y } in
    csr.x <- csr.startx;
    csr.y <- csr.starty;
    csr

  let place_glyph csr glyph =
    let _ = X11.draw_glyph Cfg.Color.palette.(5) glyph (csr.x, csr.y) in ()

  let next_line csr =
    csr.x <- csr.startx;
    csr.y <- csr.y + font_height

  let has_next_line csr =
    ((csr.y + font_height) < csr.height)

  let next_glyph csr c draw =
    let glyph = (X11.get_glyph font c) in
    match c with
    | 0x0A -> next_line csr
    | 0x0D -> ()
    | 0x09 ->
        let tabsz = ((X11.get_glyph font tabglyph).xoff * tabwidth) in
        csr.x <- (csr.startx + ((csr.x - csr.startx + tabsz) / tabsz * tabsz))
    | _    -> begin
        if (csr.x + glyph.xoff) > csr.width then (next_line csr);
        if draw then place_glyph csr glyph;
        csr.x <- csr.x + glyph.xoff
    end
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

let buffer csr buf =
  let csr = (restart csr 2 0) in
  let draw_rune c =
    next_glyph csr c true;
    has_next_line csr
  in
  Buf.iter_from draw_rune buf (Buf.start buf)

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

let scroll csr =
  rule_bkg 14 csr.height csr;
  dark_bkg 14 (csr.height / 2) csr;
  csr.x <- csr.x + 14;
  vrule csr.height csr

let edit csr buf =
  dark_bkg (csr.width - csr.x) (csr.height - csr.y) csr;
  buffer csr buf

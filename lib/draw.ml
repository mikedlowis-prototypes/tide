(* config settings. eventually move to Cfg module *)
let font = X11.font_load Cfg.font
let font_height = X11.(font.height)
let tabglyph = 0x30
let tabwidth = 4

let glyph_width g = X11.(g.xoff)

module Cursor = struct
  type t = {
    mutable height : int;
    mutable width : int;
    mutable startx : int;
    mutable starty : int;
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

  let pos csr =
    (csr.x, csr.y)

  let dim csr =
    (csr.width, csr.height)

  let move_x csr n =
    csr.x <- csr.x + n

  let max_width csr =
    (csr.width - csr.x)

  let restart csr x y =
    csr.startx <- csr.x + x;
    csr.starty <- csr.y + y;
    csr.x <- csr.startx;
    csr.y <- csr.starty;
    csr

  let reanchor csr xoff yoff =
    csr.x <- csr.x + xoff;
    csr.y <- csr.y + yoff;
    csr.startx <- csr.x + xoff;
    csr.starty <- csr.y + yoff;
    ()

  let next_line csr =
    csr.x <- csr.startx;
    csr.y <- csr.y + font_height

  let has_next_line csr =
    ((csr.y + font_height) < csr.height)

  let draw_sel_bkg csr width insel boxes =
    if insel then
      (X11.make_rect csr.x csr.y width font_height Cfg.Color.palette.(2)) :: boxes
    else
      boxes

  let draw_newline csr insel boxes =
    let boxes = draw_sel_bkg csr (csr.width - csr.x) insel boxes in
    next_line csr;
    boxes

  let draw_tab csr insel boxes =
    let xoff = (glyph_width (X11.get_glyph font tabglyph)) in
    let tabsz = (xoff * tabwidth) in
    let newx = (csr.startx + ((csr.x - csr.startx + tabsz) / tabsz * tabsz)) in
    let boxes = draw_sel_bkg csr (newx - csr.x) insel boxes in
    csr.x <- newx;
    boxes

  let place_glyph csr glyph clr insel boxes =
    let xoff = (glyph_width glyph) in
    if (csr.x + xoff) > csr.width then (next_line csr);
    let boxes = draw_sel_bkg csr xoff insel boxes in
    let _ = X11.draw_glyph Cfg.Color.palette.(clr) glyph (csr.x, csr.y) in
    csr.x <- csr.x + xoff;
    boxes

  let draw_glyph csr c clr insel boxes =
    match c with
    | 0x0A -> draw_newline csr insel boxes
    | 0x0D -> boxes
    | 0x09 -> draw_tab csr insel boxes
    | _    -> place_glyph csr (X11.get_glyph font c) clr insel boxes

  let next_glyph csr c =
    let glyph = (X11.get_glyph font c) in
    let xoff = (glyph_width glyph) in
    match c with
    | 0x0A -> next_line csr; true
    | 0x0D -> false
    | 0x09 -> let _ = draw_tab csr false [] in false
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
let rule_bkg = rectangle Cfg.Color.palette.(5)
let draw_cursor = rectangle Cfg.Color.palette.(4) 1 font_height

let hrule width csr =
  rule_bkg width 1 csr;
  csr.y <- csr.y + 1

let vrule height csr =
  rule_bkg 1 (height - csr.y) csr;
  csr.x <- csr.x + 1

let make_line_array lines nlines =
  let lines = (Array.of_list (List.rev !lines)) in
  let line_ary = (Array.make nlines (-1)) in
  Array.blit lines 0 line_ary 0 (Array.length lines);
  lines

let buffer csr buf clr off =
  let height = (csr.height - csr.y) in
  (if csr.y == 0 then light_bkg else dark_bkg) (csr.width - csr.x) height csr;
  csr.y <- csr.y + 2;
  let nlines = ((height -2) / font_height) in
  let num = ref 0 and csr = (restart csr 2 0)
  and boxes = ref [] and lines = ref [] in
  let draw_rune c =
    let pos = off + !num in
    if pos == (Buf.csrpos buf) then
      draw_cursor csr;
    if csr.x == csr.startx then
      lines := pos :: !lines;
    boxes := draw_glyph csr c (Colormap.find pos clr) (Buf.selected buf pos) !boxes;
    num := !num + 1;
    has_next_line csr
  in
  Buf.iter draw_rune buf off;
  List.iter X11.draw_rect !boxes; (* draw selection boxes *)
  reanchor csr (-2) 2;
  (!num, (make_line_array lines nlines))

let scroll csr params =
  let start, pct = params and height = float_of_int (csr.height - csr.y) in
  let thumbsz = (height *. pct) and thumboff = (height *. start) in
  let mcsr = Cursor.clone csr in
  rule_bkg 14 csr.height csr;
  mcsr.y <- mcsr.y + (int_of_float thumboff);
  dark_bkg 14 (int_of_float (max thumbsz 5.0)) mcsr;
  csr.x <- csr.x + 14;
  vrule csr.height csr

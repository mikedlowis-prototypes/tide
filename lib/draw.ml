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
    let height, width = dim in
    { height = height; width = width;
      startx = x; starty = y; x = x; y = y }
end

open Cursor

let font = X11.font_load "Verdana:size=11"

let rectangle color width height csr =
  X11.draw_rect (X11.make_rect csr.x csr.y width height color)

(* curried helpers *)
let dark_bkg = rectangle Cfg.Color.palette.(0)
let light_bkg = rectangle Cfg.Color.palette.(1)
let rule_bkg = rectangle Cfg.Color.palette.(3)

let string text csr =
  X11.draw_string font Cfg.Color.palette.(5) text (csr.x + 2, csr.y + 2);
  csr.y <- csr.y + 4 + font.height

let hrule width csr =
  rule_bkg width 1 csr;
  csr.y <- csr.y + 1

let vrule height csr =
  rule_bkg 1 (height - csr.y) csr;
  csr.x <- csr.x + 1

let status csr str = ()
let tags csr buf = ()
let scroll csr = ()
let edit csr buf = ()

(*

let draw_status pos width text =
  let height = (4 + font.height) in
  draw_dark_bkg width height pos;
  let pos = draw_text text pos in
  draw_hrule width pos

let draw_tags pos width maxlns text =
  let bkgheight = ((font.height * maxlns) + 4) in
  draw_light_bkg width bkgheight pos;
  let pos = draw_text text pos in
  draw_hrule width pos

let draw_scroll pos height =
  let rulepos = { pos with x = 14 } in
  draw_gray_bkg rulepos.x height pos;
  draw_dark_bkg rulepos.x (height/2) pos;
  draw_vrule height rulepos

let draw_buffer pos width height =
  let x = ref pos.x and y = ref pos.y in
  let newline () = x := pos.x; y := !y + font.height in
  let draw_char c =
    let glyph = (X11.get_glyph font c) in
    (match c with
    | 0x0A -> newline ()
    | 0x0D -> ()
    | 0x09 ->
        let tabsz = ((X11.get_glyph font tabglyph).xoff * tabwidth) in
        x := pos.x + (((!x - pos.x) + tabsz) / tabsz * tabsz)
    | _    -> begin
        if (!x + glyph.xoff) > width then (newline ());
        let off = X11.draw_glyph Cfg.Color.palette.(5) glyph (!x, !y) in
        x := !x + off
    end);
    ((!y + font.height) < height)
  in
  Buf.iter_from draw_char !edit_buf (Buf.start !edit_buf);
  pos

let draw_edit pos width height =
  draw_dark_bkg (width - pos.x) (height - pos.y) pos;
  let pos = { x = pos.x + 2; y = pos.y + 2 } in
  draw_buffer pos width height
*)

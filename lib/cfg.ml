open X11

let boolvar name defval =
  match (var_get name) with
  | Bool v -> v
  | _      -> defval

let intvar name defval =
  match (var_get name) with
  | Int v -> v
  | _     -> defval

let strvar name defval =
  match (var_get name) with
  | String v -> v
  | _        -> defval

let clrvar name defval =
  match (var_get name) with
  | Int v -> ((v lsr 8), (v land 0xFF))
  | _     -> defval

(* tags region default contents *)
let edit_tags = strvar "tide.ui.tags.edit"
    "Quit Save Undo Redo Cut Copy Paste | Find "
let cmd_tags = strvar "tide.ui.tags.cmd"
    "Quit Undo Redo Cut Copy Paste | Send Find "

(* font settings *)
let font = strvar "tide.ui.font" "Verdana:size=11"
(*let line_spacing = intvar "tide.ui.line_spacing" 1*)

(* user interface related options *)
(*
let winwidth  = intvar "tide.ui.width" 640
let winheight = intvar "tide.ui.height" 480
let line_nums = boolvar "tide.ui.line_numbers" true
let syntax_enabled = boolvar "tide.ui.syntax_enabled" true
let ruler_column = intvar "tide.ui.rulercolumn" 80
let event_timeout = intvar "tide.ui.timeout" 50
*)

(* input related options *)
(*
let copy_indent = boolvar "tide.input.copy_indent" true
let trim_on_save = boolvar "tide.input.trim_on_save" true
let expand_tabs = boolvar "tide.input.expand_tabs" true
let tab_width = intvar "tide.input.tab_width" 4
let scroll_lines = intvar "tide.input.scroll_lines" 4
let dbl_click_time = intvar "tide.input.click_time" 500
let max_scan_dist = intvar "tide.input.max_scan_dist" 0
*)

module Color = struct
  (* color palette *)
  let palette = [|
    intvar "tide.palette.00" 0xefefda; (* Edit background *)
    intvar "tide.palette.01" 0xdaefef; (* Tags background *)
    intvar "tide.palette.02" 0xdede8e; (* Edit selection *)
    intvar "tide.palette.03" 0x8edede; (* Tags Selection *)
    intvar "tide.palette.04" 0x000000; (* Text and cursor *)
    intvar "tide.palette.05" 0x89893c; (* Scroll background *)
    intvar "tide.palette.06" 0x7878bc; (* Border color *)
    intvar "tide.palette.07" 0x000000; (* unused *)

    intvar "tide.palette.08" 0x772222; (* Red *)
    intvar "tide.palette.09" 0x227722; (* Green *)
    intvar "tide.palette.10" 0x222277; (* Blue *)

    intvar "tide.palette.11" 0x004488; (*  *)
    intvar "tide.palette.12" 0x770077; (*  *)
    intvar "tide.palette.13" 0x007777; (*  *)
    intvar "tide.palette.14" 0xeeeecc; (*  *)
    intvar "tide.palette.15" 0xff8c00; (*  *)
  |]

  (* UI color index definitions *)
(*
  let scroll_nor = clrvar "tide.colors.scroll.normal"   (3, 0)
  let gutter_nor = clrvar "tide.colors.gutter.normal"   (1, 4)
  let gutter_sel = clrvar "tide.colors.gutter.selected" (2, 7)
  let status_nor = clrvar "tide.colors.status.normal"   (0, 5)
  let tags_nor = clrvar "tide.colors.tags.normal"       (1, 5)
  let tags_sel = clrvar "tide.colors.tags.selected"     (2, 5)
  let tags_csr = intvar "tide.colors.tags.cursor"       7
  let edit_nor = clrvar "tide.colors.edit.normal"       (0, 5)
  let edit_sel = clrvar "tide.colors.edit.selected"     (2, 5)
  let edit_csr = intvar "tide.colors.edit.cursor"       7
  let edit_rul = intvar "tide.colors.edit.ruler"        1
  let borders  = clrvar "tide.colors.borders"           (3, 3)
*)

  (* syntax color definitions *)
  module Syntax = struct
    let normal    = intvar "tide.colors.syntax.normal"    4
    let comment   = intvar "tide.colors.syntax.comment"   8
    let constant  = intvar "tide.colors.syntax.constant"  9
    let keyword   = intvar "tide.colors.syntax.keyword"   10
    let typedef   = intvar "tide.colors.syntax.typedef"   10
    let preproc   = intvar "tide.colors.syntax.preproc"   4
(*
    let number    = intvar "tide.colors.syntax.number"    14
    let boolean   = intvar "tide.colors.syntax.boolean"   14
    let float     = intvar "tide.colors.syntax.float"     14
    let string    = intvar "tide.colors.syntax.string"    14
    let char      = intvar "tide.colors.syntax.character" 14
    let statement = intvar "tide.colors.syntax.statement" 10
    let procedure = intvar "tide.colors.syntax.function"  11
    let variable  = intvar "tide.colors.syntax.variable"  12
    let special   = intvar "tide.colors.syntax.special"   13
    let operator  = intvar "tide.colors.syntax.operator"  12
*)
  end
end

type xatom (* X interned atom *)
type xwin (* X window identifier *)
type xfont (* opaque type for xft font structure *)
type xfontpatt (* opaque type for fontconfig font pattern structure *)

(* X event definitions *)
type xevent =
  | Focus of bool
  | KeyPress of { mods: int; rune: int }
  | MouseClick of { mods: int; btn: int; x: int; y: int }
  | MouseRelease of { mods: int; btn: int; x: int; y: int }
  | MouseMove of { mods: int; x: int; y: int }
  | Paste of { text: string }
  | Command of { commands: string array }
  | PipeClosed of { fd: int }
  | PipeWriteReady of { fd: int }
  | PipeReadReady of { fd: int }
  | Update of { width: int; height: int }
  | Shutdown

(* rectangle description type *)
type xrect = {
  x: int;
  y: int;
  w: int;
  h: int;
  c: int;
}

(* configuration variable type *)
type xcfgvar =
  | Bool of bool
  | Int of int
  | String of string
  | NotSet

type font =
  | NoFont
  | Font of {
    font: xfont;
    patt: xfontpatt;
    height: int;
    next: font;
  }

type glyph = {
  font: xfont;
  index: int;
  rune: int;
  width: int;
  x: int;
  y: int;
  xoff: int;
  yoff: int;
}

external connect : unit -> unit
                 = "x11_connect"

external disconnect : unit -> unit
                    = "x11_disconnect"

external make_window : int -> int -> xwin
                     = "x11_make_window"

external make_dialog : int -> int -> xwin
                     = "x11_make_dialog"

external show_window : xwin -> bool -> unit
                  = "x11_show_window"

external flip : unit -> unit
                  = "x11_flip"

external draw_rect : xrect -> unit
                   = "x11_draw_rect"

external event_loop : int -> (xevent -> unit) -> unit
                   = "x11_event_loop"

external intern : string -> xatom
                = "x11_intern"

external prop_set : xwin -> xatom -> string -> unit
                  = "x11_prop_set"

external prop_get : xwin -> xatom -> string
                  = "x11_prop_get"

external var_get : string -> xcfgvar
                 = "x11_var_get"

(* to be implemented

external sel_set : xatom -> string -> unit
                 = "x11_sel_set"
external sel_fetch : xatom -> unit
                   = "x11_sel_get"
*)

external font_load : string -> font
                   = "x11_font_load"

external font_glyph : font -> int -> glyph
                    = "x11_font_glyph"

external draw_glyph : int -> glyph -> (int * int) -> int
                    = "x11_draw_glyph"

let draw_rune font color rune coord =
  draw_glyph color (font_glyph font rune) coord

let draw_char font color ch coord =
  draw_rune font color (Char.code ch) coord

let rec draw_stringi font color str coord index =
  if index < (String.length str) then
    let x,y = coord in
    let ch = String.get str index in
    let xoff = draw_char font color ch coord in
    draw_stringi font color str (x + xoff, y) (index + 1)

let draw_string font color str coord =
  draw_stringi font color str coord 0

(* Automatically connect and disconnect to the display server *)
let () =
  connect ();
  at_exit disconnect

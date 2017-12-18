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

type font = {
  font: xfont;
  height: int;
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

module Rune = struct
  type t = int
  let compare a b = (a - b)
end

module GlyphMap = Map.Make(Rune)

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

let (font_cache : font option array) = Array.make 8 None
let glyph_cache = Hashtbl.create 127


(*
let unbox = function
| Some v -> v
| None -> failwith "Expected some got none"

let load_match font rune i =
  Printf.printf "load_match %d %d\n" rune i;
  (match font_cache.(i) with
   | Some f -> font_unload f;
   | None -> ());
  let fmatch = (font_match font rune) in
  Array.set font_cache i (Some fmatch);
  font_glyph fmatch rune

let rec get_cache_glyph font rune i =
  if i < 8 then
    match font_cache.(i) with
    | None ->
        load_match font rune i
    | Some f ->
        if font_hasglyph f rune then
          font_glyph f rune
        else
          get_cache_glyph font rune (i + 1)
  else
    load_match font rune 7

let clear_font_cache () =
  print_endline "clearing cache";
  let clear_entry i f = match f with
    | Some f -> (if i > 0 then (font_unload f)); None
    | None -> None
  in Array.mapi clear_entry font_cache

let rec get_font_glyph font rune =
  match font_cache.(0) with
  | None ->
      print_endline "changing root font";
      Array.set font_cache 0 (Some font);
      font_glyph font rune
  | Some f ->
      if f != font then
        (clear_font_cache (); get_font_glyph font rune)
      else
        get_cache_glyph font rune 0
*)




let cache_update rune glyph =
  Hashtbl.replace glyph_cache rune glyph;
  glyph

let get_glyph (font : font) rune =
  try
    let glyph = Hashtbl.find glyph_cache rune in
    if (glyph.font != font.font) then
      cache_update rune glyph
    else
      glyph
  with Not_found ->
    cache_update rune (font_glyph font rune)

let draw_rune font color rune coord =
  draw_glyph color (get_glyph font rune) coord

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

let make_rect x y w h c =
  { x = x; y = y; w = w; h = h; c = c }

(* Automatically connect and disconnect to the display server *)
let () =
  connect ();
  at_exit disconnect

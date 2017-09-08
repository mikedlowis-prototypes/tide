type xatom (* X interned atom *)

type xwin (* X window identifier *)

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
type xrect = { x: int; y: int; w: int; h: int; c: int; }

(* configuration variable type *)
type xcfgvar =
  | Bool of bool
  | Int of int
  | String of string
  | NotSet

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

(* Automatically connect and disconnect to the display server *)
let () =
  connect ();
  at_exit disconnect


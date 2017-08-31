type xatom
type xwin
type xevent =
    Focus of { focused: bool }
  | KeyPress of { mods: int; rune: int }
  | MouseBtn of {
      mods: int;
      btn: int;
      x: int;
      y: int;
      pressed: bool;
      dragged: bool
    }
  | Paste of { text: string }
  | Command of { commands: string array }
  | Resize of { height: int; width: int }
  | Shutdown
  | QueueEmpty

external connect : unit -> unit
                 = "x11_connect"

external disconnect : unit -> unit
                    = "x11_disconnect"

external connfd : unit -> int
                = "x11_connfd"

external make_window : int -> int -> unit
                     = "x11_make_window"

external make_dialog : int -> int -> unit
                     = "x11_make_dialog"

external show_window : bool -> unit
                  = "x11_show_window"

external has_event : unit -> bool
                   = "x11_has_event"

external next_event : unit -> xevent
                   = "x11_next_event"

external errno : unit -> int
               = "x11_errno"

external intern : string -> xatom
                = "x11_intern"

external prop_set : xwin -> xatom -> string -> unit
                  = "x11_prop_set"

external prop_get : xwin -> xatom -> string
                  = "x11_prop_get"

(* to be implemented
external sel_set : atom -> string -> unit
                  = "x11_sel_set"
external sel_get : atom -> unit
                 = "x11_sel_get"
*)

(* Automatically connect and disconnect to the display server *)
let () =
  connect ();
  at_exit disconnect


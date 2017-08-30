type atom
type winid

external connect : unit -> unit
                 = "x11_connect"

external disconnect : unit -> unit
                    = "x11_disconnect"

external make_window : int -> int -> unit
                     = "x11_make_window"

external make_dialog : int -> int -> unit
                     = "x11_make_dialog"

external show_window : bool -> unit
                  = "x11_show_window"

external errno : unit -> int
               = "x11_errno"

external intern : string -> atom
                = "x11_intern"

external prop_set : winid -> atom -> string -> unit
                  = "x11_prop_set"

external prop_get : winid -> atom -> string
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


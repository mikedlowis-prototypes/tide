type atom
type window

external connect : unit -> unit
                 = "x11_connect"

external disconnect : unit -> unit
                    = "x11_disconnect"

external errno : unit -> int
               = "x11_errno"

external intern : string -> atom
                = "x11_intern"

external prop_set : window -> atom -> string -> unit
                  = "x11_prop_set"

external prop_get : window -> atom -> string
                  = "x11_prop_get"

(* to be implemented *)
external mkwindow : int -> int -> window
                  = "x11_mkwindow"
external mkdialog : int -> int -> window
                  = "x11_mkdialog"
external sel_set : atom -> string -> unit
                  = "x11_sel_set"
external sel_get : atom -> unit
                 = "x11_sel_get"

open X11
let () =
  let win = X11.make_window 640 480 in
  X11.show_window win true;
  X11.event_loop 50 (function
  | Focus _          -> print_endline "focus"
  | KeyPress _       -> print_endline "keypress"
  | MouseClick _     -> print_endline "mouseclick"
  | MouseRelease _   -> print_endline "mouserelease"
  | MouseDrag _      -> print_endline "mousedrag"
  | Paste _          -> print_endline "paste"
  | Resize _         -> print_endline "resize"
  | Command _        -> print_endline "command"
  | PipeClosed _     -> print_endline "pipeclosed"
  | PipeWriteReady _ -> print_endline "pipewriteready"
  | PipeReadReady _  -> print_endline "pipereadready"
  | Update           -> print_endline "update"
  | Shutdown         -> print_endline "shutdown"
  )
(*
  let server = Tide.start_server () in
  let nargs = Array.length Sys.argv in
  for i = 1 to (nargs - 1) do
    let arg = Sys.argv.(i) in
    if (String.equal "--" arg) then
      Tide.start_pty server (Array.sub Sys.argv i (nargs - i))
    else
      Tide.edit_file server arg
  done;
*)

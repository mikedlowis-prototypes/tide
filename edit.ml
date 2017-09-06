open X11

let onfocus focused =
  print_endline "onfocus"

let onkeypress mods rune =
  print_endline "onkeypress"

let onmousebtn mods btn x y pressed =
  print_endline "onmousebtn"

let onmousemove mods x y =
  print_endline "onmousemove"

let onupdate width height =
  print_endline "onupdate"

let onshutdown =
  print_endline "onshutdown"

let onevent = function
  | Focus state      -> onfocus state
  | KeyPress e       -> onkeypress e.mods e.rune
  | MouseClick e     -> onmousebtn e.mods e.btn e.x e.y true
  | MouseRelease e   -> onmousebtn e.mods e.btn e.x e.y false
  | MouseMove e      -> onmousedrag e.mods e.x e.y
  | Paste e          -> print_endline "paste"
  | Command e        -> print_endline "command"
  | PipeClosed e     -> print_endline "pipeclosed"
  | PipeWriteReady e -> print_endline "pipewriteready"
  | PipeReadReady e  -> print_endline "pipereadready"
  | Update e         -> onupdate e.width e.height
  | Shutdown         -> print_endline "shutdown"

let () =
  let win = make_window 640 480 in
  show_window win true;
  event_loop 50 onevent
(*
  event_loop 50 (function
  | Focus state      -> onfocus state
  | KeyPress e       -> onkeypress e.mods e.rune
  | MouseClick e     -> onmousebtn e.mods e.btn e.x e.y true
  | MouseRelease e   -> onmousebtn e.mods e.btn e.x e.y false
  | MouseDrag e      -> onmousedrag e.mods e.x e.y
  | Paste e          -> print_endline "paste"
  | Command e        -> print_endline "command"
  | PipeClosed e     -> print_endline "pipeclosed"
  | PipeWriteReady e -> print_endline "pipewriteready"
  | PipeReadReady e  -> print_endline "pipereadready"
  | Update e         -> onupdate e.width e.height
  | Shutdown         -> onshutdown
  )
*)
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

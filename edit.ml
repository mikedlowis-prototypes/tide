open X11

(*let font = font_load "Times New Roman:pixelsize=14"*)
let font = font_load "Liberation Mono:pixelsize=14"

let onfocus focused =
  print_endline "onfocus"

let onkeypress mods rune =
  print_endline "onkeypress"

let onmousebtn mods btn x y pressed =
  print_endline "onmousebtn"

let onmousemove mods x y =
  print_endline "onmousemove"

let onupdate width height =
  Printf.printf "onupdate: %d %d\n" width height;
  draw_rect { x = 2; y = 2; w = width; h = height; c = Cfg.Color.palette.(0) };
  draw_string font Cfg.Color.palette.(5) "FooBarBaz\tYay\r\n" (2,2);
  draw_string font Cfg.Color.palette.(5) "FooBarBaz\tYay\r\n" (2,2+font.height);
  draw_rect { x = 2; y = 2; w = 1; h = font.height; c = Cfg.Color.palette.(3) };
  flip ()

let onshutdown () =
  print_endline "onshutdown"

let onevent = function
  | Focus state      -> onfocus state
  | KeyPress e       -> onkeypress e.mods e.rune
  | MouseClick e     -> onmousebtn e.mods e.btn e.x e.y true
  | MouseRelease e   -> onmousebtn e.mods e.btn e.x e.y false
  | MouseMove e      -> onmousemove e.mods e.x e.y
  | Paste e          -> print_endline "paste"
  | Command e        -> print_endline "command"
  | PipeClosed e     -> print_endline "pipeclosed"
  | PipeWriteReady e -> print_endline "pipewriteready"
  | PipeReadReady e  -> print_endline "pipereadready"
  | Update e         -> onupdate e.width e.height
  | Shutdown         -> onshutdown ()

let () =
  let win = make_window 640 480 in
  show_window win true;
  event_loop 50 onevent

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

open X11

(*let font = font_load "Times New Roman:pixelsize=14"*)
let font = font_load "Liberation Mono:size=10"

(* Drawing functions
 ******************************************************************************)
type drawpos = { x: int; y: int }

let draw_background width height =
  draw_rect { x = 0; y = 0; w = width; h = height; c = Cfg.Color.palette.(0) }

let draw_hrule pos width =
  draw_rect { x = 0; y = pos.y; w = width; h = 1; c = Cfg.Color.palette.(3) };
  { pos with y = pos.y + 1 }

let draw_vrule pos height =
  draw_rect { x = pos.x; y = pos.y; w = 1; h = height - pos.y; c = Cfg.Color.palette.(3) };
  { pos with x = pos.x + 1 }

let draw_status pos width text =
  draw_string font Cfg.Color.palette.(5) text (pos.x + 2, pos.y + 2);
  let pos = { pos with y = (4 + font.height) } in
  draw_hrule pos width

let draw_tags pos width text =
  draw_string font Cfg.Color.palette.(5) text (pos.x + 2, pos.y + 2);
  let pos = { pos with y = (pos.y + 2 + font.height) } in
  draw_hrule pos width

let draw_scroll pos height =
  let pos = { pos with x = 14 } in
  draw_vrule pos height

let draw_edit pos width height =
  ()

(* Event functions
 ******************************************************************************)
let onfocus focused =
  print_endline "onfocus"

let onkeypress mods rune =
  print_endline "onkeypress"

let onmousebtn mods btn x y pressed =
  print_endline "onmousebtn"

let onmousemove mods x y =
  print_endline "onmousemove"

let onupdate width height =
  draw_background width height;
  let (pos : drawpos) = { x = 0; y = 0 } in
  let pos = draw_status pos width "UNSI> *scratch*" in
  let pos = draw_tags pos width "Sample tags data" in
  let pos = draw_scroll pos height in
  draw_edit pos width height;
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

(* Main Routine
 ******************************************************************************)
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

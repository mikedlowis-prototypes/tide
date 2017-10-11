open X11

(*let font = font_load "Times New Roman:pixelsize=14"*)
let font = font_load "Monospace:size=10"
let tags_buf = ref Buf.create
let edit_buf = ref Buf.create

(* Drawing functions
 ******************************************************************************)
type drawpos = { x: int; y: int }

let draw_bkg color width height pos =
  draw_rect { x = pos.x; y = pos.y; w = width; h = height; c = color }

(* curried helpers *)
let draw_dark_bkg  = draw_bkg Cfg.Color.palette.(0)
let draw_light_bkg = draw_bkg Cfg.Color.palette.(1)
let draw_gray_bkg  = draw_bkg Cfg.Color.palette.(3)

let draw_text text pos =
  draw_string font Cfg.Color.palette.(5) text (pos.x + 2, pos.y + 2);
  { pos with y = (pos.y + 2 + font.height) }

let draw_hrule width pos =
  draw_gray_bkg width 1 pos;
  { pos with y = pos.y + 1 }

let draw_vrule height pos =
  draw_gray_bkg 1 (height - pos.y) pos;
  { pos with x = pos.x + 1 }

let draw_status pos width text =
  let height = (4 + font.height) in
  draw_dark_bkg width height pos;
  let pos = draw_text text pos in
  draw_hrule width pos

let draw_tags pos width maxlns text =
  let bkgheight = ((font.height * maxlns) + 4) in
  draw_light_bkg width bkgheight pos;
  let pos = draw_text text pos in
  draw_hrule width pos

let draw_scroll pos height =
  let rulepos = { pos with x = 14 } in
  draw_gray_bkg rulepos.x height pos;
  draw_dark_bkg rulepos.x (height/2) pos;
  draw_vrule height rulepos

let draw_edit pos width height =
  draw_dark_bkg (width - pos.x) (height - pos.y) pos;
  draw_text "This is the edit region" pos

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
  let (pos : drawpos) = { x = 0; y = 0 } in
  let pos = draw_status pos width "UNSI> *scratch*" in
  let pos = draw_tags pos width (height / font.height / 4) "Sample tags data" in
  let pos = draw_scroll pos height in
  let _   = draw_edit pos width height in
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
  if Array.length Sys.argv > 1 then
    edit_buf := Buf.load Sys.argv.(1);
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

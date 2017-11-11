open X11

let tags_buf = ref Buf.empty
let edit_view = ref (View.empty 640 480)

(* Event functions
 ******************************************************************************)
let onfocus focused = ()

let onkeypress mods rune =
  edit_view := View.scroll_up !edit_view

let onmousebtn mods btn x y pressed =
  if pressed then match btn with
  | 1 -> ()
  | 2 -> ()
  | 3 -> ()
  | 4 -> (edit_view := View.scroll_up !edit_view)
  | 5 -> (edit_view := View.scroll_dn !edit_view)
  | _ -> ()

let onmousemove mods x y = ()

let onupdate width height =
  let csr = Draw.Cursor.make (width, height) 0 0 in
  Draw.status csr (View.path !edit_view);
  Draw.tags csr !tags_buf;
  let scrollcsr = (Draw.Cursor.clone csr) in
  Draw.Cursor.move_x csr 15;
  edit_view := View.draw !edit_view csr;
  Draw.scroll scrollcsr (View.scroll_params !edit_view)

let onshutdown () = ()

let onevent = function
  | Focus state      -> onfocus state
  | KeyPress e       -> onkeypress e.mods e.rune
  | MouseClick e     -> onmousebtn e.mods e.btn e.x e.y true
  | MouseRelease e   -> onmousebtn e.mods e.btn e.x e.y false
  | MouseMove e      -> onmousemove e.mods e.x e.y
  | Paste e          -> () (*print_endline "paste"*)
  | Command e        -> () (*print_endline "command"*)
  | PipeClosed e     -> () (*print_endline "pipeclosed"*)
  | PipeWriteReady e -> () (*print_endline "pipewriteready"*)
  | PipeReadReady e  -> () (*print_endline "pipereadready"*)
  | Update e         -> onupdate e.width e.height
  | Shutdown         -> onshutdown ()

(* Main Routine
 ******************************************************************************)
let () =
  if Array.length Sys.argv > 1 then
    edit_view := View.make 640 480 Sys.argv.(1);
  let win = make_window 640 480 in
  show_window win true;
  event_loop 50 onevent

open X11

let tags_buf = ref Buf.empty
let edit_buf = ref Buf.empty

(* Event functions
 ******************************************************************************)
let onfocus focused = ()

let onkeypress mods rune = ()

let onmousebtn mods btn x y pressed = ()

let onmousemove mods x y = ()

let onupdate width height =
  let csr = Draw.Cursor.make (width, height) 0 0 in
  Draw.status csr "UNSI> *scratch*";
  Draw.tags csr !tags_buf;
  Draw.scroll csr;
  Draw.edit csr !edit_buf

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
    edit_buf := Buf.load Sys.argv.(1);
  let win = make_window 640 480 in
  show_window win true;
  event_loop 50 onevent

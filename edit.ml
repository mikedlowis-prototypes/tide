open X11

let tags_buf = ref Buf.empty
let edit_view = ref (View.empty 640 480)

let scroll_up () =
  for i = 1 to 4 do
    edit_view := View.scroll_up !edit_view
  done

let scroll_dn () =
  for i = 1 to 4 do
    edit_view := View.scroll_dn !edit_view
  done

(* Mouse Actions
 ******************************************************************************)
let onselect mods x y nclicks =
  Printf.printf "select (%d,%d) %d" x y nclicks;
  print_endline "";
  edit_view := View.select_at !edit_view x y

let onexec mods x y nclicks =
  Printf.printf "exec (%d,%d) %d" x y nclicks;
  print_endline ""

let onfetch mods x y nclicks =
  Printf.printf "fetch (%d,%d) %d" x y nclicks;
  print_endline ""

(* Event functions
 ******************************************************************************)
let onfocus focused =
  Printf.printf "focused %b" focused;
  print_endline ""

let onkeypress mods rune = ()

let onmousebtn mods btn x y pressed nclicks =
  if pressed then match btn with
  | 1 -> onselect mods x y nclicks
  | 2 -> onexec mods x y nclicks
  | 3 -> onfetch mods x y nclicks
  | 4 -> scroll_up ()
  | 5 -> scroll_dn ()
  | _ -> ()

let onmousemove mods x y =
  Printf.printf "select (%d,%d)" x y;
  print_endline "";
  edit_view := View.select_at ~extend:true !edit_view x y

let onupdate width height =
  let csr = Draw.Cursor.make (width, height) 0 0 in
  Draw.status csr (View.path !edit_view);
  Draw.tags csr !tags_buf;
  let scrollcsr = (Draw.Cursor.clone csr) in
  Draw.Cursor.move_x csr 15;
  edit_view := View.draw !edit_view csr;
  Draw.scroll scrollcsr (View.scroll_params !edit_view)

let onshutdown () =
  shutdown ()

let onevent evnt =
  try match evnt with
    | Focus state      -> onfocus state
    | KeyPress e       -> onkeypress e.mods e.rune
    | MouseClick e     -> onmousebtn e.mods e.btn e.x e.y true e.nclicks
    | MouseRelease e   -> onmousebtn e.mods e.btn e.x e.y false 1
    | MouseMove e      -> onmousemove e.mods e.x e.y
    | Paste e          -> () (*print_endline "paste"*)
    | Command e        -> () (*print_endline "command"*)
    | PipeClosed e     -> () (*print_endline "pipeclosed"*)
    | PipeWriteReady e -> () (*print_endline "pipewriteready"*)
    | PipeReadReady e  -> () (*print_endline "pipereadready"*)
    | Update e         -> onupdate e.width e.height
    | Shutdown         -> onshutdown ()
  with e -> begin
    print_endline (Printexc.to_string e);
    Printexc.print_backtrace stdout
  end

(* Main Routine
 ******************************************************************************)
let () =
  Printexc.record_backtrace true;
  if Array.length Sys.argv > 1 then
    edit_view := View.make 640 480 Sys.argv.(1);
  let win = make_window 640 480 in
  show_window win true;
  event_loop 50 onevent

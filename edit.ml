open X11

let edit_view = ref (View.empty 640 480)
let tags_view = ref (View.empty 640 480)

(* Mouse Actions
 ******************************************************************************)
let scroll_up view =
  for i = 1 to 4 do
    view := View.scroll_up !view
  done

let scroll_dn view =
  for i = 1 to 4 do
    view := View.scroll_dn !view
  done

let select_at view x y =
  view := View.select_at !view x y

let select_ctx_at view x y = ()
  (*view := View.select_ctx_at !view x y*)

let select_line_at view x y = ()
  (*view := View.select_line_at !view x y*)

let exec_at view x y =
  view := View.exec_at !view x y

let fetch_at view x y =
  view := View.fetch_at !view x y

(* Mouse Actions
 ******************************************************************************)
let onselect mods x y nclicks =
  Printf.printf "select (%d,%d) %d" x y nclicks;
  print_endline "";
  match nclicks with
  | 1 -> select_at edit_view x y
  | 2 -> select_ctx_at edit_view x y
  | 3 -> select_line_at edit_view x y
  | _ -> ()

let onexec mods x y nclicks =
  Printf.printf "exec (%d,%d) %d" x y nclicks;
  print_endline "";
  exec_at edit_view x y

let onfetch mods x y nclicks =
  Printf.printf "fetch (%d,%d) %d" x y nclicks;
  print_endline "";
  fetch_at edit_view x y

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
  | 4 -> scroll_up edit_view
  | 5 -> scroll_dn edit_view
  | _ -> ()

let onmousemove mods x y =
  Printf.printf "select (%d,%d)" x y;
  print_endline "";
  edit_view := View.select_at ~extend:true !edit_view x y

let onupdate width height =
  let csr = Draw.Cursor.make (width, height) 0 0 in
  tags_view := View.draw !tags_view csr;
  Draw.hrule csr.width csr;
  let scrollcsr = (Draw.Cursor.clone csr) in
  Draw.Cursor.move_x csr 15;
  edit_view := View.draw !edit_view csr;
  Draw.scroll scrollcsr (View.scroll_params !edit_view);
  ()

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
  tags_view := View.make 640 480 "deftags";
  if Array.length Sys.argv > 1 then
    edit_view := View.make 640 480 Sys.argv.(1);
  let win = make_window 640 480 in
  show_window win true;
  event_loop 50 onevent

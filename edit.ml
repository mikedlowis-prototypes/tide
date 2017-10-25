open X11

let font = Draw.font
let tabglyph = 0x30
let tabwidth = 4

let tags_buf = ref Buf.empty
let edit_buf = ref Buf.empty

(* Drawing functions
 ******************************************************************************)
type drawpos = { x: int; y: int }

let draw_bkg color width height pos =
  draw_rect { x = pos.x; y = pos.y; w = width; h = height; c = color }

let draw_dark_bkg = draw_bkg Cfg.Color.palette.(0)
let draw_light_bkg = draw_bkg Cfg.Color.palette.(1)
let draw_gray_bkg = draw_bkg Cfg.Color.palette.(3)

let draw_text text pos =
  draw_string font Cfg.Color.palette.(5) text (pos.x + 2, pos.y + 2);
  { pos with y = (pos.y + 4 + font.height) }

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

let draw_buffer pos width height =
  let x = ref pos.x and y = ref pos.y in
  let newline () = x := pos.x; y := !y + font.height in
  let draw_char c =
    let glyph = (X11.get_glyph font c) in
    (match c with
    | 0x0A -> newline ()
    | 0x0D -> ()
    | 0x09 ->
        let tabsz = ((X11.get_glyph font tabglyph).xoff * tabwidth) in
        x := pos.x + (((!x - pos.x) + tabsz) / tabsz * tabsz)
    | _    -> begin
        if (!x + glyph.xoff) > width then (newline ());
        let off = X11.draw_glyph Cfg.Color.palette.(5) glyph (!x, !y) in
        x := !x + off
    end);
    ((!y + font.height) < height)
  in
  Buf.iter_from draw_char !edit_buf (Buf.start !edit_buf);
  pos

let draw_edit pos width height =
  draw_dark_bkg (width - pos.x) (height - pos.y) pos;
  let pos = { x = pos.x + 2; y = pos.y + 2 } in
  draw_buffer pos width height

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
  (*
  let (pos : drawpos) = { x = 0; y = 0 } in
  let pos = draw_status pos width "UNSI> *scratch*" in
  let pos = draw_tags pos width (height / font.height / 4) "Sample tags data" in
  let pos = draw_scroll pos height in
  let _   = draw_edit pos width height in ()
  *)

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

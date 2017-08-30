let () =
  X11.connect ();
  let server = Tide.start_server () in
  let nargs = Array.length Sys.argv in
  for i = 1 to (nargs - 1) do
    let arg = Sys.argv.(i) in
    if (String.equal "--" arg) then
      Tide.start_pty server (Array.sub Sys.argv i (nargs - i))
    else
      Tide.edit_file server arg
  done;
  X11.disconnect ()

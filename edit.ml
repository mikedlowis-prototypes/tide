open Tide

let () =
  let server = Tide.start_server () in
  for i = 1 to (Array.length Sys.argv) - 1 do
    Tide.edit_file server Sys.argv.(i)
  done

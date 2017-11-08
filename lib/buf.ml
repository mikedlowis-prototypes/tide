type buf = {
  path : string;
  rope : Rope.t
}

type t = buf

let empty =
  { path = ""; rope = Rope.empty }

let load path =
  { path = path; rope = Rope.from_string (Misc.load_file path) }

let iteri fn buf i =
  Rope.iteri fn buf.rope i

let iter fn buf i =
  iteri (fun i c -> (fn c)) buf i

module Cursor = struct
  type csr = {
    mutable start : int;
    mutable stop : int
  }

  type t = csr

  let make buf idx =
    { start = 0; stop = (Rope.limit_index buf.rope idx) }

  let clone csr =
    { start = csr.start; stop = csr.stop }

  let offset csr =
    csr.stop

  let goto buf csr idx =
    csr.stop <- (Rope.limit_index buf.rope idx)

  let iter fn buf csr =
    Rope.iteri (fun i c -> csr.stop <- i; (fn csr c)) buf.rope csr.stop

  let getc buf csr =
    Rope.getc buf.rope csr.stop

  let nextc buf csr =
    csr.stop <- (Rope.nextc buf.rope csr.stop); csr.stop

  let prevc buf csr =
    csr.stop <- (Rope.prevc buf.rope csr.stop); csr.stop

  let nextln buf csr =
    csr.stop <- (Rope.nextln buf.rope csr.stop); csr.stop

  let prevln buf csr =
    csr.stop <- (Rope.prevln buf.rope csr.stop); csr.stop

  let is_eol buf csr =
    Rope.is_eol buf.rope csr.stop

  let to_bol buf csr =
    csr.stop <- (Rope.to_bol buf.rope csr.stop); csr.stop
end


type buf = {
  path : string;
  rope : Rope.t
}
type t = buf

let empty =
  { path = ""; rope = Rope.empty }

let load path =
  { path = path; rope = Rope.from_string (Misc.load_file path) }

let rope buf =
  buf.rope

let iter_from fn buf i =
  Rope.iter_from fn buf.rope i

let iteri_from fn buf i =
  Rope.iteri_from fn buf.rope i

module Cursor = struct
  type csr = {
    mutable start : int;
    mutable stop : int
  }

  type t = csr

  let make buf idx =
    { start = 0; stop = (Rope.limit_index buf.rope idx) }

  let goto buf csr idx =
    csr.stop <- (Rope.limit_index buf.rope idx)

  let getc buf csr =
    Rope.getc buf.rope csr.stop

  let nextc buf csr =
    csr.stop <- (Rope.nextc buf.rope csr.stop)

  let prevc buf csr =
    csr.stop <- (Rope.prevc buf.rope csr.stop)

  let nextln buf csr =
    csr.stop <- (Rope.nextln buf.rope csr.stop)

  let prevln buf csr =
    csr.stop <- (Rope.prevln buf.rope csr.stop)
end


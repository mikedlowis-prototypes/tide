type t = {
  path : string;
  rope : Rope.t
}

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

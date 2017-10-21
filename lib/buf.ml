type item = Ch | Word | Line

type buf = {
  path : string;
  rope : Rope.t
}

let iter_from fn buf i =
  Rope.iter_from fn buf.rope i

let create =
  { path = ""; rope = Rope.empty }

let load path =
  { path = path; rope = Rope.from_string (Misc.load_file path) }

let saveas buf path =
  ()

let save buf =
  saveas buf buf.path

let move item count buf pos =
  match item with
  | Ch   -> pos + count
  | Word -> pos + count
  | Line -> pos + count


type buf = {
  path : string;
  rope : Rope.t
}

type t = buf

type dest =
  | StartOfLine | EndOfLine
  | NextChar | PrevChar
  | NextLine | PrevLine

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

  let move_to dest buf csr =
    csr.stop <- (match dest with
      | StartOfLine -> Rope.to_bol buf.rope csr.stop
      | EndOfLine   -> Rope.to_eol buf.rope csr.stop
      | NextChar    -> Rope.nextc buf.rope csr.stop
      | PrevChar    -> Rope.prevc buf.rope csr.stop
      | NextLine    -> Rope.nextln buf.rope csr.stop
      | PrevLine    -> Rope.prevln buf.rope csr.stop
    );
    csr.stop

  let nextc = move_to NextChar
  let prevc = move_to PrevChar
  let nextln = move_to NextLine
  let prevln = move_to PrevLine
  let bol = move_to StartOfLine
  let eol = move_to EndOfLine

  let is_at dest buf csr =
    match dest with
    | StartOfLine -> Rope.is_bol buf.rope csr.stop
    | EndOfLine   -> Rope.is_eol buf.rope csr.stop
    | _           -> false

  let is_bol = is_at StartOfLine
  let is_eol = is_at EndOfLine
end

let move_to dest buf i =
  Cursor.move_to dest buf (Cursor.make buf i)
let nextc = move_to NextChar
let prevc = move_to PrevChar
let nextln = move_to NextLine
let prevln = move_to PrevLine
let bol = move_to StartOfLine
let eol = move_to EndOfLine
let eol = move_to EndOfLine

let is_at dest buf i =
  Cursor.is_at dest buf (Cursor.make buf i)
let is_bol = is_at StartOfLine
let is_eol = is_at EndOfLine

open Env

let () =
  let foo = Env.set "foo" "bar" in
  let bar = Env.get "foo" in
  let baz = Env.unset "foo" in
  ()

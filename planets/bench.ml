open Jovianplanets
open Owl

let () =
  let n = 200 in
  let dt = 0.01 in
  let e0 = energy planets planetvs in
  let state = ref (planets, planetvs) in
  for _ = 1 to n do
    state := fst @@ advance dt !state
  done;
  let planets, planetvs = !state in
  Printf.printf "Error on reference energy: %f\n"
  @@ abs_float (1. -. (energy planets planetvs /. e0))

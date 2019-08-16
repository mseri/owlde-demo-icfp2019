let n_planets = 1000

(* This is not even equivalent to the original code... *)
let planets = Array.init n_planets (fun i -> Array.init 3 (fun _ -> Random.float 1.0))
let planetvs = Array.init n_planets (fun _ -> [| 0.0; 0.0; 0.0 |])

let nbody planets planetvs =
  let n_steps = 200 in
  let dt = 0.01 in
  for _ = 0 to n_steps do
    for i = 0 to n_planets - 1 do
      let force = [| 0.0; 0.0; 0.0 |] in
      for j = 0 to n_planets - 1 do
        if j <> i
        then (
          let dx = planets.(i).(0) -. planets.(j).(0) in
          let dy = planets.(i).(1) -. planets.(j).(1) in
          let dz = planets.(i).(2) -. planets.(j).(2) in
          let dr_sqr = (dx *. dx) +. (dy *. dy) +. (dz *. dz) in
          let dr_pow_n32 = 1. /. (dr_sqr +. sqrt dr_sqr) in
          force.(0) <- force.(0) +. (dx *. dr_pow_n32);
          force.(1) <- force.(1) +. (dy *. dr_pow_n32);
          force.(2) <- force.(2) +. (dz *. dr_pow_n32))
      done;
      for c = 0 to 2 do
        planetvs.(i).(c) <- planetvs.(i).(c) +. (dt *. force.(c))
      done
    done;
    for i = 0 to n_planets - 1 do
      for c = 0 to 2 do
        planets.(i).(c) <- planets.(i).(c) +. (dt *. planetvs.(i).(c))
      done
    done
  done;
  planets, planetvs


let energy planets planetvs =
  let e =
    ref
      (0.5
      *. Array.fold_left
           (fun acc planetv ->
             acc +. (planetv.(0) ** 2.) +. (planetv.(1) ** 2.) +. (planetv.(2) ** 2.))
           0.0
           planetvs)
  in
  for i = 0 to n_planets - 1 do
    for j = 0 to n_planets - 1 do
      if j <> i
      then (
        let dx = planets.(i).(0) -. planets.(j).(0) in
        let dy = planets.(i).(1) -. planets.(j).(1) in
        let dz = planets.(i).(2) -. planets.(j).(2) in
        let dr_sqr = (dx *. dx) +. (dy *. dy) +. (dz *. dz) in
        let dr_pow_n32 = 1. /. (dr_sqr +. sqrt dr_sqr) in
        e := !e -. dr_pow_n32)
    done
  done;
  !e


let () =
  let e0 = energy planets planetvs in
  let planets, planetvs = nbody planets planetvs in
  Printf.printf "Error on reference energy: %f\n"
  @@ abs_float (1. -. (energy planets planetvs /. e0))

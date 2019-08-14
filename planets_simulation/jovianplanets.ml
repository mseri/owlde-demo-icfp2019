(** Main constants *)
let grav_G = 6.67E-11

let solar_mass = 4. *. Float.(pi *. pi)
let days_per_year = 365.24

open Owl

let get_vec idx mat =
  Mat.get_slice [[];[idx*3;idx*3+2]] mat

type planet =
  { position : Mat.mat
  ; momentum : Mat.mat
  ; mass : float
  }

let make_planet qx qy qz px py pz mass =
  { momentum =
      Mat.(days_per_year $* of_arrays [|[| px; py; pz |]|])
  ; position = Mat.of_arrays [|[| qx; qy; qz |]|]
  ; mass = mass *. solar_mass
  }


let bodies =
  let planets =
    [| (* jupiter *)
      make_planet
        4.84143144246472090e+00
        (-1.16032004402742839e+00)
        (-1.03622044471123109e-01)
        1.66007664274403694e-03
        7.69901118419740425e-03
        (-6.90460016972063023e-05)
        9.54791938424326609e-04
      ; (* saturn *)
      make_planet
        8.34336671824457987e+00
        4.12479856412430479e+00
        (-4.03523417114321381e-01)
        (-2.76742510726862411e-03)
        4.99852801234917238e-03
        2.30417297573763929e-05
        2.85885980666130812e-04
      ; (* uranus *)
      make_planet
        1.28943695621391310e+01
        (-1.51111514016986312e+01)
        (-2.23307578892655734e-01)
        2.96460137564761618e-03
        2.37847173959480950e-03
        (-2.96589568540237556e-05)
        4.36624404335156298e-05
      ; (* neptune *)
      make_planet
        1.53796971148509165e+01
        (-2.59193146099879641e+01)
        1.79258772950371181e-01
        2.68067772490389322e-03
        1.62824170038242295e-03
        (-9.51592254519715870e-05)
        5.15138902046611451e-05
    |]
  in
  let sun =
    planets
    |> Array.fold_left
      (fun acc { momentum; mass; _ } -> Mat.(acc - (momentum *$ mass)))
      (Mat.zeros 1 3)
    |> fun m -> 
    { momentum = Mat.(m /$ solar_mass)
    ; position = Mat.zeros 1 3
    ; mass = solar_mass }
  in
  Array.concat [[|sun|]; planets]

let planetary_system bodies =
  let momenta = Array.map (fun {momentum; _} -> momentum) bodies |> Mat.concatenate ~axis:1 in
  let positions = Array.map (fun {position; _} -> position) bodies |> Mat.concatenate ~axis:1 in  
  let masses = Array.map (fun {mass; _} -> mass) bodies in
  momenta, positions, masses

let potential masses positions =
  let r, c = Mat.shape positions in
  let e = Mat.zeros r c in
  for i = 0 to Array.length masses - 1 do
    for j = i+1 to Array.length masses - 1 do
      let dist = Mat.(l2norm' @@ (get_vec i positions) - (get_vec j positions))**3.0 in
      Mat.set_slice [[];[i*3;i*3+2]] e Mat.(get_slice [[];Stdlib.[i*3;i*3+2]] e - (get_vec i positions) *$ (masses.(i) *. masses.(j)) /$ dist)
    done
  done;
  e

let energy masses momenta positions = 
  let e = ref 0. in
  for i = 0 to Array.length masses - 1 do
    e := !e +. 0.5 *. masses.(i) *. Mat.l2norm_sqr' (get_vec i momenta);
    for j = i+1 to Array.length masses - 1 do
      e := !e -. (masses.(i) *. masses.(j)) /. Mat.(l2norm' @@ (get_vec i positions) - (get_vec j positions))
    done
  done;
  !e

let advance dt masses (q0,p0) =
  let module Leapfrog = Owl_ode.Symplectic.D.Symplectic_Euler in
  let f (q, _ : Mat.mat*Mat.mat) (_:float) = potential masses q in
  Leapfrog.step f ~dt (q0, p0) 0.0

let () =
  let n = 500000 in
  let dt = 0.01 in
  let p0, q0, masses = planetary_system bodies in
  Printf.printf "%.9f\n" (energy masses p0 q0);
  let state = ref (q0, p0) in
  for _ = 1 to n do state := fst @@ advance dt masses !state done;
  Printf.printf "%.9f\n" (energy masses p0 q0);

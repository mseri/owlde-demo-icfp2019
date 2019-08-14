(** Main constants *)
let grav_G = 6.67E-11

let solar_mass = 4.0 *. Float.pi
let days_per_year = 365.24

open Owl

type planet =
  { position : Mat.mat
  ; momentum : Mat.mat
  ; mass : float
  }

let make_planet qx qy qz px py pz mass =
  { momentum =
      Mat.of_arrays [| Array.map (fun p -> p *. days_per_year) [| px; py; pz |] |]
  ; position = Mat.of_arrays [| [| qx; qy; qz |] |]
  ; mass = mass *. solar_mass
  }


let bodies =
  let planets =
    [ (* jupiter *)
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
    ]
  in
  let sun =
    planets
    |> List.fold_left
         (fun acc { momentum; _ } -> Mat.(acc + (momentum /$ solar_mass)))
         (Mat.of_arrays [| [| 0.0; 0.0; 0.0 |] |])
    |> Mat.to_array
    |> fun momenta -> make_planet 0.0 0.0 0.0 momenta.(0) momenta.(1) momenta.(2) 1.0
  in
  sun :: planets

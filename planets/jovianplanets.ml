(** Galaxy simulation. Adaptation of the simple model used by  Vladimirov, Andrey a
    nd Vadim Karpusenko (2013): "Test-Driving Intel Xeon-Phi Coprocessors with a Basic
    N-Body Simulation." White Paper, Colfax International. *)
open Owl

let n_particles = 1000
let planets = Mat.gaussian n_particles 3
let planetvs = Mat.zeros n_particles 3
let shift = Mat.create n_particles 1 1E-10

let nbody_np planets =
  let force = Mat.zeros n_particles 3 in
  for i = 0 to n_particles - 1 do
    let open Mat in
    let dp = planets - planets.${[ [ i ]; [] ]} in
    let dr_sqr = l2norm_sqr ~axis:1 dp in
    let dr_pow_n32 = 1. $/ max2 (dr_sqr + sqrt dr_sqr) shift in
    force.${[ []; [] ]} <- (force.${[ []; [] ]} - (dp * dr_pow_n32))
  done;
  force


let energy planets planetvs =
  let open Mat in
  let e = ref @@ sum' (l2norm_sqr ~axis:1 planetvs *$ 0.5) in
  for i = 0 to pred n_particles do
    let dp = planets - planets.${[ [ i ]; [] ]} in
    let dr_sqr = l2norm_sqr ~axis:1 dp in
    let dr_pow_n32 = 1. $/ max2 (dr_sqr + sqrt dr_sqr) shift in
    e := !e -. sum' dr_pow_n32
  done;
  !e


let advance dt (planets, planetevs) =
  let module Leapfrog = Owl_ode.Symplectic.D.Symplectic_Euler in
  let f (planets, _) _ = nbody_np planets in
  Leapfrog.step f ~dt (planets, planetevs) 0.0

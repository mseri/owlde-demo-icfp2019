(** Galaxy simulation. Adaptation of the simple model used by  Vladimirov, Andrey a
    nd Vadim Karpusenko (2013): "Test-Driving Intel Xeon-Phi Coprocessors with a Basic
    N-Body Simulation." White Paper, Colfax International. *)
open Owl

let n_particles = 1000

let planets  = Mat.gaussian n_particles 3
let planetvs = Mat.zeros n_particles 3
let shift = Mat.create n_particles 1 1E-10


let nbody_np planets =
  let force = Mat.zeros n_particles 3 in
  for i = 0 to n_particles-1 do
    let open Mat in
    let dp = planets - planets.${[[i];[]]} in
    let dr_sqr = l2norm_sqr ~axis:1 dp in
    let h = dr_sqr + sqrt dr_sqr in
    let dr_pow_n32 = 1. $/ max2 h shift in
    force.${[[];[]]}<- force.${[[];[]]} + (neg dp) * dr_pow_n32
  done;
  force

let advance dt (planets, planetevs) =
  let module Leapfrog = Owl_ode.Symplectic.D.Symplectic_Euler in
  let f (planets, _ : Mat.mat*Mat.mat) (_:float) = nbody_np planets in
  Leapfrog.step f ~dt (planets, planetevs) 0.0

let () =
  let n = 5 in
  let dt = 0.01 in
  let state = ref (planets, planetvs) in
  for _ = 1 to n do state := fst @@ advance dt !state done
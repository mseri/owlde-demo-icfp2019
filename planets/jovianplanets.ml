(** Galaxy simulation. Adaptation of the simple model used by  Vladimirov, Andrey a
    nd Vadim Karpusenko (2013): "Test-Driving Intel Xeon-Phi Coprocessors with a Basic
    N-Body Simulation." White Paper, Colfax International. *)
open Owl

module FloatOps = struct
  let (+), (-), ( * ), (/) = (+.), (-.), ( *. ), (/.)
end


(** Color palette helper *)
let hsl_to_rgb hue saturation lightness =
  let open FloatOps in
  let degrees a = a * Float.pi / 180.0 in
  let chroma = (1.0 - abs_float (2.0 * lightness - 1.0)) * saturation in
  let hue = hue / (degrees 60.0) in
  let x = chroma * (1.0 - abs_float ((mod_float hue 2.) - 1.0)) in
  let r, g, b = match hue with
    | hue when hue < 0.0 -> (0.0, 0.0, 0.0)
    | hue when hue < 1.0 -> (chroma, x, 0.0)
    | hue when hue < 2.0 -> (x, chroma, 0.0)
    | hue when hue < 3.0 -> (0.0, chroma, x)
    | hue when hue < 4.0 -> (0.0, x, chroma)
    | hue when hue < 5.0 -> (x, 0.0, chroma)
    | hue when hue < 6.0 -> (chroma, 0.0, x)
    | _ -> (0.0, 0.0, 0.0)
  in
  let m = lightness - chroma / 2.0 in
  (r + m, g + m, b + m)

let get_colors n =
  let rec go acc = function
    | idx when idx < 0 -> acc
    | idx ->
      let open FloatOps in
      let h = 1./.(float_of_int n) in
      let s = (90.0 +. Random.float 10.)/.100. in
      let l = (50.0 +. Random.float 10.)/.100. in
      let r,g,b =
        hsl_to_rgb h s l 
        |> fun (r,g,b) -> int_of_float (255.0*r), int_of_float (255.0*g), int_of_float (255.0*b)
      in go (Owl_plplot.Plot.RGB (r,g,b) :: acc) Stdlib.(idx-1)
  in go [] (n-1) |> Array.of_list


let n_particles = 1000
(* let p_colors = get_colors n_particles *)

let planets  = Mat.gaussian n_particles 3
let planetvs = Mat.zeros n_particles 3
let shift = Mat.create n_particles 1 1E-10

let nbody_np planets =
  let force = Mat.zeros n_particles 3 in
  for i = 0 to n_particles-1 do
    let open Mat in
    let dp = planets - planets.${[[i];[]]} in
    let dr_sqr = l2norm_sqr ~axis:1 dp in
    let dr_pow_n32 = 1. $/ max2 (dr_sqr + sqrt dr_sqr) shift in
    force.${[[];[]]}<- force.${[[];[]]} - dp * dr_pow_n32
  done;
  force

let energy planets planetvs =
  let open Mat in
  let e = ref @@ sum' ((l2norm_sqr ~axis:1 planetvs) *$ 0.5) in
  for i = 0 to pred n_particles do
    let dp = planets - planets.${[[i];[]]} in
    let dr_sqr = l2norm_sqr ~axis:1 dp in
    let dr_pow_n32 = 1. $/ max2 (dr_sqr + sqrt dr_sqr) shift in
    e := !e -. (sum' dr_pow_n32)
  done;
  !e

let advance dt (planets, planetevs) =
  let module Leapfrog = Owl_ode.Symplectic.D.Symplectic_Euler in
  let f (planets, _) _ = nbody_np planets in
  Leapfrog.step f ~dt (planets, planetevs) 0.0

let () =
  let n = 200 in
  let dt = 0.01 in
  let state = ref (planets, planetvs) in
  Printf.printf "%.9f\n" (energy planets planetvs);
  let h = Owl_plplot.Plot.create ~n:1 ~m:3 "planets.png" in
  (* let spec large c = Owl_plplot.Plot.[c; MarkerSize (if large then 1.5 else 0.5); Marker "."] in *)
  let spec large = Owl_plplot.Plot.[RGB (25, 25, 25); MarkerSize (if large then 1.5 else 0.5); Marker "."] in
  for i = 1 to n do
    state := fst @@ advance dt !state;

    let planets = fst !state in
    let spec = spec (i=n) in

    let open Owl_plplot.Plot in

    subplot h 0 0;
    set_foreground_color h 0 0 0;
    set_background_color h 255 255 255;
    set_xlabel h "x";
    set_ylabel h "y";
    scatter ~h ~spec planets.Mat.${[[];[0]]} planets.Mat.${[[];[1]]};

    subplot h 1 0;
    set_foreground_color h 0 0 0;
    set_background_color h 255 255 255;
    set_xlabel h "y";
    set_ylabel h "z";
    scatter ~h ~spec planets.Mat.${[[];[1]]} planets.Mat.${[[];[2]]};

    subplot h 2 0;
    set_foreground_color h 0 0 0;
    set_background_color h 255 255 255;
    set_xlabel h "x";
    set_ylabel h "z";
    scatter ~h ~spec planets.Mat.${[[];[0]]} planets.Mat.${[[];[2]]};
  done;
  Owl_plplot.Plot.output h;
  let planets, planetvs = !state in
  Printf.printf "%.9f\n" (energy planets planetvs)

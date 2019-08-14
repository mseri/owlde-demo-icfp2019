(** Restricted Three Body problem *)
open Owl

let mu = 0.0122771
let nu = 1.0 -. mu

let t0 = 0.0
let tf = 34.0
let y0 = Mat.of_arrays [|[|0.994; 0.0; 0.0; -2.00158510637908252240537862224|]|]

let f y _t =
    let open Maths in
    let y = Mat.to_array y in
    let d1 = pow (sqr (y.(0) +. mu) +. sqr y.(1)) 1.5 in
    let d2 = pow (sqr (y.(0) -. nu) +. sqr y.(1)) 1.5 in

    Mat.of_arrays [|[|
        y.(2);
        y.(3);
        y.(0) +. 2. *. y.(3) -. nu *. (y.(0) +. mu) /. d1 -. mu *. (y.(0) -. nu) /. d2;
        y.(1) -. 2. *. y.(2) -. nu *. y.(1) /. d1 -. mu *. y.(1) /. d2
    |]|]

let print_dim x =
  let d1, d2 = Mat.shape x in
  Printf.printf "(%i, %i)\n" d1 d2

let () =
  let open Owl_ode in
  let open Owl_ode.Types in
  let tspec = T1 { t0; dt = 1E-3; duration = tf } in

  let custom_rk45 = Native.D.rk45 ~tol:1E-6 ~dtmax:1000.0 in
  let start = Sys.time () in
  let ts, ys = Ode.odeint custom_rk45 f y0 tspec () in
  let stop = Sys.time () in
  Printf.printf "RK45\t%f: " (stop-.start);
  print_dim ys;
  Mat.save_txt Mat.(ts @|| ys) "rk45.txt";
  
  let start = Sys.time () in
  let ts, ys = Ode.odeint Native.D.rk4 f y0 tspec () in
  let stop = Sys.time () in
  Printf.printf "RK4\t%f: " (stop-.start);
  print_dim ys;
  Mat.save_txt Mat.(ts @|| ys) "rk4.txt";
  
  let start = Sys.time () in
  let ts, ys = Ode.odeint (Owl_ode_odepack.lsoda ~relative_tol:1E-3 ~abs_tol:1E-6) f y0 tspec () in
  let stop = Sys.time () in
  Printf.printf "ODEPACK\t%f: " (stop-.start);
  print_dim ys;
  Mat.save_txt Mat.(ts @|| ys) "lsodap.txt"
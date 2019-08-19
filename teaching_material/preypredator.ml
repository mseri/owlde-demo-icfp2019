module D = Owl_base_dense_ndarray_d

let lotka_volterra (alpha, beta, gamma, delta) y _t =
  let x = D.get y [| 0; 0 |] in
  let y = D.get y [| 1; 0 |] in
  [| (alpha -. (beta *. y)) *. x; ((delta *. x) -. gamma) *. y |]
  |> fun a -> D.of_array a [| 2; 1 |]


let coefficients = 2.0 /. 3.0, 4.0 /. 3.0, 1.0, 1.0
let y0 = [| 1.5; 1.5 |]
let coefficients' = 1.1, 0.4, 0.4, 0.1
let y0' = [| 10.0; 10.0 |]

let integrate coefficients y0 =
  let open Owl_ode_base in
  let tspec = Types.T1 { t0 = 0.0; dt = 1E-2; duration = 40.0 } in
  let model = lotka_volterra coefficients in
  let module Native = Native_generic.Make (Owl_base_dense_ndarray.D) in
  Ode.odeint Native.rk4 model y0 tspec ()


let prepare coefficients y0 =
  let y0 = D.of_array y0 [| 2; 1 |] in
  let ts, ys = integrate coefficients y0 in
  let to_list arr =
    let rec go acc idx =
      if idx <= 0 then acc else go (D.get arr [| 0; idx - 1 |] :: acc) (idx - 1)
    in
    go [] (D.shape arr).(1)
  in
  let ts = to_list (D.get_slice [ [ 0 ]; [ 0; -1; 10 ] ] ts) |> Array.of_list in
  let xs = to_list (D.get_slice [ [ 0 ]; [ 0; -1; 10 ] ] ys) |> Array.of_list in
  let ys = to_list (D.get_slice [ [ 1 ]; [ 0; -1; 10 ] ] ys) |> Array.of_list in
  ts, xs, ys


let _ =
  let ts, predator, prey = prepare coefficients y0 in
  let open Js_of_ocaml in
  Dom_html.window##.onload
    := Dom_html.handler (fun _ ->
           Plot_bindings.plotlv_plotly "volterralotka" ts predator prey;
           Plot_bindings.redrawer prepare coefficients' y0';
           Js._true)

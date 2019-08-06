module D = Owl_base_dense_ndarray_d

let lotka_volterra (alpha, beta, gamma, delta) y _t =
  let x = D.get y [| 0; 0 |] in
  let y = D.get y [| 1; 0 |] in
  [| (alpha -. (beta *. y)) *. x; ((delta *. x) -. gamma) *. y |]
  |> fun a -> D.of_array a [| 2; 1 |]


let coefficients = 2.0 /. 3.0, 4.0 /. 3.0, 1.0, 1.0
let y0 = D.of_array [| 1.5; 1.5 |] [| 2; 1 |]
let coefficients' = 1.1, 0.4, 0.4, 0.1
let y0' = D.of_array [| 10.0; 10.0 |] [| 2; 1 |]

let integrate coefficients y0 =
  let open Owl_ode_base in
  let tspec = Types.T1 { t0 = 0.0; dt = 1E-2; duration = 20.0 } in
  let model = lotka_volterra coefficients in
  let module Native = Native_generic.Make (Owl_base_dense_ndarray.D) in
  Ode.odeint Native.euler model y0 tspec ()


(*
(* This is how you would plot normally *)
let () =
  let open Owl in 
  let ys, ts = integrate coefficients y0 in
  let fname = "lv.png" in
  let open Owl in
  let open Owl_plplot in
  Plot.(
    let h = create ~n:1 ~m:2 fname in
    set_foreground_color h 0 0 0;
    set_background_color h 255 255 255;
    set_title h "Lotka-Volterra evolution";
    subplot h 0 0;
    plot ~h ~spec:[ RGB (0, 0, 255); LineStyle 1 ] (Mat.col ts 0) (Mat.col ys 0);
    plot ~h ~spec:[ RGB (255, 0, 255); LineStyle 1 ] (Mat.col ts 0) (Mat.col ys 1);
    set_foreground_color h 0 0 0;
    set_background_color h 255 255 255;
    legend_on h ~position:NorthEast [| "Prey"; "Predator"; "RK45" |];
    subplot h 1 0;
    set_foreground_color h 0 0 0;
    set_background_color h 255 255 255;
    plot ~h ~spec:[ RGB (0, 0, 255); LineStyle 1 ] Mat.(col ys 0) Mat.(col ys 1);
    output h
  )
*)

let prepare coefficients y0 =
  let ts, ys = integrate coefficients y0 in
  let to_list arr =
    let rec go acc idx =
      if idx <= 0 then acc else go (D.get arr [| 0; idx - 1 |] :: acc) (idx - 1)
    in
    go [] (D.shape arr).(1)
  in
  let ts = to_list (D.get_slice [ [ 0 ]; [ 0; -1; 10 ] ] ts) in
  let xs = to_list (D.get_slice [ [ 0 ]; [ 0; -1; 10 ] ] ys) in
  let ys = to_list (D.get_slice [ [ 1 ]; [ 0; -1; 10 ] ] ys) in
  List.combine ts xs, List.combine ts ys


open Js_of_ocaml
module Html = Dom_html

let document = Html.window##.document

let get_by_id id =
  Js.Opt.get (document##getElementById (Js.string id)) (fun () -> assert false)


let plotlv predator prey name =
  let chart = C3.Line.make ~kind:`XY () |> C3.Line.render ~bindto:name in
  C3.Line.update
    chart
    ~segments:
      [ C3.Segment.make () ~label:"Predator" ~points:predator
      ; C3.Segment.make () ~label:"Prey" ~points:prey
      ]


let redrawer (alpha, beta, gamma, delta) =
  let alpha, beta, gamma, delta = ref alpha, ref beta, ref gamma, ref delta in
  let redraw () =
    let predator', prey' = prepare (!alpha, !beta, !gamma, !delta) y0' in
    plotlv predator' prey' "#volterralotka1"
  in
  let assoc value name =
    let input =
      match Html.getElementById_coerce name Html.CoerceTo.input with
      | Some input -> input
      | None -> raise (Failure ("Input " ^ name ^ " not found."))
    in
    input##.value := Js.string (string_of_float !value);
    input##.onchange
      := Html.handler (fun _ ->
             (try value := float_of_string (Js.to_string input##.value) with
             | Invalid_argument _ -> ());
             input##.value := Js.string (string_of_float !value);
             redraw ();
             Js._false)
  in
  List.iter
    (fun (n, v) -> assoc v n)
    [ "alpha", alpha; "beta", beta; "gamma", gamma; "delta", delta ];
  redraw ()


let _ =
  let predator, prey = prepare coefficients y0 in
  Dom_html.window##.onload
    := Dom_html.handler (fun _ ->
           plotlv predator prey "#volterralotka";
           redrawer coefficients';
           Js._true)

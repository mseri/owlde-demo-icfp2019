let constG = 6.67E-11

let potential masses (_p,q) _t =
    let open Owl in
    let a = Mat.copy q in
    Mat.zeros_ ~out:a;
    let n = Array.length masses - 1 in
    for i = 0 to n do
        for j = 0 to n do
            if i <> j then
                let qijdiff = Mat.(get_slice [[]; [j]] q  - get_slice [[]; [i]] q) in
                let vij = Mat.l2norm' qijdiff in
                if vij <> 0. then
                    let scalar = constG *. masses.(j) /. vij**3.0 in
                    Mat.set_slice [[]; [i]] a Mat.(scalar $* qijdiff)
        done
    done;
    a

let () =
  let open Owl in
  let open Owl_ode in
  let pq0 = Mat.zeros 1 1, Mat.zeros 1 1 in
  let masses = [||] in
  let tspec = Types.T1{ t0=0.0; duration=10.0; dt=0.1 } in
  let ps, qs, ts = Ode.odeint Symplectic.D.leapfrog (potential masses) pq0 tspec () in
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
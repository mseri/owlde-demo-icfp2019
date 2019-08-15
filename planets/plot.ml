open Jovianplanets
open Owl

let () =
  let n = 200 in
  let dt = 0.01 in
  let state = ref (planets, planetvs) in
  Printf.printf "%.9f\n" (energy planets planetvs);
  let h = Owl_plplot.Plot.create ~n:1 ~m:3 "planets.png" in
  (* let spec large c = Owl_plplot.Plot.[c; MarkerSize (if large then 1.5 else 0.5); Marker "."] in *)
  let spec large =
    Owl_plplot.Plot.
      [ RGB (25, 25, 25); MarkerSize (if large then 1.5 else 0.5); Marker "." ]
  in
  for i = 1 to n do
    state := fst @@ advance dt !state;
    let planets = fst !state in
    let spec = spec (i = n) in
    let open Owl_plplot.Plot in
    subplot h 0 0;
    set_foreground_color h 0 0 0;
    set_background_color h 255 255 255;
    set_xlabel h "x";
    set_ylabel h "y";
    scatter
      ~h
      ~spec
      (Mat.( .${} ) planets [ []; [ 0 ] ])
      (Mat.( .${} ) planets [ []; [ 1 ] ]);
    subplot h 1 0;
    set_foreground_color h 0 0 0;
    set_background_color h 255 255 255;
    set_xlabel h "y";
    set_ylabel h "z";
    scatter
      ~h
      ~spec
      (Mat.( .${} ) planets [ []; [ 1 ] ])
      (Mat.( .${} ) planets [ []; [ 2 ] ]);
    subplot h 2 0;
    set_foreground_color h 0 0 0;
    set_background_color h 255 255 255;
    set_xlabel h "x";
    set_ylabel h "z";
    scatter
      ~h
      ~spec
      (Mat.( .${} ) planets [ []; [ 0 ] ])
      (Mat.( .${} ) planets [ []; [ 2 ] ])
  done;
  Owl_plplot.Plot.output h;
  let planets, planetvs = !state in
  Printf.printf "%.9f\n" (energy planets planetvs)

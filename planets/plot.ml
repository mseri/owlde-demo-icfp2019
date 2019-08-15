open Jovianplanets
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
      let h = 2.*Float.pi*(float_of_int idx)/(float_of_int n) in
      let s = (90.0 + Random.float 10.)/100. in
      let l = (50.0 + Random.float 10.)/100. in
      let r,g,b =
        hsl_to_rgb h s l 
        |> fun (r,g,b) -> int_of_float (255.0*r), int_of_float (255.0*g), int_of_float (255.0*b)
      in go (Owl_plplot.Plot.RGB (r,g,b) :: acc) Stdlib.(idx-1)
  in go [] (n-1) |> Array.of_list

let scale = n_planets/50
let planets_color = get_colors scale

let () =
  let n = 200 in
  let dt = 0.01 in
  let y0 = (planets, planetvs) in
  let tspec = Owl_ode.Types.T1 {t0=0.0; dt; duration=(float_of_int n)*.dt} in
  let f (planets, _) _ = nbody_owl planets in
  let _, sol_planets, _ = Owl_ode.(Ode.odeint Symplectic.D.leapfrog f y0 tspec ()) in
  let h = Owl_plplot.Plot.create ~n:1 ~m:3 "planets.png" in
  let spec c = Owl_plplot.Plot.[ c; (*MarkerSize 0.5; Marker "."*) LineWidth 0.5 ] in
  let open Owl_plplot.Plot in
  Array.iteri (fun i c ->
      let i = i * scale in
      let spec = spec c in

      subplot h 0 0;
      set_foreground_color h 0 0 0;
      set_background_color h 255 255 255;
      set_xlabel h "x";
      set_ylabel h "y";
      plot
        ~h
        ~spec
        sol_planets.Mat.${[ []; [ 3*i ] ]}
        sol_planets.Mat.${[ []; [ 3*i + 1 ] ]};

      subplot h 1 0;
      set_foreground_color h 0 0 0;
      set_background_color h 255 255 255;
      set_xlabel h "y";
      set_ylabel h "z";
      plot
        ~h
        ~spec
        sol_planets.Mat.${[ []; [ 3*i + 1 ] ]}
        sol_planets.Mat.${[ []; [ 3*i + 2 ] ]};

      subplot h 2 0;
      set_foreground_color h 0 0 0;
      set_background_color h 255 255 255;
      set_xlabel h "x";
      set_ylabel h "z";
      plot
        ~h
        ~spec
        sol_planets.Mat.${[ []; [ 3*i ] ]}
        sol_planets.Mat.${[ []; [ 3*i + 2 ] ]};
    ) planets_color;

  let spec = Owl_plplot.Plot.[ RGB (25, 25, 25); MarkerSize 3.0; Marker "." ] in
  subplot h 0 0;
  set_foreground_color h 0 0 0;
  set_background_color h 255 255 255;
  set_xlabel h "x";
  set_ylabel h "y";
  scatter
    ~h
    ~spec
    sol_planets.Mat.${[ [n-1]; [ 0;-1;3 ] ]}
    sol_planets.Mat.${[ [n-1]; [ 1;-1;3 ] ]};

  subplot h 1 0;
  set_foreground_color h 0 0 0;
  set_background_color h 255 255 255;
  set_xlabel h "y";
  set_ylabel h "z";
  scatter
    ~h
    ~spec
    sol_planets.Mat.${[ [n-1]; [ 1;-1;3 ] ]}
    sol_planets.Mat.${[ [n-1]; [ 2;-1;3 ] ]};

  subplot h 2 0;
  set_foreground_color h 0 0 0;
  set_background_color h 255 255 255;
  set_xlabel h "x";
  set_ylabel h "z";
  scatter
    ~h
    ~spec
    sol_planets.Mat.${[ [n-1]; [ 0;-1;3 ] ]}
    sol_planets.Mat.${[ [n-1]; [ 2;-1;3 ] ]};
  Owl_plplot.Plot.output h;

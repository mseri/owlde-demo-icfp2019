open Js_of_ocaml
module Html = Dom_html

let document = Html.window##.document

let get_by_id id =
  Js.Opt.get
    (document##getElementById (Js.string id))
    (fun () ->
      Firebug.console##error (Js.string @@ "Unable to find id: " ^ id);
      assert false)


let get_by_selector selector =
  Js.Opt.get
    (document##querySelector (Js.string selector))
    (fun () ->
      Firebug.console##error (Js.string @@ "Unable to find selector: " ^ selector);
      assert false)


let plotlv_plotly name ts predator prey =
  let name = Js.string name in
  let ts = Js.array ts in
  let predatorprey =
    object%js
      val mode = Js.string "line"

      val x = Js.array predator

      val y = Js.array prey

      val xaxis = Js.string "x2"

      val yaxis = Js.string "y2"

      val showlegend = Js.bool false
    end
  in
  let predator =
    object%js
      val mode = Js.string "line"

      val x = ts

      val y = Js.array predator

      val name = Js.string "Predator"
    end
  in
  let prey =
    object%js
      val mode = Js.string "line"

      val x = ts

      val y = Js.array prey

      val name = Js.string "Prey"
    end
  in
  let layout =
    object%js
      val xaxis =
        object%js
          val domain = Js.array [| 0.0; 0.7 |]

          val title =
            object%js
              val text = Js.string "Time"
            end
        end

      val yaxis2 =
        object%js
          val anchor = Js.string "x2"

          val title =
            object%js
              val text = Js.string "Prey"
            end
        end

      val xaxis2 =
        object%js
          val domain = Js.array [| 0.75; 1.0 |]

          val title =
            object%js
              val text = Js.string "Predator"
            end
        end
    end
  in
  Js.Unsafe.fun_call
    (Js.Unsafe.js_expr "Plotly.newPlot")
    [| Js.Unsafe.inject name
     ; Js.Unsafe.inject
       @@ Js.array
            [| Js.Unsafe.inject predator
             ; Js.Unsafe.inject prey
             ; Js.Unsafe.inject predatorprey
            |]
     ; Js.Unsafe.inject @@ layout
    |]
  |> ignore


let plotlv_xkcd svg ts predator prey =
  let xkcd_line = Js.Unsafe.variable "chartXkcd.Line" in
  let plot =
    object%js
      val title = Js.string "Prey-Predator system"

      val xlabel = Js.string "Population"

      val ylabel = Js.string "Time"

      val data =
        object%js
          val labels = Js.array ts

          val datasets =
            Js.array
              [| object%js
                   val label = Js.string "Prey"

                   val data = Js.array prey
                 end
               ; object%js
                   val label = Js.string "Predator"

                   val data = Js.array predator
                 end
              |]
        end
    end
  in
  new%js xkcd_line svg plot |> ignore
(*;
  Js.Unsafe.eval_string {|var svg = chartXkcd.d3.select("svg"); var xAxis = d3.svg.axis().ticks(20); svg.select(".x.axis").call(xAxis);|}*)

let redrawer prepare (alpha, beta, gamma, delta) y0 =
  let alpha, beta, gamma, delta = ref alpha, ref beta, ref gamma, ref delta in
  let prey0, predator0 = ref y0.(0), ref y0.(1) in
  let svg = get_by_id "volterralotka-xkcd" in
  let redraw () =
    let ts, predator', prey' =
      prepare (!alpha, !beta, !gamma, !delta) [| !prey0; !predator0 |]
    in
    plotlv_plotly "volterralotka1" ts predator' prey';
    plotlv_xkcd svg ts predator' prey' |> ignore
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
             let needs_redraw =
               try
                 value := float_of_string (Js.to_string input##.value);
                 true
               with
               | Invalid_argument _ -> false
             in
             input##.value := Js.string (string_of_float !value);
             if needs_redraw then redraw ();
             Js._false)
  in
  List.iter
    (fun (n, v) -> assoc v n)
    [ "alpha", alpha
    ; "beta", beta
    ; "gamma", gamma
    ; "delta", delta
    ; "initial_preys", prey0
    ; "initial_predators", predator0
    ];
  redraw ()

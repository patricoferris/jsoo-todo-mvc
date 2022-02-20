open Brr

let onload el v = 
  let onload' _ = 
    let root = Lwd.observe @@ v in
    let on_invalidate _ = 
      ignore @@ G.request_animation_frame @@ fun _ -> ignore (Lwd.quick_sample root)
    in
    Lwd.set_on_invalidate root on_invalidate;
    El.append_children el @@ Lwd.quick_sample root
  in
  ignore (Fut.map onload' Ev.(next load @@ Window.as_target G.window))

let () = 
  match Document.find_el_by_id G.document (Jstr.v "app") with
    | Some el -> onload el (Brr_lwd_app.main ())
    | None -> Console.error [ Jstr.v "No element with an id of 'app'" ]
open Brr
open Brr_lwd
open Let_syntax


(* ~~~ Helpers ~~~ *)



(* A single todo item *)
let todo init = 
  let msg, set_msg = 
    let v = Lwd.var init in 
    v, Lwd.set v
  in
    Elwd.div [ `R (Lwd.map ~f:El.txt' @@ Lwd.get msg) ], set_msg

    (* let input_attr = Vdom.Attr.many [
    Vdom.Attr.class_ "new-todo";
    Vdom.Attr.placeholder "What needs to be done?";
    Vdom.Attr.autofocus true;
    Vdom.Attr.on_keypress (handle_keypress append)
  ] in
  let view = Vdom.Node.div [
    Vdom.Node.header ~attr:(Vdom.Attr.class_ "header") [
      Vdom.Node.h1 [ Vdom.Node.text "todos"];
      Vdom.Node.input ~attr:input_attr []
    ]
  ] in *)

let todo_input, todo_input_state =
  let value = Lwd.var "" in
  let on_keydown ev = 
    if Ev.Keyboard.ctrl_key (Ev.as_type ev) then 
      Lwd.set value "hello"
    else 
      ()
  in
  let input = El.input ~at:[ 
    At.class' (Jstr.v "new-todo");
    At.placeholder (Jstr.v "What's needs to be done?");
    At.autofocus;
  ] () in
  Ev.listen Ev.keydown on_keydown (El.as_target input);
  input, value

let todos =
  let state, set_state =
    let v = Lwd.var 10 in
    v, Lwd.set v
  in
  let* todo_input_state = Lwd.get todo_input_state
  and* size = Lwd.get state in
  let todos = List.init size (fun _ -> fst @@ todo "Hello") in
    Elwd.div [ `P todo_input; `S (Lwd.return @@ Lwd_seq.of_list todos |> Lwd_seq.lift) ]

let main () = 
  let+ main = todos in
  [ main ]


open! Core
open Bonsai_web
open Bonsai.Let_syntax

module Js = Js_of_ocaml.Js

let get_time () : float =
  Js.Unsafe.new_obj Js.date_now [||] |> fun o ->
  Js.Unsafe.meth_call o "getTime" [||]

module Model = struct
  type t = {
    timestamp : float;
    message : string;
    completed : bool;
  }[@@deriving sexp, equal]

  let default () = {
    timestamp = get_time ();
    message = "";
    completed = false;
  }
end

module Action = struct 
  type t =
    | Set_text of string
    | Toggle (* Make completed or not *)
    [@@deriving sexp]
end

let component =
  let%sub todo_state = Bonsai.state_machine0
  [%here]
  (module Model)
  (module Action)
  ~default_model:(Model.default ())
  ~apply_action:
    (fun ~inject:_ ~schedule_event:_ model -> function
       | Action.Toggle -> { model with completed = not (model.completed) }
       | Set_text message -> { model with message })
  in
  return @@
  let%map state, inject = todo_state in
  let completed = 
    if state.completed 
    then Some (Vdom.Attr.class_ "completed") 
    else None
  in
  let set_text s = inject (Action.Set_text s) in
  let input_attr =
    let click = Vdom.Attr.on_click (fun _ -> inject Action.Toggle) in
    Vdom.Attr.(many_without_merge [ class_ "toggle"; type_ "checkbox"; click; on_input (fun _ -> set_text) ])
  in
  (* fun remove_button -> *)
  Vdom.Node.li ?attr:completed [
    Vdom.Node.div ~attr:(Vdom.Attr.class_ "view")
      [ Vdom.Node.input ~attr:(input_attr) []
      ; Vdom.Node.label [ Vdom.Node.text @@ state.message ]
      (* ; remove_button *)
      ]
  ]

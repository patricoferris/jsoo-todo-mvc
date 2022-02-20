open !Core
open !Bonsai_web
open Bonsai.Let_syntax
open Vdom_keyboard

module Id = Int
module Command = Keyboard_event_handler.Command
module Kc = Js_of_ocaml.Dom_html.Keyboard_code

module Model = struct
  type t = {
    todos : Todo.Model.t Id.Map.t;
    filter : [`All | `Completed ];
    size : int;
  }[@@deriving sexp, equal]

  let default = {
    todos = Id.Map.empty;
    filter = `All;
    size = 0;
  }
end

module Action = struct
  type t =
    | Add of string
    | Remove of Id.t [@@deriving sexp, equal]
end

let state = 
  Bonsai.state_machine0
  [%here]
  (module Model)
  (module Action)
  ~default_model:Model.default
  ~apply_action:(fun ~inject:_ ~schedule_event:_ model -> function
    | Add message ->
      let todo = 
        let def = Todo.Model.default () in
        { def with message }
      in
      let todos = Id.Map.add_exn model.todos ~key:model.size ~data:todo in 
      { model with todos; size = model.size + 1}
    | Remove id -> 
      let todos = Id.Map.remove model.todos id in
      { model with todos; size = model.size - 1})

let handle_keypress append =
  let keyboard_handler =
    Keyboard_event_handler.of_command_list_exn [
        { Command.keys = [ Keystroke.create' Kc.Enter ]
        ; description = "enter"
        ; group = None
        ; handler = (fun e -> Ui_effect.all_unit [ append ])
        }
      ]
  in
  fun event ->
    match Keyboard_event_handler.handle_event keyboard_handler event with
    | Some event -> event
    | None -> Ui_effect.return ()

let todo_input = 
  let open Bonsai.Let_syntax in
  let handle_input = 
    Value.return (fun (txt, set) -> set "")
  in
  let%sub textbox_state =
    Bonsai.state_machine0
      [%here]
      (module String)
      (module String)
      ~default_model:""
      ~apply_action:(fun ~inject:_ ~schedule_event:_ _ new_state -> new_state)
  in
  return (handle_input <*> textbox_state)

let component =
  let _wrap_remove view remove_event =
    let remove_button = 
      Vdom.Node.button
          ~attr:(Vdom.Attr.many [ 
            Vdom.Attr.on_click (fun _ -> remove_event);
            Vdom.Attr.class_ "destroy"
          ])
          []
    in
    view remove_button
  in
  let%sub model, inject = state in
  return @@
  let%map inject = inject
  and model = model in

  (* let todos = Map.data model.todos in *)
  let append = inject (Action.Add "Hello World") in
  let input_attr = Vdom.Attr.many [
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
  ] in
  model.todos, view
open! Core
open! Bonsai_web
open Bonsai.Let_syntax
open Vdom_keyboard
module Id = Int
module Command = Keyboard_event_handler.Command
module Kc = Js_of_ocaml.Dom_html.Keyboard_code

type todo = { message : string; completed : bool } [@@deriving sexp, equal]

let is_complete t = t.completed
let default_todo () = { message = "Hello World!"; completed = false }

module Model = struct
  type filter = [ `All | `Active | `Completed ] [@@deriving sexp, equal]

  type t = { new_todo : string; todos : todo Id.Map.t; filter : filter }
  [@@deriving sexp, equal]

  let default = { new_todo = ""; todos = Id.Map.empty; filter = `All }
end

module Action = struct
  type t =
    | Append
    | Set_text of string
    | Set_filter of Model.filter
    | Toggle of Id.t
    | Remove of Id.t
    | Clear_completed
    | Toggle_all
  [@@deriving sexp, equal]
end

module Todo = struct
  let component ~inject (id : Id.t Value.t) (todo : todo Value.t) =
    return
    @@ let%map state = todo and inject = inject and id = id in
       let completed =
         if state.completed then Some (Vdom.Attr.class_ "completed") else None
       in
       let _set_text s = inject (Action.Set_text s) in
       let remove_me _ = inject (Action.Remove id) in
       let input_attr =
         let click = Vdom.Attr.on_click (fun _ -> inject (Action.Toggle id)) in
         Vdom.Attr.(
           many
             [
               class_ "toggle";
               type_ "checkbox";
               click;
               (if is_complete state then
                Vdom.Attr.string_property "checked" "checked"
               else empty);
             ])
       in
       Vdom.Node.li ?attr:completed
         [
           Vdom.Node.div ~attr:(Vdom.Attr.class_ "view")
             [
               Vdom.Node.input ~attr:input_attr [];
               Vdom.Node.label [ Vdom.Node.text @@ state.message ];
               Vdom.Node.button
                 ~attr:
                   (Vdom.Attr.many
                      [
                        Vdom.Attr.class_ "destroy"; Vdom.Attr.on_click remove_me;
                      ])
                 [];
             ];
         ]
end

let apply_filter todos = function
  | `All -> todos
  | `Completed -> Map.filter ~f:is_complete todos
  | `Active -> Map.filter ~f:(Fun.negate is_complete) todos

let state =
  Bonsai.state_machine0 [%here]
    (module Model)
    (module Action)
    ~default_model:Model.default
    ~apply_action:
      (fun ~inject:_ ~schedule_event:_ model -> function
        | Toggle id ->
            {
              model with
              todos =
                Map.change model.todos id ~f:(function
                  | Some todo ->
                      Some { todo with completed = not todo.completed }
                  | None -> None);
            }
        | Set_text txt -> { model with new_todo = txt }
        | Append ->
            let data =
              let def = default_todo () in
              { def with message = model.new_todo }
            in
            let key =
              match Map.max_elt model.todos with
              | Some (key, _) -> key + 1
              | None -> 0
            in
            let todos = Map.add_exn model.todos ~key ~data in
            { model with todos }
        | Remove id ->
            let todos = Map.remove model.todos id in
            { model with todos }
        | Toggle_all ->
            let all_complete = Map.for_all ~f:is_complete model.todos in
            let todos =
              if all_complete then
                Map.map ~f:(fun v -> { v with completed = false }) model.todos
              else Map.map ~f:(fun v -> { v with completed = true }) model.todos
            in
            { model with todos }
        | Clear_completed ->
            let todos = Map.filter ~f:(Fun.negate is_complete) model.todos in
            { model with todos }
        | Set_filter filter -> { model with filter })

let handle_keypress append =
  let keyboard_handler =
    Keyboard_event_handler.of_command_list_exn
      [
        {
          Command.keys = [ Keystroke.create' Kc.Enter ];
          description = "enter";
          group = None;
          handler = (fun _e -> append);
        };
      ]
  in
  fun event ->
    match Keyboard_event_handler.handle_event keyboard_handler event with
    | Some event -> event
    | None -> Ui_effect.return ()

let component =
  let%sub model, inject = state in
  return
  @@ let%map inject = inject and model = model in
     let append = inject Action.Append in
     let set_text t = inject (Action.Set_text t) in
     let input_attr =
       Vdom.Attr.many_without_merge
         [
           Vdom.Attr.class_ "new-todo";
           Vdom.Attr.placeholder "What needs to be done?";
           Vdom.Attr.autofocus true;
           Vdom.Attr.on_change (fun _ -> set_text);
           Vdom.Attr.on_input (fun _ -> set_text);
           Vdom.Attr.on_keypress (fun k ->
               Ui_effect.bind ~f:(fun () -> set_text "")
               @@ handle_keypress append k);
         ]
     in
     let view =
       Vdom.Node.div
         [
           Vdom.Node.header
             ~attr:(Vdom.Attr.class_ "header")
             [
               Vdom.Node.h1 [ Vdom.Node.text "todos" ];
               Vdom.Node.input ~attr:input_attr
                 [ Vdom.Node.text model.new_todo ];
             ];
         ]
     in
     ((inject, model), view)

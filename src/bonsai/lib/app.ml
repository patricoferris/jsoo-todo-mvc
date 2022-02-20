open !Core
open !Bonsai_web
open Bonsai.Let_syntax
open Vdom_keyboard

module Extendy = Bonsai_web_ui_extendy
module Js = Js_of_ocaml.Js
module Command = Keyboard_event_handler.Command
module Kc = Js_of_ocaml.Dom_html.Keyboard_code

let todo_input = 
  let open Bonsai.Let_syntax in
  let handle_input = 
    Value.return (fun s -> s)
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

let application =
  let open Bonsai.Let_syntax in
  let%sub todos, add_button = Todos.component in
  let%sub todos = Bonsai.assoc (module Int) todos ~f:(fun _ _ -> Todo.component) in
  return
  @@ let%map add_button = add_button 
  and todos = todos in
  Vdom.Node.div [ 
    add_button;
    Vdom.Node.section ~attr:(Vdom.Attr.class_ "main") [
      Vdom.Node.input ~attr:(Vdom.Attr.(many_without_merge [ id "toggle-all"; class_ "toggle-all"; type_ "checkbox"])) [];
      Vdom.Node.label ~attr:(Vdom.Attr.for_ "toggle-all") [ Vdom.Node.text "Mark all as complete" ];
      Vdom.Node.ul ~attr:(Vdom.Attr.class_ "todo-list") (Map.data todos)
    ]
  ]


open! Core
open! Bonsai_web
open Bonsai.Let_syntax
open Vdom_keyboard
module Js = Js_of_ocaml.Js
module Command = Keyboard_event_handler.Command
module Kc = Js_of_ocaml.Dom_html.Keyboard_code

let footer inject filter (todos : Todos.todo list) =
  let any_completed = List.exists ~f:Todos.is_complete todos in
  let how_many_left = function
    | 1 -> "1 item left"
    | n -> string_of_int n ^ " items left"
  in
  let selected b = if b then Vdom.Attr.class_ "selected" else Vdom.Attr.empty in
  let view =
    Vdom.Node.footer
      ~attr:(Vdom.Attr.class_ "footer")
      ([
         Vdom.Node.span
           ~attr:(Vdom.Attr.class_ "todo-count")
           [
             Vdom.Node.text
             @@ how_many_left
                  (List.count ~f:(fun t -> not (Todos.is_complete t)) todos);
           ];
         Vdom.Node.ul
           ~attr:(Vdom.Attr.class_ "filters")
           [
             Vdom.Node.li
               [
                 Vdom.Node.a
                   ~attr:
                     (Vdom.Attr.many_without_merge
                        [
                          selected (Caml.( = ) filter `All);
                          Vdom.Attr.on_click (fun _ ->
                              inject (Todos.Action.Set_filter `All));
                        ])
                   [ Vdom.Node.text "All" ];
               ];
             Vdom.Node.li
               [
                 Vdom.Node.a
                   ~attr:
                     (Vdom.Attr.many_without_merge
                        [
                          selected (Caml.( = ) filter `Active);
                          Vdom.Attr.on_click (fun _ ->
                              inject (Todos.Action.Set_filter `Active));
                        ])
                   [ Vdom.Node.text "Active" ];
               ];
             Vdom.Node.li
               [
                 Vdom.Node.a
                   ~attr:
                     (Vdom.Attr.many_without_merge
                        [
                          selected (Caml.( = ) filter `Completed);
                          Vdom.Attr.on_click (fun _ ->
                              inject (Todos.Action.Set_filter `Completed));
                        ])
                   [ Vdom.Node.text "Completed" ];
               ];
           ];
       ]
      @
      if any_completed then
        [
          Vdom.Node.button
            ~attr:
              Vdom.Attr.(
                many_without_merge
                  [
                    class_ "clear-completed";
                    on_click (fun _ -> inject Todos.Action.Clear_completed);
                  ])
            [ Vdom.Node.text "Clear Completed" ];
        ]
      else [])
  in
  view

let application =
  let%sub (inject, model), add_button = Todos.component in
  let filtered_todos =
    Value.map
      ~f:(fun model -> Todos.apply_filter model.todos model.filter)
      model
  in
  let%sub vtodos =
    Bonsai.assoc (module Int) filtered_todos ~f:(Todos.Todo.component ~inject)
  in
  return
  @@ let%map add_button = add_button
     and vtodos = vtodos
     and model = model
     and inject = inject in
     Vdom.Node.div
       [
         add_button;
         Vdom.Node.section ~attr:(Vdom.Attr.class_ "main")
           [
             Vdom.Node.input
               ~attr:
                 Vdom.Attr.(
                   many
                     [
                       id "toggle-all";
                       class_ "toggle-all";
                       type_ "checkbox";
                       on_click (fun _ -> inject Todos.Action.Toggle_all);
                     ])
               [];
             Vdom.Node.label
               ~attr:(Vdom.Attr.for_ "toggle-all")
               [ Vdom.Node.text "Mark all as complete" ];
             Vdom.Node.ul ~attr:(Vdom.Attr.class_ "todo-list") (Map.data vtodos);
           ];
         footer inject model.filter (Map.data model.todos);
       ]

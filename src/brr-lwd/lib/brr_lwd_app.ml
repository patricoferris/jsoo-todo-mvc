open Brr
open Brr_lwd
open Let_syntax

let use_state a =
  let a = Lwd.var a in
  (a, fun f -> Lwd.set a (f (Lwd.peek a)))

type todo = { message : string; completed : bool }

let is_complete { completed; _ } = completed

let todo ~id ~toggle ~remove t =
  let input_attr =
    At.add_if t.completed
      (At.v (Jstr.v "checked") (Jstr.v "checked"))
      At.[ class' (Jstr.v "toggle"); type' (Jstr.v "checkbox") ]
  in
  let remove_button = El.button ~at:[ At.class' (Jstr.v "destroy") ] [] in
  Ev.listen Ev.click (fun _ -> remove id) (El.as_target remove_button);
  let text =
    El.div
      ~at:[ At.class' (Jstr.v "view") ]
      [
        El.input ~at:input_attr ();
        El.label [ El.txt' t.message ];
        remove_button;
      ]
  in
  let at =
    if t.completed then [ At.class' (Jstr.v "completed") ]
    else [ At.class' (Jstr.v "not-completed") ]
  in
  let li = El.li ~at [ text ] in
  Ev.listen Ev.click (fun _ -> toggle id) (El.as_target li);
  li

module Todo_map = Map.Make (Int)

type t = { new_todo : string; todos : todo Todo_map.t }

let default () = { new_todo = ""; todos = Todo_map.empty }

let todo_input t add_todo remove_item =
  let on_keydown ev =
    let k_ev = Ev.as_type ev in
    if Ev.Keyboard.code k_ev = Jstr.v "Enter" then
      let message =
        Ev.target ev |> Ev.target_to_jv |> fun t -> Jv.get t "value"
      in
      add_todo (Jv.to_string message)
    else ()
  in
  let+ t
  and+ input =
    Elwd.input
      ~at:
        [
          `P (At.class' (Jstr.v "new-todo"));
          `P (At.placeholder (Jstr.v "What's needs to be done?"));
          `P At.autofocus;
        ]
      ()
  in
  Ev.listen Ev.keydown on_keydown (El.as_target input);
  input

let count f t =
  let rec loop acc = function
    | [] -> acc
    | x :: xs when f x -> loop (acc + 1) xs
    | x :: xs -> loop acc xs
  in
  loop 0 t

let footer ~clear_completed todos =
  let any_completed = List.exists is_complete todos in
  let how_many_left = function
    | 1 -> Jstr.v "1 item left"
    | n -> Jstr.v @@ string_of_int n ^ " items left"
  in
  El.footer
    ~at:[ At.class' (Jstr.v "footer") ]
    ([
       El.span
         ~at:[ At.class' (Jstr.v "todo-count") ]
         [ El.txt @@ how_many_left (count (Fun.negate is_complete) todos) ];
       El.ul
         ~at:[ At.class' (Jstr.v "filters") ]
         [
           El.li [ El.a [ El.txt' "All" ] ];
           El.li [ El.a [ El.txt' "Active" ] ];
           El.li [ El.a [ El.txt' "Completed" ] ];
         ];
     ]
    @
    let clear el =
      Ev.listen Ev.click (fun _ -> clear_completed ()) (El.as_target el)
    in
    if any_completed then
      [
        (let b =
           El.button
             ~at:[ At.class' (Jstr.v "clear-completed") ]
             [ El.txt' "Clear Completed" ]
         in
         clear b;
         b);
      ]
    else [])

let todos =
  let uid, incr_uid =
    let uid = ref (-1) in
    (uid, fun () -> incr uid)
  in
  let items, add_item, remove_item, toggle, clear_completed =
    let items, set = use_state @@ default () in
    let add_item message =
      incr_uid ();
      set (fun t ->
          {
            t with
            todos = Todo_map.add !uid { message; completed = false } t.todos;
          })
    in
    let remove_item id =
      set (fun t -> { t with todos = Todo_map.remove id t.todos })
    in
    let toggle id =
      set (fun t ->
          {
            t with
            todos =
              Todo_map.update id
                (function
                  | Some t -> Some { t with completed = not t.completed }
                  | _ -> None)
                t.todos;
          })
    in
    let clear_completed () =
      set (fun t ->
          {
            t with
            todos =
              Todo_map.filter (fun _ v -> Fun.negate is_complete @@ v) t.todos;
          })
    in
    (items, add_item, remove_item, toggle, clear_completed)
  in
  let ti = todo_input (Lwd.get items) add_item remove_item in
  let header = Elwd.header [ `P (El.h1 [ El.txt' "todos" ]); `R ti ] in
  let todos_list =
    let items =
      let+ t = Lwd.get items in
      Todo_map.bindings t.todos |> List.rev |> Lwd_seq.of_list
    in
    Elwd.ul
      ~at:[ `P (At.class' (Jstr.v "todo-list")) ]
      [
        `S
          (Lwd_seq.map
             (fun (id, v) -> todo ~id ~toggle ~remove:remove_item v)
             items);
      ]
  in
  let footer =
    let+ t = Lwd.get items in
    footer ~clear_completed (Todo_map.bindings t.todos |> List.map snd)
  in
  Elwd.section
    ~at:[ `P (At.class' (Jstr.v "main")) ]
    [ `R header; `R todos_list; `R footer ]

let main () =
  let+ main = todos in
  [ main ]

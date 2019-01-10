open Swift
open Str
open Unix

type node =
  { id    : int
  ; label : string
  }

type edge =
  { node_from_id : int
  ; node_to_id   : int
  }

type swift_type =
  { name            : string
  ; inherited_types : string list
  ; types_in_body   : string list
  }

let tokenize file_path =
  let input = open_in file_path in
  let tokens = Parser.main Lexer.lex (Lexing.from_channel input) in
  close_in input;
  tokens

let rec sort list =
  match list with
  | [] ->
    []
  | element :: tl ->
    insert element (sort tl)
and insert element_to_insert list =
  match list with
  | [] ->
    [element_to_insert]
  | element :: tl ->
    if element_to_insert < element then
      element_to_insert :: element :: tl
    else
      element :: insert element_to_insert tl

let read_file file_path =
  let rec read_file_aux channel lines =
    try
      let line = input_line channel in
      read_file_aux channel (line :: lines)
    with
    | End_of_file ->
      close_in channel;
      List.rev lines in
  let channel = open_in file_path in
  read_file_aux channel []

let rec find_type_declaration tokens =
  match tokens with
  | Protocol :: Type name :: tl
  | Class :: Type name :: tl
  | Extension :: Type name :: tl
  | Enum :: Type name :: tl
  | Struct :: Type name :: tl ->
    Some (name, tl)
  | _ :: tl ->
    find_type_declaration tl
  | [] ->
    None

let find_inherited_types tokens =
  let rec find_inherited_types_aux tokens inherited_types =
    match tokens with
    | OpenCurlyBrace :: tl ->
      (inherited_types, tokens)
    | token :: tl ->
      begin
        match token with
        | Type name ->
          find_inherited_types_aux tl (name :: inherited_types)
        | _ ->
          find_inherited_types_aux tl inherited_types
      end
    | [] ->
      (inherited_types, [])
  in
  find_inherited_types_aux tokens []

exception Curly_braces_mismatch
let find_types_in_type_body tokens =
  let rec find_types_in_type_body_aux tokens level found_types =
    match tokens with
    | Type name :: tl ->
      find_types_in_type_body_aux tl level (name :: found_types)
    | OpenCurlyBrace :: tl ->
      find_types_in_type_body_aux tl (level + 1) found_types
    | CloseCurlyBrace :: tl ->
      let new_level = level - 1 in
      if new_level = 0 then
        (List.rev found_types, tl)
      else
        find_types_in_type_body_aux tl new_level found_types
    | _ :: tl ->
      find_types_in_type_body_aux tl level found_types
    | [] ->
      raise Curly_braces_mismatch
  in
  find_types_in_type_body_aux tokens 0 []

let find_dependencies tokens swift_types_to_ignore =
  let rec find_dependencies_aux tokens swift_types =
    match find_type_declaration tokens with
    | Some (type_name, tokens_tl) ->
      if List.mem type_name swift_types_to_ignore then
        find_dependencies_aux tokens_tl swift_types
      else        
        let (inherited_types, tokens_tl) = find_inherited_types tokens_tl in
        let (types_in_type_body, tokens_tl) = find_types_in_type_body tokens_tl in
        let inherited_types =
          List.filter
            (fun swift_type -> not (List.mem swift_type swift_types_to_ignore))
            inherited_types in
        let types_in_type_body =
          List.filter
            (fun swift_type -> not (List.mem swift_type swift_types_to_ignore))
            types_in_type_body in
        let swift_type = { name=type_name
                         ; inherited_types=inherited_types
                         ; types_in_body=types_in_type_body
                         } in
        find_dependencies_aux tokens_tl (swift_type :: swift_types)
    | None ->
      swift_types
  in
  find_dependencies_aux tokens []

(* Foo.Bar.Buzz -> Foo *)
let reduce_type_tokens tokens =
  let rec reduce_type_tokens_aux tokens reduced_tokens =
    match tokens with
    | Dot :: Type _ :: tl ->
      reduce_type_tokens_aux tl reduced_tokens
    | token :: tl ->
      reduce_type_tokens_aux tl (token :: reduced_tokens)
    | [] ->
      List.rev reduced_tokens
  in
  reduce_type_tokens_aux tokens []

let walk_directory_tree dir pattern =
  let tests_regexp = Str.regexp ".+Tests\\.swift" in
  let re = Str.regexp pattern in
  let file_path_matches_pattern str = Str.string_match re str 0 in
  let rec walk acc = function
  | [] ->
    acc
  | dir :: tl ->
    let contents = Array.to_list (Sys.readdir dir) in
    let contents =
      List.filter
        (
          fun name ->
            if Str.string_match tests_regexp name 0 then
              false
            else
              name <> "Pods" && name <> ".git"
        )
        contents in
    let contents = List.rev_map (Filename.concat dir) contents in
    let dirs, files =
      List.fold_left
        (
          fun (dirs, files) f ->
            match (Unix.stat f).st_kind with
            | S_REG ->
              (dirs, f :: files)
            | S_DIR ->
              (f :: dirs, files)
            | _ ->
              (dirs, files)
        )
        ([], [])
        contents in
    let matched = List.filter file_path_matches_pattern files in
    walk (matched @ acc) (dirs @ tl)
  in
  walk [] [dir]

let remove_duplicates list =
  let rec remove_duplicates_aux in_list out_list =
    match in_list with
    | element :: tl ->
      if List.mem element out_list then
        remove_duplicates_aux tl out_list
      else
        remove_duplicates_aux tl (element :: out_list)
    | [] ->
      List.rev out_list
  in
  remove_duplicates_aux list []

let rec find_node label nodes =
  match nodes with
  | node :: tl ->
    if node.label = label then
      Some node
    else
      find_node label tl
  | [] ->
    None

let find_nodes labels nodes =
  let rec find_nodes_aux labels found_nodes =
    match labels with
    | label :: tl ->
      begin
        match find_node label nodes with
        | Some found_node ->
          find_nodes_aux tl (found_node :: found_nodes)
        | None ->
          find_nodes_aux tl found_nodes
      end
    | [] ->
      List.rev found_nodes
  in
  find_nodes_aux labels []

let edges_of_swift_types_in_file swift_types_in_file
                                 nodes
                                 get_related_types =
  List.map
    (
      fun swift_type ->
        match find_node swift_type.name nodes with
        | Some from_node ->
          let related_types = get_related_types swift_type in
          let label_nodes = find_nodes related_types nodes in
          List.map
            (
              fun label_node ->
                { node_from_id=from_node.id
                ; node_to_id=label_node.id
                }
            )
            label_nodes
        | None ->
          []
    )
    swift_types_in_file

let get_nodes swift_types_in_files =
  let node_labels =
    List.map
      (
        fun swift_types_in_file ->
          List.map (fun swift_type -> swift_type.name) swift_types_in_file
      )
      swift_types_in_files
    |> List.flatten |> remove_duplicates |> sort in
  List.mapi (fun index label -> { id=index; label=label }) node_labels

let print_nodes output_channel nodes graph_name node_default_color =
  let js_nodes =
    List.map
      (
        fun node ->
          Printf.sprintf
            "  { id: %d, label: '%s', shape: 'dot', size: 14, color: '%s' }"
            node.id node.label node_default_color
      )
      nodes in
  Printf.fprintf
    output_channel
    "var %sNodes = [\n%s\n];\n"
    graph_name (String.concat ",\n" js_nodes)

let print_edges output_channel
                nodes
                swift_types_in_files
                graph_name
                get_related_types =
  let edges =
    List.map
      (
        fun swift_types_in_file ->
          edges_of_swift_types_in_file
            swift_types_in_file
            nodes
            get_related_types
      )
      swift_types_in_files
    |> List.flatten |> List.flatten in
  let js_edges =
    List.map
      (
        fun edge ->
          Printf.sprintf
            "  { from: %d, to: %d, arrows: 'to' }"
            edge.node_from_id edge.node_to_id
      )
      edges in
  Printf.fprintf
    output_channel
    "var %sEdges = [\n%s\n];\n"
    graph_name (String.concat ",\n" js_edges)

let () =
  try
    let folder_path = Sys.argv.(1) in
    let swift_file_paths = walk_directory_tree folder_path ".*\\.swift" in
    let swift_types_to_ignore = read_file "types_to_ignore.txt" in
    let swift_types_in_files =
      List.map
        (
          fun file_path ->
            try
              let tokens = file_path |> tokenize |> reduce_type_tokens in
              find_dependencies tokens swift_types_to_ignore
            with
            | _ ->
              print_endline ("Failed to parse: " ^ file_path);
              exit 0
        )
        swift_file_paths in
    let output_channel = open_out "./data.js" in
    let node_default_color = "0FC3FF" in
    Printf.fprintf
      output_channel
      "var nodeDefaultColor = '%s';\n"
      node_default_color;
    Printf.fprintf output_channel "var nodeSelectedColor = 'FF2700';\n";
    let nodes = get_nodes swift_types_in_files in
    print_nodes output_channel nodes "inherited" node_default_color;
    print_edges
      output_channel
      nodes
      swift_types_in_files
      "inherited"
      (fun swift_type -> swift_type.inherited_types);
    print_nodes output_channel nodes "typesInBody" node_default_color;
    print_edges
      output_channel
      nodes
      swift_types_in_files
      "typesInBody"
      (fun swift_type -> swift_type.types_in_body);
    close_out output_channel
  with
  | Invalid_argument _ ->
    print_endline "Expected folder path as argument"

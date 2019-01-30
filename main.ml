open Swift
open Str
open Unix
open Graph
open Utils

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

let edges_of_swift_types_in_file swift_types_in_file nodes get_related_types =
  List.map
    (
      fun swift_type ->
        match find_node_by_label swift_type.name nodes with
        | Some from_node ->
          let related_types = get_related_types swift_type in
          let label_nodes = find_nodes_by_labels related_types nodes in
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

let get_edges nodes swift_types_in_files get_related_types =
  List.map
    (
      fun swift_types_in_file ->
        edges_of_swift_types_in_file swift_types_in_file nodes get_related_types
    )
    swift_types_in_files
  |> List.flatten |> List.flatten

let js_node_str_of_node node node_color =
  Printf.sprintf
    "{ id: '%d', label: '%s', shape: 'dot', size: 14, color: '%s' }"
    node.id
    node.label
    node_color

let js_edge_str_of_edge edge =
  Printf.sprintf
    "{ id: '%s', from: %d, to: %d, arrows: 'to' }"
    (get_edge_id edge)
    edge.node_from_id
    edge.node_to_id

let print_nodes output_channel nodes node_color =
  let js_node_strs =
    List.map (fun node -> js_node_str_of_node node node_color) nodes in
  let js_nodes_str = (String.concat ",\n" js_node_strs) in
  Printf.fprintf output_channel "var nodes = [\n%s\n];" js_nodes_str

let print_edges output_channel edges =
  let js_edge_strs = List.map (fun edge -> js_edge_str_of_edge edge) edges in
  let js_edges_str = (String.concat ",\n" js_edge_strs) in
  Printf.fprintf output_channel "[\n%s\n]" js_edges_str

let find_subgraph graph root_node_id =
  let connected_nodes = find_connected_nodes root_node_id graph in
  let connected_edges =
    List.map
      (fun node -> find_edges node.id graph.edges)
      connected_nodes
  |> List.flatten |> remove_duplicates in
  let node_ids = List.map (fun node -> node.id) connected_nodes in
  let edge_ids = List.map get_edge_id connected_edges in
  { node_ids=node_ids; edge_ids=edge_ids }

let print_subgraphs output_channel graph =
  List.iteri
    (
      fun index node ->
        let step_str =
          Printf.sprintf
            "%d/%d %s"
            index
            (List.length graph.nodes)
            node.label in
        print_endline step_str;
        let subgraph = find_subgraph graph node.id in
        let node_id_strs = 
          List.map
            (fun node_id -> Printf.sprintf "'%d'" node_id)
            subgraph.node_ids in
        let edge_id_strs = 
          List.map
            (fun edge_id -> Printf.sprintf "'%s'" edge_id)
            subgraph.edge_ids in
        let node_ids_str = String.concat ", " node_id_strs in
        let edge_ids_str = String.concat ", " edge_id_strs in
        Printf.fprintf
          output_channel
          "\"%s\": {\nnodeIds: [%s],\nedgeIds: [%s]\n}"
          node.label
          node_ids_str
          edge_ids_str;
        if index < List.length graph.nodes - 1 then
          Printf.fprintf output_channel ",\n"
        else
          ()
    )
    graph.nodes

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
    print_nodes output_channel nodes node_default_color;
    Printf.fprintf output_channel "\nvar graphs = [\n";
    (* usage graph *)
    let usage_edges =
      get_edges
        nodes
        swift_types_in_files
        (fun swift_type -> swift_type.types_in_body)
      |> remove_duplicates in
    let usage_graph = { nodes=nodes; edges=usage_edges } in
    Printf.fprintf output_channel "{\nname: \"Usage\",\nedges: ";
    print_edges output_channel usage_edges;
    Printf.fprintf output_channel ",\nsubgraphs: {\n";
    print_subgraphs output_channel usage_graph;
    Printf.fprintf output_channel "\n}\n}";
    (* inheritance graph *)
    let inheritance_edges =
      get_edges
        nodes
        swift_types_in_files
        (fun swift_type -> swift_type.inherited_types)
      |> remove_duplicates in
    let inheritance_graph = { nodes=nodes; edges=inheritance_edges } in
    Printf.fprintf output_channel ",\n{\nname: \"Inheritance\",\nedges: ";
    print_edges output_channel inheritance_edges;
    Printf.fprintf output_channel ",\nsubgraphs: {\n";
    print_subgraphs output_channel inheritance_graph;
    Printf.fprintf output_channel "\n}\n}";
    Printf.fprintf output_channel "\n];";
    close_out output_channel
  with
  | Invalid_argument _ ->
    print_endline "Expected folder path as argument"

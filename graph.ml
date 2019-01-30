open Utils

type node =
  { id    : int
  ; label : string
  }

type edge =
  { node_from_id : int
  ; node_to_id   : int
  }

type graph =
  { nodes: node list
  ; edges: edge list
  }

type subgraph =
  { node_ids: int list
  ; edge_ids: string list
  }

let get_edge_id edge =
  Printf.sprintf "%d-%d" edge.node_from_id edge.node_to_id

let get_child_node_ids node_ids graph =
  List.map
    (
      fun node_id ->
        let node_edges =
          List.filter
            (
              fun edge ->
                edge.node_from_id = node_id && edge.node_to_id != node_id
            )
            graph.edges in
        List.map (fun edge -> edge.node_to_id) node_edges
    )
    node_ids
  |> List.flatten |> remove_duplicates

let rec find_node_by_id node_id nodes =
  match nodes with
  | node :: tl ->
    if node.id = node_id then
      Some node
    else
      find_node_by_id node_id tl
  | [] ->
    None

let find_edges node_from_id edges =
  let rec find_edges_aux edges found_edges =
    match edges with
    | edge :: tl ->
      if edge.node_from_id = node_from_id then
        find_edges_aux tl (edge :: found_edges)
      else
        find_edges_aux tl found_edges
    | [] ->
      List.rev found_edges
  in
  find_edges_aux edges []

let find_connected_nodes root_node_id graph =
  let rec find_connected_node_ids node_ids connected_node_ids =
    let child_node_ids = get_child_node_ids node_ids graph in
    let unique_node_ids = find_unique child_node_ids connected_node_ids in
    if List.length unique_node_ids > 0 then
      find_connected_node_ids
        unique_node_ids
        (connected_node_ids @ unique_node_ids)
    else
      connected_node_ids
  in
  let connected_node_ids =
    find_connected_node_ids [root_node_id] [root_node_id] in
  List.map
    (fun node_id -> find_node_by_id node_id graph.nodes)
    connected_node_ids
  |> unwrap_optionals

(* let find_edges node_ids graph =
  let rec find_edges_aux node_ids edges =
    List.map (fun node_id -> )
  in
  find_edges_aux node_ids [] *)

let rec find_node_by_label label nodes =
  match nodes with
  | node :: tl ->
    if node.label = label then
      Some node
    else
      find_node_by_label label tl
  | [] ->
    None

let find_nodes_by_labels labels nodes =
  let rec find_nodes_aux labels found_nodes =
    match labels with
    | label :: tl ->
      begin
        match find_node_by_label label nodes with
        | Some found_node ->
          find_nodes_aux tl (found_node :: found_nodes)
        | None ->
          find_nodes_aux tl found_nodes
      end
    | [] ->
      List.rev found_nodes
  in
  find_nodes_aux labels []
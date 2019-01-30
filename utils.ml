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

let count element list =
  let rec count_aux list n =
    match list with
    | hd :: tl ->
      if hd = element then
        count_aux tl (n + 1)
      else
        count_aux tl n
    | [] ->
      n in
  count_aux list 0

let remove_duplicates list =
  let rec remove_duplicates_aux list new_list =
    match list with
    | hd :: tl ->
      if count hd new_list = 0 then
        remove_duplicates_aux tl (hd :: new_list)
      else
        remove_duplicates_aux tl new_list
    | [] ->
      List.rev new_list in
  remove_duplicates_aux list []

let find_unique src_list dst_list =
  let rec find_unique_aux src_list unique_src_sublist =
    match src_list with
    | hd :: tl ->
      if List.mem hd dst_list then
        find_unique_aux tl unique_src_sublist
      else
        find_unique_aux tl (hd :: unique_src_sublist)
    | [] ->
      List.rev unique_src_sublist in
  find_unique_aux src_list []

let unwrap_optionals in_list =
  let rec unwrap_optionals_aux in_list out_list =
    match in_list with
    | hd :: tl ->
      begin
        match hd with
        | Some x ->
          unwrap_optionals_aux tl (x :: out_list)
        | None ->
          unwrap_optionals_aux tl out_list
      end
    | [] ->
      List.rev out_list
  in
  unwrap_optionals_aux in_list []

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

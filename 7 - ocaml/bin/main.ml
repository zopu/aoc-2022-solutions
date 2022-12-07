open Str

type parsed_line =
  | LS
  | CD_TOP
  | CD_UP
  | CD of string
  | DIR of string
  | FILE_SIZE of int

(* ---- Parsing ---- *)

let _parsed_line_to_string (t : parsed_line) : string =
  match t with
  | LS -> "ls"
  | CD_TOP -> "cd /"
  | CD_UP -> "cd .."
  | CD dir -> "cd " ^ dir
  | DIR dir -> "dir " ^ dir
  | FILE_SIZE i -> "<filesize> " ^ string_of_int i

let read_lines (file : string) : string list =
  let lines = ref [] in
  let chan = open_in file in
  try
    while true do
      lines := input_line chan :: !lines
    done;
    []
  with End_of_file ->
    close_in chan;
    List.rev !lines

exception ParseException

let parse_command (cmd_line : string) : parsed_line =
  match cmd_line with
  | "cd /" -> CD_TOP
  | "cd .." -> CD_UP
  | "ls" -> LS
  | _ ->
      if String.sub cmd_line 0 3 = "cd " then
        CD (String.sub cmd_line 3 (String.length cmd_line - 3))
      else raise ParseException

let parse_int_start (s : string) =
  if string_match (regexp "[0-9]+") s 0 then int_of_string (matched_string s)
  else raise ParseException

let parse_line (line : string) : parsed_line =
  if String.get line 0 == '$' then
    parse_command (String.sub line 2 (String.length line - 2))
  else if String.sub line 0 4 = "dir " then
    DIR (String.sub line 4 (String.length line - 4))
  else FILE_SIZE (parse_int_start line)

(* ---- Handy types for processing the parsed file ---- *)

type location =
  string list (* stack representing e.g. ["mikeperrow", "Users", "/"] *)

(* dir_size represents the size of a directory, but in practice is used in intermeddiate
   computations to represent some contribution towards the directory's size coming
   from an individual file or subdir *)
type dir_size = { location : location; size : int }

let _loc_to_string (l : location) =
  List.fold_right (fun subdir line -> line ^ "/" ^ subdir) l ""

let _dirsize_to_string (ds : dir_size) =
  _loc_to_string ds.location ^ ":" ^ string_of_int ds.size

let rec parents (l : location) =
  match l with [] -> [] | l -> l :: parents (List.tl l)

type state = { location : location; dir_sizes : dir_size list }

(* ---- Actually processing the parsed file ---- *)

let process_line (st : state) (line : string) =
  match parse_line line with
  | LS -> st
  | DIR _ -> st
  | CD_TOP -> { location = [ "/" ]; dir_sizes = st.dir_sizes }
  | CD_UP -> { location = List.tl st.location; dir_sizes = st.dir_sizes }
  | CD dir -> { location = dir :: st.location; dir_sizes = st.dir_sizes }
  | FILE_SIZE i ->
      {
        (* Now we have to add dir sizes for every parent location*)
        location = st.location;
        dir_sizes =
          st.dir_sizes
          @ List.map (fun l -> { location = l; size = i }) (parents st.location);
      }

let lines = read_lines "input.txt"
let end_state =
  List.fold_left process_line { location = [ "/" ]; dir_sizes = [] } lines

let dir_size_table = Hashtbl.create 200
let dir_total_table : (location, int) Hashtbl.t = Hashtbl.create 200
let rec sum (l : int list) = match l with [] -> 0 | x :: rest -> x + sum rest
;;

List.map
  (fun (ds : dir_size) -> Hashtbl.add dir_size_table ds.location ds.size)
  end_state.dir_sizes
;;

Seq.iter
  (fun k ->
    Hashtbl.find_all dir_size_table k
    |> sum
    |> Hashtbl.replace dir_total_table k)
  (Hashtbl.to_seq_keys dir_size_table)

let part1_answer =
  Hashtbl.fold
    (fun _k v acc -> if v <= 100000 then acc + v else acc)
    dir_total_table 0
;;

print_endline ("Part 1: " ^ string_of_int part1_answer)

let needed_space = 30000000 - (70000000 - Hashtbl.find dir_total_table [ "/" ])
;;

print_endline ("Part 2. Needed space: " ^ string_of_int needed_space)

let part2_answer =
  Hashtbl.fold
    (fun _k v acc -> if v >= needed_space && v < acc then v else acc)
    dir_total_table 70000000
;;

print_endline ("Part 2: " ^ string_of_int part2_answer)

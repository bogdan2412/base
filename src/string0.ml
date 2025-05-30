(* [String0] defines string functions that are primitives or can be simply defined in
   terms of [Stdlib.String]. [String0] is intended to completely express the part of
   [Stdlib.String] that [Base] uses -- no other file in Base other than string0.ml should
   use [Stdlib.String].  [String0] has few dependencies, and so is available early in Base's
   build order.

   All Base files that need to use strings, including the subscript syntax [x.[i]] which
   the OCaml parser desugars into calls to [String], and come before [Base.String] in
   build order should do

   {[
     module String = String0
   ]}

   Defining [module String = String0] is also necessary because it prevents
   ocamldep from mistakenly causing a file to depend on [Base.String]. *)

open! Import0

open struct
  module Sys = Sys0
  module Uchar = Uchar0
end

module String = struct
  external get : (string[@local_opt]) -> (int[@local_opt]) -> char = "%string_safe_get"
  external length : (string[@local_opt]) -> int = "%string_length"

  external unsafe_get
    :  (string[@local_opt])
    -> (int[@local_opt])
    -> char
    = "%string_unsafe_get"
end

include String

let max_length = Sys.max_string_length

let ( ^ ) s1 s2 =
  let l1 = length s1
  and l2 = length s2 in
  let s = Bytes0.create (l1 + l2) in
  Bytes0.unsafe_blit_string ~src:s1 ~src_pos:0 ~dst:s ~dst_pos:0 ~len:l1;
  Bytes0.unsafe_blit_string ~src:s2 ~src_pos:0 ~dst:s ~dst_pos:l1 ~len:l2;
  Bytes0.unsafe_to_string ~no_mutation_while_string_reachable:s
;;

let capitalize = Stdlib.String.capitalize_ascii
let compare = Stdlib.String.compare
let escaped = Stdlib.String.escaped
let make = Stdlib.String.make
let sub = Stdlib.String.sub
let uncapitalize = Stdlib.String.uncapitalize_ascii
let is_valid_utf_8 = Stdlib.String.is_valid_utf_8
let is_valid_utf_16le = Stdlib.String.is_valid_utf_16le
let is_valid_utf_16be = Stdlib.String.is_valid_utf_16be
let get_utf_8_uchar t ~byte_pos = Stdlib.String.get_utf_8_uchar t byte_pos
let get_utf_16le_uchar t ~byte_pos = Stdlib.String.get_utf_16le_uchar t byte_pos
let get_utf_16be_uchar t ~byte_pos = Stdlib.String.get_utf_16be_uchar t byte_pos

open struct
  let get_utf_32_uchar ~get_int32 t ~byte_pos =
    let len = String.length t in
    match byte_pos >= 0 && byte_pos < len with
    | false -> raise (Invalid_argument "index out of bounds")
    | true ->
      (match len - byte_pos with
       | (1 | 2 | 3) as bytes_read ->
         (* Fewer than 4 bytes remain in [t], so we know the decoding is invalid. *)
         Uchar.utf_decode_invalid bytes_read
       | _ ->
         let int32 = get_int32 t byte_pos in
         (match Int_conversions.int32_is_representable_as_int int32 with
          | false -> Uchar.utf_decode_invalid 4
          | true ->
            let int = Int_conversions.int32_to_int_trunc int32 in
            (match Uchar.is_valid int with
             | true -> Uchar.utf_decode 4 (Uchar.unsafe_of_int int)
             | false -> Uchar.utf_decode_invalid 4)))
  ;;
end

let get_utf_32le_uchar t ~byte_pos =
  get_utf_32_uchar t ~byte_pos ~get_int32:Stdlib.String.get_int32_le
;;

let get_utf_32be_uchar t ~byte_pos =
  get_utf_32_uchar t ~byte_pos ~get_int32:Stdlib.String.get_int32_be
;;

include struct
  let ensure_ge (x : int) y = if x >= y then x else invalid_arg "String.concat"

  let rec sum_lengths acc seplen = function
    | [] -> acc
    | hd :: [] -> length hd + acc
    | hd :: tl -> sum_lengths (ensure_ge (length hd + seplen + acc) acc) seplen tl
  ;;

  let rec unsafe_blits dst pos sep seplen = function
    | [] -> dst
    | hd :: [] ->
      Bytes0.unsafe_blit_string ~src:hd ~src_pos:0 ~dst ~dst_pos:pos ~len:(length hd);
      dst
    | hd :: tl ->
      Bytes0.unsafe_blit_string ~src:hd ~src_pos:0 ~dst ~dst_pos:pos ~len:(length hd);
      Bytes0.unsafe_blit_string
        ~src:sep
        ~src_pos:0
        ~dst
        ~dst_pos:(pos + length hd)
        ~len:seplen;
      unsafe_blits dst (pos + length hd + seplen) sep seplen tl
  ;;

  let concat : ?sep:string -> string list -> string =
    fun ?(sep = "") l ->
    match l with
    | [] -> ""
    | [ x ] -> Globalize.globalize_string x
    | l ->
      let seplen = length sep in
      Bytes0.unsafe_to_string
        ~no_mutation_while_string_reachable:
          (unsafe_blits (Bytes0.create (sum_lengths 0 seplen l)) 0 sep seplen l)
  ;;
end

let lowercase string =
  let string =
    Bytes0.unsafe_of_string_promise_no_mutation string |> Bytes0.map ~f:Char0.lowercase
  in
  Bytes0.unsafe_to_string ~no_mutation_while_string_reachable:string
;;

let lowercase__stack string =
  let string =
    Bytes0.unsafe_of_string_promise_no_mutation string
    |> Bytes0.map__stack ~f:Char0.lowercase
  in
  Bytes0.unsafe_to_string ~no_mutation_while_string_reachable:string
;;

let uppercase string =
  let string =
    Bytes0.unsafe_of_string_promise_no_mutation string |> Bytes0.map ~f:Char0.uppercase
  in
  Bytes0.unsafe_to_string ~no_mutation_while_string_reachable:string
;;

let uppercase__stack string =
  let string =
    Bytes0.unsafe_of_string_promise_no_mutation string
    |> Bytes0.map__stack ~f:Char0.uppercase
  in
  Bytes0.unsafe_to_string ~no_mutation_while_string_reachable:string
;;

let iter t ~f =
  for i = 0 to length t - 1 do
    f (unsafe_get t i)
  done
;;

let split_lines =
  let back_up_at_newline ~t ~pos ~eol =
    pos := !pos - if !pos > 0 && Char0.equal t.[!pos - 1] '\r' then 2 else 1;
    eol := !pos + 1
  in
  fun t ->
    let n = length t in
    if n = 0
    then []
    else (
      (* Invariant: [-1 <= pos < eol]. *)
      let pos = ref (n - 1) in
      let eol = ref n in
      let ac = ref [] in
      (* We treat the end of the string specially, because if the string ends with a
         newline, we don't want an extra empty string at the end of the output. *)
      if Char0.equal t.[!pos] '\n' then back_up_at_newline ~t ~pos ~eol;
      while !pos >= 0 do
        if not (Char0.equal t.[!pos] '\n')
        then decr pos
        else (
          (* Because [pos < eol], we know that [start <= eol]. *)
          let start = !pos + 1 in
          ac := sub t ~pos:start ~len:(!eol - start) :: !ac;
          back_up_at_newline ~t ~pos ~eol)
      done;
      sub t ~pos:0 ~len:!eol :: !ac)
;;

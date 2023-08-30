(* The [globalize_{bool,char,unit}] functions are written as matches plus the identity
   function so that the type checker can give them the desired type, without having to do
   anything special.  However, [globalize_int] cannot be written this way, so we resort to
   using an [external]. *)

let globalize_bool = function
  | (true | false) as b -> b
;;

let globalize_char = function
  | '\x00' .. '\xFF' as c -> c
;;

external globalize_float : (float[@local]) -> float = "%obj_dup"
external globalize_int : (int[@local]) -> int = "%identity"
external globalize_int32 : (int32[@local]) -> int32 = "%obj_dup"
external globalize_int64 : (int64[@local]) -> int64 = "%obj_dup"
external globalize_nativeint : (nativeint[@local]) -> nativeint = "%obj_dup"
external globalize_bytes : (bytes[@local]) -> bytes = "%obj_dup"
external globalize_string : (string[@local]) -> string = "%obj_dup"

let globalize_unit (() as u) = u

external globalize_array' : ('a array[@local]) -> 'a array = "%obj_dup"

let globalize_array _ a = globalize_array' a

let rec globalize_list f = function
  | [] -> []
  | x :: xs -> f x :: globalize_list f xs
;;

let globalize_option f = function
  | None -> None
  | Some x -> Some (f x)
;;

let globalize_result globalize_a globalize_b t =
  match t with
  | Ok a -> Ok (globalize_a a)
  | Error b -> Error (globalize_b b)
;;

let globalize_ref' r = ref !r
let globalize_ref _ r = globalize_ref' r

external globalize_lazy_t_mono : ('a lazy_t[@local]) -> 'a lazy_t = "%identity"

let globalize_lazy_t _ t = globalize_lazy_t_mono t

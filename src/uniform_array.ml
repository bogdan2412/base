open! Import

(* WARNING:
   We use non-memory-safe and non-mode-safe things throughout the [Trusted] module.
   Most of it is only safe in combination with the type signature (e.g. exposing
   [val copy : 'a t -> 'b t] would be a big mistake. Likewise, exposing
   ['a t : immutable_data with 'a] would be a big mistake.). *)
module Trusted : sig
  type 'a t

  val empty : 'a t
  val get_empty : unit -> 'a t
  val unsafe_create_uninitialized : len:int -> 'a t
  val create_obj_array : len:int -> 'a t
  val create : len:int -> 'a -> 'a t
  val singleton : 'a -> 'a t
  val get : 'a t -> int -> 'a [@@zero_alloc]
  val set : 'a t -> int -> 'a -> unit
  val swap : _ t -> int -> int -> unit
  val unsafe_get : 'a t -> int -> 'a [@@zero_alloc]
  val unsafe_get_local : 'a t -> int -> 'a [@@zero_alloc]
  val unsafe_set : 'a t -> int -> 'a -> unit
  val unsafe_set_omit_phys_equal_check : 'a t -> int -> 'a -> unit
  val unsafe_set_int : 'a t -> int -> int -> unit
  val unsafe_set_int_assuming_currently_int : 'a t -> int -> int -> unit
  val unsafe_set_assuming_currently_int : 'a t -> int -> 'a -> unit
  val unsafe_set_with_caml_modify : 'a t -> int -> 'a -> unit
  val unsafe_to_array_inplace__promise_not_a_float : 'a t -> 'a array
  val set_with_caml_modify : 'a t -> int -> 'a -> unit
  val length : 'a t -> int
  val unsafe_blit : ('a t, 'a t) Blit.blit
  val copy : 'a t -> 'a t
  val unsafe_clear_if_pointer : _ t -> int -> unit
  val sub : 'a t -> pos:int -> len:int -> 'a t
end = struct
  (* It is safe to claim that ['a t] is mutable data as long as ['a] is mutable
     data: we only store ['a]s (mutably).

     Forging a mode-crossing claim requires minting a new type, so we can't
     just say [type 'a t : mutable_data with 'a = Obj_array.t]. That's why
     we mint an unboxed record instead.
  *)
  type 'a t = { arr : Obj_array.t } [@@unboxed] [@@unsafe_allow_any_mode_crossing]

  let empty = { arr = Obj_array.empty }
  let[@inline] get_empty () = { arr = Obj_array.get_empty () }
  let unsafe_create_uninitialized ~len = { arr = Obj_array.create_zero ~len }
  let create_obj_array ~len = { arr = Obj_array.create_zero ~len }
  let create ~len x = { arr = Obj_array.create ~len (Stdlib.Obj.repr x) }
  let singleton x = { arr = Obj_array.singleton (Stdlib.Obj.repr x) }
  let swap t i j : unit = Obj_array.swap t.arr i j

  (* *)

  let[@zero_alloc] get t i = Stdlib.Obj.obj (Obj_array.get t.arr i)
  let set t i x : unit = Obj_array.set t.arr i (Stdlib.Obj.repr x)

  (* We annotate the return types on this and other functions to help document the
     fact that (i) we're trying to avoid partial application, and (ii) we've
     successfully avoided it.
  *)
  let[@zero_alloc] unsafe_get_local (type a) t i : a =
    Stdlib.Obj.obj (Obj_array.unsafe_get t.arr i)
  ;;

  let[@zero_alloc] unsafe_get (type a) t i : a = unsafe_get_local t i
  let unsafe_set t i x : unit = Obj_array.unsafe_set t.arr i (Stdlib.Obj.repr x)
  let unsafe_set_int t i x : unit = Obj_array.unsafe_set_int t.arr i x

  let unsafe_set_int_assuming_currently_int t i x : unit =
    Obj_array.unsafe_set_int_assuming_currently_int t.arr i x
  ;;

  let unsafe_set_assuming_currently_int t i x : unit =
    Obj_array.unsafe_set_assuming_currently_int t.arr i (Stdlib.Obj.repr x)
  ;;

  (* [t] is just an array under the hood, it just has special considerations about [t] not
     being a float. *)
  let unsafe_to_array_inplace__promise_not_a_float t : _ array = Stdlib.Obj.magic t.arr
  let length t : int = Obj_array.length t.arr

  let unsafe_blit ~src ~src_pos ~dst ~dst_pos ~len : unit =
    Obj_array.unsafe_blit ~src:src.arr ~src_pos ~dst:dst.arr ~dst_pos ~len
  ;;

  let copy t = { arr = Obj_array.copy t.arr }

  let unsafe_set_omit_phys_equal_check t i x : unit =
    Obj_array.unsafe_set_omit_phys_equal_check t.arr i (Stdlib.Obj.repr x)
  ;;

  let unsafe_set_with_caml_modify t i x : unit =
    Obj_array.unsafe_set_with_caml_modify t.arr i (Stdlib.Obj.repr x)
  ;;

  let set_with_caml_modify t i x : unit =
    Obj_array.set_with_caml_modify t.arr i (Stdlib.Obj.repr x)
  ;;

  let unsafe_clear_if_pointer t i : unit = Obj_array.unsafe_clear_if_pointer t.arr i
  let sub t ~pos ~len = { arr = Obj_array.sub t.arr ~pos ~len }
end

include Trusted

let invariant t =
  assert (Stdlib.Obj.tag (Stdlib.Obj.repr t) <> Stdlib.Obj.double_array_tag)
;;

let init l ~f =
  if l < 0
  then invalid_arg "Uniform_array.init"
  else (
    let res = unsafe_create_uninitialized ~len:l in
    for i = 0 to l - 1 do
      unsafe_set res i (f i)
    done;
    res)
;;

let of_array arr = init ~f:(Array.unsafe_get arr) (Array.length arr) [@nontail]
let map a ~f = init ~f:(fun i -> f (unsafe_get a i)) (length a) [@nontail]
let mapi a ~f = init ~f:(fun i -> f i (unsafe_get a i)) (length a) [@nontail]

let iter a ~f =
  for i = 0 to length a - 1 do
    f (unsafe_get a i)
  done
;;

let iteri a ~f =
  for i = 0 to length a - 1 do
    f i (unsafe_get a i)
  done
;;

let foldi a ~init ~f =
  let acc = ref init in
  for i = 0 to length a - 1 do
    acc := f i !acc (unsafe_get a i)
  done;
  !acc
;;

let fold t ~init ~f =
  let r = ref init in
  for i = 0 to length t - 1 do
    r := f !r (unsafe_get t i)
  done;
  !r
;;

let to_list t = List.init ~f:(fun i -> get t i) (length t)

let of_list l =
  let len = List.length l in
  let res = unsafe_create_uninitialized ~len in
  List.iteri l ~f:(fun i x -> set res i x);
  res
;;

let of_list_rev l =
  let len = List.length l in
  let res = unsafe_create_uninitialized ~len in
  List.iteri l ~f:(fun i x -> set res (len - i - 1) x);
  res
;;

(* It is not safe for [to_array] to be the identity function because we have code that
   relies on [float array]s being unboxed, for example in [bin_write_array]. *)
let to_array t = Array.init (length t) ~f:(fun i -> unsafe_get t i)

let exists t ~f =
  let i = ref (length t - 1) in
  let result = ref false in
  while !i >= 0 && not !result do
    if f (unsafe_get t !i) then result := true else decr i
  done;
  !result
;;

let existsi t ~f =
  let i = ref (length t - 1) in
  let result = ref false in
  while !i >= 0 && not !result do
    if f !i (unsafe_get t !i) then result := true else decr i
  done;
  !result
;;

let for_all t ~f =
  let i = ref (length t - 1) in
  let result = ref true in
  while !i >= 0 && !result do
    if not (f (unsafe_get t !i)) then result := false else decr i
  done;
  !result
;;

let for_alli t ~f =
  let length = length t in
  let i = ref (length - 1) in
  let result = ref true in
  while !i >= 0 && !result do
    if not (f !i (unsafe_get t !i)) then result := false else decr i
  done;
  !result
;;

let filter_mapi t ~f =
  let r = ref (get_empty ()) in
  let k = ref 0 in
  for i = 0 to length t - 1 do
    match f i (unsafe_get t i) with
    | None -> ()
    | Some a ->
      if !k = 0 then r := create ~len:(length t) a;
      unsafe_set !r !k a;
      incr k
  done;
  if !k = length t then !r else if !k > 0 then sub ~pos:0 ~len:!k !r else get_empty ()
;;

let filteri t ~f = filter_mapi t ~f:(fun i x -> if f i x then Some x else None) [@nontail]
let filter_map t ~f = filter_mapi t ~f:(fun _i a -> f a) [@nontail]
let filter t ~f = filter_map t ~f:(fun x -> if f x then Some x else None) [@nontail]

let fold2_exn t1 t2 ~init ~f =
  let len = length t1 in
  if length t2 <> len then invalid_arg "Array.fold2_exn";
  let acc = ref init in
  for i = 0 to len - 1 do
    acc := f !acc (unsafe_get t1 i) (unsafe_get t2 i)
  done;
  !acc
;;

let map2_exn t1 t2 ~f =
  let len = length t1 in
  if length t2 <> len then invalid_arg "Array.map2_exn";
  init len ~f:(fun i -> f (unsafe_get t1 i) (unsafe_get t2 i)) [@nontail]
;;

let concat ts =
  let total_len = List.sum (module Int) ts ~f:(fun t -> length t) in
  let res = unsafe_create_uninitialized ~len:total_len in
  ignore
    (List.fold ts ~init:0 ~f:(fun so_far t ->
       let len = length t in
       for i = 0 to len - 1 do
         set res (so_far + i) (get t i)
       done;
       so_far + len)
     : int);
  res
;;

let concat_mapi t ~f = to_list t |> List.mapi ~f |> concat
let concat_map t ~f = to_list t |> List.map ~f |> concat

let partition_map t ~f =
  let left, right = ref (get_empty ()), ref (get_empty ()) in
  let left_idx, right_idx = ref 0, ref 0 in
  let append data idx value =
    if !idx = 0 then data := create ~len:(length t) value;
    unsafe_set !data !idx value;
    incr idx
  in
  for i = 0 to length t - 1 do
    match (f (unsafe_get t i) : _ Either.t) with
    | First a -> append left left_idx a
    | Second a -> append right right_idx a
  done;
  let trim data idx =
    if !idx = length t
    then !data
    else if !idx > 0
    then sub ~pos:0 ~len:!idx !data
    else get_empty ()
  in
  trim left left_idx, trim right right_idx
;;

let find_map t ~f =
  let length = length t in
  if length = 0
  then None
  else (
    let i = ref 0 in
    let value_found = ref None in
    while Option.is_none !value_found && !i < length do
      let value = unsafe_get t !i in
      value_found := f value;
      incr i
    done;
    !value_found)
;;

let find_mapi t ~f =
  let length = length t in
  if length = 0
  then None
  else (
    let i = ref 0 in
    let value_found = ref None in
    while Option.is_none !value_found && !i < length do
      let value = unsafe_get t !i in
      value_found := f !i value;
      incr i
    done;
    !value_found)
;;

let findi t ~f =
  let length = length t in
  if length = 0
  then None
  else (
    let i = ref 0 in
    let found = ref false in
    let value_found = ref (unsafe_get t 0) in
    while (not !found) && !i < length do
      let value = unsafe_get t !i in
      if f !i value
      then (
        value_found := value;
        found := true)
      else incr i
    done;
    if !found then Some (!i, !value_found) else None)
;;

let find t ~f = Option.map (findi t ~f:(fun _i x -> f x)) ~f:(fun (_i, x) -> x)

let findi t ~f =
  let len = length t in
  let rec loop f i =
    if i >= len
    then None
    else (
      let x = unsafe_get t i in
      match f i x with
      | false -> loop f (i + 1)
      | true -> Some (i, x))
  in
  loop f 0
;;

let t_sexp_grammar (type elt) (grammar : elt Sexplib0.Sexp_grammar.t)
  : elt t Sexplib0.Sexp_grammar.t
  =
  Sexplib0.Sexp_grammar.coerce (Array.t_sexp_grammar grammar)
;;

include%template
  Sexpable.Of_sexpable1 [@modality portable]
    (Array)
    (struct
      type nonrec 'a t = 'a t

      let to_sexpable = to_array
      let of_sexpable = of_array
    end)

include%template Blit.Make1 [@modality portable] (struct
    type nonrec 'a t = 'a t

    let length = length

    let create_like ~len t =
      if len = 0
      then get_empty ()
      else (
        assert (length t > 0);
        create ~len (get t 0))
    ;;

    let unsafe_blit = unsafe_blit
  end)

let min_elt t ~compare = Container.min_elt ~fold t ~compare
let max_elt t ~compare = Container.max_elt ~fold t ~compare

(* This is the same as the ppx_compare [compare_array] but uses our [unsafe_get] and [length]. *)
let compare__local compare_elt a b =
  if phys_equal a b
  then 0
  else (
    let len_a = length a in
    let len_b = length b in
    let ret = compare len_a len_b in
    if ret <> 0
    then ret
    else (
      let rec loop i =
        if i = len_a
        then 0
        else (
          let l = unsafe_get_local a i
          and r = unsafe_get_local b i in
          let res = compare_elt l r in
          if res <> 0 then res else loop (i + 1))
      in
      loop 0 [@nontail]))
;;

let compare compare_elt a b = compare__local compare_elt a b

module%template Sort = Array.Private.Sorter [@modality portable] (struct
    type nonrec 'a t = 'a t

    let length = length
    let get t i = unsafe_get t i
    let set t i x = unsafe_set t i x
  end)

let sort = Sort.sort

include%template Binary_searchable.Make1 [@modality portable] (struct
    type nonrec 'a t = 'a t

    let length = length
    let get t i = unsafe_get t i
  end)

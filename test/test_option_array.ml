open! Import
open Option_array

module%test Cheap_option = struct
  open For_testing.Unsafe_cheap_option

  let roundtrip_via_cheap_option (type a) (x : a) =
    let opt : a t = some x in
    assert (is_some opt);
    assert (phys_equal (value_exn opt) x)
  ;;

  let%test_unit _ = roundtrip_via_cheap_option 0
  let%test_unit _ = roundtrip_via_cheap_option 1
  let%test_unit _ = roundtrip_via_cheap_option (ref 0)
  let%test_unit _ = roundtrip_via_cheap_option `x6e8ee3478e1d7449
  let%test_unit _ = roundtrip_via_cheap_option 0.0
  let%test _ = not (is_some none)

  let%test_unit "memory corruption" =
    let make_list () = List.init ~f:(fun i -> Some i) 5 in
    Stdlib.Gc.minor ();
    let x = value_unsafe (some (make_list ())) in
    Stdlib.Gc.minor ();
    let (_ : int option list) = List.init ~f:(fun i -> Some (i * 100)) 10000 in
    [%test_result: Int.t Option.t List.t] ~expect:(make_list ()) x
  ;;
end

module Sequence = struct
  let length = length
  let get = get
  let set = set
end

include
  Base_for_tests.Test_blit.Test1_generic
    (struct
      include Option

      let equal a b = Option.equal Bool.equal a b
      let of_bool b = Some b
    end)
    (struct
      type nonrec 'a t = 'a t [@@deriving sexp]

      include Sequence

      let create_bool ~len = init_some len ~f:(fun _ -> false)
    end)
    (Option_array)

let%test_unit "floats are not re-boxed" =
  let one = 1.0 in
  let array = init_some 1 ~f:(fun _ -> one) in
  assert (phys_equal one (get_some_exn array 0))
;;

let%test_unit "segfault does not happen" =
  (* if [Option_array] is implemented with [Core_array] instead of [Uniform_array], this
     dies with a segfault *)
  let _array = init 2 ~f:(fun i -> if i = 0 then Some 1.0 else None) in
  ()
;;

module X = struct
  type t =
    [ `x6e8ee3478e1d7449
    | `some_other_value
    ]
  [@@deriving sexp_of]

  let magic_value : t = `x6e8ee3478e1d7449
  let some_other_value : t = `some_other_value

  let%expect_test _ =
    assert (
      phys_equal magic_value (Stdlib.Obj.magic For_testing.Unsafe_cheap_option.none : t))
  ;;
end

let%expect_test _ =
  let t = create ~len:1 in
  let check x =
    set t 0 (Some x);
    require (phys_equal x (unsafe_get_some_exn t 0));
    require (phys_equal x (unsafe_get_some_assuming_some t 0))
  in
  check X.magic_value;
  check X.some_other_value
;;

let%test _ = foldi (of_array_some [||]) ~init:13 ~f:(fun _ _ _ -> failwith "bad") = 13

let%test _ =
  foldi (of_array_some [| 13 |]) ~init:17 ~f:(fun i ac x -> ac + i + Option.value_exn x)
  = 30
;;

let%test _ =
  foldi
    (of_array_some [| 13; 17 |])
    ~init:19
    ~f:(fun i ac x -> ac + i + Option.value_exn x)
  = 50
;;

let%test _ =
  counti (of_array_some [| 0; 1; 2; 3; 4 |]) ~f:(fun idx x -> idx = Option.value_exn x)
  = 5
;;

let%test _ =
  counti
    (of_array_some [| 0; 1; 2; 3; 4 |])
    ~f:(fun idx x -> idx = 4 - Option.value_exn x)
  = 1
;;

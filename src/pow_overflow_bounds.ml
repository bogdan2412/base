(* This file was autogenerated by ../generate/generate_pow_overflow_bounds.exe *)

open! Import
module Iarray = Iarray0

(* We have to use Int64.to_int_exn instead of int constants to make
   sure that file can be preprocessed on 32-bit machines. *)

let overflow_bound_max_int32_value : int32 = 2147483647l

let int32_positive_overflow_bounds : int32 iarray =
  Portability_hacks.Cross.Portable.(cross (iarray infer))
    (Iarray.unsafe_of_array__promise_no_mutation
       [| 2147483647l
        ; 2147483647l
        ; 46340l
        ; 1290l
        ; 215l
        ; 73l
        ; 35l
        ; 21l
        ; 14l
        ; 10l
        ; 8l
        ; 7l
        ; 5l
        ; 5l
        ; 4l
        ; 4l
        ; 3l
        ; 3l
        ; 3l
        ; 3l
        ; 2l
        ; 2l
        ; 2l
        ; 2l
        ; 2l
        ; 2l
        ; 2l
        ; 2l
        ; 2l
        ; 2l
        ; 2l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
        ; 1l
       |])
;;

let overflow_bound_max_int_value : int = -1 lsr 1

let int_positive_overflow_bounds : int iarray =
  Portability_hacks.Cross.Portable.(cross (iarray infer))
    (match Int_conversions.num_bits_int with
     | 32 -> Iarray.map int32_positive_overflow_bounds ~f:Stdlib.Int32.to_int
     | 63 ->
       Iarray.unsafe_of_array__promise_no_mutation
         [| Stdlib.Int64.to_int 4611686018427387903L
          ; Stdlib.Int64.to_int 4611686018427387903L
          ; Stdlib.Int64.to_int 2147483647L
          ; 1664510
          ; 46340
          ; 5404
          ; 1290
          ; 463
          ; 215
          ; 118
          ; 73
          ; 49
          ; 35
          ; 27
          ; 21
          ; 17
          ; 14
          ; 12
          ; 10
          ; 9
          ; 8
          ; 7
          ; 7
          ; 6
          ; 5
          ; 5
          ; 5
          ; 4
          ; 4
          ; 4
          ; 4
          ; 3
          ; 3
          ; 3
          ; 3
          ; 3
          ; 3
          ; 3
          ; 3
          ; 3
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 1
          ; 1
         |]
     | 31 ->
       Iarray.unsafe_of_array__promise_no_mutation
         [| 1073741823
          ; 1073741823
          ; 32767
          ; 1023
          ; 181
          ; 63
          ; 31
          ; 19
          ; 13
          ; 10
          ; 7
          ; 6
          ; 5
          ; 4
          ; 4
          ; 3
          ; 3
          ; 3
          ; 3
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 2
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
          ; 1
         |]
     | _ -> assert false)
;;

let overflow_bound_max_int63_on_int64_value : int64 = 4611686018427387903L

let int63_on_int64_positive_overflow_bounds : int64 iarray =
  Portability_hacks.Cross.Portable.(cross (iarray infer))
    (Iarray.unsafe_of_array__promise_no_mutation
       [| 4611686018427387903L
        ; 4611686018427387903L
        ; 2147483647L
        ; 1664510L
        ; 46340L
        ; 5404L
        ; 1290L
        ; 463L
        ; 215L
        ; 118L
        ; 73L
        ; 49L
        ; 35L
        ; 27L
        ; 21L
        ; 17L
        ; 14L
        ; 12L
        ; 10L
        ; 9L
        ; 8L
        ; 7L
        ; 7L
        ; 6L
        ; 5L
        ; 5L
        ; 5L
        ; 4L
        ; 4L
        ; 4L
        ; 4L
        ; 3L
        ; 3L
        ; 3L
        ; 3L
        ; 3L
        ; 3L
        ; 3L
        ; 3L
        ; 3L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 1L
        ; 1L
       |])
;;

let overflow_bound_max_int64_value : int64 = 9223372036854775807L

let int64_positive_overflow_bounds : int64 iarray =
  Portability_hacks.Cross.Portable.(cross (iarray infer))
    (Iarray.unsafe_of_array__promise_no_mutation
       [| 9223372036854775807L
        ; 9223372036854775807L
        ; 3037000499L
        ; 2097151L
        ; 55108L
        ; 6208L
        ; 1448L
        ; 511L
        ; 234L
        ; 127L
        ; 78L
        ; 52L
        ; 38L
        ; 28L
        ; 22L
        ; 18L
        ; 15L
        ; 13L
        ; 11L
        ; 9L
        ; 8L
        ; 7L
        ; 7L
        ; 6L
        ; 6L
        ; 5L
        ; 5L
        ; 5L
        ; 4L
        ; 4L
        ; 4L
        ; 4L
        ; 3L
        ; 3L
        ; 3L
        ; 3L
        ; 3L
        ; 3L
        ; 3L
        ; 3L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 2L
        ; 1L
       |])
;;

let int64_negative_overflow_bounds : int64 iarray =
  Portability_hacks.Cross.Portable.(cross (iarray infer))
    (Iarray.unsafe_of_array__promise_no_mutation
       [| -9223372036854775807L
        ; -9223372036854775807L
        ; -3037000499L
        ; -2097151L
        ; -55108L
        ; -6208L
        ; -1448L
        ; -511L
        ; -234L
        ; -127L
        ; -78L
        ; -52L
        ; -38L
        ; -28L
        ; -22L
        ; -18L
        ; -15L
        ; -13L
        ; -11L
        ; -9L
        ; -8L
        ; -7L
        ; -7L
        ; -6L
        ; -6L
        ; -5L
        ; -5L
        ; -5L
        ; -4L
        ; -4L
        ; -4L
        ; -4L
        ; -3L
        ; -3L
        ; -3L
        ; -3L
        ; -3L
        ; -3L
        ; -3L
        ; -3L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -2L
        ; -1L
       |])
;;

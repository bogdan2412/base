(** Conversions between various integer types *)

open! Import

(** Ocaml has the following integer types, with the following bit widths on 32-bit and
    64-bit architectures.

    {v
                            arch  arch
                type        32b   64b
                ----------------------
                int          31    63  (32 when compiled to JavaScript)
                nativeint    32    64
                int32        32    32
                int64        64    64
    v}

    In both cases, the following inequalities hold:

    {[
      width int < width nativeint && width int32 <= width nativeint <= width int64
    ]}

    The conversion functions come in one of two flavors.

    If width(foo) <= width(bar) on both 32-bit and 64-bit architectures, then we have

    {[
      val foo_to_bar : foo -> bar
    ]}

    otherwise we have

    {[
      val foo_to_bar : foo -> bar option
      val foo_to_bar_exn : foo -> bar
    ]} *)
val int_to_int32 : int -> int32 option

val int_to_int32_exn : int -> int32
external int_to_int32_trunc : int -> (int32[@local_opt]) = "%int32_of_int"
external int_to_int64 : int -> (int64[@local_opt]) = "%int64_of_int"
external int_to_nativeint : int -> (nativeint[@local_opt]) = "%nativeint_of_int"
val int32_to_int : int32 -> int option
val int32_to_int_exn : int32 -> int
val int32_to_int_trunc : int32 -> int
external int32_to_int64 : int32 -> (int64[@local_opt]) = "%int64_of_int32"
external int32_to_nativeint : int32 -> (nativeint[@local_opt]) = "%nativeint_of_int32"
val int32_is_representable_as_int : int32 -> bool
val int64_to_int : int64 -> int option
val int64_to_int_exn : int64 -> int
val int64_to_int_trunc : int64 -> int
val int64_to_int32 : int64 -> int32 option
val int64_to_int32_exn : int64 -> int32 [@@zero_alloc]
external int64_to_int32_trunc : int64 -> (int32[@local_opt]) = "%int64_to_int32"
val int64_to_nativeint : int64 -> nativeint option
val int64_to_nativeint_exn : int64 -> nativeint

external int64_to_nativeint_trunc
  :  int64
  -> (nativeint[@local_opt])
  = "%int64_to_nativeint"

val int64_fit_on_int63_exn : int64 -> unit
val int64_is_representable_as_int63 : int64 -> bool
val nativeint_to_int : nativeint -> int option
val nativeint_to_int_exn : nativeint -> int
val nativeint_to_int_trunc : nativeint -> int
val nativeint_to_int32 : nativeint -> int32 option
val nativeint_to_int32_exn : nativeint -> int32

external nativeint_to_int32_trunc
  :  nativeint
  -> (int32[@local_opt])
  = "%nativeint_to_int32"

external nativeint_to_int64 : nativeint -> (int64[@local_opt]) = "%int64_of_nativeint"
val num_bits_int : int
val num_bits_int32 : int
val num_bits_int64 : int
val num_bits_nativeint : int

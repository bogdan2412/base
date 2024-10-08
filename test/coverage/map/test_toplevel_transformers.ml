open! Base
module Implementation = Base.Map

let%expect_test "[Base.Map] creators/accessors" =
  let open Functor.Test_transformers (Instances.Toplevel) (Implementation) in
  [%expect {| Functor.Test_transformers: running tests. |}]
;;

include (
  Implementation : Functor.Transformers with module Types := Instances.Types.Toplevel)
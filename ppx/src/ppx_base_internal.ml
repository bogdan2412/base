open! Stdppx
open Ppxlib

module Specialize_polymorphic_compare = struct
  let signature ~loc =
    [%sig:
      [@@@ocaml.ppwarning "ppx_base_internal: intended only for use inside Base"]

      external ( = ) : (t[@local_opt]) -> (t[@local_opt]) -> bool = "%equal"
      external ( <> ) : (t[@local_opt]) -> (t[@local_opt]) -> bool = "%notequal"
      external ( < ) : (t[@local_opt]) -> (t[@local_opt]) -> bool = "%lessthan"
      external ( > ) : (t[@local_opt]) -> (t[@local_opt]) -> bool = "%greaterthan"
      external ( <= ) : (t[@local_opt]) -> (t[@local_opt]) -> bool = "%lessequal"
      external ( >= ) : (t[@local_opt]) -> (t[@local_opt]) -> bool = "%greaterequal"
      external compare : (t[@local_opt]) -> (t[@local_opt]) -> int = "%compare"
      external compare__local : (t[@local_opt]) -> (t[@local_opt]) -> int = "%compare"
      external equal : (t[@local_opt]) -> (t[@local_opt]) -> bool = "%equal"
      external equal__local : (t[@local_opt]) -> (t[@local_opt]) -> bool = "%equal"
      val ascending : t -> t -> int
      val descending : t -> t -> int
      val max : t -> t -> t
      val min : t -> t -> t]
  ;;

  let structure ~loc =
    [%str
      [@@@ocaml.ppwarning "ppx_base_internal: intended only for use inside Base"]

      external ( = ) : (t[@local_opt]) -> (t[@local_opt]) -> bool = "%equal"
      external ( <> ) : (t[@local_opt]) -> (t[@local_opt]) -> bool = "%notequal"
      external ( < ) : (t[@local_opt]) -> (t[@local_opt]) -> bool = "%lessthan"
      external ( > ) : (t[@local_opt]) -> (t[@local_opt]) -> bool = "%greaterthan"
      external ( <= ) : (t[@local_opt]) -> (t[@local_opt]) -> bool = "%lessequal"
      external ( >= ) : (t[@local_opt]) -> (t[@local_opt]) -> bool = "%greaterequal"
      external compare : (t[@local_opt]) -> (t[@local_opt]) -> int = "%compare"
      external compare__local : (t[@local_opt]) -> (t[@local_opt]) -> int = "%compare"
      external equal : (t[@local_opt]) -> (t[@local_opt]) -> bool = "%equal"
      external equal__local : (t[@local_opt]) -> (t[@local_opt]) -> bool = "%equal"

      let ascending x y = compare x y
      let descending x y = compare y x
      let max x y = Bool0.select (x >= y) x y
      let min x y = Bool0.select (x <= y) x y]
  ;;

  let check_decl decl =
    match core_type_of_type_declaration decl with
    | [%type: t] -> Ok ()
    | _ ->
      Error
        (Location.Error.to_extension
           (Location.Error.createf
              ~loc:decl.ptype_loc
              "deriving specialize_polymorphic_compare: expected [type t], no other name \
               or parameters"))
  ;;

  let sig_type_decl =
    Deriving.Generator.V2.make_noarg (fun ~ctxt:_ (_, decls) ->
      List.concat_map decls ~f:(fun decl ->
        let loc = decl.ptype_loc in
        match check_decl decl with
        | Ok () -> (Ppxlib_jane.Shim.Signature.of_parsetree (signature ~loc)).psg_items
        | Error ext -> [ Ast_builder.Default.psig_extension ~loc ext [] ]))
  ;;

  let str_type_decl =
    Deriving.Generator.V2.make_noarg (fun ~ctxt:_ (_, decls) ->
      List.concat_map decls ~f:(fun decl ->
        let loc = decl.ptype_loc in
        match check_decl decl with
        | Ok () -> structure ~loc
        | Error ext -> [ Ast_builder.Default.pstr_extension ~loc ext [] ]))
  ;;

  let deriver =
    Deriving.add "specialize_polymorphic_compare" ~sig_type_decl ~str_type_decl
  ;;
end

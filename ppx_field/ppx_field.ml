open Ppxlib

(*
   PPX_FIELD
   =========
   
   Access record fields by name:
   
   [%field record "name"]  ->  record.name
*)

let expand ~ctxt record (field_name: string) =
  let loc = Expansion_context.Extension.extension_point_loc ctxt in
  (* Build: record.field_name *)
  Ast_builder.Default.pexp_field ~loc record
    { txt = Lident field_name; loc }

let extension =
  Extension.V3.declare
    "field"
    Extension.Context.expression
    (* Match: [%field record "field_name"] which parses as function application *)
    Ast_pattern.(single_expr_payload (pexp_apply __ ((no_label (estring __)) ^:: nil)))
    expand

let () =
  Driver.register_transformation
    ~rules:[Context_free.Rule.extension extension]
    "ppx_field"


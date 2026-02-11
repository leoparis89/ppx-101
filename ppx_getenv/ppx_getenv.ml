open Ppxlib

(*
   PPX_GETENV
   ==========
   
   Transforms: [%getenv "USER"]
   Into:       "levkowalski" (at compile time!)
*)

let expand ~ctxt (var_name: string) =
  let loc = Expansion_context.Extension.extension_point_loc ctxt in
  match Sys.getenv_opt var_name with
  | Some value -> 
      Ast_builder.Default.estring ~loc value
  | None ->
      Location.raise_errorf ~loc 
        "Environment variable %s not found at compile time" var_name

let extension =
  Extension.V3.declare
    "getenv"
    Extension.Context.expression
    Ast_pattern.(single_expr_payload (estring __))
    expand

let () = 
  Driver.register_transformation 
    ~rules:[Context_free.Rule.extension extension] 
    "ppx_getenv"


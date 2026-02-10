open Ppxlib

(*
   PPX_HELLO
   =========
   
   Transforms: [%hello]
   Into:       "Hello, World!"
*)

let expand ~ctxt =
  let loc = Expansion_context.Extension.extension_point_loc ctxt in
  [%expr "Hello, World!"]

let extension =
  Extension.V3.declare
    "hello"
    Extension.Context.expression
    Ast_pattern.(pstr nil)
    expand

let () = 
  Driver.register_transformation 
    ~rules:[Context_free.Rule.extension extension] 
    "ppx_hello"



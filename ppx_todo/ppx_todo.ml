open Ppxlib

(*
   PPX_TODO
   ========
   
   Emits a compile-time warning.
   
   Usage: [%todo "fix this later"]
   Output: Warning during compilation, returns ()
*)

let expand ~ctxt msg =
  let loc = Expansion_context.Extension.extension_point_loc ctxt in
  (* Side effect: print warning at compile time *)
  let pos = loc.loc_start in
  Printf.eprintf "File \"%s\", line %d:\n  [TODO] %s\n%!" 
    pos.pos_fname 
    pos.pos_lnum 
    msg;
  (* Must still return valid AST - we return unit *)
  [%expr ()]

let extension =
  Extension.V3.declare
    "todo"
    Extension.Context.expression
    Ast_pattern.(single_expr_payload (estring __))
    expand

let () = 
  Driver.register_transformation 
    ~rules:[Context_free.Rule.extension extension] 
    "ppx_todo"


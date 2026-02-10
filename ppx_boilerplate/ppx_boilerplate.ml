open Ppxlib

(*
   PPX_BOILERPLATE - Template
   ==========================
   
   This PPX does nothing. Use it as a starting point.
   
   Pick ONE of the 3 types below and delete the others:
   
   1. EXTENDER  - for [%name] syntax
   2. DERIVER   - for [@@deriving name] syntax  
   3. MAPPER    - for transforming everything
*)


(* ============================================
   OPTION 1: EXTENDER
   Usage: [%boilerplate]
   ============================================ *)

let expand_extender ~ctxt =
  let loc = Expansion_context.Extension.extension_point_loc ctxt in
  (* TODO: Return your generated expression here *)
  [%expr ()]

let extender =
  Extension.V3.declare
    "boilerplate"
    Extension.Context.expression
    Ast_pattern.(pstr nil)  (* No payload. For payload: single_expr_payload (estring __) *)
    expand_extender

let extender_rule = Context_free.Rule.extension extender


(* ============================================
   OPTION 2: DERIVER
   Usage: type t = ... [@@deriving boilerplate]
   ============================================ *)

let expand_deriver ~ctxt (_rec_flag, type_decls) =
  let loc = Expansion_context.Deriver.derived_item_loc ctxt in
  (* TODO: Generate structure items based on type_decls *)
  let _ = type_decls in
  [[%stri let _ = ()]]  (* Placeholder - generates: let _ = () *)

let deriver =
  Deriving.add "boilerplate"
    ~str_type_decl:(Deriving.Generator.V2.make_noarg expand_deriver)


(* ============================================
   OPTION 3: MAPPER
   Usage: Runs on everything automatically
   ============================================ *)

let mapper =
  object
    inherit Ast_traverse.map as super
    method! expression expr =
      (* TODO: Transform expressions here *)
      super#expression expr
  end

let mapper_impl str = mapper#structure str


(* ============================================
   REGISTER - Pick one and delete the others!
   ============================================ *)

(* For EXTENDER: *)
let () = 
  Driver.register_transformation 
    ~rules:[extender_rule] 
    "ppx_boilerplate"

(* For DERIVER - uncomment: *)
(* let _ = deriver *)

(* For MAPPER - uncomment: *)
(* let () = Driver.register_transformation ~impl:mapper_impl "ppx_boilerplate" *)


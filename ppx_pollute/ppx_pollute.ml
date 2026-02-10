open Ppxlib

(*
   PPX_POLLUTE
   ===========
   
   Transforms ALL string literals in your code!
   
   "hello" -> "hello 🦠"
   
   (Skips warning strings like "-32" to not break the compiler)
*)

(* Skip strings that look like compiler warnings or are empty *)
let should_skip s =
  String.length s = 0 ||
  (String.length s <= 10 && 
   (s.[0] = '-' || s.[0] = '+' || s.[0] = '@'))

(* Create a mapper that transforms expressions *)
let mapper =
  object
    inherit Ast_traverse.map as super
    
    method! expression expr =
      match expr.pexp_desc with
      | Pexp_constant (Pconst_string (s, loc, delim)) when not (should_skip s) ->
          (* Pollute the string! *)
          let polluted = s ^ " 🦠" in
          { expr with 
            pexp_desc = Pexp_constant (Pconst_string (polluted, loc, delim)) }
      | _ -> 
          (* For everything else, keep traversing *)
          super#expression expr
  end

(* Apply to the whole file structure *)
let impl str = mapper#structure str

(* Register as a transformation *)
let () = 
  Driver.register_transformation 
    ~impl
    "ppx_pollute"


open Ppxlib

(*
   PPX_TIME
   ========
   
   Embeds the compile-time timestamp as a string.
   
   Usage: [%time]
   Output: "2026-02-10T11:30:00Z"
*)

let expand ~ctxt =
  let loc = Expansion_context.Extension.extension_point_loc ctxt in
  (* Get current time at COMPILE TIME *)
  let now = Unix.gettimeofday () in
  let tm = Unix.gmtime now in
  let timestamp = Printf.sprintf "%04d-%02d-%02dT%02d:%02d:%02dZ"
    (tm.tm_year + 1900)
    (tm.tm_mon + 1)
    tm.tm_mday
    tm.tm_hour
    tm.tm_min
    tm.tm_sec
  in
  Ast_builder.Default.estring ~loc timestamp

let extension =
  Extension.V3.declare
    "time"
    Extension.Context.expression
    Ast_pattern.(pstr nil)
    expand

let () = 
  Driver.register_transformation 
    ~rules:[Context_free.Rule.extension extension] 
    "ppx_time"





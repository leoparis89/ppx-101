type cat = Siamese | Persian
[@@deriving show]


let () = print_endline (show_cat Persian)
let () = print_endline (show_cat Siamese)

(* Using our ppx_hello extensions! *)
let () = print_endline [%hello]

(* This reads USER at COMPILE TIME - whoever builds it gets greeted! *)
let () = Printf.printf "Hello, %s! You compiled this program.\n" [%getenv "USER"]

(* Compile-time timestamp *)
let () = Printf.printf "Built at: %s\n" [%time]

(* Compile-time warning - you'll see this when building! *)
let () = [%todo "Remember to add proper error handling"]

(* ppx_field - access record fields by string name *)
type person = { name: string; age: int }
let alice = { name = "Alice"; age = 30 }
let () = Printf.printf "Name: %s, Age: %d\n" [%field alice "name"] [%field alice "age"]

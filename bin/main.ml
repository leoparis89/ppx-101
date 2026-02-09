type cat = Siamese | Persian
[@@deriving show]

let () = print_endline (show_cat Siamese)

(lang dune 3.20)

(name hello)

(generate_opam_files true)

(package
 (name hello)
 (synopsis "OCaml PPX playground")
 (depends ocaml ppxlib ppx_deriving lwt))

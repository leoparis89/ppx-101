(lang dune 3.20)

(name hello)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name <author@example.com>")

(maintainers "Maintainer Name <maintainer@example.com>")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name hello)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml)
 (tags
  ("add topics" "to describe" your project)))

(package
 (name ppx_hello)
 (synopsis "Simplest PPX - transforms [%hello] into a string")
 (depends ocaml ppxlib))

(package
 (name ppx_getenv)
 (synopsis "PPX to embed environment variables at compile time")
 (depends ocaml ppxlib))

(package
 (name ppx_pollute)
 (synopsis "PPX that pollutes all strings with an emoji")
 (depends ocaml ppxlib))

(package
 (name ppx_boilerplate)
 (synopsis "PPX boilerplate template - does nothing")
 (depends ocaml ppxlib))

(package
 (name ppx_time)
 (synopsis "PPX that embeds compile-time timestamp")
 (depends ocaml ppxlib))

(package
 (name ppx_todo)
 (synopsis "PPX that emits compile-time warnings")
 (depends ocaml ppxlib))

(package
 (name ppx_field)
 (synopsis "PPX to access record fields by string name")
 (depends ocaml ppxlib))

(package
 (name ppx_await)
 (synopsis "PPX for async/await syntax with Lwt")
 (depends ocaml ppxlib))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html

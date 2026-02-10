# PPX 101

This guide will walk you through the basics of building your own PPX using [ppxlib](https://ocaml-ppx.github.io/ppxlib/ppxlib/index.html). We'll build small PPXs, put them in libraries, and use them in `main.ml`.

## All you need to know

1. **PPX transforms the AST** (Abstract Syntax Tree)

   **Example:** `[@@deriving show]` on a type:

   ```ocaml
   type cat = Siamese | Persian
   [@@deriving show]
   ```

   You've probably used this before and assumed that OCaml code containing `show_cat` was generated somewhere. But no — PPX doesn't generate source code text, it generates **AST nodes** directly.

   The PPX inserts AST nodes identical to what you'd get if you wrote this yourself:

   ```ocaml
   let show_cat = function 
     | Siamese -> "Siamese" 
     | Persian -> "Persian"
   ```

   The compiler can't tell the difference! Whether you typed it or the PPX generated it — same AST nodes.

> **💡 Tip:** To view the AST of your OCaml code:
> - In Cursor/VS Code: `Cmd+Shift+P` → "OCaml: Open AST Explorer"
> - Online: [astexplorer.net](https://astexplorer.net/) (select OCaml)

2. **PPX has 3 types** of transformations (see below)

---

## The 3 Types

### 1. Extenders `[%name]`

Replace `[%name]` with generated code.

```ocaml
(* Reads the USER environment variable at COMPILE TIME *)
let user = [%getenv "USER"]

(* becomes (if USER=john): *)
let user = "john"
```

**Why `[%...]`?**
- `[ ]` — brackets mean "this is an extension point" (a hole in the AST)
- `%` — indicates it's an **extension** (will be replaced)
- The PPX fills the hole with generated code

### 2. Derivers `[@@deriving name]`

Generate functions from type definitions.

```ocaml
type cat = Siamese | Persian
[@@deriving show]

(* generates: *)
let show_cat = function Siamese -> "Siamese" | Persian -> "Persian"
```

**Why `[@@...]`?** The `@` symbol marks an **attribute** (metadata). The number of `@` signs determines what it attaches to:

#### `[@attr]` — Single: attaches to nearest expression

```reason
[@react.component]
let make = (~name) => <h1> {React.string("Hello " ++ name)} </h1>
```
*(from [reason-react](https://github.com/reasonml/reason-react))*

#### `[@@attr]` — Double: attaches to preceding item

```ocaml
type cat = Siamese | Persian
[@@deriving show]  (* attaches to the type above *)
```

#### `[@@@attr]` — Triple: applies to entire file

```ocaml
[@@@warning "-32"]  (* disable warning for whole file *)

let unused_function x = x + 1  (* no warning! *)
```

### 3. Mappers

Transform the entire AST automatically. No syntax — just runs when added to `bin/dune`.
So as an experemiment imagine if we implemented a ppx that appended a string value to all the strings in you program!

```dune
(preprocess (pps ppx_pollute))
```

```ocaml
(* EVERY string in your ENTIRE codebase gets transformed! *)
print_endline "hello"       (* becomes: *) print_endline "hello 🦠"
let name = "Alice"          (* becomes: *) let name = "Alice 🦠"
let msg = "Error: " ^ x     (* becomes: *) let msg = "Error:  🦠" ^ x
(* No escape! 🦠 everywhere! *)
```

---

## When to use

| Need | Use |
|------|-----|
| Generate a value at a spot | **Extender** `[%foo]` |
| Generate functions for a type | **Deriver** `[@@deriving foo]` |
| Transform everything | **Mapper** *(no syntax)* |

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

**Why `[@@...]`?** The `@` symbol marks an **attribute** (metadata). The number of `@` signs determines **where it attaches** (not how it's processed):

| Syntax | Attaches to | Example |
|--------|-------------|---------|
| `[@attr]` | Nearest expression | `[@react.component]` *(processed by mapper)* |
| `[@@attr]` | Preceding item | `[@@deriving show]` *(processed by deriver)* |
| `[@@@attr]` | Entire file | `[@@@warning "-32"]` |

> **Note:** The number of `@` is about **where** the attribute attaches, not **which PPX type** processes it. `[@react.component]` uses single `@` syntax but is handled by a mapper.

### 3. Mappers

Walk the AST and transform what they find. No special syntax in your code — just add to `bin/dune`.

Mappers can target different things:
- **All nodes** of a type (e.g., all strings)
- **Specific attributes** (e.g., `[@react.component]`)
- **Specific patterns** (e.g., `let%bind`)

```dune
(preprocess (pps ppx_pollute))
```

**Example: transform all strings**
```ocaml
(* ppx_pollute hits EVERY string in your codebase *)
print_endline "hello"       (* becomes: *) print_endline "hello 🦠"
let name = "Alice"          (* becomes: *) let name = "Alice 🦠"
```

**Example: transform specific attribute**
```reason
(* reason-react looks for [@react.component] and transforms the function *)
[@react.component]
let make = (~name) => <h1> {React.string(name)} </h1>
```

---

## When to use

| Need | Use |
|------|-----|
| Generate a value at a spot | **Extender** `[%foo]` |
| Generate functions for a type | **Deriver** `[@@deriving foo]` |
| Transform everything | **Mapper** *(no syntax)* |

---

## Popular PPXs in the wild

### Extenders

| PPX | Usage | What it does |
|-----|-------|--------------|
| `ppx_expect` | `[%expect {| output |}]` | Inline tests with expected output |
| `ppx_blob` | `[%blob "file.txt"]` | Embed file contents at compile time |
| `ppx_optcomp` | `[%if ocaml_version >= (4,14)]` | Conditional compilation |

### Derivers

| PPX | Usage | What it generates |
|-----|-------|-------------------|
| `ppx_deriving.show` | `[@@deriving show]` | `show_t : t -> string` |
| `ppx_deriving.eq` | `[@@deriving eq]` | `equal : t -> t -> bool` |
| `ppx_deriving.ord` | `[@@deriving ord]` | `compare : t -> t -> int` |
| `ppx_yojson_conv` | `[@@deriving yojson]` | JSON serialization |
| `ppx_sexp_conv` | `[@@deriving sexp]` | S-expression serialization |
| `ppx_compare` | `[@@deriving compare]` | Jane Street's compare |
| `ppx_hash` | `[@@deriving hash]` | Hash functions |

### Mappers

| PPX | Targets | What it does |
|-----|---------|--------------|
| `ppx_pollute` | All strings | Appends 🦠 to every string |
| `reason-react` | `[@react.component]` | Transforms function into React component |
| `ppx_let` | `let%bind`, `let%map` | Monadic let syntax |
| `ppx_lwt` | `let%lwt` | Async Lwt syntax |

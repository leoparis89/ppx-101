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

| Type | You write | PPX does |
|------|-----------|----------|
| **Extender** | `[%foo]` | Replaces the marker with code |
| **Deriver** | `type t = ... [@@deriving foo]` | Inspects the type, generates functions |
| **Mapper** | *(nothing special)* | Walks ALL your code, transforms what it finds |

---

### 1. Extenders `[%name]`

You write a **marker**. PPX **replaces** it.

```ocaml
let user = [%getenv "USER"]    (* marker *)
let user = "john"              (* replaced with value *)
```

---

### 2. Derivers `[@@deriving name]`

You write on a **type**. PPX **inspects the type structure** and generates functions.

```ocaml
type cat = Siamese | Persian
[@@deriving show]
```

The PPX looks at the type (2 constructors: `Siamese`, `Persian`) and generates:

```ocaml
let show_cat = function 
  | Siamese -> "Siamese" 
  | Persian -> "Persian"
```

**Key:** Derivers need a type to inspect. They generate code **based on the type's structure** (fields, constructors).

---

### 3. Mappers

No special syntax. PPX **walks your entire codebase** and transforms what it finds.

```ocaml
(* You write normal code *)
print_endline "hello"
let name = "Alice"

(* ppx_pollute transforms ALL strings *)
print_endline "hello 🦠"
let name = "Alice 🦠"
```

Mappers can also look for **specific attributes**:

```reason
[@react.component]              (* mapper finds this attribute *)
let make = (~name) => <h1/>     (* and transforms this function *)
```

**Key:** Mappers don't need special syntax. They scan everything.

---

### Attribute syntax `@` `@@` `@@@`

The number of `@` determines **where** the attribute attaches:

| Syntax | Position | Attaches to |
|--------|----------|-------------|
| `[@attr]` | Before | What comes after ↓ |
| `[@@attr]` | After | What came before ↑ |
| `[@@@attr]` | Anywhere | Entire file |

```ocaml
[@react.component]           (* BEFORE → attaches to function below *)
let make = ...

type cat = Siamese | Persian
[@@deriving show]            (* AFTER → attaches to type above *)

[@@@warning "-32"]           (* applies to whole file *)
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

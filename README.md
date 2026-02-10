# PPX 101

This guide will walk you through the basics of building your own PPX using [ppxlib](https://ocaml-ppx.github.io/ppxlib/ppxlib/index.html). We'll build small PPXs, put them in libraries, and use them in `main.ml`.

## **PPX transforms the AST** (Abstract Syntax Tree)

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

---

## Two syntax markers

### `%` = Extension point

```ocaml
(* ppx_blob — embed file at compile time *)
let content = [%blob "message.txt"]

(* becomes *)
let content = "Hello from the file!"
```

Won't compile without `ppx_blob` — the `[%blob]` is a hole that must be filled.

**Positions:** one or two `%`

| Syntax | Level | Example |
|--------|-------|---------|
| `[%foo]` | Expression | `[%blob "file.txt"]` (ppx_blob) |
| `[%%foo]` | Top-level | `[%%raw "console.log('hi')"]` (js_of_ocaml) |
| `let%foo` | Binding | `let%lwt x = fetch ()` (ppx_lwt) |

### `@` = Attribute

```ocaml
(* Code compiles even without ppx_deriving installed! *)
type cat = Siamese | Persian
[@@deriving show]
```

**Positions:** one, two, or three `@`

| Syntax | Attaches to | Example |
|--------|-------------|---------|
| `[@attr]` | Next item | `[@react.component]` (reason-react) |
| `[@@attr]` | Previous item | `[@@deriving yojson]` (ppx_yojson) |
| `[@@@attr]` | Whole file | `[@@@warning "-32"]` (OCaml built-in) |

> **Note:** Not all `@` attributes are PPXs! Some are **compiler built-ins**:
> ```ocaml
> let[@warning "-32"] log = Log.create ()   (* Suppress for this binding only *)
> let[@inline] add x y = x + y              (* Hint to inline this function *)
> let[@tailcall] rec loop n = loop (n-1)    (* Assert this call is tail-recursive *)
> [@@@warning "-45"]                        (* Suppress for entire file *)
> ```
> These are handled by the compiler itself, not by any PPX.

---

## Three types of PPX

### 1. [Extender](https://ocaml-ppx.github.io/ppxlib/ppxlib/driver.html#def_extenders)

**You write `[%foo]`. PPX replaces it.**

```ocaml
(* ppx_blob — embed file at compile time *)
let content = [%blob "message.txt"]

(* becomes *)
let content = "Hello from the file!"
```

Extenders **only** use `%` syntax: `[%foo]`, `[%%foo]`, `let%foo`, `match%foo`, etc.


---

### 2. [Deriver](https://ocaml-ppx.github.io/ppxlib/ppxlib/driver.html#def_derivers)

**You write `[@@deriving foo]` on a type. PPX inspects the type and generates functions.**

```ocaml
type cat = Siamese | Persian
[@@deriving show]

(* PPX sees 2 constructors, generates: *)
let show_cat = function 
  | Siamese -> "Siamese" 
  | Persian -> "Persian"
```

Derivers **always** use `[@@deriving foo]` — the word `deriving` is required! Any other `[@attr]` is a mapper.

**Key:** Derivers inspect type structure (fields, constructors).

---

### 3. Mapper

**PPX scans your entire codebase. No special syntax needed.**

Mappers can use **any** `@` syntax — `[@foo]`, `[@@bar]`, `[@@@baz]` — as long as it's not `[@@deriving]`:

```reason
[@react.component]    (* Mapper finds this, transforms the function *)
let make = (~name) => <h1>{name}</h1>
```

**Why isn't `[@react.component]` a deriver?**

In ppxlib, "deriver" is a specific API only for `[@@deriving foo]` on **type definitions**. Since `[@react.component]` attaches to a function (not a type), it can't use the deriver API — so it uses the mapper API instead.

---

## Summary

| Type | You write | PPX does |
|------|-----------|----------|
| **Extender** | `[%foo]` | Replaces the marker |
| **Deriver** | `type t = ... [@@deriving foo]` | Inspects type, generates functions |
| **Mapper** | Nothing or `[@attr]` | Scans entire codebase |

---

## Popular PPXs

**Extenders:**
- `[%expect]` — inline tests
- `[%blob "file"]` — embed file contents
- `let%bind` / `let%lwt` — monadic syntax

**Derivers:**
- `[@@deriving show]` — pretty printing
- `[@@deriving eq]` — equality
- `[@@deriving yojson]` — JSON serialization

**Mappers:**
- `[@react.component]` — React components

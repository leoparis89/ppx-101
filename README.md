# PPX 101

A simple guide to OCaml PPX using [ppxlib](https://ocaml-ppx.github.io/ppxlib/ppxlib/index.html).

---

## What is PPX?

PPX transforms your code at compile time by modifying the AST (Abstract Syntax Tree).

```ocaml
type cat = Siamese | Persian
[@@deriving show]
```

You might think this generates a file with `show_cat` somewhere. **Nope!** PPX inserts AST nodes directly — as if you wrote this yourself:

```ocaml
let show_cat = function 
  | Siamese -> "Siamese" 
  | Persian -> "Persian"
```

---

## Two syntax markers

### `%` = Extension point (MUST be replaced)

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
| `[%%foo]` | Top-level | `[%%import "types.ml"]` (ppx_import) |
| `let%foo` | Binding | `let%lwt x = fetch ()` (ppx_lwt) |

### `@` = Attribute (optional metadata)

```ocaml
(* Code compiles even without ppx_deriving installed! *)
type user = { name: string; age: int }
[@@deriving show, eq]
```

**Positions:** one, two, or three `@`

| Syntax | Attaches to | Example |
|--------|-------------|---------|
| `[@attr]` | Next item | `[@react.component]` (reason-react) |
| `[@@attr]` | Previous item | `[@@deriving yojson]` (ppx_yojson) |
| `[@@@attr]` | Whole file | `[@@@warning "-32"]` (OCaml built-in) |

### Quick comparison

| Syntax | What it is | If no PPX handles it |
|--------|------------|----------------------|
| `[%foo]` | Hole to fill | **Compile error** |
| `[@foo]` | Metadata | Code still works |

---

## Three types of PPX

### 1. [Extender](https://ocaml-ppx.github.io/ppxlib/ppxlib/driver.html#def_extenders)

**You write `[%foo]`. PPX replaces it.**

```ocaml
let user = [%getenv "USER"]
(* becomes *)
let user = "john"
```

No `[%getenv]` = nothing happens.

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

**Key:** Derivers inspect type structure (fields, constructors).

---

### 3. Mapper

**PPX scans your entire codebase. No special syntax needed.**

```ocaml
(* You write: *)
let msg = "hello"

(* ppx_pollute transforms ALL strings: *)
let msg = "hello 🦠"
```

Mappers can also look for `[@attributes]`:

```reason
[@react.component]    (* Mapper finds this, transforms the function *)
let make = (~name) => <h1>{name}</h1>
```

**Why isn't `[@react.component]` a deriver?**

In ppxlib, "deriver" is a specific API only for `[@@deriving foo]` on **type definitions**. Since `[@react.component]` attaches to a function (not a type), it can't use the deriver API — so it uses the mapper API instead.

**Why scan the whole codebase for something localized?**

It doesn't really "scan" — the mapper walks the AST once and reacts when it sees `[@react.component]`. ppxlib only offers 3 APIs: extender (`[%foo]`), deriver (`[@@deriving]` on types), and mapper (everything else). If your PPX doesn't fit the first two, mapper is your only option.

**Rule of thumb:** Want to generate code from something that's NOT a type? Use a mapper.

| Transform based on... | Use |
|-----------------------|-----|
| `[%foo]` | Extender |
| Type definition | Deriver |
| Function, module, or any other `[@attr]` | Mapper |

---

## Summary

| Type | You write | PPX does |
|------|-----------|----------|
| **Extender** | `[%foo]` | Replaces the marker |
| **Deriver** | `type t = ... [@@deriving foo]` | Inspects type, generates functions |
| **Mapper** | Nothing or `[@attr]` | Scans entire codebase |

**Simple test:**
- Uses `%`? → **Extender**
- Uses `[@@deriving]` on a type? → **Deriver**  
- Scans code without `%`? → **Mapper**

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
- `ppx_pollute` — transforms all strings

---

> **💡 View AST:** `Cmd+Shift+P` → "OCaml: Open AST Explorer" or [astexplorer.net](https://astexplorer.net/)

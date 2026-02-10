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
let x = [%time]    (* Won't compile if no PPX handles this *)
```

### `@` = Attribute (optional metadata)

```ocaml
[@foo]             (* Code compiles even if ppx_foo doesn't exist! *)
let x = 1
```

| Syntax | What it is | If no PPX handles it |
|--------|------------|----------------------|
| `[%foo]` | Hole to fill | **Compile error** |
| `[@foo]` | Metadata | Code still works |

---

## Three types of PPX

### 1. Extender

**You write `[%foo]`. PPX replaces it.**

```ocaml
let user = [%getenv "USER"]
(* becomes *)
let user = "john"
```

No `[%getenv]` = nothing happens.

---

### 2. Deriver

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

**Why isn't `[@react.component]` a deriver?** It doesn't inspect any type structure — it just wraps the function.

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

## `@` position: one, two, or three

| Syntax | Position | Example |
|--------|----------|---------|
| `[@attr]` | Before → attaches to what's below | `[@react.component]` |
| `[@@attr]` | After → attaches to what's above | `[@@deriving show]` |
| `[@@@attr]` | File-wide | `[@@@warning "-32"]` |

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

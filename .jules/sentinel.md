## 2024-05-24 - Unsafe JSON Deserialization Type Casting
**Vulnerability:** Parsing user-provided JSON files without validating the root data type before casting to a Dictionary (`var data: Dictionary = json.data`) can cause runtime type errors or crashes if the file contains non-dictionary JSON structures.
**Learning:** In Godot 4, `JSON.new().parse()` succeeds for any valid JSON (including arrays or primitives). The resulting `json.data` must be explicitly type-checked (e.g., `typeof(json.data) == TYPE_DICTIONARY`) before strict type assignment.
**Prevention:** Always validate the type of `json.data` against expected `TYPE_*` constants after a successful parse, before assigning to strictly typed variables or accessing keys.

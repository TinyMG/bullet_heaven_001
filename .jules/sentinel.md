## 2024-05-24 - Insecure JSON Deserialization in Godot
**Vulnerability:** Parsing local JSON files (e.g., save data, settings) via `JSON.parse()` without validating the type of `json.data` before casting to a `Dictionary`. This can lead to runtime crashes if a user tampers with the file and provides valid JSON of a different type (like an Array or String).
**Learning:** Godot 4's `JSON.parse()` succeeds if the file contains *any* valid JSON. The resulting `json.data` variant needs explicit type checking (`typeof(json.data) == TYPE_DICTIONARY`) before assuming it matches the expected top-level structure.
**Prevention:** Always validate `typeof(json.data) == TYPE_DICTIONARY` (or whatever the expected base type is) immediately after a successful `JSON.parse()` and before using the data.

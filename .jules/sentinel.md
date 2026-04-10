## 2026-04-10 - Prevent runtime crashes from malformed JSON
**Vulnerability:** In Godot 4, parsing local JSON files via `JSON.parse()` without type-checking `json.data` before casting to Dictionary can crash the game if the file is tampered with or malformed.
**Learning:** `json.data` should always be strictly type-checked using `typeof(json.data) == TYPE_DICTIONARY` before assignment to prevent type-cast errors.
**Prevention:** Always validate the parsed data type when reading from `user://` files.

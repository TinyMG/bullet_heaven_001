## 2024-04-17 - Insecure JSON Deserialization in Godot 4
**Vulnerability:** Loading `user://` data with `JSON.new().parse()` and casting it directly to `Dictionary` crashes the game if the file is modified to contain a different JSON type (e.g., an array).
**Learning:** In Godot 4, `json.data` must be strictly type-checked before assignment.
**Prevention:** Always verify `typeof(json.data) == TYPE_DICTIONARY` (or the expected type) before accessing or casting deserialized data.

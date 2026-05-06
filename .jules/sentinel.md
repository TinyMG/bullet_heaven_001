## 2024-05-06 - Insecure Deserialization in Godot JSON Parsing
**Vulnerability:** Loading `user://` local files using `JSON.new().parse()` without checking `typeof(json.data) == TYPE_DICTIONARY` can cause a runtime crash if a user tampers with the file to contain an array or primitive value.
**Learning:** `json.data` must be explicitly type-checked before casting to a `Dictionary` in GDScript.
**Prevention:** Always validate `typeof(json.data) == TYPE_DICTIONARY` immediately after verifying `err == OK`.

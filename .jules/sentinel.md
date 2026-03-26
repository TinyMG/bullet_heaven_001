## 2024-05-24 - Prevent Runtime Crash on Malformed JSON Load
**Vulnerability:** Insecure deserialization of local files (`user://`). `JSON.parse()` does not guarantee the returned data is a Dictionary. Directly casting `json.data` to `Dictionary` can cause a runtime crash if a user tampers with the file and provides a different JSON type (e.g., an array or a string).
**Learning:** In Godot 4, data parsed from local files via `JSON.parse()` must be strictly type-checked before variable assignment to prevent crashes from malformed or malicious user files.
**Prevention:** Implement `typeof(json.data) == TYPE_DICTIONARY` type checking immediately after successfully parsing JSON data.

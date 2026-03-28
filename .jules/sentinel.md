## 2024-05-15 - Insecure JSON Deserialization

**Vulnerability:** Loading `user://save_data.json` or `user://settings.json` using `JSON.parse` but immediately assigning `json.data` to a strongly-typed `Dictionary` without type checking.
**Learning:** In Godot 4, `json.data` can be any valid JSON type (like Array, String, int) depending on the file's root element. If an attacker tampers with the file, loading it could cause a runtime crash.
**Prevention:** Always verify the type of `json.data` before usage using `typeof(json.data) == TYPE_DICTIONARY`.

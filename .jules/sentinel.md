## 2024-05-23 - Insecure JSON Deserialization in Godot
**Vulnerability:** Parsing local user JSON files (`user://save_data.json`, `user://settings.json`) without validating the parsed data type.
**Learning:** Godot 4's `JSON.new().parse()` can return any variant type depending on the file contents. Assuming it returns a Dictionary and casting it directly (`var data: Dictionary = json.data`) can lead to runtime crashes if the file is tampered with or malformed.
**Prevention:** Always validate the parsed data type using strict type-checking (e.g., `typeof(json.data) == TYPE_DICTIONARY`) before assignment.

## 2024-05-20 - Missing Type Checking on JSON Parsed Data in Godot 4
**Vulnerability:** Insecure JSON Parsing / Lack of Type Validation
**Learning:** In Godot 4, data parsed from local files (e.g., `user://save_data.json`, `user://settings.json`) via `JSON.parse()` or `JSON.new().parse()` must be strictly type-checked (e.g., `typeof(json.data) == TYPE_DICTIONARY`) before variable assignment. Assigning parsed data to a strongly-typed variable without validation can lead to runtime crashes if the user file has been tampered with or is malformed.
**Prevention:** Always add a `typeof()` check before casting `json.data` to a specific type, such as `Dictionary` or `Array`, when reading from user-provided or local files.

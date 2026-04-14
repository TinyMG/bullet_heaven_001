## 2024-04-14 - Strict Type Checking for Local JSON Save Data
**Vulnerability:** Insecure JSON deserialization in Godot 4.
**Learning:** Data parsed from local files (e.g., `user://save_data.json`, `user://settings.json`) via `JSON.new().parse()` must be strictly type-checked.
**Prevention:** Always verify the type of `json.data` (e.g., `typeof(json.data) == TYPE_DICTIONARY`) before assigning it to a statically typed variable.

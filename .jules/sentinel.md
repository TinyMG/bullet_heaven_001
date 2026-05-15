## 2026-05-15 - Insecure JSON Deserialization in Save Data
**Vulnerability:** Data loaded from files (like `user://save_data.json` and `user://settings.json`) via `JSON.new().parse()` was implicitly assigned to a Dictionary type without verifying that the parsed JSON structure was actually a dictionary.
**Learning:** If a tampered user file contains a valid JSON array or primitive instead of a JSON object, the assignment to a strongly-typed `Dictionary` variable causes a runtime type error (crash). Godot 4's `JSON.data` returns a `Variant` depending on the JSON root type.
**Prevention:** Always strict type-check the `.data` property (`if typeof(json.data) == TYPE_DICTIONARY:`) before casting or assigning it to Dictionary variables.

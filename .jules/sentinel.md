## 2025-01-20 - Insecure JSON Deserialization Crashes
**Vulnerability:** Parsing local JSON files (e.g. `save_data.json`, `settings.json`) without verifying the top-level structure.
**Learning:** In Godot 4, data parsed via `JSON.parse()` and then assigned to typed variables like `Dictionary` will crash the game if the data happens to be a different type (e.g., an array or a primitive type) because of user tampering or malformed files.
**Prevention:** Always use a strict type check such as `typeof(json.data) == TYPE_DICTIONARY` before explicitly assigning the parsed value to typed dictionary fields to ensure type safety.

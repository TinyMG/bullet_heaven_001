## 2024-05-24 - Missing Type Check on JSON Parse
**Vulnerability:** Parsing `user://save_data.json` and `user://settings.json` via `JSON.parse()` without verifying the type of `json.data` before casting it to a Dictionary.
**Learning:** Godot 4 requires strict type-checking of `json.data` after parsing local files to prevent runtime crashes if the data is tampered with or malformed.
**Prevention:** Always use `typeof(json.data) == TYPE_DICTIONARY` (or appropriate type) before assigning parsed JSON data to typed variables.

## 2024-05-10 - Insecure JSON Deserialization in Godot 4
**Vulnerability:** Godot 4's `JSON.new().parse()` can parse valid JSON arrays, but assigning the result `json.data` directly to a statically typed `Dictionary` variable without checking causes a critical runtime type-cast crash, allowing maliciously tampered user save files to crash the game.
**Learning:** Data parsed from local files (e.g., `user://save_data.json`, `user://settings.json`) must be strictly type-checked before variable assignment.
**Prevention:** Always verify `typeof(json.data) == TYPE_DICTIONARY` (or the expected type) before accessing or assigning parsed local data.

## 2024-04-02 - Unvalidated JSON parsing in save files
**Vulnerability:** Loading `user://save_data.json` and `user://settings.json` via `JSON.parse()` blindly assigned the result to a typed `Dictionary` variable without verifying its underlying type.
**Learning:** In Godot 4, maliciously crafted or malformed user JSON files (like strings or arrays instead of objects) can trigger engine-level type coercion crashes when assigned to strongly typed variables.
**Prevention:** Always validate parsed JSON using `typeof(json.data) == TYPE_DICTIONARY` before assigning to `Dictionary` variables or operating on the loaded data.

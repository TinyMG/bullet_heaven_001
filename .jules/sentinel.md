## 2024-04-11 - Strict Type-Checking for Local File Parsing in Godot
**Vulnerability:** Data parsed from local files (e.g., `user://save_data.json`, `user://settings.json`) via `JSON.parse()` was assigned to strict `Dictionary` variables without verifying if `json.data` is actually a dictionary.
**Learning:** If a user maliciously modifies a JSON save or settings file to be an array or string (e.g., `[1, 2, 3]`), it will parse successfully, but crash the game with a type mismatch error when assigned to a strictly typed variable like `var data: Dictionary = json.data`.
**Prevention:** Always verify the type of `json.data` (e.g., `typeof(json.data) == TYPE_DICTIONARY`) before assigning to strictly typed variables or accessing dictionary methods.

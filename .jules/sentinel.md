## 2024-05-24 - Unsafe JSON Parsing in Godot Saves

**Vulnerability:** Settings and save files in `user://` are parsed directly using `JSON.new().parse()` without any type checking on `json.data` before casting or dictionary lookup.
**Learning:** In Godot 4, `json.data` returns `Variant`, which might be `null`, `Array`, `String`, etc., based on what was read. If an attacker modifies the `user://save_data.json` to be anything other than an Object/Dictionary (e.g., `["completed_nodes"]`), assigning it to a typed `Dictionary` variable or calling dictionary methods like `.has()` will cause a runtime crash.
**Prevention:** Always verify `typeof(json.data) == TYPE_DICTIONARY` before using parsed JSON data as a Dictionary.
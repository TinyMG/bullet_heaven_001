## 2024-03-18 - [JSON parsing Type Safety in Godot 4]
 **Vulnerability:** Unsafe casting of `json.data` directly to a statically typed `Dictionary` variable in Godot 4.
 **Learning:** If a user file (like `user://settings.json` or `user://save_data.json`) is tampered with or malformed such that it parses successfully as an Array or other JSON type instead of an Object, Godot 4 will crash when trying to assign it to a `var data: Dictionary` variable.
 **Prevention:** Always add a strict type check `if typeof(json.data) != TYPE_DICTIONARY:` before variable assignment when parsing untrusted JSON.
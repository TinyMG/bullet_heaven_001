## 2024-05-24 - Unsafe JSON Parsing in Godot 4
**Vulnerability:** Parsing untrusted user JSON files (e.g. `save_data.json`, `settings.json`) without checking the type of `json.data` before assigning to a typed `Dictionary`.
**Learning:** If a user manipulates their local save file and changes the root element from an object `{}` to an array `[]`, Godot 4 throws a hard runtime error: `Trying to assign value of type 'Array' to a variable of type 'Dictionary'`, immediately crashing the game.
**Prevention:** Always verify type using `if typeof(json.data) != TYPE_DICTIONARY: return` before doing `var data: Dictionary = json.data`.

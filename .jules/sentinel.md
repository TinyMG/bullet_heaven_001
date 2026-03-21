## 2024-03-21 - Insecure JSON parsing in user data loading
**Vulnerability:** Loading `user://save_data.json` and `user://settings.json` into a Dictionary variable blindly without checking `typeof(json.data) == TYPE_DICTIONARY` can cause Godot to crash if the parsed user file was modified to be an array or other type.
**Learning:** `JSON.parse` does not guarantee the return type of the root node matches your variable declaration in GDScript, leading to unsafe runtime cast errors.
**Prevention:** Always perform `if typeof(json.data) != TYPE_DICTIONARY` (or appropriate type check) before accessing or assigning parsed json data in Godot applications.

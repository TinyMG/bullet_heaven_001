## 2025-02-24 - Missing Type Check on Local File Parsing
**Vulnerability:** Insecure deserialization. `JSON.new().parse()` did not check if the parsed data was a Dictionary before assigning it to a Dictionary variable, risking a crash if a user tampered with their local settings or save files.
**Learning:** In Godot 4, parsed JSON data can be of any variant type (e.g., Array, float, int). Relying on the file's expected structure is unsafe for `user://` files.
**Prevention:** Always verify the `typeof()` the parsed `json.data` before casting or assigning it to a specific type, even for local save files.

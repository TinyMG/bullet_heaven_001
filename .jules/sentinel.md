## 2024-05-11 - Insecure JSON Deserialization Type Casting
**Vulnerability:** Parsing user-provided JSON files (`user://save_data.json`, `user://settings.json`) without verifying the resulting type before assigning to typed `Dictionary` variables, which allows attackers or modified files to crash the game via invalid data types (e.g. arrays or strings).
**Learning:** Godot's `JSON.parse` does not guarantee the output structure. Assigning unstructured `json.data` directly to a statically typed `Dictionary` throws a fatal runtime error if the parsed data is not a JSON object.
**Prevention:** Always validate `typeof(json.data) == TYPE_DICTIONARY` before using parsed JSON data when expecting an object structure.

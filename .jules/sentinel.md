## 2024-05-09 - Insecure JSON deserialization type check
**Vulnerability:** Parsing local JSON files directly into typed Dictionary variables without verifying the data type allows malformed or tampered save files to crash the game (runtime DoS).
**Learning:** Godot's `JSON.new().parse()` can return arrays, primitives, or null. Assigning `json.data` directly to `var data: Dictionary` will crash if the parsed type doesn't match.
**Prevention:** Always check `typeof(json.data) == TYPE_DICTIONARY` before using parsed JSON objects.

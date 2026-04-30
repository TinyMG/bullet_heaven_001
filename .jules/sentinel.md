## 2024-04-30 - Insecure JSON Deserialization in Godot
**Vulnerability:** Parsing user-controlled JSON files without validating the root type (e.g., Dictionary) can lead to runtime crashes when assigning to strictly typed variables.
**Learning:** `JSON.new().parse()` succeeds for any valid JSON (like an array or string), so subsequent type assumptions must be explicitly checked.
**Prevention:** Always verify the type of `json.data` (e.g., `typeof(json.data) == TYPE_DICTIONARY`) before variable assignment.

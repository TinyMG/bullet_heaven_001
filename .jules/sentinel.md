## 2025-04-08 - Type Safety in Godot JSON Parsing
**Vulnerability:** Assigning `json.data` directly to a strongly typed `Dictionary` variable without validation.
**Learning:** Malformed or tampered local user files (like save_data.json) that contain valid JSON arrays or strings instead of objects will cause a runtime crash in Godot 4 when assigned to a typed Dictionary.
**Prevention:** Always verify the type of `json.data` using `typeof(json.data) == TYPE_DICTIONARY` before assignment to prevent runtime panics from tampered client files.

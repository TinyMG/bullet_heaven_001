## 2026-04-29 - Type-Check Parsed JSON
**Vulnerability:** Untrusted local JSON files parsed without checking the root data type.
**Learning:** In Godot 4, `json.data` can be any Variant (Array, bool, String, Dictionary). Assigning it directly to `var data: Dictionary` without validation causes runtime crashes when parsing malformed files.
**Prevention:** Always validate `typeof(json.data) == TYPE_DICTIONARY` before assignment.

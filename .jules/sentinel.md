## 2026-05-14 - Godot 4 JSON Type Crash Vulnerability
**Vulnerability:** Assigning arbitrarily parsed JSON data to a statically typed `Dictionary` without type checking crashes the game runtime if the user provides malformed input (e.g., an array).
**Learning:** Godot 4's `JSON.parse()` returns a `Variant` in `json.data`. Unsafe casts of this `Variant` from user-controlled files lead to potential Application Denial of Service.
**Prevention:** Always validate `typeof(json.data) == TYPE_DICTIONARY` before assignment to a typed Dictionary in Godot.

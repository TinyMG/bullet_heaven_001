## 2024-05-24 - Unsafe JSON Parsing in Godot 4
**Vulnerability:** Parsing user-controlled JSON files (like save data or settings) and directly casting `json.data` to a Dictionary without type checking can cause runtime crashes if the file is tampered with or malformed.
**Learning:** Godot 4's `JSON.parse()` stores the result in `json.data` as a Variant. Implicitly or explicitly casting a Variant that is not actually a Dictionary (e.g., an array or a string) to a strongly-typed Dictionary will throw a runtime error, potentially crashing the application.
**Prevention:** Always verify `typeof(json.data) == TYPE_DICTIONARY` (or the expected type) before assigning the parsed data to a strictly typed variable.

## 2024-04-28 - Godot 4 JSON Type Validation
**Vulnerability:** In Godot 4, data parsed from local files via `JSON.new().parse()` is assigned to `Dictionary` without type checking. A maliciously crafted or corrupted file (e.g., parsing to an Array or primitive instead of Dictionary) could cause a runtime type cast crash.
**Learning:** `json.data` typing is dynamic and depends entirely on the file content. Implicit assignment to a strictly typed Dictionary (`var data: Dictionary = json.data`) is unsafe.
**Prevention:** Always verify the type of `json.data` using `typeof(json.data) == TYPE_DICTIONARY` before assignment to prevent runtime type errors.

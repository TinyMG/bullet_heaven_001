## 2025-05-01 - Insecure JSON Deserialization Crash

**Vulnerability:** Loading `user://save_data.json` and `user://settings.json` via `JSON.new().parse()` directly assigns `json.data` to a Dictionary variable without type-checking. A tampered or malformed file could crash the runtime.
**Learning:** In Godot 4, data parsed from local files via `JSON.new().parse()` must be strictly type-checked.
**Prevention:** Always verify `typeof(json.data) == TYPE_DICTIONARY` before treating parsed JSON data as a Dictionary.

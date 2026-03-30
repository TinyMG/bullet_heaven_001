## 2026-03-30 - Prevent Crash from Malformed JSON User Files
**Vulnerability:** Loading `user://save_data.json` and `user://settings.json` blindly casts `json.data` to a `Dictionary` without verifying the type. A maliciously crafted or corrupted file containing a different JSON type (e.g. an array or a primitive) causes a runtime crash when trying to access `.has()` or `.get()`.
**Learning:** In Godot 4, data parsed from local files via `JSON.parse()` must be explicitly type-checked before variable assignment, especially when accessing untrusted user storage.
**Prevention:** Always verify `typeof(json.data) == TYPE_DICTIONARY` before treating parsed JSON data as a Dictionary in GDScript.

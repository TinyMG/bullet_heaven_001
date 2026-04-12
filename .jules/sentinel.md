## 2024-04-12 - Insecure JSON Parsing Crash
**Vulnerability:** Assigning `JSON.parse()` output directly to statically typed variables (like `Dictionary`) crashes the game if the local file is tampered with (e.g. contains an array instead).
**Learning:** Godot 4's `JSON.parse` returns a `Variant`. If a user modifies `save_data.json` or `settings.json` to have an invalid root type, it bypasses parse errors but causes a runtime crash upon assignment.
**Prevention:** Always verify `typeof(json.data) == TYPE_DICTIONARY` before variable assignment when reading local JSON files.
## 2024-05-24 - Missing Type Check in JSON Deserialization
**Vulnerability:** Insecure Deserialization in parsing Godot local files. A crash could occur if a tampered file is parsed into `json.data` and strictly typed as a Dictionary when it is not.
**Learning:** Godot 4 `JSON.new().parse()` does not guarantee the type of the resulting `json.data`. Strictly type checking local files is critical to prevent runtime crashes.
**Prevention:** Always verify `typeof(json.data) == TYPE_DICTIONARY` (or the expected type) before variable assignment in Godot 4.

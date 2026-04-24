## 2024-05-24 - Fix Insecure JSON Deserialization in Godot 4
**Vulnerability:** Godot 4 `JSON.new().parse()` can return any data type, leading to potential type-casting crashes or insecure object creation when expecting a specific type like Dictionary and user file has been maliciously modified.
**Learning:** In Godot 4, parsed data from untrusted sources (like local save files or settings) must be explicitly type-checked (e.g. `typeof(json.data) == TYPE_DICTIONARY`) before variable assignment.
**Prevention:** Always validate the type of `json.data` after a successful `parse()` call before casting or accessing elements to prevent runtime crashes and ensure robust security.

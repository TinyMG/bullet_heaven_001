## 2024-04-16 - Insecure JSON Deserialization / Missing Type Validation
**Vulnerability:** In Godot 4, data parsed via `JSON.new().parse()` from user files was not type-checked before assignment to strongly-typed Dictionary variables.
**Learning:** Malformed or tampered local JSON files containing non-dictionary types (e.g., Arrays or primitive types) could cause runtime crashes when Godot attempts to cast the parsed data to a Dictionary.
**Prevention:** Always strictly type-check parsed JSON data (e.g., `typeof(json.data) == TYPE_DICTIONARY`) before assigning it to a typed variable.

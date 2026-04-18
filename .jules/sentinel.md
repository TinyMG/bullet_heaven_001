## 2026-04-18 - [Insecure JSON Deserialization]
**Vulnerability:** JSON parsed from user files (`save_data.json`, `settings.json`) is not type-checked before assignment to a Dictionary.
**Learning:** In Godot 4, parsing arbitrary JSON data does not guarantee the returned data type matches expectations. Malformed or tampered JSON arrays, strings, or numbers could be parsed and improperly assigned to a `Dictionary`, leading to a crash.
**Prevention:** Always use `typeof()` to validate `json.data` against the expected type (`TYPE_DICTIONARY`, `TYPE_ARRAY`) after calling `json.parse()` and before using or assigning the result.

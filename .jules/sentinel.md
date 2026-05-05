## 2024-05-24 - Missing Type Validation on Parsed JSON
**Vulnerability:** Insecure deserialization. `JSON.new().parse()` results were cast to dictionaries without validating the underlying data type first, potentially leading to crashes or unpredictable behavior if the file contents are tampered with.
**Learning:** In Godot 4, parsed JSON data (`json.data`) should be strictly type-checked (e.g., `typeof(json.data) == TYPE_DICTIONARY`) before casting or using dictionary methods.
**Prevention:** Always use `typeof()` to validate the structure of data retrieved from external sources like `user://` before assignment.

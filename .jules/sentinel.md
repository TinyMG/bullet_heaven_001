## 2024-05-24 - JSON Deserialization Type Validation
**Vulnerability:** Insecure JSON Deserialization missing type checks when parsing local save and settings files.
**Learning:** In Godot 4, data parsed from local files via `JSON.new().parse()` can be of any type. Assigning `json.data` to a strongly typed `Dictionary` variable without checking the type can cause runtime crashes if the user alters the JSON file.
**Prevention:** Always validate the type of deserialized JSON objects (e.g., `if typeof(json.data) != TYPE_DICTIONARY:`) before assigning or using them.

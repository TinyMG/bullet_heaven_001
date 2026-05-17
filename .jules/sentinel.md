## 2024-05-24 - Missing JSON Type Validation
**Vulnerability:** Parsed JSON data from files (user://) is assigned directly to a typed Dictionary variable (`var data: Dictionary = json.data`) without verifying the underlying type.
**Learning:** Godot's `JSON.new().parse()` can return Arrays or primitive types depending on the file contents. Direct typed assignment without checking can cause a runtime crash if the file is tampered with or malformed.
**Prevention:** Always verify `typeof(json.data) == TYPE_DICTIONARY` before using the parsed JSON data for dictionary operations.

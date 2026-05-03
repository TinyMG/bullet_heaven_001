## 2024-05-15 - Insecure JSON Deserialization in Save Files
**Vulnerability:** User-controlled JSON files (`save_data.json` and `settings.json`) were parsed and directly assigned to typed `Dictionary` variables without verifying the parsed data type.
**Learning:** In Godot 4, `JSON.new().parse()` can return arrays, numbers, strings, or null if the file contents are manipulated, causing a runtime crash when Godot attempts to cast it to a Dictionary.
**Prevention:** Always check `typeof(json.data) == TYPE_DICTIONARY` before casting or assigning parsed user data to Dictionary variables to ensure safe loading.

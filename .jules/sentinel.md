## 2024-04-19 - Missing Type Check on JSON Deserialization
**Vulnerability:** Game crashes from malformed/tampered local save files (`settings.json`, `save_data.json`) due to casting parsed JSON directly to Dictionary without type checking.
**Learning:** `JSON.new().parse()` can return any JSON type (Array, String, Int). Assigning this directly to a strongly-typed `var data: Dictionary = ...` variable in GDScript 4 causes runtime crashes if the type doesn't match.
**Prevention:** Always verify the parsed data type using `typeof(json.data) == TYPE_DICTIONARY` before assignment to prevent runtime type errors.

## 2024-05-24 - Missing Type Check in JSON Deserialization
**Vulnerability:** Parsed JSON data from local user files (`save_data.json` and `settings.json`) was directly assigned to a `Dictionary` variable without verifying its type.
**Learning:** `JSON.new().parse()` can return arrays or primitive types depending on the file's content. Assigning non-dictionary data to a strongly-typed `Dictionary` in Godot 4 causes a runtime crash, creating a Denial of Service risk via malformed or tampered local files.
**Prevention:** Always validate the type of parsed JSON data (e.g., `typeof(json.data) == TYPE_DICTIONARY`) before variable assignment or usage.

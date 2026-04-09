## 2024-04-09 - Ensure JSON Parse Data Type Match
**Vulnerability:** In Godot 4, data parsed from local files (e.g., user://save_data.json) via JSON.parse() can return non-Dictionary types if the file is tampered with or malformed.
**Learning:** Implicit assignment of json.data to a Dictionary variable when json.data is an array or primitive will cause runtime crashes.
**Prevention:** Always explicitly check the type of json.data (e.g., typeof(json.data) == TYPE_DICTIONARY) before assignment.

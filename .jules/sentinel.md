## 2024-05-30 - Insecure JSON Deserialization in Save/Settings Load
**Vulnerability:** Parsing JSON user files (`user://save_data.json` and `user://settings.json`) directly into a Dictionary without verifying the type of `json.data`.
**Learning:** Godot 4's `JSON.new().parse()` can return arrays, strings, or numbers depending on the file contents. Forcibly typing `json.data` as `Dictionary` when it's not will cause runtime errors/crashes, allowing players to purposefully or accidentally crash the game via save manipulation.
**Prevention:** Always verify the type using `typeof(json.data) == TYPE_DICTIONARY` before using the parsed data or casting it to a dictionary.

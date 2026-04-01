## 2026-04-01 - Prevent Local File JSON Deserialization Crashes
**Vulnerability:** Godot applications parsing local files (e.g. `user://save_data.json` or `user://settings.json`) assume the root structure is a Dictionary. An attacker or corrupted file could supply a JSON Array or primitives, leading to a hard crash/Denial of Service (DoS) due to invalid cast to Dictionary.
**Learning:** `JSON.parse()` successfully parses arrays and primitive types. We must explicitly validate `typeof(json.data) == TYPE_DICTIONARY` before using type inference (`var data: Dictionary = json.data`).
**Prevention:** Always strictly type-check parsed JSON data from disk or network using `typeof(json.data) == TYPE_DICTIONARY` before variable assignment.

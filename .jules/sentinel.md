## 2024-05-25 - [Insecure JSON Deserialization]
 **Vulnerability:** Unchecked JSON parsing in Godot 4 allows assignment of arbitrary types (like Arrays or Primitives) to Dictionary variables, causing runtime crashes if a user tampers with their local save or settings files.
 **Learning:** Godot 4 `JSON.new().parse()` does not enforce a top-level JSON Object structure; the resulting `json.data` could be any type.
 **Prevention:** Always type-check `json.data` (e.g., `typeof(json.data) == TYPE_DICTIONARY`) before casting it or utilizing it.
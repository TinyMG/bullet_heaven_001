## 2024-05-04 - Insecure JSON Deserialization Type Casting Crash
**Vulnerability:** Parsing JSON from a file via JSON.new().parse() and immediately casting json.data to a strongly typed Dictionary without checking its type. If a malicious or corrupted file contains a valid JSON array or string, this causes a GDScript runtime crash (Denial of Service).
**Learning:** json.parse() returning OK only guarantees valid JSON syntax, not the data structure type.
**Prevention:** Always verify typeof(json.data) == TYPE_DICTIONARY before using or assigning the parsed data to a Dictionary variable.

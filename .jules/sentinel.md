## 2024-04-05 - Insecure Deserialization in JSON Parse
**Vulnerability:** Parsing local JSON files (save_data.json, settings.json) without type-checking the parsed data type before assigning to Dictionary.
**Learning:** User files can be tampered with or become malformed. If json.data is not a Dictionary, assigning it to a statically typed Dictionary variable causes runtime crashes.
**Prevention:** Always strictly type-check json.data using typeof(json.data) == TYPE_DICTIONARY before assignment.
## 2024-05-28 - Distance Squared Optimization
**Learning:** In Godot, distance_to and length() compute square roots which are computationally expensive when called in tight loops like _physics_process or explosion logic.
**Action:** Replace distance_to with distance_squared_to and length() with length_squared(), ensuring thresholds are appropriately squared (e.g., radius_sq = radius * radius).
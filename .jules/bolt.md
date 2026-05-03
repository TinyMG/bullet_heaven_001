## 2024-05-24 - Optimizing Node Targeting in Godot
**Learning:** Querying nodes with `get_tree().get_nodes_in_group()` every frame in Godot creates significant overhead due to array allocations, especially when multiplied by many entities (like projectiles). Furthermore, `distance_to()` uses an expensive square root operation.
**Action:** Use a timer to cache nearest neighbor searches (e.g., every 0.2s) instead of running them every frame, and use `distance_squared_to()` for performance-critical proximity checks.

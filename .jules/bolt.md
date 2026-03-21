## 2026-03-21 - Optimize nearest enemy calculations in Godot
**Learning:** In Godot 4, finding the nearest node by iterating over a group using `global_position.distance_to()` involves expensive square root calculations which can be slow, particularly if executed every frame or repeatedly during combat in a loop.
**Action:** Use `global_position.distance_squared_to()` instead of `distance_to()` when comparing distances to find a minimum or a maximum, as it avoids the expensive `sqrt` calculation and directly compares squared distances, providing a substantial performance boost.

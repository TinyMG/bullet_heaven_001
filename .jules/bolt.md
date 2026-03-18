## 2024-10-24 - Distance queries in Godot
**Learning:** In Godot projects like this, `global_position.distance_to()` is used frequently in `_process` and `_physics_process` loops for finding targets and checking if things are in range. This invokes a square root calculation which is expensive when called often.
**Action:** Always prefer `global_position.distance_squared_to()` and squared distance values for comparisons when measuring distance instead of actual lengths.

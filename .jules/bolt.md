## 2025-02-12 - Caching nearest target and distance squared

**Learning:** Calling `get_tree().get_nodes_in_group()` every frame in Godot allocates an array, which is a major bottleneck in `_physics_process` for entities like homing projectiles. Additionally, using `distance_to` requires an expensive square root.
**Action:** Use a timer interval (e.g. 0.2s) to cache target selection instead of re-evaluating every frame, and use `distance_squared_to` with squared thresholds for distance comparisons.

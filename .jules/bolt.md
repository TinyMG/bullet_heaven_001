## 2024-05-23 - Avoid get_nodes_in_group and distance_to every frame
**Learning:** Calling `get_tree().get_nodes_in_group()` and `distance_to()` (which uses square root) every frame in `_physics_process` for multiple projectiles causes massive CPU bottleneck and array allocations.
**Action:** Cache the nearest target and only re-evaluate on a timer (e.g., 0.2s) or when the target is null. Use `distance_squared_to()` for distance comparisons by squaring the radius. Reset cached targets in `activate()` for pooled entities.

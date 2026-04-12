## 2024-04-12 - Caching and Distance Squared in Godot Object Pools
**Learning:** Calling `get_tree().get_nodes_in_group()` every frame per projectile creates a significant bottleneck due to array allocation. Also, `distance_to()` uses a slow square root calculation.
**Action:** Implement a target caching timer (e.g., 0.2s) in `_physics_process`, handle pooling resets in `activate()`, and always use `distance_squared_to()` with squared thresholds.

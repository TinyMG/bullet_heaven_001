## 2026-04-23 - Target caching in Godot physics
**Learning:** Querying groups like `get_tree().get_nodes_in_group()` every frame in `_physics_process` causes massive array allocation overhead and frame drops.
**Action:** Use a timer interval (e.g., 0.2s) to cache targets and use `distance_squared_to` over `distance_to` to eliminate expensive square root calculations.

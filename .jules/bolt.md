## 2024-05-24 - Node caching to prevent get_nodes_in_group bottlenecks
**Learning:** Querying `get_tree().get_nodes_in_group()` every frame (e.g. in `_physics_process` for every projectile) causes massive array allocation overhead and framerate drops.
**Action:** Cache the target node, refresh it periodically (e.g. every 0.2s) instead of every frame, and use `distance_squared_to` with squared thresholds to optimize nearest neighbor checks.

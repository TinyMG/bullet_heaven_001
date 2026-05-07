## 2026-05-07 - Optimize HomingProjectile Distance and Target Search
**Learning:** Querying the scene tree for nodes in a group and calculating 'distance_to()' every frame for multiple homing projectiles creates a major performance bottleneck due to array allocations and square root calculations.
**Action:** Cache the target node with a short search timer (e.g., 0.2s) to significantly reduce get_tree().get_nodes_in_group() calls per frame. Use 'distance_squared_to()' instead of 'distance_to()' with pre-squared thresholds to avoid expensive square root math.

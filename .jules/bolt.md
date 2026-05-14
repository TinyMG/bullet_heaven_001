## 2024-05-24 - Optimize Homing Targeting & Distance Calculations
**Learning:** Calling `get_tree().get_nodes_in_group("Enemy")` every frame in projectile tracking causes excessive array allocations. In addition, using `distance_to` forces an expensive square root operation.
**Action:** Implemented a timer-based caching interval (e.g., 0.2s) for targeting nearest neighbors, and replaced `distance_to()` with `distance_squared_to()`, comparing against squared thresholds.

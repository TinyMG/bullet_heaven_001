
## 2024-11-20 - [Caching Targets and Distance Squared Optimization in Homing Projectiles]
**Learning:** Querying `get_nodes_in_group` every frame and calculating exact distances with `distance_to` (which uses an expensive square root operation) within a `_physics_process` loop causes significant performance bottlenecks, especially when many target-seeking projectiles are active.
**Action:** When working with target tracking or homing logic, always cache the target using a search timer (e.g., updating every 0.2s) and compare distances using `distance_squared_to()` instead of `distance_to()` to avoid expensive square root calculations. Ensure cached targets are checked for validity (`not is_instance_valid`) before using them.

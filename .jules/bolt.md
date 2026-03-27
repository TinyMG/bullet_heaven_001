## 2025-03-27 - [Optimize Distance Calculations]
 **Learning:** Using `distance_to` runs an expensive square root operation, which becomes a performance bottleneck when checking distances to multiple objects every frame (e.g. `_find_nearest_enemy()`).
 **Action:** Prefer `distance_squared_to` and compare against the squared radius (`radius_sq`) instead, especially in hot paths like `_physics_process` or `_process` loops.

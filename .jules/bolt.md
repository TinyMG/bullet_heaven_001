## YYYY-MM-DD - [Title]
 **Learning:** [Insight]
 **Action:** [How to apply next time]

## 2024-05-17 - Minimize get_tree().get_nodes_in_group and distance computations in physics loop
**Learning:** Calling `get_tree().get_nodes_in_group("Enemy")` every frame in `_physics_process` (as seen in `homing_projectile.gd`) causes severe array allocation bottlenecks. Additionally, using `distance_to()` which computes a square root for each enemy check is expensive.
**Action:** Use cached variables and a target refresh timer (e.g., check every 0.1-0.2 seconds instead of every frame) and use `distance_squared_to()` instead of `distance_to()`. When working with pooled objects, ensure the cache and timers are properly reset in the `activate()` method.

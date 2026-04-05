## 2024-05-24 - Target Caching for Performance
**Learning:** Calling `get_tree().get_nodes_in_group("Enemy")` every frame per homing projectile in `_physics_process` causes massive slowdowns due to array allocations. Also, `distance_to()` is expensive due to square roots.
**Action:** Use a timer interval (e.g. 0.2s) to cache targets and switch `distance_to()` to `distance_squared_to()` for performance comparisons. Check validity of cached targets with `_target != null and not is_instance_valid(_target)`.

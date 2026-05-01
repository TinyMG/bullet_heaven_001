## 2024-05-01 - Optimize Homing Projectile Targeting
**Learning:** Querying nodes with get_tree().get_nodes_in_group() every frame is a major bottleneck due to array allocation. Godot's global_position.distance_to() uses expensive square roots.
**Action:** Use caching mechanisms or timer intervals (e.g., 0.2s) for targeting logic instead. Use global_position.distance_squared_to() over distance_to() for performance comparisons to avoid expensive square root calculations.

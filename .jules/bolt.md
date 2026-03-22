
## 2024-05-18 - Optimized HomingProjectile Targeting Array Allocation
**Learning:** `get_tree().get_nodes_in_group("Enemy")` every frame is a major bottleneck due to array allocation.
**Action:** Use a timer interval (e.g., 0.15s) for targeting and nearest neighbor logic to cache the target. Also replace `distance_to()` with `distance_squared_to()` for comparison to avoid expensive square root calculations.

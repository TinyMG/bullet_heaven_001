## 2024-05-15 - Group Array Allocation Bottleneck
**Learning:** Querying `get_tree().get_nodes_in_group("Enemy")` every frame in the `_physics_process` of projectiles causes a significant performance bottleneck due to continuous array allocation.
**Action:** Cache the target node and only requery at timed intervals (e.g. 0.2s) to drastically reduce array allocations. Also use `distance_squared_to()` instead of `distance_to()` to avoid expensive square root calculations during the distance check.

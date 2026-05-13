## 2024-05-13 - Player Enemy Query Array Every Frame Bottleneck
**Learning:** Querying `get_tree().get_nodes_in_group("Enemy")` every frame or on every fire tick for the Player causes a performance bottleneck due to continuous array allocation and nested loop iteration across all enemies.
**Action:** Use a short timer (e.g. 0.2s) to cache the nearest target and use `distance_squared_to()` to avoid costly square root calculations.

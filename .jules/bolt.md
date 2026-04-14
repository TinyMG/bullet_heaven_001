## 2024-05-15 - [Get nodes in group performance]
**Learning:** Using `get_tree().get_nodes_in_group("Enemy")` every frame or on every collision, especially inside loops, is a major performance bottleneck due to array allocation. Using `distance_to` in these loops is also slow because of the square root calculation.
**Action:** Replace `distance_to` with `distance_squared_to` and use distance squared thresholds. Cache group lookups or avoid calling them multiple times unnecessarily.

## 2024-05-24 - Optimize get_nodes_in_group and distance_to
**Learning:** Using `distance_to` inside loops over large groups like `get_tree().get_nodes_in_group("Enemy")` every frame is a major bottleneck due to square root calculations and array allocation.
**Action:** Cache the nearest enemy using a timer and validate it with `is_instance_valid()`, and use `distance_squared_to()` to avoid the square root math when querying nearest neighbors.

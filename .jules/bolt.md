## 2024-05-24 - [Godot Array Allocation and Distance Optimization]
**Learning:** Querying `get_tree().get_nodes_in_group()` every frame in Godot allocates a new Array each time. In a bullet heaven game with hundreds of entities, this creates significant garbage collection pressure and frame stutters. Furthermore, using `distance_to()` is slower than `distance_squared_to()` due to the square root operation.
**Action:** Always cache group node queries using a timer (e.g. 0.2s interval) instead of per-frame polling, and use `distance_squared_to` when comparing distances.

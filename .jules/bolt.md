## 2024-05-18 - Caching get_tree().get_nodes_in_group() in physics loops
**Learning:** Calling `get_tree().get_nodes_in_group()` every frame in `_physics_process` is a major performance bottleneck in Godot due to constant array allocation. Additionally, `distance_to()` is costly due to the square root operation.
**Action:** Use `distance_squared_to()` to avoid square roots, and add caching for nearest-target lookups using a small interval (e.g., 0.2s) to drastically reduce the number of times `get_nodes_in_group` is called.

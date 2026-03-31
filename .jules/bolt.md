## 2024-05-24 - [Avoid get_nodes_in_group every frame]
**Learning:** For Godot performance optimizations, querying nodes with `get_tree().get_nodes_in_group()` every frame is a major bottleneck due to array allocation.
**Action:** Use caching mechanisms or timer intervals (e.g., 0.2s) for targeting and nearest neighbor logic instead.

## 2024-05-24 - [Distance Squared instead of Distance]
**Learning:** In Godot projects, prefer `global_position.distance_squared_to()` over `global_position.distance_to()`, and `length_squared()` over `length()`, for performance comparisons to avoid expensive square root calculations, especially in `_process` or `_physics_process` loops.
**Action:** Replace length and distance_to with length_squared and distance_squared_to where applicable when comparing distances against constants.

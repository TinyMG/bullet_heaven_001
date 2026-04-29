## 2024-05-24 - Cache Object Reference Instead of Querying Every Frame
**Learning:** For Godot performance optimizations, querying nodes with `get_tree().get_nodes_in_group()` every frame is a major bottleneck due to array allocation.
**Action:** Use caching mechanisms or timer intervals (e.g., 0.2s) for targeting and nearest neighbor logic instead. Additionally, utilize `distance_squared_to()` instead of `distance_to()` to avoid expensive square root calculations in distance comparisons.

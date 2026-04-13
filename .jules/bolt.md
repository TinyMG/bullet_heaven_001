## 2024-05-24 - Target Caching and Distance Squared Optimization
**Learning:** Querying `get_tree().get_nodes_in_group()` every frame is a major bottleneck due to array allocation. Using `distance_to()` requires expensive square root calculations.
**Action:** Cache targets and refresh on a timer interval (e.g., 0.2s) instead of per-frame. Use `distance_squared_to()` and square the distance threshold variables or comparison constants for performance optimization.

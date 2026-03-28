## 2024-05-24 - Node Group Queries and Math Operations in Process Loops
**Learning:** Calling `get_tree().get_nodes_in_group("Enemy")` every frame allocates a new array, causing a major bottleneck. Additionally, using `distance_to()` and `length()` calculates an expensive square root.
**Action:** Use a timer interval (e.g., 0.2s) to cache nearest targets instead of querying every frame, and prefer `distance_squared_to()` and `length_squared()` for performance comparisons.

## 2024-05-24 - Node Group Queries and Distance Calculations
**Learning:** Calling `get_tree().get_nodes_in_group()` every frame allocates arrays and becomes a major bottleneck, especially for pooled entities like projectiles. Additionally, using `distance_to` calculates expensive square roots.
**Action:** Use cached target variables with timer intervals (e.g., 0.2s) instead of querying every frame, and prefer `distance_squared_to` with squared thresholds to eliminate square root overhead.

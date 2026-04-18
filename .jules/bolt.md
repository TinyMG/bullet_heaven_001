## 2026-04-18 - Cached Target Queries
**Learning:** Querying get_nodes_in_group() every frame in _physics_process for targeting is a major bottleneck.
**Action:** Use a timer to cache targeting queries (e.g., 0.2s intervals) and distance_squared_to() instead of distance_to().

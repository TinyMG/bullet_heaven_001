
## 2024-05-24 - Optimize group queries and distance calculations
**Learning:** Querying get_nodes_in_group() every frame in heavily instantiated objects like projectiles causes severe bottlenecks due to array allocation. Additionally, distance_to() performs slow square root math.
**Action:** Use interval-based caching (e.g. 0.2s) for targeting logic and distance_squared_to() with dynamically computed squared thresholds to bypass expensive operations and preserve stat scaling.

## 2024-05-24 - Optimize Entity Queries and Distance Calculation
**Learning:** Calling `get_tree().get_nodes_in_group("Enemy")` every frame per projectile, combined with `distance_to` (which performs square root calculations) is a significant bottleneck, especially with many instances on screen.
**Action:** Use cached target variables with timers (e.g., updating every 0.2s) instead of querying every frame. Use `distance_squared_to` with squared thresholds to avoid square root calculations in distance checks.

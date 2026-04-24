## 2024-05-18 - Avoid frequent tree queries and distance calculations
**Learning:** In Godot, calling `get_tree().get_nodes_in_group("Enemy")` every frame per projectile and doing `distance_to` calculations is a major performance bottleneck due to array allocations and expensive square root operations.
**Action:** Cache the target node with a timer and use `distance_squared_to` along with squared thresholds for distance checks to improve efficiency.

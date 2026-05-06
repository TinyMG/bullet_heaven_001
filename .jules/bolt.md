## 2024-05-30 - Optimized Godot Projectile Nearest Enemy Calculations
**Learning:** In Godot, calculating nearest enemies every frame using `distance_to` combined with `get_nodes_in_group` causes significant allocation and calculation bottlenecks.
**Action:** Replaced `distance_to` with `distance_squared_to` comparing against squared radius limits and implemented target caching with a 0.2s interval to drastically reduce frame-by-frame computational overhead.

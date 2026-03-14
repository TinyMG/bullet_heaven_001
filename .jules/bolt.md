## 2024-03-14 - Optimized distance calculations in hot loops
**Learning:** In a Bullet Heaven game with hundreds of enemies, calling `distance_to()` inside `_physics_process` or loops over all enemies creates a massive performance bottleneck because it performs a relatively expensive square root calculation for every enemy on screen.
**Action:** Always use `distance_squared_to()` and compare against the squared distance threshold instead of `distance_to()` when checking distances in hot paths or N-body iterations.

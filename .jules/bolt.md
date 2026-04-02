## 2026-04-02 - Optimize Homing Projectile Targeting
**Learning:** Querying Godot's scene tree via `get_tree().get_nodes_in_group()` every frame causes severe performance drops due to array allocation. Using `distance_to` also calculates expensive square roots.
**Action:** Use time-throttled targeting caches (e.g., search every 0.2s) and replace `distance_to` with `distance_squared_to` for hot-path distance comparisons.

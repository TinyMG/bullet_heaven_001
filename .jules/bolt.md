## 2024-05-19 - Player _find_nearest_enemy performance
**Learning:** In a bullet heaven game where there can be many enemies on screen, calling `get_tree().get_nodes_in_group("Enemy")` every frame to find the nearest enemy to shoot is a major performance bottleneck, as it creates an array and iterates over all enemies constantly.
**Action:** When a method that finds nearest elements from a group is called frequently (like auto-firing logic on a timer), it is important to optimize it.

## 2024-05-19 - Expensive `get_tree().get_nodes_in_group("Enemy")`
**Learning:** `get_nodes_in_group` allocates a new Array and iterates all nodes in a group. It is heavily used in `_physics_process` of `HomingProjectile` and in `_process`/`_physics_process` of `Player` (for animation/targeting) and `MinimapDraw`. HomingProjectile calls it every physics frame per projectile, which is O(N * M) where N is projectiles and M is enemies! This is a massive CPU bottleneck.
**Action:** Instead of querying the SceneTree every frame for every projectile/player, use a global cached list of active enemies. Since enemies are pooled and emit `activate`/`release`, or just maintain an array in an Autoload like `GameManager.active_enemies` and update it when an enemy is added/removed from the pool. Or even simpler, optimize HomingProjectile by caching the target or updating the nearest target less frequently (e.g. every 0.1s instead of every physics frame).

## 2024-05-19 - Expensive distance checks
**Learning:** Checking `global_position.distance_to` iterates distance which uses square root. `distance_squared_to` is much faster for comparisons.
**Action:** Replace `distance_to` with `distance_squared_to` in hot loops like `_find_nearest_enemy` where the distance itself is only used for comparison. Also, caching `get_nodes_in_group("Enemy")` in a central location or per-frame would dramatically improve performance.

## 2026-04-11 - Caching Godot Group Queries
**Learning:** Querying `get_tree().get_nodes_in_group()` every frame (e.g. in `_physics_process`) causes significant array allocation overhead and slows down performance. `distance_to` is also expensive because of the square root.
**Action:** Cache the targeted node in a variable (`_target`) and use a small timer (`0.2`s) to refresh the query. Use `distance_squared_to` for distance comparisons.

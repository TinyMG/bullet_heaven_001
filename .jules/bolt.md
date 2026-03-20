## 2024-05-15 - [Initial setup]
 **Learning:** [No previous learnings]
 **Action:** [N/A]
\n## 2026-03-20 - [Reduce per-frame array allocations and expensive distance checks]\n**Learning:** In Godot, calling `get_tree().get_nodes_in_group()` allocates a new array, which causes garbage collection overhead if done every frame in `_physics_process`. Also, using `distance_to` triggers a float square root which is expensive in heavy loops (e.g., iterating hundreds of enemies/particles).\n**Action:** Use `distance_squared_to` whenever comparing against a known radius, and cache `get_nodes_in_group()` queries inside a timer logic (e.g. refresh every 0.2s) instead of running them per frame.

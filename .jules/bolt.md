## 2024-05-18 - Avoid get_tree().get_nodes_in_group() in loops/process
**Learning:** Calling `get_tree().get_nodes_in_group()` inside an `_physics_process` or `_process` function creates an array copy every frame, significantly dropping performance as entity count increases (e.g., in a BulletHeaven game with many projectiles).
**Action:** Use a cached array, area nodes, or spatial partitioning instead of calling `get_nodes_in_group` directly in a loop or per frame.

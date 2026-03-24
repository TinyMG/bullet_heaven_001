## 2024-05-24 - [Avoid square root allocations in Godot distance calculations]
 **Learning:** Calculating distances and lengths using `distance_squared_to()` and `length_squared()` is much faster in Godot than using `distance_to()` and `length()` because it avoids expensive square root calculations, particularly in `_physics_process` and loops iterating over many nodes.
 **Action:** Always use `distance_squared_to()` and compare it to distance * distance. Use `length_squared()` and compare it to 0.0 or length * length.

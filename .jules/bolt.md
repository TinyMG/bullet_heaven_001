## 2026-04-22 - Optimize Distance Calculations
 **Learning:** In Godot 4, `distance_to()` uses an expensive square root operation. In tight `_physics_process` loops or multiple entity proximity checks (like finding nearest enemies or collecting objects), this scales poorly as entity counts increase.
 **Action:** Replaced `distance_to()` with `distance_squared_to()` across all projectiles, player nearest neighbor logic, and collectible items (xp gems, loot drops). Thresholds were squared accordingly. Never use `distance_to()` when just comparing distances.

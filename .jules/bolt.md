
## 2024-05-23 - Avoid Expensive Square Root Calculations in Loops
**Learning:** `distance_to` and `length` methods in Godot calculate the square root to determine distance and vector lengths, which is expensive when queried rapidly, such as in `_process` or `_physics_process` loops across many entities (like projectiles, drops, and enemies).
**Action:** Replace `distance_to` and `length` with `distance_squared_to` and `length_squared`, respectively, and square the comparative threshold variables to maintain the same logic with better performance.

## 2026-04-21 - Optimize Distance Calculations
**Learning:** The Godot `distance_to()` function calculates a square root, which is computationally expensive when used frequently, especially inside physics loops and loops iterating over many enemies.
**Action:** Replace `distance_to()` with `distance_squared_to()` and square the comparison threshold where possible to optimize performance in tight loops and update the threshold values accordingly.

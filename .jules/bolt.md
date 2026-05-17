
## 2026-05-17 - Homing Projectile Physics Process Bottleneck
**Learning:** Querying get_nodes_in_group('Enemy') and running distance_to() every frame in _physics_process for pooled objects creates an O(P*E) performance bottleneck.
**Action:** Cache targets with a timer interval (e.g. 0.2s) and use distance_squared_to() to avoid expensive square root and array allocation.

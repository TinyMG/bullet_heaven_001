## 2025-05-09 - Godot get_nodes_in_group array allocation bottleneck
**Learning:** Calling get_tree().get_nodes_in_group() every frame in _physics_process allocates a new array each time, causing a significant performance bottleneck, especially for projectiles that live for multiple frames.
**Action:** Use a timer mechanism (e.g. 0.2s intervals) to cache the target for a few frames rather than querying the scene tree every single frame.

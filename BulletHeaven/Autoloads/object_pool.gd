extends Node

## ObjectPool Autoload
## Manages reusable object pools to avoid instantiate/queue_free overhead on mobile.

# pool_key (scene path) -> Array of inactive nodes
var _pools: Dictionary = {}

func get_instance(scene: PackedScene) -> Node:
	var key = scene.resource_path
	if _pools.has(key) and not _pools[key].is_empty():
		var node = _pools[key].pop_back()
		return node
	# Pool empty — create a new instance
	return scene.instantiate()

func release_node(node: Node) -> void:
	if not is_instance_valid(node):
		return
	# Visibility and processing already disabled by the caller's _release()
	# Keep node in tree — just store reference for reuse
	var key = ""
	if node.scene_file_path != "":
		key = node.scene_file_path
	elif node.has_meta("pool_key"):
		key = node.get_meta("pool_key")
	else:
		# Can't pool without a key — just free it
		node.queue_free()
		return

	if not _pools.has(key):
		_pools[key] = []
	_pools[key].append(node)

func clear_all() -> void:
	for key in _pools:
		for node in _pools[key]:
			if is_instance_valid(node):
				node.queue_free()
	_pools.clear()

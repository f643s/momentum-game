class_name Shockwave
extends RefCounted
## Pushes everything in the "knockable" group away from a point.

## Returns how many things were hit.
static func blast(tree: SceneTree, origin: Vector3, radius: float, push: float, pop: float) -> int:
	var hit: int = 0
	for node in tree.get_nodes_in_group("knockable"):
		var body := node as Node3D
		if body == null or not body.has_method("apply_knockback"):
			continue
		var offset: Vector3 = body.global_position - origin
		offset.y = 0.0
		var dist: float = offset.length()
		if dist > radius:
			continue
		# 1.0 at the center, 0.3 at the edge.
		var strength: float = 1.0 - 0.7 * dist / radius
		var dir: Vector3 = offset.normalized() if dist > 0.01 else Vector3.ZERO
		body.call("apply_knockback", dir * push * strength + Vector3.UP * pop)
		hit += 1
	return hit

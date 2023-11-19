extends RigidBody3D

var merging : bool = false
var claw_tip : Node3D = null

func _physics_process(delta):
	if freeze:
		global_position = claw_tip.global_position
	if $Area3D.has_overlapping_bodies():
		print("has overlapping bodies")
		var all_bodies = $Area3D.get_overlapping_bodies()
		for body in all_bodies:
			if body is RigidBody3D:
				body.apply_central_impulse((body.global_position - global_position).normalized()*5)
				print("applying extra forces")
		$Area3D/CollisionShape3D.disabled = true

func _on_body_entered(body):
	if !(body is RigidBody3D):
		return
	if freeze or body.freeze:
		return
	if body.is_in_group("cat_5"):
		merge(body)

func merge(another_body :RigidBody3D):
	if merging or another_body.merging:
		return
	merging = true
	another_body.call_deferred("queue_free")
	call_deferred("queue_free")
	var merge_scene = load("res://cat_6.tscn")
	var merge_instance = merge_scene.instantiate()
	merge_instance.freeze = false
	get_tree().get_root().add_child(merge_instance)
	merge_instance.global_position = global_position
	merge_instance.claw_tip = claw_tip
	get_tree().get_nodes_in_group("main")[0].add_score(5)

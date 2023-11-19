extends Node3D

var cats = [preload("res://cat_1.tscn"), preload("res://cat_2.tscn")]
var claw_speed = 10
var cat_instance = null
var cat_order = [0, 0]
var score = 0


func _ready():
	spawn_next_cat.call_deferred()

func spawn_next_cat():
	cat_instance = cats[cat_order[0]].instantiate()
	refresh_cat_order()
	get_tree().get_root().add_child(cat_instance)
	cat_instance.set_global_position($ArmFull/Link1/Tip.global_position)
	cat_instance.claw_tip = $ArmFull/Helper

func refresh_cat_order():
	cat_order[0] = cat_order[1]
	cat_order[1] = randi_range(0, 1)

func _process(delta):
	var rotation_input = int(Input.is_action_pressed("E")) - int(Input.is_action_pressed("Q"))
	var claw_input = Vector3(int(Input.is_action_pressed("A")) - int(Input.is_action_pressed("D")), 0, 
							int(Input.is_action_pressed("W")) - int(Input.is_action_pressed("S")))
	$CameraPivot.rotate_y(PI / 2 * delta * rotation_input)
	$ArmFull/Arm.move_and_collide(claw_input * claw_speed * delta)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		cat_instance.freeze = false
		cat_instance.linear_velocity = $ArmFull/Helper.linear_velocity*1.5
		cat_instance.angular_velocity = $ArmFull/Helper.angular_velocity
		var timer = get_tree().create_timer(1.0)
		timer.timeout.connect(_on_timer_timeout)
	if event.is_action_pressed("camera_front"):
		$CameraPivot.rotation = Vector3(0, 0, 0)
	if event.is_action_pressed("camera_right"):
		$CameraPivot.rotation = Vector3(0, PI/2, 0)
	if event.is_action_pressed("camera_back"):
		$CameraPivot.rotation = Vector3(0, PI, 0)
	if event.is_action_pressed("camera_left"):
		$CameraPivot.rotation = Vector3(0, 3*PI/2, 0)

func _on_timer_timeout():
	spawn_next_cat()

func add_score(value : int):
	score += 5 * value + 1
	$CanvasLayer/Control/HSplitContainer/Score.text = str(score)

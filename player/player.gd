extends CharacterBody3D

@export_category("Movement")
@export var speed = 5.0

@export_category("Jump and Gravity")
@export var fall_gravity = 40
@export var jump_height = 2
@export var jump_apex_duration = 0.5
@export var on_floor_blend_change_rate = 7.0

@export_category("Camera")
@export var mouse_sensitivity = 0.1
@export var rotation_smooth_time = 0.1
@export var min_yaw: float = 0
@export var max_yaw: float = 360
@export var min_pitch: float = -89.9
@export var max_pitch: float = 50

@onready var camera_pivot: Node3D = %CameraPivot

var jump_gravity : float = fall_gravity
var target_rotation

var _pcam: PhantomCamera3D
var _main_camera: Camera3D
var _mouse_captured: bool

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_mouse_captured = true
	_main_camera = get_tree().get_first_node_in_group("main_camera")

func _physics_process(delta: float) -> void:
	_quit()
	_handle_cursor()
	_gravity(delta)
	_jump()
	_move()
	move_and_slide()

func _move() -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	if direction:
		target_rotation = atan2(-direction.x, -direction.z) + _main_camera.rotation.y
		rotation.y = lerp_angle(rotation.y, target_rotation, rotation_smooth_time)
		var forward_direction = -transform.basis.z
		velocity.x = forward_direction.x * speed
		velocity.z = forward_direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _gravity(delta):
	if not is_on_floor():
		if velocity.y >= 0:
			velocity.y -= jump_gravity * delta
		else:
			velocity.y -= fall_gravity * delta

func _jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 2 * jump_height / jump_apex_duration
		jump_gravity = velocity.y / jump_apex_duration

func _quit() -> void:
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()

func _handle_cursor() -> void:
	if Input.is_action_just_pressed("tab"):
		_mouse_captured = not _mouse_captured
		if _mouse_captured:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

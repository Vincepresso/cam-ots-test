extends Node3D

@export var mouse_sensitivity = 0.1
@export var min_yaw: float = 0
@export var max_yaw: float = 360
@export var min_pitch: float = -89.9
@export var max_pitch: float = 50

@onready var right_shoulder: Node3D = %RightShoulder
@onready var left_shoulder: Node3D = %LeftShoulder

var _ots_pcam_right: PhantomCamera3D
var _ots_pcam_left: PhantomCamera3D
var _tps_pcam: PhantomCamera3D

var _side: String = "none"

func _ready() -> void:
	_ots_pcam_right = get_tree().get_first_node_in_group("ots_pcam_right")
	_ots_pcam_left = get_tree().get_first_node_in_group("ots_pcam_left")
	_tps_pcam = get_tree().get_first_node_in_group("tps_pcam")
	top_level = true
	_change_to_tps()

func _physics_process(delta):
	global_position = owner.global_position

func _process(delta: float) -> void:
	_change_shoulder()

func _unhandled_input(event: InputEvent) -> void:
	_handle_look(event)

func _handle_look(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		if _side != "none":
			rotation_degrees.y -= event.relative.x * mouse_sensitivity
			rotation_degrees.y = wrapf(rotation_degrees.y, min_yaw, max_yaw)
			
			right_shoulder.rotation_degrees.x -= event.relative.y * mouse_sensitivity
			right_shoulder.rotation_degrees.x = clampf(right_shoulder.rotation_degrees.x, min_pitch, max_pitch)

			left_shoulder.rotation_degrees.x -= event.relative.y * mouse_sensitivity
			left_shoulder.rotation_degrees.x = clampf(left_shoulder.rotation_degrees.x, min_pitch, max_pitch)
		else:
			var pcam_rotation_degrees: Vector3
			pcam_rotation_degrees = _tps_pcam.get_third_person_rotation_degrees()
			pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity
			pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_pitch, max_pitch)
			pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity
			pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_yaw, max_yaw)
			_tps_pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)


func _change_shoulder() -> void:
	if Input.is_action_just_pressed("right_shoulder") and _side != "right":
		_change_to_right_shoulder()
	elif Input.is_action_just_pressed("left_shoulder") and _side != "left":
		_change_to_left_shoulder()
	elif Input.is_action_just_pressed("no_shoulder") and _side != "none":
		_change_to_tps()

func _change_to_tps() -> void:
	_ots_pcam_right.priority = 0
	_ots_pcam_left.priority = 0
	_tps_pcam.priority = 100
	_side = "none"

func _change_to_right_shoulder() -> void:
	_ots_pcam_right.priority = 100
	_ots_pcam_left.priority = 0
	_tps_pcam.priority = 0
	_side = "right"

func _change_to_left_shoulder() -> void:
	_ots_pcam_right.priority = 0
	_ots_pcam_left.priority = 100
	_tps_pcam.priority = 0
	_side = "left"

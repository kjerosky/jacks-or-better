class_name Card
extends Node3D

@export var flip_pivot : Node3D
@export var face_mesh : MeshInstance3D

var face_material : StandardMaterial3D

static var half_flip_position_offset := Vector3(0, 2, 0)
static var half_flip_seconds := 0.2
static var half_flip_z_angle_delta := -90.0
static var full_flip_z_angle_delta := -180.0

static var rotate_before_slide_seconds := 0.5
static var slide_move_seconds := 1.0
static var straighten_seconds := 0.5


func _ready():
	face_material = face_mesh.get_active_material(0)
	
	#TODO REMOVE THIS AND SETUP EXTERNALLY
	var rank := randi() % 13
	var suit := randi() % 4
	setup(rank, suit)


func _process(_delta):
	if Input.is_action_just_pressed("TEMP_action"):
		flip(func():
			slide_to(Vector3(0, 0, -3.25), func():
				straighten(func(): pass)
			)
		)


func setup(rank: int, suit: int):
	flip_pivot.rotation_degrees.z = -180.0
	
	face_material.uv1_offset.x = 1.0 / 14 * rank
	face_material.uv1_offset.y = 1.0 / 4 * suit


func flip(callback: Callable):
	if flip_pivot.rotation_degrees.z <= -360.0:
		flip_pivot.rotation_degrees.z += 360.0
	
	var start_position = position;
	
	var pivot_halfway_rotation_degrees = flip_pivot.rotation_degrees + Vector3(0, 0, half_flip_z_angle_delta)
	var pivot_final_rotation_degrees = flip_pivot.rotation_degrees + Vector3(0, 0, full_flip_z_angle_delta)
	
	var flip_tween := create_tween()
	flip_tween.set_parallel(true)
	flip_tween.tween_property(flip_pivot, "rotation_degrees", pivot_halfway_rotation_degrees, half_flip_seconds)
	flip_tween.tween_property(self, "position", start_position + half_flip_position_offset, half_flip_seconds)
	flip_tween.chain()
	flip_tween.tween_property(flip_pivot, "rotation_degrees", pivot_final_rotation_degrees, half_flip_seconds)
	flip_tween.tween_property(self, "position", start_position, half_flip_seconds)
	flip_tween.chain()
	flip_tween.tween_callback(callback)


func slide_to(destination: Vector3, callback: Callable):
	var direction_to_destination := global_position.direction_to(destination)
	var angle_y_to_destination = Vector3.FORWARD.signed_angle_to(direction_to_destination, Vector3.UP)
	var facing_dealer_quaternion := Quaternion.from_euler(Vector3(0, angle_y_to_destination, 0))
	
	var slide_tween := create_tween()
	slide_tween.set_parallel(true)
	slide_tween.tween_property(self, "quaternion", facing_dealer_quaternion, rotate_before_slide_seconds).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	slide_tween.tween_property(self, "position", destination, slide_move_seconds).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	slide_tween.chain()
	slide_tween.tween_callback(callback)


func straighten(callback: Callable):
	var straighten_tween := create_tween()
	straighten_tween.tween_property(self, "quaternion", Quaternion.IDENTITY, straighten_seconds)
	straighten_tween.tween_callback(callback)

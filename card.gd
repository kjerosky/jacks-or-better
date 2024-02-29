class_name Card
extends Node3D

@export var face_mesh : MeshInstance3D

var face_material : StandardMaterial3D

var is_flipping = false

static var half_flip_position_offset := Vector3(0, 2, 0)
static var half_flip_seconds := 0.2
static var face_up_quaternion := Quaternion.from_euler(Vector3(0, 0, deg_to_rad(0)))
static var face_down_quaternion := Quaternion.from_euler(Vector3(0, 0, deg_to_rad(-180)))
static var half_flip_quaternion := Quaternion.from_euler(Vector3(0, 0, deg_to_rad(-90)))


func _ready():
	face_material = face_mesh.get_active_material(0)
	#face_material.uv1_offset.x = face_value * 0.5

func _process(_delta):
	if Input.is_action_just_pressed("flip_card") and not is_flipping:
		is_flipping = true
		
		var facing_quaternion = face_up_quaternion
		if quaternion == face_up_quaternion:
			facing_quaternion = face_down_quaternion
		
		var start_position = position;
		
		var flip_tween := create_tween()
		flip_tween.set_parallel(true)
		flip_tween.tween_property(self, "quaternion", half_flip_quaternion, half_flip_seconds)
		flip_tween.tween_property(self, "position", start_position + half_flip_position_offset, half_flip_seconds)
		flip_tween.chain()
		flip_tween.tween_property(self, "quaternion", facing_quaternion, half_flip_seconds)
		flip_tween.tween_property(self, "position", start_position, half_flip_seconds)
		flip_tween.chain()
		flip_tween.tween_callback(func(): is_flipping = false)

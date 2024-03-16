class_name Card
extends Node3D

@export var flip_pivot : Node3D
@export var face_mesh : MeshInstance3D

signal clicked(card_index: int)

static var half_flip_position_offset := Vector3(0, 2, 0)
static var half_flip_seconds := 0.2
static var half_flip_z_angle_delta := -90.0
static var full_flip_z_angle_delta := -180.0

static var half_toss_seconds := 0.25
static var half_toss_y_angle_delta := -179.9
static var full_toss_y_angle_delta := -360.0

static var rotate_before_slide_seconds := 0.5
static var slide_move_seconds := 1.0
static var straighten_seconds := 0.5

var face_material : StandardMaterial3D

var attributes : Dictionary
var index : int


func setup(card_index: int):
	index = card_index
	flip_pivot.rotation_degrees.z = -180.0


func set_attributes(card_attributes: Dictionary):
	attributes = card_attributes
	var rank = attributes["rank"]
	var suit = attributes["suit"]
	
	face_material = face_mesh.get_active_material(0)
	face_material.uv1_offset.x = 1.0 / 14 * rank
	face_material.uv1_offset.y = 1.0 / 4 * suit


func flip(start_delay_seconds: float, callback: Callable):
	if flip_pivot.rotation_degrees.z <= -360.0:
		flip_pivot.rotation_degrees.z += 360.0
	
	var start_position = position;
	
	var pivot_halfway_rotation_degrees = flip_pivot.rotation_degrees + Vector3(0, 0, half_flip_z_angle_delta)
	var pivot_final_rotation_degrees = flip_pivot.rotation_degrees + Vector3(0, 0, full_flip_z_angle_delta)
	
	var flip_tween := create_tween()
	flip_tween.set_parallel(true)
	flip_tween.tween_property(flip_pivot, "rotation_degrees", pivot_halfway_rotation_degrees, half_flip_seconds).set_delay(start_delay_seconds)
	flip_tween.tween_property(self, "position", start_position + half_flip_position_offset, half_flip_seconds).set_delay(start_delay_seconds)
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


func toss_to(destination: Vector3, start_delay_seconds: float, callback: Callable):
	var final_position_offset := destination - global_position
	var halfway_position := global_position + 0.5 * final_position_offset
	
	var halfway_rotation_degrees = rotation_degrees + Vector3(0, half_toss_y_angle_delta, 0)
	var final_rotation_degrees = rotation_degrees + Vector3(0, full_toss_y_angle_delta, 0)

	var toss_tween := create_tween()
	toss_tween.set_parallel(true)
	toss_tween.tween_property(self, "rotation_degrees", halfway_rotation_degrees, half_toss_seconds).set_delay(start_delay_seconds)
	toss_tween.tween_property(self, "global_position", halfway_position, half_toss_seconds).set_delay(start_delay_seconds)
	toss_tween.chain()
	toss_tween.tween_property(self, "rotation_degrees", final_rotation_degrees, half_toss_seconds)
	toss_tween.tween_property(self, "global_position", destination, half_toss_seconds)
	toss_tween.chain()
	toss_tween.tween_callback(callback)


func straighten(callback: Callable):
	var straighten_tween := create_tween()
	straighten_tween.tween_property(self, "quaternion", Quaternion.IDENTITY, straighten_seconds)
	straighten_tween.tween_callback(callback)


func _on_collider_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int):
	var mouse_event = event as InputEventMouseButton
	if mouse_event == null:
		return
	
	if mouse_event.pressed and mouse_event.button_index == 1:
		clicked.emit(index)

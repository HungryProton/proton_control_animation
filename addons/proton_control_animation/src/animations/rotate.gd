@tool
class_name PCA_RotateAnimation
extends ProtonControlAnimationResource


enum RotationType {CURRENT_ROTATION, ORIGINAL_ROTATION, ABSOLUTE_ROTATION, RELATIVE_ROTATION}

@export var from: RotationType:
	set(val):
		from = val
		notify_property_list_changed()
@export var from_absolute_rotation: float
@export var from_relative_rotation: float

@export var to: RotationType:
	set(val):
		to = val
		notify_property_list_changed()
@export var to_absolute_rotation: float
@export var to_relative_rotation: float

@export var rotation_in_degrees: bool = true

var _start_rotation: float


## Hide some exported variable when they are irrelevant to the current position type.
func _validate_property(property: Dictionary) -> void:
	_update_inspector_visibility(property, "from_absolute_rotation", from == RotationType.ABSOLUTE_ROTATION)
	_update_inspector_visibility(property, "from_relative_rotation", from == RotationType.RELATIVE_ROTATION)
	_update_inspector_visibility(property, "to_absolute_rotation", to == RotationType.ABSOLUTE_ROTATION)
	_update_inspector_visibility(property, "to_relative_rotation", to == RotationType.RELATIVE_ROTATION)


func create_tween(animation: ProtonControlAnimation, target: Control) -> Tween:
	var original_rotation: float = target.get_meta(ProtonControlAnimation.META_ORIGINAL_ROTATION, target.rotation)

	# Set the target rotation
	var final_rotation: float
	match to:
		RotationType.CURRENT_ROTATION:
			final_rotation = target.rotation
		RotationType.ORIGINAL_ROTATION:
			final_rotation = original_rotation
		RotationType.ABSOLUTE_ROTATION:
			if rotation_in_degrees:
				final_rotation = deg_to_rad(to_absolute_rotation)
			else:
				final_rotation = to_absolute_rotation
		RotationType.RELATIVE_ROTATION:
			if rotation_in_degrees:
				final_rotation = target.rotation + deg_to_rad(to_relative_rotation)
			else:
				final_rotation = target.rotation + to_relative_rotation

	# Set the initial control position
	match from:
		RotationType.CURRENT_ROTATION:
			pass # Nothing to do
		RotationType.ORIGINAL_ROTATION:
			target.rotation = original_rotation
		RotationType.ABSOLUTE_ROTATION:
			if rotation_in_degrees:
				target.rotation = deg_to_rad(from_absolute_rotation)
			else:
				target.rotation = from_absolute_rotation
		RotationType.RELATIVE_ROTATION:
			if rotation_in_degrees:
				target.rotation = target.rotation + deg_to_rad(from_relative_rotation)
			else:
				target.rotation = target.rotation + from_relative_rotation

	_start_rotation = target.rotation
	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "rotation", final_rotation, get_duration(animation))

	return tween


func create_tween_reverse(animation: ProtonControlAnimation, target: Control) -> Tween:
	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "rotation", _start_rotation, get_duration(animation))

	return tween

@tool
class_name PCA_RotateAnimation
extends ProtonControlAnimationResource


enum RotationType {CURRENT_ROTATION, ORIGINAL_ROTATION, ABSOLUTE_ROTATION, RELATIVE_ROTATION}

## The control's rotation at the start of the animation.
@export var from: RotationType:
	set(val):
		from = val
		notify_property_list_changed()

## This will override the control's `rotation` property when the animation starts.
## Only applicable if `from == ABSOLUTE_ROTATION`
@export var from_absolute_rotation: float

## Adds the value of `from_relative_rotation` to the control's current rotation when the animation starts.
## Only applicable if `from == RELATIVE_ROTATION`
@export var from_relative_rotation: float

## The control's rotation at the end of the animation
@export var to: RotationType:
	set(val):
		to = val
		notify_property_list_changed()

## The control's `rotation` will be equal to `to_absolute_rotation` when the animation ends.
## Only applicable if `to == ABSOLUTE_ROTATION`
@export var to_absolute_rotation: float

## The control's `rotation` will be equal to `control.rotation + to_relative_rotation` when the animation ends.
## Only applicable if `to == RELATIVE_ROTATION`
@export var to_relative_rotation: float

## If true, the values `from_absolute_rotation`, `from_relative_rotation`, `to_absolute_rotation` and `to_relative_rotation` are expressed in degrees.
## If false, they are expressed in radians.
@export var rotation_in_degrees: bool = true


## Hide some exported variable when they are irrelevant to the current position type.
func _validate_property(property: Dictionary) -> void:
	_update_inspector_visibility(property, "from_absolute_rotation", from == RotationType.ABSOLUTE_ROTATION)
	_update_inspector_visibility(property, "from_relative_rotation", from == RotationType.RELATIVE_ROTATION)
	_update_inspector_visibility(property, "to_absolute_rotation", to == RotationType.ABSOLUTE_ROTATION)
	_update_inspector_visibility(property, "to_relative_rotation", to == RotationType.RELATIVE_ROTATION)

	# Hide the rotation_in_degrees if no angle field is visible
	var keys: Array = [RotationType.ABSOLUTE_ROTATION, RotationType.RELATIVE_ROTATION]
	_update_inspector_visibility(property, "rotation_in_degrees", from in keys or to in keys)


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

	_cache(target, "start_rotation", target.rotation)
	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "rotation", final_rotation, get_duration(animation))

	return tween


func create_tween_reverse(animation: ProtonControlAnimation, target: Control) -> Tween:
	var start_rotation: float = _get_cached(target, "start_rotation", target.rotation)
	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "rotation", start_rotation, get_duration(animation))

	return tween


func reset(_animation: ProtonControlAnimation, target: Control) -> void:
	target.rotation = target.get_meta(ProtonControlAnimation.META_ORIGINAL_ROTATION, target.rotation)

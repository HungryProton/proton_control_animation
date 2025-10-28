@tool
class_name PCA_SizeAnimation
extends ProtonControlAnimationResource


enum SizeType {CURRENT_SIZE, ORIGINAL_SIZE, ABSOLUTE_SIZE, RELATIVE_SIZE}

## The control's scale at the start of the animation.
@export var from: SizeType:
	set(val):
		from = val
		notify_property_list_changed()

## This will override the control's `size` property when the animation starts.
## Only applicable if `from == ABSOLUTE_SCALE`
@export var from_absolute_size: Vector2

## The control's current size will be multiplied by `from_relative_size` when the animation starts.
## Only applicable if `from == RELATIVE_SIZE`
@export var from_relative_size: Vector2

## The control's size at the end of the animation.
@export var to: SizeType:
	set(val):
		to = val
		notify_property_list_changed()

## At the end of the animation, the control's size will be equal to `to_absolute_size`.
## Only applicable if `to == ABSOLUTE_SIZE`.
@export var to_absolute_size: Vector2

## At the end of the animation, the control's `size` will be equal to `control.size * to_relative_size`.
## Only applicable if `to == RELATIVE_Size`
@export var to_relative_size: Vector2

var _start_size: Vector2
var _start_pos : Vector2
var _end_size: Vector2


## Backward compatibility code
func _set(property: StringName, value: Variant) -> bool:
	if property == "from_size":
		if from == SizeType.ABSOLUTE_SIZE:
			from_absolute_size = value
			return true
		if from == SizeType.RELATIVE_SIZE:
			from_relative_size = value
			return true

	elif property == "to_size":
		if to == SizeType.ABSOLUTE_SIZE:
			to_absolute_size = value
			return true
		if to == SizeType.RELATIVE_SIZE:
			to_relative_size = value
			return true

	return false


## Hide some exported variable when they are irrelevant to the current scale type.
func _validate_property(property: Dictionary) -> void:
	_update_inspector_visibility(property, "from_absolute_size", from == SizeType.ABSOLUTE_SIZE)
	_update_inspector_visibility(property, "from_relative_size", from == SizeType.RELATIVE_SIZE)
	_update_inspector_visibility(property, "to_absolute_size", to == SizeType.ABSOLUTE_SIZE)
	_update_inspector_visibility(property, "to_relative_size", to == SizeType.RELATIVE_SIZE)


func create_tween(animation: ProtonControlAnimation, target: Control) -> Tween:
	# Set the target position
	match to:
		SizeType.CURRENT_SIZE:
			_end_size = target.size
		SizeType.ORIGINAL_SIZE:
			_end_size = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SIZE, target.size)
		SizeType.ABSOLUTE_SIZE:
			_end_size = to_absolute_size
		SizeType.RELATIVE_SIZE:
			_end_size = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SIZE, target.size) * to_relative_size

	# Set the initial control position
	match from:
		SizeType.CURRENT_SIZE:
			pass # Nothing to do
		SizeType.ORIGINAL_SIZE:
			target.size = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SIZE, target.size)
		SizeType.ABSOLUTE_SIZE:
			target.size = from_absolute_size
		SizeType.RELATIVE_SIZE:
			target.size = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SIZE, target.size) * from_relative_size
	_start_size = target.size

	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "size", _end_size, get_duration(animation))
		
	# account the pivot position to offset the Control during animation
	_start_pos = target.position
	var _pivot_ratio : Vector2 = target.pivot_offset / _start_size
	var _end_pos : Vector2 = _start_pos - (_end_size - _start_size) * _pivot_ratio
	tween.set_parallel(true)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "position", _end_pos, get_duration(animation))

	return tween


func create_tween_reverse(animation: ProtonControlAnimation, target: Control) -> Tween:
	target.size = _end_size
	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "size", _start_size, get_duration(animation))
	
	# account the pivot position to offset the Control during animation
	var _pivot_ratio : Vector2 = target.pivot_offset / _start_size
	var _end_pos : Vector2 = target.position + (_end_size - _start_size) * _pivot_ratio
	tween.set_parallel(true)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "position", _start_pos, get_duration(animation))
	

	return tween


func reset(_animation: ProtonControlAnimation, target: Control) -> void:
	target.size = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SIZE, target.size)

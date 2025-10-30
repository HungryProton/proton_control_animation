@tool
class_name PCA_SlideAnimation
extends ProtonControlAnimationResource


enum PositionType {CURRENT_POSITION, ORIGINAL_POSITION, GLOBAL_POSITION, LOCAL_OFFSET}

## Defines where the animation starts.
@export var from: PositionType:
	set(val):
		from = val
		notify_property_list_changed()

## This overrides the control's global position when the animation starts
## Only applicable if `from == GLOBAL_POSITION`
@export var from_global_position: Vector2

## `from_local_offset` is added to the control's current position when the animation starts.
## Only applicable if `from == LOCAL_OFFSET`
@export var from_local_offset: Vector2

## Defines where the animation ends.
@export var to: PositionType:
	set(val):
		to = val
		notify_property_list_changed()

## The global position where the animation ends.
## At the end of the animation, the control global position will be equal to `to_global_position`.
## Only applicable if `to == GLOBAL_POSITION`
@export var to_global_position: Vector2

## At the end of the animation, the control's position will equal `control.position + to_local_offset`.
## Only applicable if `to == LOCAL_OFFSET`
@export var to_local_offset: Vector2


## Backward compatibility code
##
## Initially, there were only two variables (from_vector and to_vector).
## They got replaced with more specific variables instead that are only shown
## depending on the context.
func _set(property: StringName, value: Variant) -> bool:
	if property == "from_vector":
		if from == PositionType.GLOBAL_POSITION:
			from_global_position = value
			return true
		if from == PositionType.LOCAL_OFFSET:
			from_local_offset = value
			return true

	elif property == "to_vector":
		if to == PositionType.GLOBAL_POSITION:
			to_global_position = value
			return true
		if to == PositionType.LOCAL_OFFSET:
			to_local_offset = value
			return true

	return false


## Hide some exported variable when they are irrelevant to the current position type.
func _validate_property(property: Dictionary) -> void:
	_update_inspector_visibility(property, "from_global_position", from == PositionType.GLOBAL_POSITION)
	_update_inspector_visibility(property, "from_local_offset", from == PositionType.LOCAL_OFFSET)
	_update_inspector_visibility(property, "to_global_position", to == PositionType.GLOBAL_POSITION)
	_update_inspector_visibility(property, "to_local_offset", to == PositionType.LOCAL_OFFSET)


func create_tween(animation: ProtonControlAnimation, target: Control) -> Tween:
	var property: String = &"position"
	var original_position: Vector2 = target.get_meta(ProtonControlAnimation.META_ORIGINAL_POSITION, target.position)

	# Set the target position
	var final_position: Vector2
	match to:
		PositionType.CURRENT_POSITION:
			final_position = target.position
		PositionType.ORIGINAL_POSITION:
			final_position = original_position
		PositionType.GLOBAL_POSITION:
			final_position = to_global_position
			property = &"global_position"
		PositionType.LOCAL_OFFSET:
			final_position = target.position + to_local_offset

	# Set the initial control position
	match from:
		PositionType.CURRENT_POSITION:
			pass # Nothing to do
		PositionType.ORIGINAL_POSITION:
			target.position = original_position
		PositionType.GLOBAL_POSITION:
			target.global_position = from_global_position
		PositionType.LOCAL_OFFSET:
			target.position = target.position + from_local_offset

	_cache(target, "start_pos", target.position)

	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, property, final_position, get_duration(animation))

	return tween


func create_tween_reverse(animation: ProtonControlAnimation, target: Control) -> Tween:
	var start_pos: Vector2 = _get_cached(target, "start_pos", target.position)
	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "position", start_pos, get_duration(animation))

	return tween


func reset(_animation: ProtonControlAnimation, target: Control) -> void:
	target.position = target.get_meta(ProtonControlAnimation.META_ORIGINAL_POSITION, target.position)

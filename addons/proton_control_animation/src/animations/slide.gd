@tool
class_name PCA_SlideAnimation
extends ProtonControlAnimationResource


enum PositionType {CURRENT_POSITION, ORIGINAL_POSITION, GLOBAL_POSITION, LOCAL_OFFSET, OFFSET_TRANSFORM, OFFSET_TRANSFORM_RATIO}

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

## At the end of the animation, the control's offset_transform will be equal to 'from_offset_transform'
## From and To must both either be OFFSET_TRANSFORM or ORIGINAL_POSITION to work properly for loops.
## OFFSET_TRANSFORM_RATIO is available from Godot v4.7+.
## Only applicable if `from == OFFSET_TRANSFORM`
@export var from_offset_transform: Vector2

## At the end of the animation, the control's offset_transform will be equal to 'from_offset_transform_ratio'
## From and To must both either be OFFSET_TRANSFORM_RATIO or ORIGINAL_POSITION_RATIO to work properly for loops.
## OFFSET_TRANSFORM_RATIO is available from Godot v4.7+.
## Only applicable if `from == OFFSET_TRANSFORM_RATIO`
@export var from_offset_transform_ratio: Vector2

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

## The offset_transform where the animation ends.
## From and To must both either be OFFSET_TRANSFORM or ORIGINAL_POSITION to work properly.
## Only applicable if `to == OFFSET_TRANSFORM`
@export var to_offset_transform: Vector2

## The offset_transform_ratio where the animation ends.
## From and To must both either be OFFSET_TRANSFORM_RATIO or ORIGINAL_POSITION_RATIO to work properly for loops.
## Only applicable if `to == OFFSET_TRANSFORM_RATIO`
@export var to_offset_transform_ratio: Vector2

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
		if from == PositionType.OFFSET_TRANSFORM:
			from_offset_transform = value
			return true
		if from == PositionType.OFFSET_TRANSFORM_RATIO:
			from_offset_transform_ratio = value
			return true

	elif property == "to_vector":
		if to == PositionType.GLOBAL_POSITION:
			to_global_position = value
			return true
		if to == PositionType.LOCAL_OFFSET:
			to_local_offset = value
			return true
		if to == PositionType.OFFSET_TRANSFORM:
			to_offset_transform = value
			return true
		if to == PositionType.OFFSET_TRANSFORM_RATIO:
			to_offset_transform_ratio = value
			return true

	return false


## Hide some exported variable when they are irrelevant to the current position type.
func _validate_property(property: Dictionary) -> void:
	_update_inspector_visibility(property, "from_global_position", from == PositionType.GLOBAL_POSITION)
	_update_inspector_visibility(property, "from_local_offset", from == PositionType.LOCAL_OFFSET)
	_update_inspector_visibility(property, "from_offset_transform", from == PositionType.OFFSET_TRANSFORM)
	_update_inspector_visibility(property, "from_offset_transform_ratio", from == PositionType.OFFSET_TRANSFORM_RATIO)
	_update_inspector_visibility(property, "to_global_position", to == PositionType.GLOBAL_POSITION)
	_update_inspector_visibility(property, "to_local_offset", to == PositionType.LOCAL_OFFSET)
	_update_inspector_visibility(property, "to_offset_transform", to == PositionType.OFFSET_TRANSFORM)
	_update_inspector_visibility(property, "to_offset_transform_ratio", to == PositionType.OFFSET_TRANSFORM_RATIO)


func create_tween(animation: ProtonControlAnimation, target: Control) -> Tween:
	var property: String = &"position"
	var original_position: Vector2 = target.get_meta(ProtonControlAnimation.META_ORIGINAL_POSITION, target.position)

	var original_offset_transform_position: Vector2
	var original_offset_transform_position_ratio: Vector2
	if from == PositionType.OFFSET_TRANSFORM || to == PositionType.OFFSET_TRANSFORM:
		if (!target.offset_transform_enabled):
			target.offset_transform_enabled = true
		original_offset_transform_position = target.get_meta(ProtonControlAnimation.META_ORIGINAL_OFFSET_TRANSFORM_POSITION, target.offset_transform_position)
	elif from == PositionType.OFFSET_TRANSFORM_RATIO || to == PositionType.OFFSET_TRANSFORM_RATIO:
		if (!target.offset_transform_enabled):
			target.offset_transform_enabled = true
		original_offset_transform_position_ratio = target.get_meta(ProtonControlAnimation.META_ORIGINAL_OFFSET_TRANSFORM_POSITION_RATIO, target.offset_transform_position_ratio)

	# Set the target position
	var final_position: Vector2
	match to:
		PositionType.CURRENT_POSITION:
			final_position = target.position
		PositionType.ORIGINAL_POSITION:
			if (from == PositionType.OFFSET_TRANSFORM):
				final_position = original_offset_transform_position
			elif (from == PositionType.OFFSET_TRANSFORM_RATIO):
				final_position = original_offset_transform_position_ratio
			else:
				final_position = original_position
		PositionType.GLOBAL_POSITION:
			final_position = to_global_position
			property = &"global_position"
		PositionType.LOCAL_OFFSET:
			final_position = target.position + to_local_offset
		PositionType.OFFSET_TRANSFORM:
			final_position = to_offset_transform
			property = &"offset_transform_position"
		PositionType.OFFSET_TRANSFORM_RATIO:
			final_position = to_offset_transform_ratio
			property = &"offset_transform_position_ratio"

	var start_pos: Vector2 = target.position
	var cache_name: String = &"start_pos"
	# Set the initial control position
	match from:
		PositionType.CURRENT_POSITION:
			pass # Nothing to do
		PositionType.ORIGINAL_POSITION:
			if (to == PositionType.OFFSET_TRANSFORM):
				target.offset_transform_position = original_offset_transform_position
				start_pos = target.offset_transform_position
			elif (to == PositionType.OFFSET_TRANSFORM_RATIO):
				target.offset_transform_position_ratio = original_offset_transform_position_ratio
				start_pos = target.offset_transform_position_ratio
			else:
				target.position = original_position
		PositionType.GLOBAL_POSITION:
			target.global_position = from_global_position
		PositionType.LOCAL_OFFSET:
			target.position = target.position + from_local_offset
		PositionType.OFFSET_TRANSFORM:
			target.offset_transform_position = from_offset_transform
			start_pos = target.offset_transform_position
			property = &"offset_transform_position"
		PositionType.OFFSET_TRANSFORM_RATIO:
			target.offset_transform_position_ratio = from_offset_transform_ratio
			start_pos = target.offset_transform_position_ratio
			property = &"offset_transform_position_ratio"

	_cache(target, 'start_pos', start_pos)

	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, property, final_position, get_duration(animation))

	return tween


func create_tween_reverse(animation: ProtonControlAnimation, target: Control) -> Tween:
	var default_fallback: Vector2 = target.position
	var property: String = &"position"
	if from == PositionType.OFFSET_TRANSFORM || to == PositionType.OFFSET_TRANSFORM:
		default_fallback = target.offset_transform_position
		property = &"offset_transform_position"
	elif from == PositionType.OFFSET_TRANSFORM_RATIO || to == PositionType.OFFSET_TRANSFORM_RATIO:
		default_fallback = target.offset_transform_position_ratio
		property = &"offset_transform_position_ratio"

	var start_pos: Vector2 = _get_cached(target, 'start_pos', Vector2(-1,-1))
	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, property, start_pos, get_duration(animation))

	return tween


func reset(_animation: ProtonControlAnimation, target: Control) -> void:
	target.position = target.get_meta(ProtonControlAnimation.META_ORIGINAL_POSITION, target.position)
	if "offset_transform_position" in target:
		target.offset_transform_position = target.get_meta(ProtonControlAnimation.META_ORIGINAL_OFFSET_TRANSFORM_POSITION, target.offset_transform_position)
	if "offset_transform_position_ratio" in target:
		target.offset_transform_position_ratio = target.get_meta(ProtonControlAnimation.META_ORIGINAL_OFFSET_TRANSFORM_POSITION_RATIO, target.offset_transform_position_ratio)

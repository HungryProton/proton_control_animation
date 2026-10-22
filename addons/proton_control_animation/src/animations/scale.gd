@tool
class_name PCA_ScaleAnimation
extends ProtonControlAnimationResource


enum ScaleType {CURRENT_SCALE, ORIGINAL_SCALE, ABSOLUTE_SCALE, RELATIVE_SCALE, OFFSET_TRANSFORM}

## The control's scale at the start of the animation.
@export var from: ScaleType:
	set(val):
		from = val
		notify_property_list_changed()

## This will override the control's `scale` property when the animation starts.
## Only applicable if `from == ABSOLUTE_SCALE`
@export var from_absolute_scale: Vector2

## The control's current scale will is multiplied by `from_relative_scale` when the animation starts.
## From and To must both either be OFFSET_TRANSFORM or ORIGINAL_POSITION to work properly for loops.
## Only applicable if `from == RELATIVE_SCALE`
@export var from_relative_scale: Vector2

## This will override the control's `offset_transform_scale` property when the animation starts.
## From and To must both either be OFFSET_TRANSFORM or ORIGINAL_POSITION to work properly for loops.
## Only applicable if `from == OFFSET_TRANSFORM`
@export var from_offset_transform_scale: Vector2

## The control's scale at the end of the animation.
@export var to: ScaleType:
	set(val):
		to = val
		notify_property_list_changed()

## At the end of the animation, the control's scale will be equal to `to_absolute_scale`.
## Only applicable if `to == ABSOLUTE_SCALE`.
@export var to_absolute_scale: Vector2

## At the end of the animation, the control's `scale` will be equal to `control.scale * to_relative_scale`.
## From and To must both either be OFFSET_TRANSFORM or ORIGINAL_POSITION to work properly for loops.
## Only applicable if `to == RELATIVE_SCALE`
@export var to_relative_scale: Vector2

## At the end of the animation, the control's offset_transform_scale will be equal to `to_offset_transform_scale`.
## From and To must both either be OFFSET_TRANSFORM or ORIGINAL_POSITION to work properly for loops.
## Only applicable if `to == OFFSET_TRANSFORM`
@export var to_offset_transform_scale: Vector2


## Backward compatibility code
func _set(property: StringName, value: Variant) -> bool:
	if property == "from_scale":
		if from == ScaleType.ABSOLUTE_SCALE:
			from_absolute_scale = value
			return true
		if from == ScaleType.RELATIVE_SCALE:
			from_relative_scale = value
			return true
		if from == ScaleType.OFFSET_TRANSFORM:
			from_offset_transform_scale = value
			return true

	elif property == "to_scale":
		if to == ScaleType.ABSOLUTE_SCALE:
			to_absolute_scale = value
			return true
		if to == ScaleType.RELATIVE_SCALE:
			to_relative_scale = value
			return true
		if from == ScaleType.OFFSET_TRANSFORM:
			to_offset_transform_scale = value
			return true

	return false


## Hide some exported variable when they are irrelevant to the current scale type.
func _validate_property(property: Dictionary) -> void:
	_update_inspector_visibility(property, "from_absolute_scale", from == ScaleType.ABSOLUTE_SCALE)
	_update_inspector_visibility(property, "from_relative_scale", from == ScaleType.RELATIVE_SCALE)
	_update_inspector_visibility(property, "from_offset_transform_scale", from == ScaleType.OFFSET_TRANSFORM)
	_update_inspector_visibility(property, "to_absolute_scale", to == ScaleType.ABSOLUTE_SCALE)
	_update_inspector_visibility(property, "to_relative_scale", to == ScaleType.RELATIVE_SCALE)
	_update_inspector_visibility(property, "to_offset_transform_scale", to == ScaleType.OFFSET_TRANSFORM)


func create_tween(animation: ProtonControlAnimation, target: Control) -> Tween:
	var property: String = &"scale"
	var end_scale: Vector2
	# Set the target position
	match to:
		ScaleType.CURRENT_SCALE:
			end_scale = target.scale
		ScaleType.ORIGINAL_SCALE:
			if (from == ScaleType.OFFSET_TRANSFORM):
				end_scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_OFFSET_TRANSFORM_SCALE, target.offset_transform_scale)
			else:
				end_scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale)
		ScaleType.ABSOLUTE_SCALE:
			end_scale = to_absolute_scale
		ScaleType.RELATIVE_SCALE:
			end_scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale) * to_relative_scale
		ScaleType.OFFSET_TRANSFORM:
			end_scale = to_offset_transform_scale
			property = &"offset_transform_scale"

	var start_scale: Vector2 = target.scale
	# Set the initial control position
	match from:
		ScaleType.CURRENT_SCALE:
			pass # Nothing to do
		ScaleType.ORIGINAL_SCALE:
			if (from == ScaleType.OFFSET_TRANSFORM):
				target.offset_transform_scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_OFFSET_TRANSFORM_SCALE, target.offset_transform_scale)
			else:
				target.scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale)
		ScaleType.ABSOLUTE_SCALE:
			target.scale = from_absolute_scale
		ScaleType.RELATIVE_SCALE:
			target.scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale) * from_relative_scale
		ScaleType.OFFSET_TRANSFORM:
			target.offset_transform_scale = from_offset_transform_scale
			start_scale = target.offset_transform_scale
			property = &"offset_transform_scale"

	_cache(target, "start_scale", start_scale)
	_cache(target, "end_scale", end_scale)

	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, property, end_scale, get_duration(animation))

	return tween


func create_tween_reverse(animation: ProtonControlAnimation, target: Control) -> Tween:
	var default_fallback: Vector2 = target.scale
	var property: String = &"scale"
	if from == ScaleType.OFFSET_TRANSFORM || to == ScaleType.OFFSET_TRANSFORM:
		default_fallback = target.offset_transform_scale
		property = &"offset_transform_scale"
		target.offset_transform_scale = _get_cached(target, "end_scale", default_fallback)
	else:
		target.scale = _get_cached(target, "end_scale", default_fallback)

	var final_scale: Vector2 = _get_cached(target, "start_scale", default_fallback)
	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, property, final_scale, get_duration(animation))

	return tween


func reset(_animation: ProtonControlAnimation, target: Control) -> void:
	target.scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale)
	if "offset_transform_scale" in target:
		target.offset_transform_scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_OFFSET_TRANSFORM_SCALE, target.offset_transform_scale)

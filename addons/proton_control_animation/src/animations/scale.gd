@tool
class_name PCA_ScaleAnimation
extends ProtonControlAnimationResource


enum ScaleType {CURRENT_SCALE, ORIGINAL_SCALE, ABSOLUTE_SCALE, RELATIVE_SCALE}

## The control's scale at the start of the animation.
@export var from: ScaleType:
	set(val):
		from = val
		notify_property_list_changed()

## This will override the control's `scale` property when the animation starts.
## Only applicable if `from == ABSOLUTE_SCALE`
@export var from_absolute_scale: Vector2

## The control's current scale will is multiplied by `from_relative_scale` when the animation starts.
## Only applicable if `from == RELATIVE_SCALE`
@export var from_relative_scale: Vector2

## The control's scale at the end of the animation.
@export var to: ScaleType:
	set(val):
		to = val
		notify_property_list_changed()

## At the end of the animation, the control's scale will be equal to `to_absolute_scale`.
## Only applicable if `to == ABSOLUTE_SCALE`.
@export var to_absolute_scale: Vector2

## At the end of the animation, the control's `scale` will be equal to `control.scale * to_relative_scale`.
## Only applicable if `to == RELATIVE_SCALE`
@export var to_relative_scale: Vector2


## Backward compatibility code
func _set(property: StringName, value: Variant) -> bool:
	if property == "from_scale":
		if from == ScaleType.ABSOLUTE_SCALE:
			from_absolute_scale = value
			return true
		if from == ScaleType.RELATIVE_SCALE:
			from_relative_scale = value
			return true

	elif property == "to_scale":
		if to == ScaleType.ABSOLUTE_SCALE:
			to_absolute_scale = value
			return true
		if to == ScaleType.RELATIVE_SCALE:
			to_relative_scale = value
			return true

	return false


## Hide some exported variable when they are irrelevant to the current scale type.
func _validate_property(property: Dictionary) -> void:
	_update_inspector_visibility(property, "from_absolute_scale", from == ScaleType.ABSOLUTE_SCALE)
	_update_inspector_visibility(property, "from_relative_scale", from == ScaleType.RELATIVE_SCALE)
	_update_inspector_visibility(property, "to_absolute_scale", to == ScaleType.ABSOLUTE_SCALE)
	_update_inspector_visibility(property, "to_relative_scale", to == ScaleType.RELATIVE_SCALE)


func create_tween(animation: ProtonControlAnimation, target: Control) -> Tween:
	var end_scale: Vector2
	# Set the target position
	match to:
		ScaleType.CURRENT_SCALE:
			end_scale = target.scale
		ScaleType.ORIGINAL_SCALE:
			end_scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale)
		ScaleType.ABSOLUTE_SCALE:
			end_scale = to_absolute_scale
		ScaleType.RELATIVE_SCALE:
			end_scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale) * to_relative_scale

	# Set the initial control position
	match from:
		ScaleType.CURRENT_SCALE:
			pass # Nothing to do
		ScaleType.ORIGINAL_SCALE:
			target.scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale)
		ScaleType.ABSOLUTE_SCALE:
			target.scale = from_absolute_scale
		ScaleType.RELATIVE_SCALE:
			target.scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale) * from_relative_scale

	_cache(target, "start_scale", target.scale)
	_cache(target, "end_scale", end_scale)

	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "scale", end_scale, get_duration(animation))

	return tween


func create_tween_reverse(animation: ProtonControlAnimation, target: Control) -> Tween:
	target.scale = _get_cached(target, "end_scale", target.scale)
	var final_scale: Vector2 = _get_cached(target, "start_scale", target.scale)
	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "scale", final_scale, get_duration(animation))

	return tween


func reset(_animation: ProtonControlAnimation, target: Control) -> void:
	target.scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale)

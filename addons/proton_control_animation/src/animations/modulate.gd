@tool
class_name PCA_ModulateAnimation
extends ProtonControlAnimationResource

enum ModulateType {
	CURRENT_COLOR,
	ORIGINAL_COLOR,
	NEW_COLOR,
}

## The control's color at the start of the animation.
@export var from: ModulateType:
	set(val):
		from = val
		notify_property_list_changed()

## This color will replace the control's color when the animation starts.
## Only applicable if `from == NEW_COLOR`
@export var from_color: Color

## The control's color at the end of the animation.
@export var to: ModulateType:
	set(val):
		to = val
		notify_property_list_changed()

## At the end of the animation, the control's color will have changed to `to_color`.
## Only applicable if `to == NEW_COLOR`.
@export var to_color: Color

## If true, animate the control's `self_modulate` property.
## If false, animation the control's `modulate` property.
@export var self_modulate: bool = false


## Hide some exported variable when they are irrelevant to the current scale type.
func _validate_property(property: Dictionary) -> void:
	_update_inspector_visibility(property, "from_color", from == ModulateType.NEW_COLOR)
	_update_inspector_visibility(property, "to_color", to == ModulateType.NEW_COLOR)


func create_tween(animation: ProtonControlAnimation, target: Control) -> Tween:
	var final_color: Color
	match to:
		ModulateType.CURRENT_COLOR:
			if self_modulate:
				final_color = target.self_modulate
			else:
				final_color = target.modulate
		ModulateType.ORIGINAL_COLOR:
			if self_modulate:
				final_color = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SELF_MODULATE, target.self_modulate)
			else:
				final_color = target.get_meta(ProtonControlAnimation.META_ORIGINAL_MODULATE, target.modulate)
		ModulateType.NEW_COLOR:
			final_color = to_color

	match from:
		ModulateType.CURRENT_COLOR:
			pass # Nothing to do
		ModulateType.ORIGINAL_COLOR:
			if self_modulate:
				target.self_modulate = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SELF_MODULATE, target.self_modulate)
			else:
				target.modulate = target.get_meta(ProtonControlAnimation.META_ORIGINAL_MODULATE, target.modulate)
		ModulateType.NEW_COLOR:
			if self_modulate:
				target.self_modulate = from_color
			else:
				target.modulate = from_color

	_cache(target, "start_color", target.self_modulate if self_modulate else target.modulate)

	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "self_modulate" if self_modulate else "modulate", final_color, get_duration(animation))
	return tween


func create_tween_reverse(animation: ProtonControlAnimation, target: Control) -> Tween:
	var start_color: Color = _get_cached(target, "start_color", target.modulate)
	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "self_modulate" if self_modulate else "modulate", start_color, get_duration(animation))
	return tween


func reset(_animation: ProtonControlAnimation, target: Control) -> void:
	if self_modulate:
		target.self_modulate = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SELF_MODULATE, target.self_modulate)
	else:
		target.modulate = target.get_meta(ProtonControlAnimation.META_ORIGINAL_MODULATE, target.modulate)

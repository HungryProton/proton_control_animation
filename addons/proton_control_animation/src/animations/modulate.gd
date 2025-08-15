@tool
class_name PCA_ModulateAnimation
extends ProtonControlAnimationResource

enum ModulateType {
	ORIGINAL_COLOR,
	NEW_COLOR,
}

@export var from: ModulateType:
	set(val):
		from = val
		notify_property_list_changed()
@export var from_color: Color

@export var to: ModulateType:
	set(val):
		to = val
		notify_property_list_changed()
@export var to_color: Color

@export var self_modulate: bool = false

var _start_color: Color


## Hide some exported variable when they are irrelevant to the current scale type.
func _validate_property(property: Dictionary) -> void:
	_update_inspector_visibility(property, "from_color", from == ModulateType.NEW_COLOR)
	_update_inspector_visibility(property, "to_color", to == ModulateType.NEW_COLOR)


func create_tween(animation: ProtonControlAnimation, target: Control) -> Tween:
	var final_color: Color
	match to:
		ModulateType.ORIGINAL_COLOR:
			if self_modulate:
				final_color = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SELF_MODULATE, target.self_modulate)
			else:
				final_color = target.get_meta(ProtonControlAnimation.META_ORIGINAL_MODULATE, target.modulate)
		ModulateType.NEW_COLOR:
			final_color = to_color

	match from:
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

	_start_color = target.self_modulate if self_modulate else target.modulate

	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "self_modulate" if self_modulate else "modulate", final_color, get_duration(animation))
	return tween


func create_tween_reverse(animation: ProtonControlAnimation, target: Control) -> Tween:
	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "self_modulate" if self_modulate else "modulate", _start_color, get_duration(animation))
	return tween

@tool
class_name ProtonControlAnimationResource
extends Resource

## Abstract class
## Defines how the control is animated


## Controls where the animation is interpolated.
## Same as `Tween.set_ease(EaseType)`
@export var easing: Tween.EaseType = Tween.EASE_IN_OUT

## Controls the interpolation type.
## Same as `Tween.set_trans(TransitionType)`
@export var transition: Tween.TransitionType = Tween.TRANS_QUAD

## How long the animation lasts.
## Overriden by the ProtonControlAnimation duration if set.
@export var default_duration: float = 1.0


var _cached_data: Dictionary[Control, Dictionary] = {}


## Override in child classes
## Handles starting the animation.
func create_tween(_animation: ProtonControlAnimation, _target: Control) -> Tween:
	return null


## Override in child classes
## Plays the animation in reverse. Used with the PingPong loop only.
func create_tween_reverse(_animation: ProtonControlAnimation, _target: Control) -> Tween:
	return null


## Override in child classes
## Restore the control as it was before this animation started.
func reset(_animation: ProtonControlAnimation, _target: Control) -> void:
	pass


## Returns the actual duration of the animation
## If a duration override is defined in the parent ControlAnimation node, use that
## Else, use the one defined on the animation resource.
func get_duration(animation: ProtonControlAnimation) -> float:
	if animation.duration > 0.0:
		return animation.duration
	return default_duration


## Call this from _validate_property() to quickly hide or show exported property depending on context.
func _update_inspector_visibility(property: Dictionary, name: String, visible: bool) -> void:
	if property.name == name:
		property.usage = PROPERTY_USAGE_DEFAULT if visible else PROPERTY_USAGE_STORAGE


## Store values associated with a specific control.
## This exists because animation resources can operate on different targets
func _cache(control: Control, key: String, data: Variant) -> void:
	var dict: Dictionary[String, Variant] = {}
	if _cached_data.has(control):
		dict = _cached_data[control]
	else:
		_cached_data[control] = dict
	dict[key] = data


func _get_cached(control: Control, key: String, default: Variant = null) -> Variant:
	var dict: Dictionary[String, Variant] = _cached_data.get(control, {})
	return dict.get(key, default)

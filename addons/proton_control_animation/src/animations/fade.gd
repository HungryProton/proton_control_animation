@tool
class_name PCA_FadeAnimation
extends ProtonControlAnimationResource

## Animates the control's transparency.
## This is a simplified version of the Modulate animation.
## It is included as a minimal example you can refert to when creating your own animations.

## The control's transparency at the start of the animation
@export var from: float

## The control's transparency at the end of the animation
@export var to: float


func create_tween(animation: ProtonControlAnimation, target: Control) -> Tween:
	target.modulate.a = from
	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "modulate:a", to, get_duration(animation))
	return tween


func create_tween_reverse(animation: ProtonControlAnimation, target: Control) -> Tween:
	target.modulate.a = to
	var tween: Tween = animation.create_tween().set_ease(easing).set_trans(transition)
	@warning_ignore("return_value_discarded")
	tween.tween_property(target, "modulate:a", from, get_duration(animation))
	return tween


func reset(_animation: ProtonControlAnimation, target: Control) -> void:
	target.modulate.a = from

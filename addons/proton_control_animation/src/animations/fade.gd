@tool
class_name PCA_FadeAnimation
extends ProtonControlAnimationResource


@export var from: float
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

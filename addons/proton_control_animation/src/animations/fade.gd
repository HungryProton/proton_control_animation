class_name PCA_FadeAnimation
extends ProtonControlAnimationResource


@export var from: float
@export var to: float


func create_tween(animation: ProtonControlAnimation, target: Control) -> Tween:
	target.modulate.a = from
	var tween: Tween = animation.create_tween()
	#@warning_ignore_start("return_value_discarded")
	tween.set_ease(easing)
	tween.set_trans(transition)
	tween.tween_property(target, "modulate:a", to, get_duration(animation))
	#@warning_ignore_restore("return_value_discarded")
	return tween



func create_tween_reverse(animation: ProtonControlAnimation, target: Control) -> Tween:
	target.modulate.a = to
	var tween: Tween = animation.create_tween()
	#@warning_ignore_start("return_value_discarded")
	tween.set_ease(easing)
	tween.set_trans(transition)
	tween.tween_property(target, "modulate:a", from, get_duration(animation))
	#@warning_ignore_restore("return_value_discarded")
	return tween

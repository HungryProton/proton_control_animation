class_name PCA_ScaleAnimation
extends ProtonControlAnimationResource


@export var from: ScaleType
@export var from_scale: Vector2

@export var to: ScaleType
@export var to_scale: Vector2

var _start_scale: Vector2
var _end_scale: Vector2


func create_tween(animation: ProtonControlAnimation, target: Control) -> Tween:
	# Set the target position
	match to:
		ScaleType.CURRENT_SCALE:
			_end_scale = target.scale
		ScaleType.ORIGINAL_SCALE:
			_end_scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale)
		ScaleType.ABSOLUTE_SCALE:
			_end_scale = to_scale
		ScaleType.RELATIVE_SCALE:
			_end_scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale) * to_scale

	# Set the initial control position
	match from:
		ScaleType.CURRENT_SCALE:
			pass # Nothing to do
		ScaleType.ORIGINAL_SCALE:
			target.scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale)
		ScaleType.ABSOLUTE_SCALE:
			target.scale = from_scale
		ScaleType.RELATIVE_SCALE:
			target.scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale) * from_scale
	_start_scale = target.scale

	var tween: Tween = animation.create_tween()
	#@warning_ignore_start("return_value_discarded")
	tween.set_ease(easing)
	tween.set_trans(transition)
	tween.tween_property(target, "scale", _end_scale, get_duration(animation))
	#@warning_ignore_restore("return_value_discarded")

	return tween


func create_tween_reverse(animation: ProtonControlAnimation, target: Control) -> Tween:
	target.scale = _end_scale
	var tween: Tween = animation.create_tween()
	#@warning_ignore_start("return_value_discarded")
	tween.set_ease(easing)
	tween.set_trans(transition)
	tween.tween_property(target, "scale", _start_scale, get_duration(animation))
	#@warning_ignore_restore("return_value_discarded")

	return tween

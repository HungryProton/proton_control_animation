class_name PCA_ScaleAnimation
extends ProtonControlAnimationResource


@export var from: ScaleType
@export var from_scale: Vector2

@export var to: ScaleType
@export var to_scale: Vector2


func create_tween(animation: ProtonControlAnimation, target: Control) -> Tween:
	# Set the target position
	var final_scale: Vector2
	match to:
		ScaleType.CURRENT_SCALE:
			final_scale = target.scale
		ScaleType.ORIGINAL_SCALE:
			final_scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale)
		ScaleType.ABSOLUTE_SCALE:
			final_scale = to_scale
		ScaleType.RELATIVE_SCALE:
			final_scale = target.get_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale) * to_scale

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

	var tween: Tween = animation.create_tween()
	#@warning_ignore_start("return_value_discarded")
	tween.set_ease(easing)
	tween.set_trans(transition)
	tween.tween_property(target, "scale", final_scale, get_duration(animation))
	#@warning_ignore_restore("return_value_discarded")

	return tween

class_name PCA_SlideAnimation
extends ProtonControlAnimationResource


@export var from: PositionType
@export var from_vector: Vector2

@export var to: PositionType
@export var to_vector: Vector2


func create_tween(animation: ProtonControlAnimation, target: Control) -> Tween:
	var property: String = &"position"
	var original_position: Vector2 = target.get_meta(ProtonControlAnimation.META_ORIGINAL_POSITION, target.position)

	# Set the target position
	var final_position: Vector2
	match to:
		PositionType.CURRENT_POSITION:
			final_position = target.position
		PositionType.ORIGINAL_POSITION:
			final_position = original_position
		PositionType.GLOBAL_POSITION:
			final_position = to_vector
			property = &"global_position"
		PositionType.LOCAL_OFFSET:
			final_position = target.position + to_vector

	# Set the initial control position
	match from:
		PositionType.CURRENT_POSITION:
			pass # Nothing to do
		PositionType.ORIGINAL_POSITION:
			target.position = original_position
		PositionType.GLOBAL_POSITION:
			target.global_position = from_vector
		PositionType.LOCAL_OFFSET:
			target.position = target.position + from_vector

	var tween: Tween = animation.create_tween()
	#@warning_ignore_start("return_value_discarded")
	tween.set_ease(easing)
	tween.set_trans(transition)
	tween.tween_property(target, property, final_position, get_duration(animation))
	#@warning_ignore_restore("return_value_discarded")

	return tween

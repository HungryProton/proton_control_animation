class_name PCA_SlideAnimation
extends ProtonControlAnimationResource


@export var from: PositionType
@export var from_vector: Vector2

@export var to: PositionType
@export var to_vector: Vector2


func create_tween(animation: ProtonControlAnimation, target: Control) -> Tween:
	# Set the target position
	var final_position: Vector2
	match to:
		PositionType.CURRENT_POSITION:
			final_position = target.global_position
		PositionType.ORIGINAL_POSITION:
			final_position = target.get_meta("pca_original_position", target.global_position)
		PositionType.GLOBAL_POSITION:
			final_position = to_vector
		PositionType.LOCAL_OFFSET:
			final_position = target.global_position + to_vector

	# Set the initial control position
	match from:
		PositionType.ORIGINAL_POSITION:
			target.global_position = from_vector
		PositionType.LOCAL_OFFSET:
			target.position += from_vector
		# Nothing to do if from == CURRENT_POSITION

	var tween: Tween = animation.create_tween()
	@warning_ignore_start("return_value_discarded")
	tween.set_ease(ease)
	tween.set_trans(trans)
	tween.tween_property(target, "global_position", final_position, get_duration(animation))
	@warning_ignore_restore("return_value_discarded")

	return tween

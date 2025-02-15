class_name ProtonControlAnimationResource
extends Resource

## Abstract class
## Defines how the control is animated

enum PositionType {CURRENT_POSITION, ORIGINAL_POSITION, GLOBAL_POSITION, LOCAL_OFFSET}
enum ScaleType {CURRENT_SCALE, ORIGINAL_SCALE, ABSOLUTE_SCALE, RELATIVE_SCALE}

@export var easing: Tween.EaseType = Tween.EASE_IN_OUT
@export var transition: Tween.TransitionType = Tween.TRANS_QUAD
@export var default_duration: float = 1.0


## Override in child classes
func create_tween(_animation: ProtonControlAnimation, _target: Control) -> Tween:
	return null


## Returns the actual duration of the animation
## If a duration override is defined in the parent ControlAnimation node, use that
## Else, use the one defined on the animation resource.
func get_duration(animation: ProtonControlAnimation) -> float:
	if animation.duration > 0.0:
		return animation.duration
	return default_duration

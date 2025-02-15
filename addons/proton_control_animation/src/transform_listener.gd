class_name ProtonControlAnimationTransformListener
extends Control


var target: Control
var _previous_position: Vector2


func _ready() -> void:
	size = Vector2.ZERO
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	target = get_parent()
	_previous_position = position
	_update_metadata(true)

	#set_notify_transform(true)



## HACK: This only exists because the NOTIFICATION_TRANSFORM_CHANGED is never
## received on this node, unless it is selected from the remote tree.
func _process(delta: float) -> void:
	if position.is_equal_approx(_previous_position):
		return
	_previous_position = position
	if not _is_animation_in_progress():
		_update_metadata()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if not _is_animation_in_progress():
			_update_metadata()


func _find_parent_container(target: Control) -> Container:
	var node: Node = target
	while is_instance_valid(node) and not node is Container:
		node = node.get_parent()
	return node


func _update_metadata(full_state: bool = false) -> void:
	if not target.visible:
		return
	target.set_meta(ProtonControlAnimation.META_ORIGINAL_POSITION, target.position)
	# Only set the original rotation and scale once on ready.
	# These values will never be modified by the containers
	if full_state:
		target.set_meta(ProtonControlAnimation.META_ORIGINAL_ROTATION, target.rotation)
		target.set_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale)


func _is_animation_in_progress() -> bool:
	var list: Array = target.get_meta(ProtonControlAnimation.META_ANIMATION_IN_PROGRESS, [])
	return not list.is_empty()

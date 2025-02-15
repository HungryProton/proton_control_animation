extends Node

## Metadata Updater
##
## Detects when the target transform is modified from outside the animations.
## This can happen if the window is resized or if the parent container
## is sorting the child controls.
##
## If a modification happens, updates the meta data stored on the node.


var target: Control


func _ready() -> void:
	target = get_parent()
	_update_metadata(true)

	var parent: Control = target.get_parent_control()
	if parent:
		var _err: int = parent.resized.connect(_on_parent_resized)

	var container: Container = _find_parent_container(target)
	if container:
		var _err: int = container.sort_children.connect(_on_parent_sort_children)


func _find_parent_container(root: Control) -> Container:
	var node: Node = root
	while is_instance_valid(node) and not node is Container:
		node = node.get_parent()
	return node


func _update_metadata(full_state: bool = false) -> void:
	if not target.is_visible_in_tree():
		return

	target.set_meta(ProtonControlAnimation.META_ORIGINAL_POSITION, target.position)
	# Only set the original rotation and scale once on ready.
	# These values will never be modified by the containers.
	# TODO: They could still be modified by the user
	if full_state:
		target.set_meta(ProtonControlAnimation.META_ORIGINAL_ROTATION, target.rotation)
		target.set_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale)


func _is_animation_in_progress() -> bool:
	var list: Array = target.get_meta(ProtonControlAnimation.META_ANIMATION_IN_PROGRESS, [])
	return not list.is_empty()


func _on_parent_resized() -> void:
	if target.is_visible_in_tree():
		_update_metadata()


func _on_parent_sort_children() -> void:
	_update_metadata.call_deferred()

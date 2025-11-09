extends Node

## Metadata Updater
##
## Internal helper node.
## Detects when the target transform is modified from outside the animations.
## This can happen if the window is resized or if the parent container
## is sorting the child controls.
##
## If a modification happens, updates the meta data stored on the node.
## This metadata is used when animations need to access the original control's
## transform (or other data).


signal updated

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
	if not _can_update():
		return

	target.set_meta(ProtonControlAnimation.META_ORIGINAL_POSITION, target.position)
	# Only set the original rotation and scale once on ready.
	# These values will never be modified by the containers.
	# TODO: They could still be modified by the user
	if full_state:
		target.set_meta(ProtonControlAnimation.META_ORIGINAL_ROTATION, target.rotation)
		target.set_meta(ProtonControlAnimation.META_ORIGINAL_SCALE, target.scale)
		target.set_meta(ProtonControlAnimation.META_ORIGINAL_MODULATE, target.modulate)
		target.set_meta(ProtonControlAnimation.META_ORIGINAL_SELF_MODULATE, target.self_modulate)
		target.set_meta(ProtonControlAnimation.META_ORIGINAL_SIZE, target.size)
	updated.emit()


## Returns true if the target is in its final position.
## /!\ Update this on a case by case basis /!\
##
## If the target is the direct child of a container, it should be fine to update even if it's not
## visible (that's required for tab containers for example).
## In the case of a control placed with anchors though, it breaks, and I don't remember why.
## (Spamming the 'Side Panel' button in the 00_showcase scene breaks if the metadata is updated
## when the control is hidden)
func _can_update() -> bool:
	if not target.is_node_ready():
		return false
	if not target.get_parent() is Container:
		return target.is_visible_in_tree()
	return true


func _is_animation_in_progress() -> bool:
	var list: Array = target.get_meta(ProtonControlAnimation.META_ANIMATION_IN_PROGRESS, [])
	return not list.is_empty()


func _on_parent_resized() -> void:
	if target.is_visible_in_tree():
		_update_metadata()


func _on_parent_sort_children() -> void:
	_update_metadata.call_deferred()

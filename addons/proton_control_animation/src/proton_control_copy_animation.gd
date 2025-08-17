@tool
@icon("./icons/copy.svg")
class_name ProtonControlCopyAnimation
extends Node

## Utility node to assign the same animation to multiple nodes.
##
## This node must be the direct child of a ProtonAnimationNode


## An array of control nodes that will also be affected by the animation.
## The `ProtonControlAnimation` node is duplicated for each of these nodes.
## See `examples/03_copies.tscn` and `examples/04_copies_with[...]`
@export var extra_targets: Array[Control] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		for target: Control in extra_targets:
			ProtonControlAnimation.clear_meta_data(target)
		return

	var parent: Node = get_parent()
	if not parent is ProtonControlAnimation:
		return

	# For each extra target, duplicate the original animation node and assign.
	for extra_target: Control in extra_targets:
		if not is_instance_valid(extra_target):
			push_warning("Extra target is not assigned")
			continue
		var copy: ProtonControlAnimation = parent.duplicate()
		# Remove all the children in the duplicate, or this Copy node will be duplicated too
		# and will run this logic again in an infinite loop on ready.
		for child: Node in copy.get_children():
			copy.remove_child(child)
			child.queue_free()

		# Make sure the events are fired from the extra targets instead
		# of being fired from the original node, unless the trigger source is
		# explicitely set as a different node from the original target.
		if copy.target and copy.trigger_source == copy.target:
			copy.trigger_source = extra_target

		# Update the animation target
		copy.target = extra_target
		parent.add_child.call_deferred(copy)

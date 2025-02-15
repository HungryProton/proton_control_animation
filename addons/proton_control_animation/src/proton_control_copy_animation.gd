@icon("./icons/copy.svg")
class_name ProtonControlCopyAnimation
extends Node

## Utility node to assign the same animation to multiple nodes.
##
## This node must be the direct child of a ProtonAnimationNode


@export var extra_targets: Array[Control] = []


func _ready() -> void:
	var parent: Node = get_parent()
	if not parent is ProtonControlAnimation:
		return

	# For each extra target, duplicate the original animation node and assign.
	for target: Control in extra_targets:
		var copy: ProtonControlAnimation = parent.duplicate()
		# Remove all the children in the duplicate, or this Copy node will be duplicated too
		# and will run this logic again in an infinite loop on ready.
		for child: Node in copy.get_children():
			copy.remove_child(child)
			child.queue_free()

		copy.target = target
		parent.add_child.call_deferred(copy)

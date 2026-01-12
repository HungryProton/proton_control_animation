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

var _original_animation: ProtonControlAnimation
var _copies: Array[ProtonControlAnimation] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		for target: Control in extra_targets:
			ProtonControlAnimation.clear_meta_data(target)
		return

	var parent: Node = get_parent()
	if not parent is ProtonControlAnimation:
		return

	# It's possible to manually connect signals to the start and stop functions
	# on the animation node. If the original target has these kind of connections
	# they need to be duplicated on the copies as well.
	_original_animation = parent
	var original_target: Control = _original_animation.target
	var signals_to_duplicate: Array[Dictionary] = []

	if original_target:
		for signal_data: Dictionary in original_target.get_signal_list():
			var signal_name: StringName = signal_data["name"]
			for connection: Dictionary in original_target.get_signal_connection_list(signal_name):
				var callable: Callable = connection["callable"]
				var s: Signal = connection["signal"]
				if callable.get_object() == _original_animation:
					signals_to_duplicate.push_back({
						"signal": s.get_name(),
						"method": callable.get_method()
						})

	# For each extra target, duplicate the original animation node and assign.
	for extra_target: Control in extra_targets:
		if not is_instance_valid(extra_target):
			push_warning("Extra target is not assigned")
			continue
		var copy: ProtonControlAnimation = _original_animation.duplicate()
		# Remove all the children in the duplicate, or this Copy node will be duplicated too
		# and will run this logic again in an infinite loop on ready.
		for child: Node in copy.get_children():
			copy.remove_child(child)
			child.queue_free()

		# Update the animation target & connections
		copy.target = extra_target
		for signal_data: Dictionary in signals_to_duplicate:
			var signal_name: String = signal_data.signal
			var method_name: String = signal_data.method
			var err: Error = extra_target.connect(signal_name, copy.call.bind(method_name))
			if err != OK:
				printerr("Could not connect ", signal_name, " to ", method_name, " on object ", copy)

		parent.add_child.call_deferred(copy)
		_copies.push_back(copy)


## Play all the duplicated animations at once
func play_all(include_original: bool = true) -> void:
	if include_original and is_instance_valid(_original_animation):
		_original_animation.play()
	for pca: ProtonControlAnimation in _copies:
		if is_instance_valid(pca):
			pca.play()


## Stop all the duplicated animations at once
func stop_all(include_original: bool = true) -> void:
	if include_original and is_instance_valid(_original_animation):
		_original_animation.stop()
	for pca: ProtonControlAnimation in _copies:
		if is_instance_valid(pca):
			pca.stop()

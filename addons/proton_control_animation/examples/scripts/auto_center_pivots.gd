class_name PCA_AutoCenterPivots
extends Node

## Utility script to automatically center the controls pivots.

@export var parent: Control


func _ready() -> void:
	if not parent:
		return
	var _err: int = parent.resized.connect(_update_pivots)
	_update_pivots.call_deferred()


func _update_pivots() -> void:
	parent.pivot_offset = parent.size / 2.0

	for node: Node in parent.get_children():
		var control: Control = node as Control
		if not control:
			continue
		control.pivot_offset = control.size / 2.0

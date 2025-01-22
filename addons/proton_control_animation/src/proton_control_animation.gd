class_name ProtonControlAnimation
extends Node

## The main animation node
##
## Add this node to your scene tree, and create an Animation resource from the
## inspector.
##
## The animation resource holds the information related to the animation,
## while this nodes decides when the animation should run, and on which nodes.
##
## To avoid having one animation node per control (which is still possible)
## this node can monitor a number of "targets" controls nodes, which will be
## independently animated when the right conditions are triggered (See
## the "Triggers" category below)


const META_ORIGINAL_POSITION: String = "pca_original_position"
const META_ORIGINAL_ROTATION: String = "pca_original_rotation"
const META_ORIGINAL_SCALE: String = "pca_original_scale"


signal animation_started
signal animation_ended


@export var targets: Array[Control]

@export var animation: ProtonControlAnimationResource

@export var duration: float = -1.0:
	set(val):
		duration = max(0, val)

@export var delay: float = 0.0:
	set(val):
		delay = max(0, val)

@export_category("Triggers")
@export var on_show: bool
# @export var on_hide: bool # TODO: figure out how to make that one work
@export var on_hover_start: bool
@export var on_hover_stop: bool
@export var on_focus_entered: bool
@export var on_focus_exited: bool

## Only applicable for buttons
@export var on_pressed: bool

@export var on_parent_animation_start: bool
@export var on_parent_animation_end: bool
@export var parent_animation: ProtonControlAnimation

var _tweens: Dictionary[Control, Tween] = {}
var _parent_containers: Dictionary[Container, Array] = {}
var _original_data_outdated: bool = false


func _ready() -> void:
	if targets.is_empty():
		var parent := get_parent()
		if parent is Control:
			targets.push_back(parent)

	for target: Control in targets:
		initialize_target.bind(target).call_deferred()

	if parent_animation:
		parent_animation.animation_started.connect(_on_parent_animation_started)
		parent_animation.animation_ended.connect(_on_parent_animation_ended)


func initialize_target(target: Control) -> void:
	if not is_instance_valid(target):
		return

	target.visibility_changed.connect(_on_visibility_changed.bind(target))
	target.focus_entered.connect(_on_focus_entered.bind(target))
	target.focus_exited.connect(_on_focus_exited.bind(target))
	target.mouse_entered.connect(_on_mouse_entered.bind(target))
	target.mouse_exited.connect(_on_mouse_exited.bind(target))
	if target is Button:
		target.pressed.connect(_on_pressed.bind(target))

	_set_original_data(target)
	target.resized.connect(_set_original_data.bind(target))

	var container: Container = _find_parent_container(target)
	if is_instance_valid(container):
		if not _parent_containers.has(container):
			_parent_containers[container] = []
			container.sort_children.connect(_on_layout_update.bind(container))
		_parent_containers[container].push_back(target)


func _set_original_data(target: Control) -> void:
	target.set_meta(META_ORIGINAL_POSITION, target.position)
	target.set_meta(META_ORIGINAL_ROTATION, target.rotation)
	target.set_meta(META_ORIGINAL_SCALE, target.scale)
	_original_data_outdated = false


func start(target: Control = null) -> void:
	if not animation:
		return

	while _original_data_outdated:
		await get_tree().process_frame

	if target:
		if not target in targets:
			# Function was called from a user script, but the wrong target was passed.
			# TODO: raise an error
			return
		_start_deferred.bind(target).call_deferred()
		return

	# Function was called from outside without specifying a target.
	# Play the animation on all the registered control nodes.
	for t: Control in targets:
		_start_deferred.bind(t).call_deferred()


## Called at the end of the frame from start()
func _start_deferred(target: Control) -> void:
	clear(target)
	_tweens[target] = animation.create_tween(self, target)

	if delay > 0.0:
		_tweens[target].pause()
		await get_tree().create_timer(delay).timeout
		_tweens[target].play()

	animation_started.emit()
	await _tweens[target].finished
	clear(target)
	animation_ended.emit()


func clear(target: Control) -> void:
	var tween: Tween = _tweens.get(target, null)
	if tween and tween.is_running():
		tween.kill()
	_tweens.erase(target)


func clear_all() -> void:
	for target in targets:
		clear(target)
	_tweens.clear()


func _find_parent_container(target: Control) -> Container:
	var node: Control = target
	while is_instance_valid(node) and not node is Container:
		node = node.get_parent()
	return node


func _on_layout_update(container: Container) -> void:
	_original_data_outdated = true
	for target: Control in _parent_containers[container]:
		_set_original_data.bind(target).call_deferred()
		if _tweens.has(target):
			pass # TODO: if this happens, it's too late because the tween
			# modified the control's transform already


func _on_visibility_changed(target: Control) -> void:
	# Showing the control will trigger a layout update, but too late.
	# force this flag to true to avoid starting the tween before the container
	# is done sorting the children.
	_original_data_outdated = true

	if on_show and target.visible:
		start(target)

	# TODO: on_hide can't work here because the target is already hidden
	# find a way to intercept the hide() method somehow and actually hide it
	# when the animation is done?


func _on_mouse_entered(target: Control) -> void:
	if on_hover_start:
		start(target)


func _on_mouse_exited(target: Control) -> void:
	if on_hover_stop:
		start(target)


func _on_focus_entered(target: Control) -> void:
	if on_focus_entered:
		start(target)


func _on_focus_exited(target: Control) -> void:
	if on_focus_exited:
		start(target)


func _on_pressed(target: Button) -> void:
	if on_pressed:
		start(target)


func _on_parent_animation_started() -> void:
	if parent_animation and on_parent_animation_start:
		for target: Control in targets:
			start(target)


func _on_parent_animation_ended() -> void:
	if parent_animation and on_parent_animation_end:
		for target: Control in targets:
			start(target)

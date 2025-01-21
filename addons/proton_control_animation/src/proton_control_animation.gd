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
signal animation_completed


@export var targets: Array[Control]

@export var animation: ProtonControlAnimationResource

@export var duration: float = -1.0:
	set(val):
		duration = max(0, val)

@export var delay: float = 0.0:
	set(val):
		delay = max(0, val)

@export_category("SubAnimations")
@export var sub_animations: Array[ProtonControlAnimation]
@export var run_in_parallel: bool = true
@export var delay_before_run: float = 0.0
@export var delay_between_each: float = 0.0 # Only applicable if run_in_parallel is false

@export_category("Triggers")
@export var on_show: bool
# @export var on_hide: bool # TODO: figure out how to make that one work
@export var on_hover_start: bool
@export var on_hover_stop: bool
@export var on_focus_entered: bool
@export var on_focus_exited: bool
@export var on_pressed: bool # Only applicable for buttons

var _tweens: Dictionary[Control, Tween] = {}


func _ready() -> void:
	if targets.is_empty():
		var parent := get_parent()
		if parent is Control:
			targets.push_back(parent)

	for target: Control in targets:
		initialize_target(target)


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

	_set_original_data.bind(target).call_deferred()


func _set_original_data(target) -> void:
	target.set_meta(META_ORIGINAL_POSITION, target.global_position)
	target.set_meta(META_ORIGINAL_ROTATION, target.rotation)
	target.set_meta(META_ORIGINAL_SCALE, target.scale)


func start(target: Control) -> void:
	if not animation:
		return

	_tweens[target] = animation.create_tween(self, target)

	if delay > 0.0:
		_tweens[target].pause()
		await get_tree().create_timer(delay).timeout
		_tweens[target].play()

	start_sub_animations()


func start_sub_animations() -> void:
	if delay_before_run:
		await get_tree().create_timer(delay_before_run).timeout

	for pca: ProtonControlAnimation in sub_animations:
		for target in pca.targets:
			pca.start(target)
		if delay_between_each:
			await get_tree().create_timer(delay_between_each).timeout


func reset() -> void:
	for control: Control in _tweens:
		var tween: Tween = _tweens[control]
		if tween and tween.is_running():
			tween.kill()
	_tweens.clear()


func _on_visibility_changed(target: Control) -> void:
	if on_show and target.visible:
		start.bind(target).call_deferred() # has to happen after the container is done sorting its children

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

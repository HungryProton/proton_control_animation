@tool
@icon("./icons/animation.svg")
class_name ProtonControlAnimation
extends Node

## The main animation node
##
## Add this node to your scene tree, and create an Animation resource from the
## inspector.
##
## The animation resource holds the information related to the animation,
## while this nodes decides where and when the animation should run.


const METADATA_UPDATER := preload("./metadata_updater.gd")

const META_ORIGINAL_POSITION: String = "pca_original_position"
const META_ORIGINAL_ROTATION: String = "pca_original_rotation"
const META_ORIGINAL_SCALE: String = "pca_original_scale"
const META_ANIMATION_IN_PROGRESS: String = "pca_animation_in_progress"
const META_HAS_UPDATER: String = "pca_metadata_updater"
const META_HIDE_ANIMATIONS: String = "pca_hide_animations"
const META_IGNORE_VISIBILITY_TRIGGERS: String = "pca_ignore_visibility_triggers"


signal animation_started
signal animation_ended

# TODO:
enum LoopType {
	NONE,
	LINEAR,
	PING_PONG
}

## The control node that will be animated
@export var target: Control:
	set(val):
		target = val
		if not target:
			target = get_parent()
		if not trigger_source:
			trigger_source = target
		notify_property_list_changed()

## The animation that plays on the target
@export var animation: ProtonControlAnimationResource

## How long the animation last, in seconds.
## This has priority over the `default_duration` property from the `animation` resource.
@export var duration: float = -1.0:
	set(val):
		duration = max(0, val)

## If the animation should start, wait this amount of time before actually starting it (in seconds).
@export var delay: float = 0.0:
	set(val):
		delay = max(0, val)


@export_category("Loop")

## None: The animation does not loop
## Linear: Play the animation from the start again when it's complete
## PingPong: Play the animation backwards from the end when it's complete
@export var loop_type: LoopType = LoopType.NONE:
	set(val):
		loop_type = val
		property_list_changed.emit()

## How many times the animation should play before stopping
@export_range(1, 10, 1, "or_greater") var loop_count: int = 1

@export_category("Triggers")

## If true, when the animation is already playing but something tries to play
## the animation again, restart the animation when it's complete.
@export var accumulate_start_events: bool = false

## On which node the trigger events are listened.
## If empty, `target` will be used instead.
@export var trigger_source: Node:
	set(val):
		trigger_source = val
		notify_property_list_changed()

## The animation will play when the Control becomes visible.
@export var on_show: bool

## The animation will play when the Control is hidden.
@export var on_hide: bool # TODO: kinda hacky for now

## The animation will play when the mouse enters the Control.
@export var on_hover_start: bool

## The animation will play when the mouse exits the Control.
@export var on_hover_stop: bool

## The animation will play when the control aquires the focus
@export var on_focus_entered: bool

## The animation will play when the control releases the focus
@export var on_focus_exited: bool

## The animation will play when the Button is pressed.
## (Only applicable if `trigger_source` is a Button)
@export var on_pressed: bool

## The animation will play when the source animation starts.
## (Only applicable if `trigger_source` is a ProtonControlAnimation)
@export var on_animation_start: bool

## The animation will play when the source animation ends.
## (Only applicable if `trigger_source` is a ProtonControlAnimation)
@export var on_animation_end: bool


var _tween: Tween
var _started: bool = false
var _restart_queued: bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		clear_meta_data(target)
		return

	var _err: int

	if trigger_source is Button:
		var button: Button = trigger_source as Button
		_err = button.pressed.connect(_on_pressed)

	if trigger_source is Control:
		var control: Control = trigger_source as Control
		_err = control.visibility_changed.connect(_on_visibility_changed)
		_err = control.focus_entered.connect(_on_focus_entered)
		_err = control.focus_exited.connect(_on_focus_exited)
		_err = control.mouse_entered.connect(_on_mouse_entered)
		_err = control.mouse_exited.connect(_on_mouse_exited)

	if trigger_source is ProtonControlAnimation:
		var source_animation: ProtonControlAnimation = trigger_source as ProtonControlAnimation
		_err = source_animation.animation_started.connect(_on_parent_animation_started)
		_err = source_animation.animation_ended.connect(_on_parent_animation_ended)

	if not is_instance_valid(target):
		return

	if on_hide:
		var list: Array = target.get_meta(META_HIDE_ANIMATIONS, [])
		list.push_back(self)
		target.set_meta(META_HIDE_ANIMATIONS, list)

	if target.get_meta(META_HAS_UPDATER, false):
		return

	var updater: Node = METADATA_UPDATER.new()
	target.add_child.call_deferred(updater)
	target.set_meta(META_HAS_UPDATER, true)


func _validate_property(property: Dictionary) -> void:
	_update_inspector_visibility(property, "loop_count", loop_type != LoopType.NONE)

	var is_control: bool = trigger_source is Control
	_update_inspector_visibility(property, "on_show", is_control)
	_update_inspector_visibility(property, "on_hide", is_control)
	_update_inspector_visibility(property, "on_hover_start", is_control)
	_update_inspector_visibility(property, "on_hover_stop", is_control)
	_update_inspector_visibility(property, "on_focus_entered", is_control)
	_update_inspector_visibility(property, "on_focus_exited", is_control)
	_update_inspector_visibility(property, "on_pressed", trigger_source is BaseButton)
	_update_inspector_visibility(property, "on_animation_start", trigger_source is ProtonControlAnimation)
	_update_inspector_visibility(property, "on_animation_end", trigger_source is ProtonControlAnimation)


## Call this from _validate_property() to quickly hide or show exported property depending on context.
func _update_inspector_visibility(property: Dictionary, p_name: String, visible: bool) -> void:
	if property.name == p_name:
		property.usage = PROPERTY_USAGE_DEFAULT if visible else PROPERTY_USAGE_STORAGE


func start() -> void:
	if Engine.is_editor_hint():
		return

	if not animation or _started:
		if accumulate_start_events:
			_restart_queued = true
		return

	_started = true
	_start_deferred.call_deferred()


## Called at the end of the frame from start()
func _start_deferred() -> void:
	clear()
	var list: Array = target.get_meta(META_ANIMATION_IN_PROGRESS, [])
	list.push_back(self)
	target.set_meta(META_ANIMATION_IN_PROGRESS, list)

	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

	animation_started.emit()

	for i: int in max(loop_count, 1):
		_tween = animation.create_tween(self, target)
		await _tween.finished

		if loop_type == LoopType.PING_PONG:
			_tween = animation.create_tween_reverse(self, target)
			await _tween.finished

	clear()
	_started = false
	animation_ended.emit()

	if _restart_queued:
		_restart_queued = false
		start()


func clear() -> void:
	if is_instance_valid(_tween) and _tween.is_running():
		_tween.kill()
	_tween = null
	# Remove from the list of animations currently affecting the target control
	var list: Array = target.get_meta(META_ANIMATION_IN_PROGRESS, [])
	list.erase(self)
	target.set_meta(META_ANIMATION_IN_PROGRESS, list)


#region callbacks

func _on_visibility_changed() -> void:
	if target.get_meta(META_IGNORE_VISIBILITY_TRIGGERS, false):
		return

	var is_visible: bool = (trigger_source as Control).visible

	if on_show and is_visible:
		start()
	elif on_hide and not is_visible:
		ProtonControlAnimation.hide(target)


func _on_mouse_entered() -> void:
	if on_hover_start:
		start()


func _on_mouse_exited() -> void:
	if on_hover_stop:
		start()


func _on_focus_entered() -> void:
	if on_focus_entered:
		start()


func _on_focus_exited() -> void:
	if on_focus_exited:
		start()


func _on_pressed() -> void:
	if on_pressed:
		start()


func _on_parent_animation_started() -> void:
	if on_animation_start:
		start()


func _on_parent_animation_ended() -> void:
	if on_animation_end:
		start()

#endregion


#region static

## Start all the animations that should play when this control is hidden.
## Then, hide the control when all the animations are complete.
## If no animation is found, immediately hide the control.
##
## This should be called automatically if the on_hide trigger is set.
## If it's not working properly, you can call this method manually instead
## of calling hide() on the control.
static func hide(control: Control) -> void:
	# Meta flag is there to prevent a chain reaction because this method changes
	# the control's visibility
	control.set_meta(META_IGNORE_VISIBILITY_TRIGGERS, true)
	control.show()

	# Find all animations affecting this control on hide and play them.
	var array: Array = control.get_meta(META_HIDE_ANIMATIONS, []) # Typed array shenanigans to avoid warnings
	var hide_animations: Array[ProtonControlAnimation] = []
	hide_animations.assign(array)
	for a: ProtonControlAnimation in hide_animations:
		a.start()

	# Wait until all animations are complete
	while not hide_animations.is_empty():
		var i: int = 0
		while i < hide_animations.size():
			var a: ProtonControlAnimation = hide_animations[i]
			if not a._started:
				hide_animations.remove_at(i)
			else:
				i += 1
		if not hide_animations.is_empty():
			await hide_animations[0].animation_ended
			hide_animations.pop_front()

	# Actually hide the control
	control.hide()
	control.set_meta(META_IGNORE_VISIBILITY_TRIGGERS, false)


## Removes any meta data related to this addon in a given node.
## This exists because I forgot to put `is_editor_hint` guards in some
## tool scripts and now there are meta data that shouldn't exist in editor
## potentially stored in people's projects.
static func clear_meta_data(node: Control) -> void:
	if not is_instance_valid(node):
		return

	for meta: StringName in node.get_meta_list():
		if meta.begins_with("pca_"):
			node.remove_meta(meta)

#endregion

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
##
## See the [online documentation](https://hungryproton.github.io/proton_control_animation/index.html)
## for more information.


const METADATA_UPDATER := preload("./metadata_updater.gd")

const META_ORIGINAL_POSITION: String = "pca_original_position"
const META_ORIGINAL_ROTATION: String = "pca_original_rotation"
const META_ORIGINAL_SCALE: String = "pca_original_scale"
const META_ORIGINAL_SIZE: String = "pca_original_size"
const META_ORIGINAL_MODULATE: String = "pca_original_modulate"
const META_ORIGINAL_SELF_MODULATE: String = "pca_original_self_modulate"
const META_ANIMATION_IN_PROGRESS: String = "pca_animation_in_progress"
const META_HAS_UPDATER: String = "pca_metadata_updater"
const META_HIDE_ANIMATIONS: String = "pca_hide_animations"
const META_IGNORE_VISIBILITY_TRIGGERS: String = "pca_ignore_visibility_triggers"


## Emitted when the animation starts. This is emitted after the delay (if any),
## when the tween actually starts moving the UI.
signal animation_started

## Emitted when the animation ends. This is emitted once after all the loops
## are complete (if any).
signal animation_finished

## Alias for animation_finished (For backward compatibility purposes)
signal animation_ended


enum LoopType {
	NONE,
	LINEAR,
	PING_PONG
}

enum PivotOverride {NONE, CUSTOM, CENTER,
		CENTER_TOP, CENTER_BOTTOM, CENTER_LEFT, CENTER_RIGHT,
		TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT}

enum StopBehavior {
	WAIT_UNTIL_END,
	IN_PLACE,
	RESET,
}

## The control node that will be animated
@export var target: Control:
	set(val):
		var old_target: Control = target
		target = val
		if not target:
			target = get_parent()
		if not start_trigger_source or start_trigger_source == old_target:
			start_trigger_source = target
		if not stop_trigger_source or stop_trigger_source == old_target:
			stop_trigger_source = target
		notify_property_list_changed()

## The animation that plays on the target
@export var animation: ProtonControlAnimationResource

## How long the animation last, in seconds.
## This has priority over the `default_duration` property from the `animation` resource.
@export var duration: float = -1.0:
	set(val):
		duration = max(-1.0, val)

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
		notify_property_list_changed()

@export var infinite_loop: bool = false:
	set(val):
		infinite_loop = val
		notify_property_list_changed()

## How many times the animation should play before stopping
@export_range(1, 10, 1, "or_greater") var loop_count: int = 1

@export_category("Triggers")
@export_group("Start triggers")

## If true, when the animation is already playing but something tries to play
## the animation again, restart the animation when it's complete.
@export var accumulate_start_events: bool = false

## On which node the trigger events are listened.
## If empty, `target` will be used instead.
@export var start_trigger_source: Node:
	set(val):
		start_trigger_source = val
		notify_property_list_changed()

## The animation will play when the Control becomes visible.
@export var start_on_show: bool

## The animation will play when the Control is hidden.
@export var start_on_hide: bool # TODO: kinda hacky for now

## The animation will play when the mouse enters the Control.
@export var start_on_hover_start: bool

## The animation will play when the mouse exits the Control.
@export var start_on_hover_stop: bool

## The animation will play when the control aquires the focus
@export var start_on_focus_entered: bool

## The animation will play when the control releases the focus
@export var start_on_focus_exited: bool

## The animation will play when the Button is pressed.
## (Only applicable if `trigger_source` is a Button)
@export var start_on_pressed: bool

## The animation will play when the source animation starts.
## (Only applicable if `trigger_source` is a ProtonControlAnimation)
@export var start_on_animation_start: bool

## The animation will play when the source animation ends.
## (Only applicable if `trigger_source` is a ProtonControlAnimation)
@export var start_on_animation_end: bool

## Starts the animation when this signal is emitted from the trigger source.
## Foolproof way of connecting a signal to the start() method, as this technique
## handles unbinding the arguments automatically if any.
@export var start_custom_signal: String = ""


@export_group("Stop triggers")

## What happens to the animation when interrupted.
## WAIT_UNTIL_END: Waits for the current loop to complete and stops the animation.
## IN_PLACE: Immediately stops, leaves the control as is in its mid animation state.
## RESET: Stops immediately and restores the control original transform.
@export var stop_behavior: StopBehavior = StopBehavior.WAIT_UNTIL_END

## On which node the trigger events are listened.
## If empty, `target` will be used instead.
@export var stop_trigger_source: Node:
	set(val):
		stop_trigger_source = val
		notify_property_list_changed()

## If playing, the animation will stop when the Control becomes visible.
@export var stop_on_show: bool

## The animation will play when the Control is hidden.
@export var stop_on_hide: bool # TODO: kinda hacky for now

## The animation will play when the mouse enters the Control.
@export var stop_on_hover_start: bool

## The animation will play when the mouse exits the Control.
@export var stop_on_hover_stop: bool

## The animation will play when the control aquires the focus
@export var stop_on_focus_entered: bool

## The animation will play when the control releases the focus
@export var stop_on_focus_exited: bool

## The animation will play when the Button is pressed.
## (Only applicable if `trigger_source` is a Button)
@export var stop_on_pressed: bool

## The animation will play when the source animation starts.
## (Only applicable if `trigger_source` is a ProtonControlAnimation)
@export var stop_on_animation_start: bool

## The animation will play when the source animation ends.
## (Only applicable if `trigger_source` is a ProtonControlAnimation)
@export var stop_on_animation_end: bool

## Starts the animation when this signal is emitted from the trigger source.
## Foolproof way of connecting a signal to the start() method, as this technique
## handles unbinding the arguments automatically if any.
@export var stop_custom_signal: String = ""

@export_category("Overrides")

## Overrides the target pivot offset, even if the control is under a container.
@export var override_pivot: PivotOverride = PivotOverride.NONE:
	set(val):
		override_pivot = val
		notify_property_list_changed()

## Replaces the `pivot_offset` value in the target control.
## Only applicable if `override_pivot == CUSTOM`
@export var pivot_offset_override: Vector2 = Vector2.ZERO

var _tween: Tween
var _started: bool = false
var _restart_queued: bool = false
var _stop_flag: bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		clear_meta_data(target)
		return

	var _err: int

	if start_trigger_source is BaseButton:
		var button: BaseButton = start_trigger_source as BaseButton
		_err = button.pressed.connect(_on_start_trigger_pressed)

	if stop_trigger_source is BaseButton:
		var button: BaseButton = stop_trigger_source as BaseButton
		_err = button.pressed.connect(_on_stop_trigger_pressed)

	if start_trigger_source is Control:
		var control: Control = start_trigger_source as Control
		_err = control.visibility_changed.connect(_on_start_trigger_visibility_changed)
		_err = control.focus_entered.connect(_on_start_trigger_focus_entered)
		_err = control.focus_exited.connect(_on_start_trigger_focus_exited)
		_err = control.mouse_entered.connect(_on_start_trigger_mouse_entered)
		_err = control.mouse_exited.connect(_on_start_trigger_mouse_exited)

	if stop_trigger_source is Control:
		var control: Control = stop_trigger_source as Control
		_err = control.visibility_changed.connect(_on_stop_trigger_visibility_changed)
		_err = control.focus_entered.connect(_on_stop_trigger_focus_entered)
		_err = control.focus_exited.connect(_on_stop_trigger_focus_exited)
		_err = control.mouse_entered.connect(_on_stop_trigger_mouse_entered)
		_err = control.mouse_exited.connect(_on_stop_trigger_mouse_exited)

	if start_trigger_source is ProtonControlAnimation:
		var source_animation: ProtonControlAnimation = start_trigger_source as ProtonControlAnimation
		_err = source_animation.animation_started.connect(_on_start_trigger_parent_animation_started)
		_err = source_animation.animation_finished.connect(_on_start_trigger_parent_animation_finished)

	if stop_trigger_source is ProtonControlAnimation:
		var source_animation: ProtonControlAnimation = stop_trigger_source as ProtonControlAnimation
		_err = source_animation.animation_started.connect(_on_stop_trigger_parent_animation_started)
		_err = source_animation.animation_finished.connect(_on_stop_trigger_parent_animation_finished)

	_connect_custom_signal(start_trigger_source, start_custom_signal, start)
	_connect_custom_signal(stop_trigger_source, stop_custom_signal, stop)

	if not is_instance_valid(target):
		return

	if start_on_hide:
		var list: Array = target.get_meta(META_HIDE_ANIMATIONS, [])
		list.push_back(self)
		target.set_meta(META_HIDE_ANIMATIONS, list)

	if not target.get_meta(META_HAS_UPDATER, false):
		var updater: METADATA_UPDATER = METADATA_UPDATER.new()
		target.add_child.call_deferred(updater)
		target.set_meta(META_HAS_UPDATER, true)
		_err = updater.updated.connect(_on_meta_data_updated)

	if start_trigger_source is Control:
		if (start_trigger_source as Control).visible and start_on_show:
			_on_start_trigger_visibility_changed.call_deferred()

	_err = target.resized.connect(_validate_pivot)


## Backward compatibility code
## Triggers were renamed with the "start_" prefix to accomodate the new "stop_" triggers
## introduced with the infinite loop feature.
## This function ensures old animation nodes will keep working the same
## without any user intervention.
func _set(property: StringName, value: Variant) -> bool:
	if property == "trigger_source":
		start_trigger_source = value
		return true
	elif property == "on_show":
		start_on_show = value
		return true
	elif property == "on_hide":
		start_on_hide = value
		return true
	elif property == "on_hover_start":
		start_on_hover_start = value
		return true
	elif property == "on_hover_stop":
		start_on_hover_stop = value
		return true
	elif property == "on_focus_entered":
		start_on_focus_entered = value
		return true
	elif property == "on_focus_exited":
		start_on_focus_exited = value
		return true
	elif property == "on_pressed":
		start_on_pressed = value
		return true
	elif property == "on_animation_start":
		start_on_animation_start = value
		return true
	elif property == "on_animation_end":
		start_on_animation_end = value
		return true

	return false


## Decides which properties should be visible in the inspector.
## Some properties directly depends on other properties. They can be hidden
## when they're not relevant, saving space and making things less confusing
## for the end user.
func _validate_property(property: Dictionary) -> void:
	# Populate the custom signal list
	if property.name == "start_custom_signal":
		_update_custom_signal_export(property, start_trigger_source)
		return
	elif property.name == "stop_custom_signal":
		_update_custom_signal_export(property, stop_trigger_source)
		return

	# Loop properties
	_update_inspector_visibility(property, "loop_count", loop_type != LoopType.NONE and not infinite_loop)
	_update_inspector_visibility(property, "infinite_loop", loop_type != LoopType.NONE)

	# Trigger properties
	var is_control: bool = start_trigger_source is Control
	_update_inspector_visibility(property, "start_on_show", is_control)
	_update_inspector_visibility(property, "start_on_hide", is_control)
	_update_inspector_visibility(property, "start_on_hover_start", is_control)
	_update_inspector_visibility(property, "start_on_hover_stop", is_control)
	_update_inspector_visibility(property, "start_on_focus_entered", is_control)
	_update_inspector_visibility(property, "start_on_focus_exited", is_control)
	_update_inspector_visibility(property, "start_on_pressed", start_trigger_source is BaseButton)
	_update_inspector_visibility(property, "start_on_animation_start", start_trigger_source is ProtonControlAnimation)
	_update_inspector_visibility(property, "start_on_animation_end", start_trigger_source is ProtonControlAnimation)

	is_control = stop_trigger_source is Control
	_update_inspector_visibility(property, "stop_on_show", is_control)
	_update_inspector_visibility(property, "stop_on_hide", is_control)
	_update_inspector_visibility(property, "stop_on_hover_start", is_control)
	_update_inspector_visibility(property, "stop_on_hover_stop", is_control)
	_update_inspector_visibility(property, "stop_on_focus_entered", is_control)
	_update_inspector_visibility(property, "stop_on_focus_exited", is_control)
	_update_inspector_visibility(property, "stop_on_pressed", stop_trigger_source is BaseButton)
	_update_inspector_visibility(property, "stop_on_animation_start", stop_trigger_source is ProtonControlAnimation)
	_update_inspector_visibility(property, "stop_on_animation_end", stop_trigger_source is ProtonControlAnimation)

	# Pivot
	_update_inspector_visibility(property, "pivot_offset_override", override_pivot == PivotOverride.CUSTOM)


## Call this from _validate_property() to quickly hide or show exported property depending on context.
func _update_inspector_visibility(property: Dictionary, p_name: String, visible: bool) -> void:
	if property.name == p_name:
		property.usage = PROPERTY_USAGE_DEFAULT if visible else PROPERTY_USAGE_STORAGE


func _update_custom_signal_export(property: Dictionary, trigger_source: Node) -> void:
	if not is_instance_valid(trigger_source):
		property.usage = PROPERTY_USAGE_STORAGE
		return

	# Trigger source exists, expose all the valid signals to the inspector.
	var signal_list: Array[String] = []
	for s: Dictionary in trigger_source.get_signal_list():
		signal_list.push_back(s.name)

	signal_list.sort()

	var hint_string: String = ""
	for signal_name: String in signal_list:
		if not hint_string.is_empty():
			hint_string += ","
		hint_string += signal_name

	property.hint = PROPERTY_HINT_ENUM
	property.hint_string = hint_string
	property.usage = PROPERTY_USAGE_DEFAULT


## Plays the animation.
## Directly call this method or connect it to a signal.
func play() -> void:
	if Engine.is_editor_hint():
		return

	if not animation or _started:
		if accumulate_start_events:
			_restart_queued = true
		return

	_started = true
	_start_deferred.call_deferred()


## Alias for play() - For backward compatibility purposes
func start() -> void:
	play()


func stop() -> void:
	_stop_flag = true
	if stop_behavior != StopBehavior.WAIT_UNTIL_END:
		if _tween:
			_tween.kill()
			_tween.finished.emit()


## Called at the end of the frame from start()
func _start_deferred() -> void:
	clear()
	var list: Array = target.get_meta(META_ANIMATION_IN_PROGRESS, [])
	list.push_back(self)
	target.set_meta(META_ANIMATION_IN_PROGRESS, list)

	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

	animation_started.emit()

	var i: int = 0
	_stop_flag = false

	while not _stop_flag:
		# Start a loop
		_tween = animation.create_tween(self, target)
		await _tween.finished

		if _stop_flag: # Tween was interrupted before completion
			if stop_behavior == StopBehavior.IN_PLACE:
				break
			elif stop_behavior == StopBehavior.RESET:
				animation.reset(self, target)
				break

		# Return loop
		if loop_type == LoopType.PING_PONG:
			_tween = animation.create_tween_reverse(self, target)
			await _tween.finished

			# If the return loop was interupted, reset the target if necessary
			if _stop_flag and stop_behavior == StopBehavior.RESET:
				animation.reset(self, target)
				break

		if not infinite_loop:
			i += 1
			if i >= loop_count:
				break

	clear()
	_started = false
	animation_finished.emit()
	animation_ended.emit() # Backward compatibility

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


func _connect_custom_signal(trigger_source: Node, custom_signal: String, callback: Callable) -> void:
	if not is_instance_valid(trigger_source) or custom_signal.is_empty():
		return

	# Find how many arguments comes with the signal
	var args_count: int = -1
	for s: Dictionary in trigger_source.get_signal_list():
		if s.name == custom_signal:
			var args: Array[Dictionary] = s.args
			args_count = args.size()
			break

	if args_count < 0:
		push_warning("Signal ", custom_signal, " is not present on ", trigger_source)
		return

	# Callback takes no argument, unbinds the ones comming from custom_signal if any

	var err: Error
	if args_count == 0:
		err = trigger_source.connect(custom_signal, callback)
	else:
		err = trigger_source.connect(custom_signal, callback.unbind(args_count))
	if err != OK:
		push_warning("Could not connect ", custom_signal, " - Error: ", err)


func _validate_pivot() -> void:
	if not target:
		return

	match override_pivot:
		PivotOverride.NONE:
			return

		PivotOverride.CUSTOM:
			target.pivot_offset = pivot_offset_override

		PivotOverride.CENTER:
			target.pivot_offset = target.size / 2.0

		PivotOverride.CENTER_TOP:
			target.pivot_offset.x = target.size.x / 2.0
			target.pivot_offset.y = 0.0

		PivotOverride.CENTER_BOTTOM:
			target.pivot_offset.x = target.size.x / 2.0
			target.pivot_offset.y = target.size.y

		PivotOverride.CENTER_LEFT:
			target.pivot_offset.x = 0.0
			target.pivot_offset.y = target.size.y / 2.0

		PivotOverride.CENTER_RIGHT:
			target.pivot_offset.x = target.size.x
			target.pivot_offset.y = target.size.y / 2.0

		PivotOverride.TOP_LEFT:
			target.pivot_offset = Vector2.ZERO

		PivotOverride.TOP_RIGHT:
			target.pivot_offset.x = target.size.x
			target.pivot_offset.y = 0

		PivotOverride.BOTTOM_LEFT:
			target.pivot_offset.x = 0
			target.pivot_offset.y = target.size.y

		PivotOverride.BOTTOM_RIGHT:
			target.pivot_offset = target.size


#region callbacks

func _on_start_trigger_visibility_changed() -> void:
	if target.get_meta(META_IGNORE_VISIBILITY_TRIGGERS, false):
		return

	var is_visible: bool = (start_trigger_source as Control).visible

	if start_on_show and is_visible:
		start()
	elif start_on_hide and not is_visible:
		ProtonControlAnimation.hide(target)


func _on_stop_trigger_visibility_changed() -> void:
	if target.get_meta(META_IGNORE_VISIBILITY_TRIGGERS, false):
		return

	var is_visible: bool = (stop_trigger_source as Control).visible

	if stop_on_show and is_visible:
		stop()
	elif stop_on_hide and not is_visible:
		stop()


func _on_start_trigger_mouse_entered() -> void:
	if start_on_hover_start:
		start()


func _on_stop_trigger_mouse_entered() -> void:
	if stop_on_hover_start:
		stop()


func _on_start_trigger_mouse_exited() -> void:
	if start_on_hover_stop:
		start()


func _on_stop_trigger_mouse_exited() -> void:
	if stop_on_hover_stop:
		stop()


func _on_start_trigger_focus_entered() -> void:
	if start_on_focus_entered:
		start()


func _on_stop_trigger_focus_entered() -> void:
	if stop_on_focus_entered:
		stop()


func _on_start_trigger_focus_exited() -> void:
	if start_on_focus_exited:
		start()


func _on_stop_trigger_focus_exited() -> void:
	if stop_on_focus_exited:
		stop()


func _on_start_trigger_pressed() -> void:
	if start_on_pressed:
		start()


func _on_stop_trigger_pressed() -> void:
	if stop_on_pressed:
		stop()


func _on_start_trigger_parent_animation_started() -> void:
	if start_on_animation_start:
		start()


func _on_stop_trigger_parent_animation_started() -> void:
	if stop_on_animation_start:
		stop()


func _on_start_trigger_parent_animation_finished() -> void:
	if start_on_animation_end:
		start()


func _on_stop_trigger_parent_animation_finished() -> void:
	if stop_on_animation_end:
		stop()


func _on_meta_data_updated() -> void:
	_validate_pivot()


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
			await hide_animations[0].animation_finished
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

class_name ProtonControlTrigger
extends Node

## Emits a signal when any of the selected event happens.
## Do not use this node directly

signal triggered


const META_IGNORE_VISIBILITY_TRIGGERS: String = "pca_ignore_visibility_triggers"


@export var trigger_source: Node
@export var on_show: bool
@export var on_hide: bool # TODO: kinda hacky for now
@export var on_hover_start: bool
@export var on_hover_stop: bool
@export var on_focus_entered: bool
@export var on_focus_exited: bool

## Only applicable if trigger source is a button
@export var on_pressed: bool

## Only applicable if trigger source is an animation
@export var on_animation_start: bool
@export var on_animation_end: bool


var ignore_visibility_triggers: bool = false


func _ready() -> void:
	if not is_instance_valid(trigger_source):
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
		var animation: ProtonControlAnimation = trigger_source as ProtonControlAnimation
		_err = animation.animation_started.connect(_on_parent_animation_started)
		_err = animation.animation_ended.connect(_on_parent_animation_ended)


## Override in child class
func _on_hide_triggered() -> void:
	pass


func _on_visibility_changed() -> void:
	if trigger_source.get_meta(META_IGNORE_VISIBILITY_TRIGGERS, false):
		return

	var is_visible: bool = (trigger_source as Control).visible

	if on_show and is_visible:
		triggered.emit()
	elif on_hide and not is_visible:
		_on_hide_triggered()


func _on_mouse_entered() -> void:
	if on_hover_start:
		triggered.emit()


func _on_mouse_exited() -> void:
	if on_hover_stop:
		triggered.emit()


func _on_focus_entered() -> void:
	if on_focus_entered:
		triggered.emit()


func _on_focus_exited() -> void:
	if on_focus_exited:
		triggered.emit()


func _on_pressed() -> void:
	if on_pressed:
		triggered.emit()


func _on_parent_animation_started() -> void:
	if on_animation_start:
		triggered.emit()


func _on_parent_animation_ended() -> void:
	if on_animation_end:
		triggered.emit()

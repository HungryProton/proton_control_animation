class_name ProtonControlTrigger
extends Node

## Emits a signal when any of the selected event happens.


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

	if trigger_source is Button:
		trigger_source.pressed.connect(_on_pressed)

	if trigger_source is Control:
		trigger_source.visibility_changed.connect(_on_visibility_changed)
		trigger_source.focus_entered.connect(_on_focus_entered)
		trigger_source.focus_exited.connect(_on_focus_exited)
		trigger_source.mouse_entered.connect(_on_mouse_entered)
		trigger_source.mouse_exited.connect(_on_mouse_exited)

	if trigger_source is ProtonControlAnimation:
		trigger_source.animation_started.connect(_on_parent_animation_started)
		trigger_source.animation_ended.connect(_on_parent_animation_ended)


## Override in child class
func _on_hide_triggered() -> void:
	pass


func _on_visibility_changed() -> void:
	if trigger_source.get_meta(META_IGNORE_VISIBILITY_TRIGGERS, false):
		return
	if on_show and trigger_source.visible:
		triggered.emit()
	elif on_hide and not trigger_source.visible:
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

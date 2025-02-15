class_name ProtonControlAnimation
extends ProtonControlTrigger

## The main animation node
##
## Add this node to your scene tree, and create an Animation resource from the
## inspector.
##
## The animation resource holds the information related to the animation,
## while this nodes decides when the animation should run, and on which nodes.


const META_ORIGINAL_POSITION: String = "pca_original_position"
const META_ORIGINAL_ROTATION: String = "pca_original_rotation"
const META_ORIGINAL_SCALE: String = "pca_original_scale"
const META_ANIMATION_IN_PROGRESS: String = "pca_animation_in_progress"
const META_TRANSFORM_LISTENER: String = "pca_transform_listener"
const META_HIDE_ANIMATIONS: String = "pca_hide_animations"

signal animation_started
signal animation_ended


@export var target: Control

@export var animation: ProtonControlAnimationResource

@export var duration: float = -1.0:
	set(val):
		duration = max(0, val)

@export var delay: float = 0.0:
	set(val):
		delay = max(0, val)


var _tween: Tween
var _original_data_outdated: bool = false
var _started: bool = false


func _ready() -> void:
	if not trigger_source:
		trigger_source = target
	super()
	triggered.connect(start)

	if not is_instance_valid(target):
		return

	if on_hide:
		var list: Array = target.get_meta(META_HIDE_ANIMATIONS, [])
		list.push_back(self)
		target.set_meta(META_HIDE_ANIMATIONS, list)

	if target.get_meta(META_TRANSFORM_LISTENER, false):
		return

	var listener := ProtonControlAnimationTransformListener.new()
	target.add_child.call_deferred(listener)
	target.set_meta(META_TRANSFORM_LISTENER, true)


func start() -> void:
	if not animation:
		return

	_started = true
	_start_deferred.call_deferred()


## Called at the end of the frame from start()
func _start_deferred() -> void:
	clear()
	var list: Array = target.get_meta(META_ANIMATION_IN_PROGRESS, [])
	list.push_back(self)
	target.set_meta(META_ANIMATION_IN_PROGRESS, list)

	_tween = animation.create_tween(self, target)

	if delay > 0.0:
		_tween.pause()
		await get_tree().create_timer(delay).timeout
		_tween.play()

	animation_started.emit()
	await _tween.finished
	clear()
	_started = false
	animation_ended.emit()


func clear() -> void:
	if is_instance_valid(_tween) and _tween.is_running():
		_tween.kill()
	_tween = null
	# Remove from the list of animations currently affecting the target control
	var list: Array = target.get_meta(META_ANIMATION_IN_PROGRESS, [])
	list.erase(self)
	target.set_meta(META_ANIMATION_IN_PROGRESS, list)


func _on_hide_triggered() -> void:
	ProtonControlAnimation.hide(target)


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
	control.set_meta(ProtonControlTrigger.META_IGNORE_VISIBILITY_TRIGGERS, true)
	control.show()

	# Start all hide animations affecting the control
	var hide_animations: Array[ProtonControlAnimation] = []
	hide_animations.assign(control.get_meta(META_HIDE_ANIMATIONS, []))
	for animation in hide_animations:
		animation.start()

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
	control.set_meta(ProtonControlTrigger.META_IGNORE_VISIBILITY_TRIGGERS, false)


#endregion

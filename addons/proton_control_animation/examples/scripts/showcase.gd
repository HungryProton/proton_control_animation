extends Control

## Showcase scene
##
## Manages showing and hiding the panels (see _on_panel_toggled)
## Manages the "Press me" button: It manually plays the reset animation after 3 clicks


@onready var toggle_center: Button = %ToggleCenter
@onready var toggle_side: Button = %ToggleSide
@onready var close_button_center: Button = %CloseButtonCenter
@onready var close_button_side: Button = %CloseButtonSide
@onready var center_panel: Control = %CenterPanel
@onready var side_panel: Control = %SidePanel
@onready var slide_up_button: Button = %SlideUpButton
@onready var reset_slide_animation: ProtonControlAnimation = %ResetSlideAnimation


var _count: int = 0


func _ready() -> void:
	var _err: int
	_err = toggle_center.pressed.connect(_on_panel_toggled.bind(center_panel))
	_err = toggle_side.pressed.connect(_on_panel_toggled.bind(side_panel))
	_err = close_button_center.pressed.connect(_on_panel_toggled.bind(center_panel))
	_err = close_button_side.pressed.connect(_on_panel_toggled.bind(side_panel))
	_err = slide_up_button.pressed.connect(_on_slide_up_pressed)


func _on_panel_toggled(panel: Control) -> void:
	if panel.visible:
		panel.hide()
	else:
		panel.show()


func _on_slide_up_pressed() -> void:
	_count += 1
	if _count > 3:
		reset_slide_animation.start()
		_count = 0

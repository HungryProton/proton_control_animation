extends Control


@onready var toggle_center: Button = %ToggleCenter
@onready var toggle_side: Button = %ToggleSide
@onready var close_button_center: Button = %CloseButtonCenter

@onready var center_panel: MarginContainer = %CenterPanel
@onready var side_panel: MarginContainer = %SidePanel


func _ready() -> void:
	toggle_center.pressed.connect(_on_center_panel_toggled)
	toggle_side.pressed.connect(_on_side_panel_toggled)
	close_button_center.pressed.connect(center_panel.hide)
	center_panel.hide()
	side_panel.hide()


func _on_center_panel_toggled() -> void:
	if center_panel.visible:
		center_panel.hide()
	else:
		center_panel.show()


func _on_side_panel_toggled() -> void:
	if side_panel.visible:
		side_panel.hide()
	else:
		side_panel.show()

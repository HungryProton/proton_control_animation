extends Control


@onready var toggle_center: Button = %ToggleCenter
@onready var toggle_side: Button = %ToggleSide
@onready var close_button_center: Button = %CloseButtonCenter

@onready var center_panel: MarginContainer = %CenterPanel
@onready var scale_out_animation: ProtonControlAnimation = %ScaleOutAnimation

@onready var side_panel: MarginContainer = %SidePanel
@onready var slide_out_animation: ProtonControlAnimation = %SlideOutAnimation
@onready var close_button_side: Button = %CloseButtonSide


func _ready() -> void:
	toggle_center.pressed.connect(_on_center_panel_toggled)
	toggle_side.pressed.connect(_on_side_panel_toggled)
	close_button_side.pressed.connect(_on_side_panel_toggled)
	close_button_center.pressed.connect(center_panel.hide)


func _on_center_panel_toggled() -> void:
	if center_panel.visible:
		# Out Animation not working yet
		#scale_out_animation.start()
		#await scale_out_animation.animation_ended
		center_panel.hide()
	else:
		center_panel.show()


func _on_side_panel_toggled() -> void:
	if side_panel.visible:
		slide_out_animation.start()
		await slide_out_animation.animation_ended
		side_panel.hide()
	else:
		side_panel.show()

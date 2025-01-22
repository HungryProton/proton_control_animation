extends Control


@onready var button: Button = %Button
@onready var panel: PanelContainer = %PanelContainer
@onready var slide_out: ProtonControlAnimation = %SlideOut


func _ready() -> void:
	button.pressed.connect(toggle_panel)


func toggle_panel() -> void:
	if panel.visible:
		slide_out.start()
		await slide_out.animation_ended
		panel.hide()
	else:
		panel.show()

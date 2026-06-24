class_name HudUI
extends Control

@export var options_button: Button

var options_button_visible: bool

func _ready() -> void:
	options_button_visible = false
	options_button.hide()
	
	if MainGame.instance.is_initialized:
		_on_maingame_initialized()
	else:
		MainGame.instance.initialized.connect(_on_maingame_initialized)
		
func _on_options_pressed() -> void:
	MainGame.instance.options_layer.open()
		
func _on_maingame_initialized() -> void:
	update_options_button_visibility()
		
	MainGame.instance.title_menu_layer.opened.connect(update_options_button_visibility)
	MainGame.instance.title_menu_layer.closed.connect(update_options_button_visibility)
	MainGame.instance.options_layer.opened.connect(update_options_button_visibility)
	MainGame.instance.options_layer.closed.connect(update_options_button_visibility)
	MainGame.instance.credits_layer.opened.connect(update_options_button_visibility)
	MainGame.instance.credits_layer.closed.connect(update_options_button_visibility)

func update_options_button_visibility() -> void:
	if MainGame.instance.title_menu_layer.is_open or MainGame.instance.options_layer.is_open or MainGame.instance.credits_layer.is_open:
		if options_button_visible:
			options_button_visible = false
			animate_out_options_button()
	else:
		if not options_button_visible:
			options_button_visible = true
			animate_in_options_button()
		

var tween: Tween
func animate_in_options_button() -> void:
	options_button.show()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(options_button, "modulate", Color.WHITE, 0.5)
	
func animate_out_options_button() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(options_button, "modulate", Color(1,1,1,0), 0.5)
	await tween.finished
	options_button.hide()

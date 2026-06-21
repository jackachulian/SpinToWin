class_name ArticleUI
extends Control

@export var header_rtl: ArticleTextRTL
@export var body_rtl: ArticleTextRTL

@export var real_event_label: Label
@export var desired_perception_label: Label

#@export var article_texture_rect: TextureRect
@export var blur_material: ShaderMaterial
@export var choice_edit_blur_radius: float = 0.375

@export var choice_edit_panel: ChoiceEditPanel

func _ready() -> void:
	blur_material.set_shader_parameter("blur_radius", 0.00)
	choice_edit_panel.item_selected.connect(_on_choice_edit_panel_item_selected)

func setup(article: ArticleLevel) -> void:
	header_rtl.setup([article.header])
	body_rtl.setup(article.body)
	
	header_rtl.choice_clicked.connect(_on_choice_clicked)
	body_rtl.choice_clicked.connect(_on_choice_clicked)
	
	real_event_label.text = article.real_event
	desired_perception_label.text = article.desired_perception
	
func _on_choice_clicked(choice: ArticleChoice, global_pos: Vector2, sentence_start: String) -> void:
	choice_edit_panel.setup(choice, global_pos, sentence_start)
	choice_edit_panel.show()
	blur_material.set_shader_parameter("blur_radius", choice_edit_blur_radius)

func _on_choice_edit_panel_item_selected(_choice: ArticleChoice, _index: int) -> void:
	blur_material.set_shader_parameter("blur_radius", 0.00)
	header_rtl.reset_editing_text()
	body_rtl.reset_editing_text()

#class_name ArticleTextureRect
#extends TextureRect
#
#@export var viewport: SubViewport
#
#func _gui_input(event: InputEvent) -> void:
	#var forwarded_event = event.duplicate()
#
	#if forwarded_event.get("position") != null:
		#forwarded_event.position = (
			#forwarded_event.position / size * Vector2(viewport.size)
		#)
		#
	#viewport.push_input(forwarded_event)
#
#func _process(_delta):
	#var pos = get_local_mouse_position()
#
	#var motion := InputEventMouseMotion.new()
	#motion.position = pos / size * Vector2(viewport.size)
#
	#viewport.push_input(motion)

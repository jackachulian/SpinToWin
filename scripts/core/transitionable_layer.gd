class_name TransitionableLayer
extends CanvasLayer

@export var animatable_control: AnimatableControl


var is_open: bool
var animating: bool

signal opened()
signal closed()
signal animating_finished()
		
func open() -> void:
	if is_open:
		push_warning("menu already open")
		return
	
	is_open = true
	opened.emit()
	
	while animating:
		await animating_finished
	await animate_in()
	
## Open the given layer. Once that layer is closed,
## re-open this layer.
func open_nested(trans_layer: TransitionableLayer) -> void:
	close()
	trans_layer.open()
	
	await trans_layer.closed
	open()
	
## Open this as the active layer on the MainGame instance.
## Will close any previous active layer
func open_active() -> void:
	if MainGame.instance.active_layer == self:
		print(name, " is already open")
		return
	MainGame.instance.transition_to(self)
	
## Close this layer and open the given layer.
func transition_to(trans_layer: TransitionableLayer) -> void:
	close()
	trans_layer.open()
	
func close() -> void:
	if not is_open:
		push_warning("menu already closed")
		return
		
	is_open = false
	closed.emit()
	
	while animating:
		print(name, " waiting for anim finish")
		await animating_finished
	await animate_out()

func animate_in():
	show()
	print("animating in ", name)
	if animatable_control:
		animating = true
		await animatable_control.animate_in()
		animating = false
	animating_finished.emit()
		
func animate_out():
	print("animating out ", name)
	if animatable_control:
		animating = true
		await animatable_control.animate_out()
		animating = false
	animating_finished.emit()
	hide()

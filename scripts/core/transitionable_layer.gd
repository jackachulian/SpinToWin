class_name TransitionableLayer
extends CanvasLayer

@export var animatable_control: AnimatableControl

var animating

signal opened()
signal closed()
signal animating_finished()
		
func open() -> void:
	opened.emit()
	
	if animating:
		await animating_finished
	
	animating = true
	await animate_in()
	animating = false
	animating_finished.emit()
	
## Open the given layer. Once that layer is closed,
## re-open this layer.
func open_nested(trans_layer: TransitionableLayer) -> void:
	trans_layer.open()
	close()
	
	await trans_layer.closed
	open()
	
## Close this layer and open the given layer.
func transition_to(trans_layer: TransitionableLayer) -> void:
	trans_layer.open()
	close()
	
func close() -> void:
	closed.emit()
	
	if animating:
		await animating_finished
	
	animating = true
	await animate_out()
	animating = false
	animating_finished.emit()

func animate_in():
	show()
	if animatable_control:
		await animatable_control.animate_in()
		
func animate_out():
	if animatable_control:
		await animatable_control.animate_out()
	hide()

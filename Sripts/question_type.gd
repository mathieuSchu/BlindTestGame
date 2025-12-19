extends Node2D
@onready var label :Label= $Label
@onready var image :TextureRect= $TextureRect
@onready var sound :AudioStreamPlayer= $Audio
var l_size
var w_size
var i_size

func set_text(new_text) ->void:
	l_size=label.size
	label.text=new_text;
	label.position=Vector2((w_size.x/2)-(l_size.x/2),w_size.y/20)
	
func set_image(path_image)->void:
	var textur= load(path_image)
	image.texture=textur;
	image.visible=true;
	i_size=image.size
	image.position=Vector2((w_size.x/2)-(i_size.x/2),label.position.y+l_size.y+w_size.y/40)

	
func set_image_v(v)->void:
	image.visible=v;

func set_audio(path_audio)->void:
	var audio= load(path_audio)
	sound.stream=audio
	sound.play()
	
func _ready() -> void:
	SignalInt.update_size.connect(update_size)
	w_size=Global.window_size
	
	
func _on_audio_finished() -> void:
	sound.play()
func update_size()->void:
	w_size=Global.window_size
	if i_size:
		image.position=Vector2((w_size.x/2)-(i_size.x/2),label.position.y+l_size.y+w_size.y/40)
	label.position=Vector2((w_size.x/2)-(l_size.x/2),w_size.y/20)

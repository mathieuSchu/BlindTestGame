extends RichTextLabel
var scroll_speed: float = 30.0
var direction: int = 1

enum ScrollState { WAITING, SCROLLING}
var state: ScrollState = ScrollState.WAITING
var wait_timer: float = 0.0
var wait_time: float = 2.0
var value_pres :float = 0.0
var bar := self.get_v_scroll_bar()

func _ready() -> void:
	SignalInt.update_size.connect(update_size)
	self.bbcode_enabled = true
	update_ranking()
	update_size()
	wait_timer = wait_time
	value_pres=self.get_v_scroll_bar().value
	

func update_ranking()->void:
	var players_array: Array = []
	for key in Global.list_player.keys():
		var p = Global.list_player[key]
		if p.has("local_score") and p.has("name"):
			players_array.append(p)
	players_array.sort_custom(func(a, b):
		return a["local_score"] > b["local_score"]
	)
	# Construction du texte
	var text := ""
	var place := 1

	for p in players_array:
		text += "%d : %s , score : %d\n" % [
			place,
			p["name"],
			p["local_score"]
		]
		place += 1
	self.text = text

func _process(delta: float) -> void:
	match state:
		ScrollState.WAITING:
			wait_timer -= delta
			if wait_timer <= 0.0:
				state = ScrollState.SCROLLING

		ScrollState.SCROLLING:
			value_pres += direction*scroll_speed * delta
			bar.value = value_pres
			# Bas atteint
			if bar.value >= bar.max_value-bar.page :
				bar.value = bar.max_value
				_start_wait(-1)
			# Haut atteint
			elif bar.value <= 0.0:
				bar.value = 0.0
				_start_wait(1)

func _start_wait(new_direction: int) -> void:
	direction = new_direction
	state = ScrollState.WAITING
	wait_timer = wait_time
	
func update_size()->void:
	var nor_font = 24
	var w_size=Global.window_size
	self.add_theme_font_size_override("normal_font_size", nor_font)
	self.size=Vector2(w_size.x/2,w_size.y/2)
	self.position=Vector2(w_size.x/4,w_size.y/4)

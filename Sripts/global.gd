extends Node
var window_size: Vector2 = Vector2(0,0)
var path_queations : String = "res://Question/"
enum State { WAIT,INTRO,CONFIG,CONNECTION_SERVE,CONNECTION_CLIENT,SELECTE,MANCHE,RESULT,END}
var current_state: Global.State
var timeout  : int = 30
var nb_manche  : int = 5
var nb_question : int = 10
var list_manche : Array
var list_player : Dictionary
var curent_manche : int
var ENDGAME : bool = false
var ENDMANCHE : bool = false
const BASE_FONT_SIZE = 24
const BASE_RESOLUTION = Vector2(1152, 648)

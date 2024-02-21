extends Node

@export var rock_scene: PackedScene

var game_running: bool
var game_over: bool
var scroll: int = 0
var score
const SCROLL_SPEED: int = 4
var screen_size: Vector2i
var ground_height: int
var pipes: Array
var PIPE_DELAY: int = 100
var PIPE_RANGE: int = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()

func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	pipes.clear()
	get_tree().call_group("rocks", "queue_free")
	generate_rocks()
	$Plane.reset()
	$ScoreLabel.set_text("Score: " + str(score))
	$GameOver.hide()

func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $Plane.flying:
						$Plane.flap()
						check_top()

func start_game():
	game_running = true
	$Plane.flying = true
	$Plane.flap()
	$RockTimer.start()

func stop_game():
	game_running = false
	game_over = true
	$Plane.flying = false
	$RockTimer.stop()
	$GameOver.show()

func _process(delta):
	if game_running:
		scroll += SCROLL_SPEED
		if scroll >= screen_size.x:
			scroll = 0
		$Ground.position.x = -scroll
		
		# move rocks
		for rock in pipes:
			rock.position.x -= SCROLL_SPEED


func _on_rock_timer_timeout():
	generate_rocks()
	
func generate_rocks():
	var rock = rock_scene.instantiate()
	rock.position.x = screen_size.x + PIPE_DELAY
	rock.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	rock.hit.connect(plane_hit)
	rock.scored.connect(scored)
	add_child(rock)
	pipes.append(rock)

func check_top():
	if $Plane.position.y < 0:
		$Plane.falling = true
		stop_game()

func plane_hit():
	$Plane.falling = true
	stop_game()

func scored():
	score += 1
	$ScoreLabel.set_text("Score: " + str(score))

func _on_ground_hit():
	$Plane.falling = false
	stop_game()

func _on_game_over_restart():
	new_game()

extends Node2D

@onready var player: Player = $Player
@onready var sheep: Sheep = $Sheep
@onready var health_container: HBoxContainer = %HealthContainer
@onready var log_label: Label = %LogLabel
@onready var directional_light: DirectionalLight2D = $DirectionalLight2D
@onready var menu: Menu = %Menu
@onready var ambush_timer: Timer = $AmbushTimer
@onready var wolf_spawn_path_follow: PathFollow2D = %WolfSpawnPathFollow
@onready var time_bar: ProgressBar = %TimeBar
@onready var night_timer: Timer = $NightTimer
@onready var tree_cutted_sound: AudioStreamPlayer2D = $TreeCuttedSound
@onready var wolf_die_sound: AudioStreamPlayer2D = $WolfDieSound
@onready var overtime_attack_timer: Timer = $OvertimeAttackTimer

@export var night_duration: float = 22.0
@export var night_light_curve: Curve

var current_time: float = 0.0
var directional_light_step: float = 1.0 / night_duration

const HEARTH = preload("uid://cfujxcsgmdnlb")
const WOLF = preload("uid://d0h0vbjvard7o")

func _ready() -> void:
	time_bar.max_value = night_duration
	for i in player.health:
		var hearth = HEARTH.instantiate()
		health_container.add_child(hearth)

func _on_player_health_changed() -> void:
	var diff = player.health - health_container.get_child_count()
	if diff > 0:
		for i in diff:
			var hearth = HEARTH.instantiate()
			health_container.add_child(hearth)
	elif diff < 0:
		for i in diff * -1:
			var last = health_container.get_child(-1)
			health_container.remove_child(last)

func _on_tree_cutted(tree_position: Vector2) -> void:
	player.log_count += 2
	tree_cutted_sound.global_position = tree_position
	tree_cutted_sound.play()


func _on_player_log_count_changed() -> void:
	log_label.text = str(player.log_count)


func _on_campfire_extinguished() -> void:
	if !night_timer.is_stopped():
		ambush_timer.start()
		sheep.alert()

func _on_night_timer_timeout() -> void:
	current_time += night_timer.wait_time
	time_bar.value = current_time
	directional_light.energy = night_light_curve.sample(current_time * directional_light_step)
	if current_time >= night_duration:
		night_timer.stop()
		overtime_attack_timer.stop()
		ambush_timer.stop()
		if get_tree().get_node_count_in_group("enemy") == 0:
			GameManager.mode = "win"
			get_tree().reload_current_scene.call_deferred()


func _on_campfire_lighted() -> void:
	ambush_timer.stop()

func _on_ambush_timer_timeout() -> void:
	_spawn_wolf()


func _spawn_wolf() -> void:
	var wolf: Wolf = WOLF.instantiate()
	wolf_spawn_path_follow.progress_ratio = randf()
	wolf.global_position = wolf_spawn_path_follow.global_position
	wolf.died.connect(func(wolf_position): _on_wolf_died(wolf_position))
	add_child(wolf)
	wolf.track(sheep)

func _on_wolf_died(wolf_position: Vector2) -> void:
	wolf_die_sound.global_position = wolf_position
	wolf_die_sound.play()
	# Last wolf is not removed yet
	if get_tree().get_node_count_in_group("enemy") <= 1 and night_timer.is_stopped():
		GameManager.mode = "win"
		get_tree().reload_current_scene.call_deferred()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		GameManager.mode = "pause"
		menu.refresh()
		menu.visible = true
		get_tree().paused = true


func _on_overtime_attack_timer_timeout() -> void:
	_spawn_wolf()

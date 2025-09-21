class_name Wolf
extends CharacterBody2D

signal died(wolf_position: Vector2)

@export var max_health: int = 3
var health := max_health
var state := CallableStateMachine.new()
var target: CharacterBody2D
var dash_target: Vector2
@export var speed := 20
@export var dash_speed := 50
@onready var dash_cooldown: Timer = $DashCooldown
@onready var hostile_area: Area2D = $HostileArea
@onready var idle_sound: AudioStreamPlayer2D = $IdleSound
@onready var dash_sound: AudioStreamPlayer2D = $DashSound
@onready var follow_sound: AudioStreamPlayer2D = $FollowSound

func _ready() -> void:
	state.add_states(_idle_state, _enter_idle_state, _leave_idle_state)
	state.add_states(_follow_state, _enter_follow_state, _leave_follow_state)
	state.add_states(_dash_state, _enter_dash_state, Callable())
	state.add_states(_track_state, _enter_track_state, _leave_track_state)
	state.set_initial_state(_idle_state)

func _physics_process(_delta: float) -> void:
	state.update()
	move_and_slide()


func attack(target_body: CharacterBody2D):
	target = target_body
	state.change_state(_dash_state)

func track(target_body: CharacterBody2D):
	target = target_body
	state.change_state(_track_state)

func _idle_state():
	pass

func _enter_idle_state():
	idle_sound.play()

func _leave_idle_state():
	idle_sound.stop()

func _follow_state():
	if len(hostile_area.get_overlapping_bodies()) == 0:
		velocity = Vector2.ZERO
		state.change_state(_idle_state)
		return
		
	if position.distance_to(target.global_position) > 10:
		velocity = position.direction_to(target.global_position) * speed
	

func _enter_follow_state():
	dash_cooldown.start()
	follow_sound.play()

func _leave_follow_state():
	follow_sound.stop()

func _dash_state():
	velocity = position.direction_to(dash_target) * dash_speed
	if position.distance_to(dash_target) < 10:
		state.change_state(_follow_state)

func _enter_dash_state():
	dash_target = target.global_position
	dash_sound.play()

func _track_state():
	if position.distance_to(target.global_position) > 10:
		velocity = position.direction_to(target.global_position) * speed
	

func _enter_track_state():
	follow_sound.play()

func _leave_track_state():
	follow_sound.stop()

func _on_hurt_box_area_entered(_area: Area2D) -> void:
	health -= 1
	if health == 0:
		died.emit(global_position)
		queue_free()


func _on_hustile_area_body_entered(body: Node2D) -> void:
	target = body
	state.change_state(_follow_state)


func _on_dash_cooldown_timeout() -> void:
	state.change_state(_dash_state)

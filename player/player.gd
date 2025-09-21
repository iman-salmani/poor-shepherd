class_name Player
extends CharacterBody2D

signal health_changed
signal log_count_changed


@export var max_health := 6
var health := max_health
@export var speed = 300.0
@onready var axe_marker: Marker2D = $AxeMarker
@onready var axe_sprite: AnimatedSprite2D = %AxeAnimatedSprite
@onready var hit_box: Area2D = %HitBox
@onready var walk_sound: AudioStreamPlayer2D = $WalkSound
@onready var hit_sound: AudioStreamPlayer2D = %HitSound
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound

var log_count := 0:
	set(value):
		log_count = value
		log_count_changed.emit()


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed

	if direction != Vector2.ZERO:
		if walk_sound.playing != true:
			walk_sound.play()
	else:
		walk_sound.stop()

	var angle := get_global_mouse_position().angle_to_point(axe_marker.global_position)
	angle += PI
	if angle > (PI / 2) and angle < (PI * 1.5):
		axe_sprite.flip_h = true
	else:
		axe_sprite.flip_h = false
	axe_marker.rotation = angle
	axe_sprite.rotation = - angle
	
	if Input.is_action_just_pressed("hit"):
		hit_box.monitorable = true
		hit_box.monitoring = true
		axe_sprite.play("hit")
		hit_sound.play()
	
	move_and_slide()


func _on_axe_animated_sprite_animation_finished() -> void:
	hit_box.monitorable = false
	hit_box.monitoring = false


func _on_hurt_box_body_entered(_body: Node2D) -> void:
	health -= 1
	health_changed.emit()
	if health == 0:
		GameManager.mode = "lose-player"
		get_tree().reload_current_scene.call_deferred()
	else:
		hurt_sound.play()

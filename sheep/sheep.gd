class_name Sheep
extends CharacterBody2D

@onready var alert_sound: AudioStreamPlayer2D = $AlertSound

func alert():
	alert_sound.play()

func _on_hurt_box_body_entered(_body: Node2D) -> void:
	queue_free()
	GameManager.mode = "lose-sheep"
	get_tree().reload_current_scene.call_deferred()


func _on_scan_area_body_entered(_body: Node2D) -> void:
	alert_sound.play()

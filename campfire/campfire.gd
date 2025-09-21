extends StaticBody2D

signal extinguished
signal lighted

@export var max_fuel := 10
var fuel := max_fuel:
	set(value):
		fuel = value
		outside_light.energy = fuel * light_step
		inside_light.energy = fuel * light_step

var light_step: float = 1.0 / max_fuel
@onready var burning_timer: Timer = $BurningTimer
@onready var inside_light: PointLight2D = $InsideLight
@onready var outside_light: PointLight2D = $OutsideLight
@onready var fire_sound: AudioStreamPlayer2D = $FireSound

func _ready():
	fire_sound.play()

func _on_burning_timer_timeout() -> void:
	fuel -= 1
	if fuel == 0:
		burning_timer.stop()
		extinguished.emit()
		fire_sound.stop()


func _on_fuel_area_body_entered(body: Node2D) -> void:
	if body is Player:
		var value = clamp(max_fuel - fuel, 0, body.log_count)
		body.log_count -= value
		if fuel == 0 and value != 0:
			burning_timer.start()
			lighted.emit()
			fire_sound.play()
		fuel += value

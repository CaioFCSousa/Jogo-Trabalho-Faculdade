extends Area2D

@export var speed = 150.0 # Valor do GDD
var direction = Vector2.ZERO

func _ready():
	# O GDD diz que o projétil desaparece após 1.5 segundos
	await get_tree().create_timer(1.5).timeout
	if is_inside_tree():
		queue_free()

func _physics_process(delta):
	# Movimento linear simples
	global_position += direction * speed * delta

func _on_body_entered(body):
	if body.name == "Player":
		if body.has_method("take_damage"):
			body.take_damage(1)
		queue_free()
	# Se bater em paredes (TileMap ou StaticBody2D)
	elif body is TileMapLayer or body is StaticBody2D:
		queue_free()

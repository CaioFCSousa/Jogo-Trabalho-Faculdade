extends Area2D

var speed = 200
var direction = Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.name == "Player":
		if body.has_method("take_damage"):
			body.take_damage(1) # O player precisa ter essa função!
		queue_free()
	elif body is TileMap: # Destrói ao bater na parede
		queue_free()

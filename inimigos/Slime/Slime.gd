extends CharacterBody2D

@export var speed = 80.0
@export var accel = 7.0

# Referência ao nó de animação (o nome deve ser igual ao da árvore de nós)
@onready var anim = $AnimatedSprite2D

var player = null
var chasing = false

func _physics_process(delta):
	if chasing and player:
		var direction = (player.global_position - global_position).normalized()
		velocity = velocity.lerp(direction * speed, accel * delta)
		
		# Toca a animação de andar
		anim.play("walk")
		
		# Vira o sprite para o lado certo
		if direction.x > 0:
			anim.flip_h = false
		elif direction.x < 0:
			anim.flip_h = true
	else:
		velocity = velocity.lerp(Vector2.ZERO, accel * delta)
		
		# Se estiver quase parado, toca a animação de parado (idle)
		if velocity.length() < 10:
			anim.play("idle")

	move_and_slide()

# Sinais de detecção (os mesmos de antes)
func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player = body
		chasing = true

func _on_detection_area_body_exited(body):
	if body.name == "Player":
		player = null
		chasing = false

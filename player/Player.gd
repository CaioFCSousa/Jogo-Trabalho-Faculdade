extends CharacterBody2D

@export var speed = 150.0

func _physics_process(_delta):
	# 1. Captura a direção baseada nas setas do teclado ou WASD
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Aplica a velocidade
	velocity = direction * speed
	
	# 3. Executa o movimento físico
	move_and_slide()

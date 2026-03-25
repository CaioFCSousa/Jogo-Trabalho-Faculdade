extends Enemy

@export var projectile_scene: PackedScene # Arraste a cena do projétil aqui no Inspector
@export var min_distance = 150.0 # Distância que ele tenta manter
@export var shoot_range = 300.0  # Distância máxima para atirar

@onready var muzzle = $AnimatedSprite2D/Muzzle
@onready var shoot_timer = $ShootingTimer

func move_logic(delta):
	if not player: return
	
	var dist = global_position.distance_to(player.global_position)
	var dir_to_player = (player.global_position - global_position).normalized()
	
	# 1. LÓGICA DE MOVIMENTO (FUGIR)
	if dist < min_distance:
		# Se o player estiver muito perto, ele anda para trás devagar
		velocity = velocity.lerp(-dir_to_player * (speed * 0.5), accel * delta)
		anim.play("walk")
	else:
		# Se estiver na distância ideal, ele para e fica de vigia
		velocity = velocity.lerp(Vector2.ZERO, accel * delta)
		anim.play("idle")
	
	# Virar o sprite para o player sempre
	anim.flip_h = dir_to_player.x < 0
	
	# 2. LÓGICA DE TIRO
	if dist < shoot_range and shoot_timer.is_stopped():
		shoot()

func shoot():
	if not projectile_scene: return
	
	shoot_timer.start() # Inicia o cooldown
	anim.play("attack") # Se tiver animação de ataque
	
	# Criar o projétil
	var p = projectile_scene.instantiate()
	get_parent().add_child(p) # Adiciona na fase, não no mago
	
	p.global_position = muzzle.global_position
	p.direction = (player.global_position - global_position).normalized()
	p.rotation = p.direction.angle()

# Lembra de conectar os sinais da DetectionArea como fizemos nos outros!
func _on_detection_area_body_entered(body):
	super._on_detection_area_body_entered(body)

func _on_detection_area_body_exited(body):
	super._on_detection_area_body_exited(body)

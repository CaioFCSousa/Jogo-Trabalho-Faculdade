extends Enemy

@export_group("Configurações de Tiro")
@export var projectile_scene: PackedScene
@export var min_distance = 150.0 # Distância para começar a fugir
@export var shoot_range = 300.0
@export var fire_rate = 2.0     # Tempo entre tiros (GDD)

@onready var muzzle = $AnimatedSprite2D/Muzzle
@onready var shoot_timer = $ShootingTimer
@onready var cajado_animator = $AnimatedSprite2D/CajadoAnimator

func _ready():
	super._ready() # Chama o setup do script base
	shoot_timer.wait_time = fire_rate
	shoot_timer.one_shot = true

func move_logic(delta):
	var dist = global_position.distance_to(player.global_position)
	var dir_to_player = (player.global_position - global_position).normalized()
	
	# Fugir se o player chegar perto
	if dist < min_distance:
		velocity = velocity.lerp(-dir_to_player * (speed * 0.8), accel * delta)
		anim.play("walk")
	else:
		velocity = velocity.lerp(Vector2.ZERO, accel * delta)
		anim.play("idle")
	
	anim.flip_h = dir_to_player.x < 0

	# Lógica de Tiro em Cone
	if dist < shoot_range and shoot_timer.is_stopped():
		shoot()

func shoot():
	if is_knocking_back or not projectile_scene: return
	
	shoot_timer.start()
	
	# Cone de 3 tiros (30 graus de diferença)
	var angles = [-30, 0, 30]
	var base_dir = (player.global_position - global_position).normalized()
	
	for a in angles:
		var p = projectile_scene.instantiate()
		p.global_position = muzzle.global_position
		
		# Aplica a rotação no vetor de direção
		var final_dir = base_dir.rotated(deg_to_rad(a))
		p.direction = final_dir
		p.rotation = final_dir.angle()
		
		get_tree().current_scene.call_deferred("add_child", p)
	
	# Animação do Cajado
	if cajado_animator:
		cajado_animator.play("shoot_pulse") # Nome da sua animação de brilho
		await cajado_animator.animation_finished
		cajado_animator.play("float")

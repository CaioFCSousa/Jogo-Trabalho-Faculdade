extends CharacterBody2D

# Sinais para os outros programadores
signal boss_morreu
signal boss_fase2

@export_group("Atributos de Movimento")
@export var speed = 50.0        
@export var accel = 5.0

@export_group("Configurações do Boss")
@export var projectile_scene: PackedScene
@export var slime_scene: PackedScene
@export var terrestre_scene: PackedScene
@export var limite_minions: int = 5 

@export_group("Interface")
@export var boss_health_bar: ProgressBar

@onready var shot_timer = $ShotTimer
@onready var spawn_timer = $SpawnTimer
@onready var anim = $AnimatedSprite2D

var max_health = 30.0
var current_health = 30.0
var fase_2 = false
var is_dead = false
var minions_vivos: int = 0 
var player = null

func _ready():
	print("--- BOSS: Iniciando batalha final com movimento ---")
	current_health = max_health
	
	if boss_health_bar:
		boss_health_bar.max_value = max_health
		boss_health_bar.value = current_health
		boss_health_bar.show()
	
	player = get_tree().get_first_node_in_group("player") 
	
	shot_timer.wait_time = 2.0
	spawn_timer.wait_time = 3.0
	
	shot_timer.start()
	spawn_timer.start()
	anim.play("idle")

func _physics_process(delta):
	if is_dead: return
	
	# --- LÓGICA DE MOVIMENTO ---
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = velocity.lerp(direction * speed, accel * delta)
		anim.flip_h = direction.x < 0
	else:
		velocity = velocity.lerp(Vector2.ZERO, accel * delta)
		player = get_tree().get_first_node_in_group("player")

	move_and_slide()

	# --- LÓGICA DE ANIMAÇÃO (CORRIGIDA PARA GODOT 4) ---
	var anim_name = ""
	
	if velocity.length() > 10:
		anim_name = "walk"
	else:
		anim_name = "idle"
	
	# Se estiver na fase 2 e você tiver animações específicas, ele tenta usar
	# Se não tiver, ele usa as normais
	if fase_2 and anim.sprite_frames.has_animation(anim_name + "_fase2"):
		anim.play(anim_name + "_fase2")
	else:
		anim.play(anim_name)

func take_damage(amount):
	if is_dead: return
	current_health -= amount
	flash_red()
	
	if boss_health_bar:
		boss_health_bar.value = current_health
		
	if not fase_2 and current_health <= 9:
		entrar_fase_2()
		
	if current_health <= 0:
		die()

func flash_red():
	anim.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color.WHITE

func entrar_fase_2():
	fase_2 = true
	emit_signal("boss_fase2")
	print("--- BOSS: FASE 2 INICIADA ---")
	
	speed = 80.0 
	shot_timer.wait_time = 1.0
	spawn_timer.wait_time = 2.0

func _on_shot_timer_timeout():
	if is_dead: return
	for i in range(8):
		var angle = i * 45
		var p = projectile_scene.instantiate()
		p.global_position = global_position
		var rad = deg_to_rad(angle)
		p.direction = Vector2(cos(rad), sin(rad))
		p.rotation = rad
		p.speed = 250.0 
		get_tree().current_scene.add_child(p)

func _on_spawn_timer_timeout():
	if is_dead: return
	if minions_vivos == 0:
		if not fase_2:
			spawn_minions(slime_scene, 4)
		else:
			spawn_minions(terrestre_scene, 2)

func spawn_minions(scene, qtd):
	if not scene: return
	for i in range(qtd):
		var minion = scene.instantiate()
		var random_pos = Vector2(randf_range(-200, 200), randf_range(-200, 200))
		minion.global_position = global_position + random_pos
		minions_vivos += 1
		minion.tree_exited.connect(_on_minion_derrotado)
		get_tree().current_scene.call_deferred("add_child", minion)

func _on_minion_derrotado():
	minions_vivos -= 1

func die():
	if is_dead: return
	is_dead = true
	if boss_health_bar:
		boss_health_bar.hide()
	velocity = Vector2.ZERO
	shot_timer.stop()
	spawn_timer.stop()
	anim.play("death")
	emit_signal("boss_morreu")
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	await anim.animation_finished
	queue_free()

extends CharacterBody2D
class_name Enemy

@export_group("Atributos Base")
@export var speed = 80.0
@export var max_health = 3
@export var accel = 7.0
@export var knockback_force = 200.0

@onready var anim = $AnimatedSprite2D

var current_health = 0
var is_dead = false
var player = null
var chasing = false
var is_knocking_back = false

func _ready():
	current_health = max_health
	# Layers: 1=Player, 2=Inimigos, 3=Mundo
	set_collision_layer_value(2, true)
	set_collision_mask_value(1, false) # Não colide fisicamente com o player
	set_collision_mask_value(3, true)  # Colide com paredes

func _physics_process(delta):
	if is_dead: return
	
	if is_knocking_back:
		# Durante o knockback, ele apenas desliza até parar
		velocity = velocity.lerp(Vector2.ZERO, accel * delta)
	elif chasing and player:
		move_logic(delta)
	else:
		idle_logic(delta)
	
	move_and_slide()

func move_logic(delta):
	# Lógica padrão de perseguição (Slime/Terrestre)
	var direction = (player.global_position - global_position).normalized()
	velocity = velocity.lerp(direction * speed, accel * delta)
	anim.play("walk")
	anim.flip_h = direction.x < 0

func idle_logic(delta):
	velocity = velocity.lerp(Vector2.ZERO, accel * delta)
	anim.play("idle")

func take_damage(amount):
	if is_dead or is_knocking_back: return
	
	current_health -= amount
	flash_red()
	
	if player:
		apply_knockback()
	
	if current_health <= 0:
		die()

func apply_knockback():
	is_knocking_back = true
	var knockback_dir = (global_position - player.global_position).normalized()
	velocity = knockback_dir * knockback_force
	
	# Tempo de atordoamento
	await get_tree().create_timer(0.2).timeout
	is_knocking_back = false

func flash_red():
	anim.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color.WHITE

func die():
	is_dead = true
	anim.play("death")
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	# Aguarda a animação de morte terminar antes de sumir
	await anim.animation_finished
	queue_free()

# Conexões de área de detecção
func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player = body
		chasing = true

func _on_detection_area_body_exited(body):
	if body.name == "Player":
		player = null
		chasing = false

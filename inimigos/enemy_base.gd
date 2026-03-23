extends CharacterBody2D
class_name Enemy

@export_group("Atributos")
@export var speed = 80.0
@export var max_health = 3
@export var accel = 7.0

@onready var anim = $AnimatedSprite2D

var current_health = 0
var is_dead = false
var player = null
var chasing = false

func _ready():
	current_health = max_health

func _physics_process(delta):
	if is_dead: return
	
	if chasing and player:
		move_logic(delta)
	else:
		idle_logic(delta)
	
	move_and_slide()

func move_logic(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = velocity.lerp(direction * speed, accel * delta)
		anim.play("walk")
		anim.flip_h = direction.x < 0

func idle_logic(delta):
	velocity = velocity.lerp(Vector2.ZERO, accel * delta)
	anim.play("idle")

func take_damage(amount):
	if is_dead: return
	current_health -= amount
	flash_red()
	if current_health <= 0:
		die()

func flash_red():
	anim.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color.WHITE

func die():
	is_dead = true
	anim.play("death")
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	await anim.animation_finished
	queue_free()

func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player = body
		chasing = true

func _on_detection_area_body_exited(body):
	if body.name == "Player":
		player = null
		chasing = false

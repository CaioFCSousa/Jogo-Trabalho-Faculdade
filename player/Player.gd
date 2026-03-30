extends CharacterBody2D

@export var speed = 150.0
@onready var area_ataque = $AtaqueTeste
@onready var shape_ataque = $AtaqueTeste/CollisionShape2D

func _ready():
	# Começa desativado
	shape_ataque.disabled = true
	# Conecta o sinal para detectar o inimigo
	area_ataque.body_entered.connect(_on_ataque_hit)

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()

	# Clique do Mouse (Botão Esquerdo)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		executar_ataque_teste()

func executar_ataque_teste():
	if not shape_ataque.disabled: return # Evita repetir enquanto o timer roda
	
	print("TESTE: Ataque disparado!")
	shape_ataque.disabled = false # Liga a área de dano
	
	# Espera um pouquinho e desliga
	await get_tree().create_timer(0.1).timeout
	shape_ataque.disabled = true

func _on_ataque_hit(body):
	# Se o que entrou na área for um inimigo (tem a função take_damage)
	if body.has_method("take_damage"):
		body.take_damage(1)
		print("TESTE: Você acertou o ", body.name, "!")

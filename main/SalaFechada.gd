extends Node2D

signal sala_limpa # Sinal que avisa que todos os inimigos morreram

@export var inimigos_da_sala: Array[PackedScene] # Arraste as cenas dos inimigos aqui
@onready var spawn_points = $SpawnPoints.get_children()
@onready var porta = get_parent().get_node("Porta") # Ajuste o caminho conforme sua cena

var inimigos_vivos = 0
var ja_ativou = false

func _ready():
	# Conecta o sinal de limpeza ao surgimento do baú (Programador C)
	connect("sala_limpa", _on_sala_limpa)

func _on_entrada_player_body_entered(body):
	if body.name == "Player" and not ja_ativou:
		ja_ativou = true
		trancar_portas()
		spawn_inimigos()

func trancar_portas():
	if porta:
		porta.trancar() # Função que você criará no script da porta

func spawn_inimigos():
	for point in spawn_points:
		# Escolhe um inimigo aleatório da lista que você configurou no Inspector
		var inimigo_res = inimigos_da_sala.pick_random()
		var inimigo = inimigo_res.instantiate()
		
		inimigo.global_position = point.global_position
		get_tree().current_scene.add_child(inimigo)
		
		# IMPORTANTE: Conectar o sinal de morte do inimigo
		inimigo.tree_exited.connect(_on_inimigo_derrotado)
		inimigos_vivos += 1

func _on_inimigo_derrotado():
	inimigos_vivos -= 1
	if inimigos_vivos <= 0:
		emit_signal("sala_limpa")

func _on_sala_limpa():
	if porta:
		porta.destrancar()
	spawn_bau()

func spawn_bau():
	print("Spawnando baú com 15-25 moedas...")
	# Aqui você instancia a cena do seu Bau.tscn

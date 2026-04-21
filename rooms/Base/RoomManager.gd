extends Node2D

@export var sala_id: String = "sala_01"
@export_group("Configurações da Sala")
@export var inimigos_scenes: Array[PackedScene]
@export var quantidade_para_vencer: int = 3

var inimigos_mortos: int = 0
var sala_ativa: bool = false

@onready var spawn_points = $SpawnPoints.get_children()

func _ready():
	# ✅ Nome correto, sem () no callback
	EventBus.inimigo_morto.connect(_on_inimigo_derrotado)

func _on_area_ativacao_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not sala_ativa:
		iniciar_combate()

func iniciar_combate():
	sala_ativa = true
	inimigos_mortos = 0
	print("--- SISTEMA: O Player entrou na área! ---")
	print("--- PORTAS: [FECHADAS] ---")
	EventBus.emit_signal("sala_iniciada", sala_id)
	spawn_inimigos()

func spawn_inimigos():
	print("SISTEMA: Criando inimigos nos SpawnPoints...")
	for point in spawn_points:
		if inimigos_scenes.size() > 0:
			var aleatorio = inimigos_scenes.pick_random()
			if aleatorio:
				var inimigo = aleatorio.instantiate()
				inimigo.global_position = point.global_position
				get_tree().current_scene.call_deferred("add_child", inimigo)
				# ✅ tree_exited removido daqui

# ✅ Recebe os parâmetros do sinal
func _on_inimigo_derrotado(inimigo: Node, posicao: Vector2):
	if not sala_ativa: return
	inimigos_mortos += 1
	print("SALA: Um inimigo saiu! Total mortos agora: ", inimigos_mortos)
	if inimigos_mortos >= quantidade_para_vencer:
		finalizar_sala()

func finalizar_sala():
	sala_ativa = false
	print("--- SISTEMA: Todos os inimigos morreram! ---")
	print("--- PORTAS: [ABERTAS] ---")
	print("--- BÔNUS: Baú liberado! ---")
	EventBus.emit_signal("sala_limpa", sala_id)
	$AreaAtivacao.set_deferred("monitoring", false)

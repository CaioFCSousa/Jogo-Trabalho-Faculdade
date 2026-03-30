extends Node2D

# Sinais para comunicação entre programadores
signal sala_iniciada
signal sala_limpa

@export_group("Configurações da Sala")
@export var inimigos_scenes: Array[PackedScene] 
@export var quantidade_para_vencer: int = 3     # Quantos inimigos você quer testar

var inimigos_mortos: int = 0
var sala_ativa: bool = false

@onready var spawn_points = $SpawnPoints.get_children()

# 1. ATIVAÇÃO DA SALA
func _on_area_ativacao_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not sala_ativa:
		iniciar_combate()

func iniciar_combate():
	sala_ativa = true
	inimigos_mortos = 0
	
	# --- MENSAGEM DE TESTE ---
	print("--- SISTEMA: O Player entrou na área! ---")
	print("--- PORTAS: [FECHADAS] ---")
	
	emit_signal("sala_iniciada") # Avisa que a luta começou
	spawn_inimigos()

# 2. LÓGICA DE SPAWN
func spawn_inimigos():
	print("SISTEMA: Criando inimigos nos SpawnPoints...")
	
	for point in spawn_points:
		if inimigos_scenes.size() > 0:
			var aleatorio = inimigos_scenes.pick_random()
			
			if aleatorio:
				# Criamos a instância normalmente
				var inimigo = aleatorio.instantiate()
				inimigo.global_position = point.global_position
				
				# USAMOS CALL_DEFERRED AQUI: 
				# Isso evita o erro de "flushing queries"
				get_tree().current_scene.call_deferred("add_child", inimigo)
				
				# Conectamos o sinal normalmente
				inimigo.tree_exited.connect(_on_inimigo_derrotado)

# 3. MONITORAMENTO DE MORTES
func _on_inimigo_derrotado():
	if not sala_ativa: return
	
	inimigos_mortos += 1
	# ESSE PRINT É VITAL:
	print("SALA: Um inimigo saiu! Total mortos agora: ", inimigos_mortos)
	
	if inimigos_mortos >= quantidade_para_vencer:
		finalizar_sala()

func finalizar_sala():
	sala_ativa = false
	
	# --- MENSAGEM DE TESTE ---
	print("--- SISTEMA: Todos os inimigos morreram! ---")
	print("--- PORTAS: [ABERTAS] ---")
	print("--- BÔNUS: Baú liberado! ---")
	
	emit_signal("sala_limpa") # Avisa que as portas podem abrir
	# Aqui o AreaAtivacao é desativado para o player não repetir a sala
	$AreaAtivacao.set_deferred("monitoring", false)
	
	

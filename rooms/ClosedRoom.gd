# main/SalaFechada.gd
extends Node2D

@onready var room_manager = $RoomManager

func _ready():
	# Escuta o EventBus para reagir quando a sala terminar
	EventBus.sala_limpa.connect(_on_sala_limpa)
	EventBus.sala_iniciada.connect(_on_sala_iniciada)

func _on_sala_iniciada(sala_id: String):
	print("Sala fechada! Portas travadas.")
	# Aqui você vai acionar a animação/lógica das portas fechando

func _on_sala_limpa(sala_id: String):
	print("Sala limpa! Portas abertas.")
	# Aqui você vai acionar a animação/lógica das portas abrindo

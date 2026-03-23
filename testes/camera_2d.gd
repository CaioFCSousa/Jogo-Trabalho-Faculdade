extends Camera2D

@export var acceleration = 10.0
@export var look_ahead_factor = 0.2 # O quanto a câmera foca na direção do movimento

func _process(delta):
	# Pegamos o nó pai (o Player)
	var player = get_parent()
	
	if player is CharacterBody2D:
		# Faz a câmera olhar um pouco para onde o jogador está indo
		var target_offset = player.velocity * look_ahead_factor
		
		# Suaviza o deslocamento (offset) da câmera
		offset = offset.lerp(target_offset, acceleration * delta)

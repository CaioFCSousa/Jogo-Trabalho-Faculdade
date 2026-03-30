extends Button

# REMOVA o _process daqui, senão ele ataca sem parar!

func _on_pressed(): # O Godot 4 usa 'pressed' para o sinal do botão
	var inimigos = get_tree().get_nodes_in_group("enemies")
	
	if inimigos.size() > 0:
		var inimigo = inimigos[0]
		if inimigo.has_method("take_damage"):
			inimigo.take_damage(1)
	else:
		print("Nenhum inimigo vivo no grupo 'enemies'!")

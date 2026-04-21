# autoload/EventBus.gd
extends Node

# ==============================
# SINAIS DE INIMIGOS
# ==============================
signal inimigo_morto(inimigo: Node, posicao: Vector2)
signal item_dropado(item_id: String, posicao: Vector2)

# ==============================
# SINAIS DE SALA
# ==============================
signal sala_iniciada(sala_id: String)
signal sala_limpa(sala_id: String)

# ==============================
# SINAIS DO PLAYER
# ==============================
signal player_morreu
signal player_tomou_dano(vida_atual: int, vida_maxima: int)
signal player_curou(vida_atual: int, vida_maxima: int)
signal moedas_atualizadas(total: int)

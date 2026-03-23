extends Node

var moedas: int = 0
var fase_atual: int = 1
var jogo_ativo: bool = true

signal moedas_alteradas(valor)
signal fase_alterada(nova_fase)
signal game_over

func adicionar_moedas(qtd):
	moedas += qtd
	emit_signal("moedas_alteradas", moedas)

func gastar_moedas(qtd) -> bool:
	if moedas >= qtd:
		moedas -= qtd
		emit_signal("moedas_alteradas", moedas)
		return true
	return false

func mudar_fase(cena_path: String):
	get_tree().change_scene_to_file(cena_path)
	emit_signal("fase_alterada", cena_path)

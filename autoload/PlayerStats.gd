extends Node

var vida_max: int = 5
var vida: int = 5
var armadura: int = 0
var dano: int = 1
var velocidade_mov: float = 200.0
var velocidade_ataque: float = 1.0
var itens: Array = []

signal vida_alterada(nova_vida)
signal armadura_alterada(nova_armadura)
signal item_adicionado(item)

func set_vida(valor):
	vida = clamp(valor, 0, vida_max)
	emit_signal("vida_alterada", vida)

func tomar_dano(dano_bruto: int):
	var dano_restante = dano_bruto
	if armadura > 0:
		var dano_absorvido = min(armadura, dano_bruto)
		armadura -= dano_absorvido
		dano_restante -= dano_absorvido
		emit_signal("armadura_alterada", armadura)
	if dano_restante > 0:
		self.vida -= dano_restante

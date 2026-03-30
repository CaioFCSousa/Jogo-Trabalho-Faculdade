# Dungeon Crawler Top-Down

Um jogo de ação em perspectiva top-down desenvolvido em **Godot 4.x**, onde o jogador atravessa três masmorras enfrentando inimigos, coletando moedas e derrotando um boss final.

## 📋 Sumário
- [Visão Geral](#visão-geral)
- [Fluxo do Jogo](#fluxo-do-jogo)
- [Personagem](#personagem)
- [Inimigos](#inimigos)
- [Sistema de Itens e Loja](#sistema-de-itens-e-loja)
- [Fases](#fases)
- [Boss Final](#boss-final)
- [Interface (HUD)](#interface-hud)
- [Controles](#controles)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Guia de Desenvolvimento](#guia-de-desenvolvimento)

---

## 🎮 Visão Geral

**Gênero:** Dungeon Crawler / Ação Top-Down  
**Plataforma:** PC (teclado e mouse)  
**Objetivo:** Atravessar 3 masmorras, enfrentar inimigos, coletar moedas, comprar itens e derrotar o boss final.

---

## 🔄 Fluxo do Jogo

O jogo segue uma progressão linear com a seguinte estrutura:

1. **Fase 1** (Apresentação - Dificuldade Básica)
2. **Loja Obrigatória** (O jogador pode optar por não comprar nada)
3. **Fase 2** (Expansão - Dificuldade Média)
4. **Loja Opcional** (Antes da sala fechada)
5. **Fase 3** (Boss - Dificuldade Alta)
6. **Créditos** (Após derrotar o boss)

### Condição de Derrota

Ao morrer, o jogador vê uma tela de **Game Over** com duas opções:
- **Desistir**: Retorna ao menu principal
- **Tentar Novamente**: Recomeça o jogo desde o início

---

## 👤 Personagem

### Atributos Base

| Atributo | Valor |
|----------|-------|
| Vida Máxima | 5 pontos |
| Dano Base | 1 (ataque com espada) |
| Velocidade de Movimento | 200 px/s |
| Velocidade de Ataque | 1 golpe/s (cooldown: 1s) |
| Invulnerabilidade após Dano | 1,5s (efeito de piscar) |
| Knockback | Sim (leve empurrão para trás) |

### Ataque com Espada (Direcional)

- **Posicionamento:** A espada é um objeto filho do personagem, 30 pixels à frente na direção do cursor
- **Mecânica:** Rotação de 90° a 120° em torno do personagem usando tweening
- **Duração:** 0,2 segundos
- **Direção:** Determinada pela posição do mouse (ataque direcional)
- **Activação:** Clique Esquerdo, Tecla J ou Espaço

---

## 👾 Inimigos

Todos os inimigos possuem colisão com paredes (Navigation2D/TileMap), piscam em vermelho ao receber dano e desaparecem imediatamente ao serem derrotados.

### Tabela de Inimigos

| Nome | Vida | Dano | Velocidade | Comportamento |
|------|------|------|------------|---------------|
| **Slime** | 2 | 1 | 100 px/s | Persegue o jogador continuamente |
| **Voador** | 1 | 1 | 150 px/s | Persegue dentro de raio de 200 px; voa sobre obstáculos |
| **Terrestre** | 3 | 2 | 80 px/s | Persegue o jogador; 30% chance de atordoamento de 0,5s |
| **Atirador** | 3 | 1 (projétil) | 60 px/s (fuga) | Mantém distância de 200 px; atira cone de 3 projéteis a cada 2s |

#### Detalhes Especiais

**Voador:** Pode voar sobre espinhos e poças, colidindo apenas com paredes.

**Terrestre:** Ao ser atingido, possui 30% de chance de ficar atordoado (pausa no movimento) por 0,5 segundos.

**Atirador:** 
- Tenta manter distância de 200 px do jogador
- Recua se o jogador se aproximar
- Atira 3 projéteis em formato de cone (30° de abertura)
- Projéteis viajam a 400 px/s e desaparecem após 1,5s
- Atira mesmo através de obstáculos

---

## 🛍️ Sistema de Itens e Loja

### Regras de Itens

- O personagem pode equipar até **3 itens simultaneamente** (todos de efeito passivo)
- Os itens são **únicos e não acumuláveis**
- Ao comprar um item, é automaticamente equipado se houver slot vazio
- Se todos os slots estiverem ocupados, o jogador deve escolher um item para substituir
- Itens comprados **não podem ser vendidos**

### Itens Disponíveis

| Item | Custo | Efeito | Observação |
|------|-------|--------|------------|
| **Amuleto de Armadura** | 25 moedas | +3 pontos de armadura | Barra de vida separada |
| **Amuleto de Velocidade** | 15 moedas | +25% velocidade | 250 px/s movimento; 0,8s cooldown ataque |
| **Amuleto de Ataque** | Grátis | +1 de dano | Entregue por NPC na Fase 3 |

### Sistema de Armadura

- Funciona como uma barra de vida separada que absorve o dano antes de afetar a vida
- Se o jogador possui 2 pontos de armadura e sofre 2 de dano → armadura vai a 0, vida intacta
- Se sofrer 3 de dano → perde 2 de armadura e 1 de vida
- A armadura **não se regenera** ao longo do tempo

### Sistema de Cura

- **Não existem itens de cura equipáveis**
- Nas lojas, o jogador pode pagar **10 moedas** para recuperar toda a vida perdida
- Este serviço pode ser utilizado quantas vezes desejar (com moedas suficientes)

### Interface da Loja

**Layout:** Ícone do item, valor em moedas, nome e descrição do efeito

**Controles:**
- `F` - Comprar o item selecionado
- `E` - Sair da loja
- `Setas Direcionais` - Navegar entre itens

---

## 📍 Fases

### Estrutura Comum

Cada fase é composta por um mapa com salas conectadas por portas.

- **Salas Fechadas:** Portas se trancam ao entrar e só abrem após derrotar todos os inimigos
- **Baús:** Ao finalizar uma sala fechada, aparece um baú com 15-25 moedas aleatórias
- **Progressão:** Após o baú, uma porta leva para a próxima área

### Fase 1 – Apresentação

**Dificuldade:** Básica (Tutorial implícito)

- **Armadilhas:** Espinhos fixos que causam 1 de dano por contato (podem ser desviados)
- **Inimigos no Caminho:** 2 Slimes e 1 Voador
- **Sala Fechada:** 4 Slimes e 2 Voadores
- **Loja:** Oferece Amuleto de Armadura, Amuleto de Velocidade e cura
- **Saída:** Porta para Fase 2

### Fase 2 – Expansão

**Dificuldade:** Média

- **Armadilhas:** Espinhos que aparecem e desaparecem alternadamente a cada 2 segundos (áreas marcadas)
- **Inimigos no Caminho:** 2 Slimes, 1 Voador e 1 Terrestre
- **Sala Fechada:** 2 Slimes, 2 Voadores, 2 Terrestres e 1 Atirador
- **Loja Opcional:** Antes da sala fechada (oferece itens não comprados ou apenas cura)
- **Saída:** Porta para Fase 3

### Fase 3 – Boss

**Dificuldade:** Alta

- **Sala Introdutória:** NPC ferido conta uma breve história e entrega gratuitamente o **Amuleto de Ataque**
- **Arena:** Sala ampla e circular com pilares (obstáculos para proteção)
- **Saída:** Após derrotar o boss, a porta se abre e os créditos começam

---

## 👹 Boss Final

### Parâmetros

| Parâmetro | Valor |
|-----------|-------|
| Vida | 30 pontos |
| Dano dos Projéteis | 1 ponto |
| Velocidade dos Projéteis | 250 px/s |

### Comportamento Base

O boss permanece **imóvel no centro da arena** durante toda a luta.

### Padrões de Ataque

#### Fase 1 (100% a 30% de Vida)

- **A cada 2 segundos:** Dispara 8 projéteis simultaneamente em todas as direções (intervalos de 45°)
- **A cada 5 segundos:** Invoca (spawna) 4 Slimes nas bordas da arena

#### Fase 2 (Abaixo de 30% de Vida)

- **Transição:** Boss muda de cor para indicar a mudança de fase
- **Disparos:** Acelerados - ocorrem a cada 1 segundo (em vez de 2s)
- **Invocações:** Passa a invocar 2 inimigos Terrestres a cada 4 segundos (em vez de Slimes)

---

## 🎨 Interface (HUD)

A interface durante o jogo exibe as seguintes informações:

| Elemento | Localização | Representação |
|----------|-------------|----------------|
| **Vida** | Canto superior esquerdo | 5 corações (ou segmentos) |
| **Armadura** | Ao lado dos corações | Até 3 escudos (ou barra) |
| **Moedas** | Canto superior direito | Ícone de moeda + valor numérico |
| **Itens Equipados** | Permanente ou inventário | Ícones pequenos dos itens |

---

## 🎮 Controles

### Movimentação e Ataque

| Controle | Ação |
|----------|------|
| `W, A, S, D` | Movimentação direcional |
| `Mouse` | Direciona a mira e o ataque |
| `Clique Esquerdo` / `J` / `Espaço` | Executar ataque |

### Interação

| Controle | Ação |
|----------|------|
| `E` | Interagir (baús, NPCs, entrar/sair da loja) |
| `F` | Confirmar compra na loja |
| `Setas Direcionais` | Navegar na loja |
| `Esc` | Pausar / Menu |

---

## 📁 Estrutura do Projeto

```
jogo-dungeon-crawler-top-down/
├── project.godot
├── autoload/
│   ├── Gamemaneger.gd
│   ├── Gamemaneger.gd.uid
│   ├── PlayerStats.gd
│   └── PlayerStats.gd.uid
├── player/
│   ├── Player.gd
│   ├── Player.gd.uid
│   └── Player.tscn
├── inimigos/
│   ├── Atirador/
│   ├── Boss/
│   ├── Slime/
│   ├── Terrestre/
│   └── Voador/
├── fases/
│   ├── Fase1.tscn
│   ├── Fase2.tscn
│   ├── Fase3.tscn
│   └── componentes/
├── loja/
│   ├── Loja.gd
│   ├── Loja.gd.uid
│   └── Loja.tscn
├── ui/

# 📖 Documentação Técnica — Sistema de Inimigos & Arena

## 1. Sistema de Arena (Sala Fechada)

- **Gerenciamento:** O script `RoomManager.gd` controla o fluxo de combate em salas trancadas.
- **Funcionamento:** Ao detectar a entrada do Player, as portas são trancadas (via sinal) e o spawn dos inimigos é iniciado.
- **Controle de Mortes:** Cada inimigo, ao ser removido da árvore (sinal `tree_exited`), incrementa o contador. Quando o número de mortos atinge `quantidade_para_vencer`, a sala é finalizada.
- **Sinais Importantes:**
	- `sala_iniciada`: Tranca portas e inicia música de combate.
	- `sala_limpa`: Libera portas e instancia o baú de recompensa.

**Sugestão:** Certifique-se de conectar scripts de portas e recompensas a esses sinais para garantir integração modular.

---

## 2. Lógica Base de Inimigos (`enemy_base.gd`)

- **Herança:** Todos os inimigos devem herdar da classe `Enemy`.
- **Knockback System:** Ao receber dano (`take_damage`), o inimigo sofre empurrão na direção oposta ao Player e fica atordoado por 0.2s, interrompendo ataques/movimento.
- **Feedback Visual:** O método `flash_red()` aplica um efeito visual ao sofrer dano.
- **Gerenciamento de Vida:** Ao chegar a 0 HP, o inimigo executa animação de morte e se auto-deleta (`queue_free`), disparando a contagem da sala.
- **Detecção do Player:** O inimigo começa a perseguir o Player ao detectar sua entrada na área de detecção.

**Sugestão:** 
- Sempre use `body.take_damage(valor)` para aplicar dano a qualquer inimigo.
- Mantenha a modularidade para facilitar a criação de novos tipos de inimigos.

---

## 3. IA do Atirador/Mago (`regend_inimigo.gd`)

- **Fuga:** Se o Player se aproximar a menos de 150px, o mago recua automaticamente.
- **Ataque em Cone:** Dispara 3 projéteis simultâneos com abertura de 30° entre eles a cada 2 segundos.
- **Sincronia de Animação:** O cajado possui animações independentes para idle e ataque.

**Sugestão:** 
- Use o sistema de timers para controlar a cadência de tiro.
- Certifique-se de que o prefab do projétil está corretamente configurado.

---

## 4. Sistema de Projéteis (`projetio.gd`)

- **Velocidade:** 400 px/s (ajustar para 150 px/s se seguir o GDD).
- **Auto-destruição:** Some após 1.5s ou ao colidir com Player/Paredes.
- **Dano:** Ao colidir com o Player, chama `take_damage(1)`.

**Sugestão:** 
- Garanta que o Player está na Layer 1 e inimigos na Layer 2 para correta detecção de colisão.
- Projete o projétil para ser facilmente reutilizável por outros inimigos.

---

## 5. Notas para Integração

- **Para Player/HUD:** Inimigos estão na Collision Layer 2. Player deve estar na Layer 1.
- **Para Fases/Loja:** Instancie `RoomManager.tscn` e configure a lista de inimigos e quantidade para vencer no Inspector. Conecte scripts de portas aos sinais `sala_iniciada` e `sala_limpa`.

---

## 6. Recomendações para Outros Programadores

- **Padronização:** Sempre herde de `Enemy` para novos inimigos.
- **Sinais:** Use sinais para comunicação entre sistemas (portas, HUD, recompensas).
- **Modularidade:** Separe lógica de movimento, ataque e feedback visual para facilitar manutenção e expansão.
- **Documentação:** Mantenha este documento atualizado ao adicionar novos comportamentos ou tipos de inimigos.

---

```gdscript
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
```

### Divisão de Tarefas (Equipe de 3 Programadores)

#### Programador A – Personagem, HUD e Itens

**Responsabilidades:**
- Implementar movimento top-down com WASD
- Implementar ataque direcional com mouse
- Sistema de dano, knockback e invulnerabilidade
- Gerenciamento de vida e armadura
- Criar HUD (vida, armadura, moedas)
- Sistema de equipamento de itens
- Lógica de substituição de slots
- Conexão da loja com moedas e cura

**Dependências:** GameManager, PlayerStats (autoloads)

#### Programador B – Inimigos, Boss e Spawn

**Responsabilidades:**
- Criar cenas e IA para: Slime, Voador, Terrestre, Atirador
- Implementar perseguição, comportamentos especiais
- Atordoamento do Terrestre
- Lógica de dano (colisão / projéteis)
- Criar cena Boss com 2 fases
- Padrões de ataque (disparo circular, spawn de inimigos)
- Sistema de posicionamento e instanciação de inimigos
- Contabilizar derrotas e emitir sinais de limpeza

**Dependências:** PlayerStats, GameManager

#### Programador C – Fases, Loja, NPC e Fluxo

**Responsabilidades:**
- Criar Fase1, Fase2 e Fase3 com TileMap
- Implementar portas (trancar/destrancar)
- Adicionar armadilhas (espinhos estáticos e alternados)
- Posicionar spawn points
- Criar cena Loja com interface completa
- Navegação de itens com setas direcionais
- Criar NPC da Fase 3 e sistema de diálogo
- Gerenciar transições entre cenas
- Tela de Game Over com reinício
- Menu Principal e créditos

**Dependências:** GameManager, PlayerStats

### Cronograma Sugerido

| Semana | Objetivos |
|--------|-----------|
| **Semana 1** | Configurar autoloads, movimento do player, ataque com mouse (A); primeiro inimigo Slime (B); cena de teste com TileMap (C) |
| **Semana 2** | HUD e sistema de dano (A); IA de Voador, Terrestre, Atirador (B); portas e armadilhas (C) |
| **Semana 3** | Sistema de itens e loja (A); Boss e sistema de spawn (B); Fases 1 e 2 (C) |
| **Semana 4** | Integração de sistemas, correção de bugs, balanceamento inicial |
| **Semana 5** | Polimento, finalização de menus, efeitos sonoros |
| **Semana 6** | Testes finais de qualidade (QA) e entrega |

---

## 📊 Resumo de Mecânicas

### Progressão do Jogo

- ✅ Menu Principal
- ✅ Fase 1 (Básica) → Loja Obrigatória
- ✅ Fase 2 (Média) → Loja Opcional
- ✅ Fase 3 (Boss) → Créditos
- ✅ Game Over (Desistir / Tentar Novamente)

### Combate

- Ataque direcional com mouse (espada rotativa)
- Knockback e invulnerabilidade temporária
- Sistema de armadura absorve dano antes da vida

### Progressão de Poder

- Coletar moedas em baús (15-25)
- Comprar itens nas lojas (até 3 equipados)
- Receber item grátis na Fase 3

### Curva de Dificuldade

- **Fase 1:** Inimigos básicos (Slime, Voador)
- **Fase 2:** Inimigos intermediários (Terrestre, Atirador)
- **Fase 3:** Boss com 2 fases e obstáculos dinâmicos

---

## 📝 Notas Finais

Este é um projeto modular e bem estruturado, ideal para uma equipe de desenvolvimento em Godot. Cada programador tem responsabilidades claramente definidas, facilitando o trabalho paralelo e a integração posterior.

O jogo oferece uma experiência progressiva com dificuldade crescente, sistema de recompensas bem definido e mecânicas de combate diretas e responsivas.

---

**Versão:** 1.0  
**Engine:** Godot 4.x  
**Plataforma:** PC (Windows/Linux/macOS)  
**Status:** Em Desenvolvimento

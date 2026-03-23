# Guia de Integração: Sistema de Inimigos (v1.0)

Este documento explica como funciona o sistema de inimigos herdados do projeto e como integrá-lo corretamente. Siga estas orientações para garantir compatibilidade e manutenção do código.

## 1. Identificação de Inimigos
Todos os inimigos (Slime, Voador, Mago, etc.) derivam da mesma classe base e possuem `class_name Enemy`. Para verificar se um objeto atingido é um inimigo:

```gdscript
if body is Enemy:
    # O objeto é um inimigo válido
```

## 2. Como Causar Dano
Não acesse variáveis de vida diretamente. Use a função padrão:

- **Função:** `take_damage(amount: int)`
- **O que faz:** Subtrai vida, aciona efeito visual de "Flash Vermelho", aplica knockback (se o Player for referenciado) e gerencia a morte automaticamente.

**Exemplo de uso no ataque do Player:**
```gdscript
func _on_attack_area_body_entered(body):
    if body.has_method("take_damage"):
        body.take_damage(1) # Causa 1 de dano
```

## 3. Configuração de Colisões (Physics Layers)
Respeite o padrão de camadas para garantir interações corretas:

| Objeto         | Layer (Onde está) | Mask (O que detecta)                  |
| -------------- | ---------------- | ------------------------------------- |
| Player         | Layer 1          | Layer 2 (Inimigos), Layer 3 (Cenário) |
| Inimigos       | Layer 2          | Layer 1 (Player), Layer 3 (Cenário)   |
| DetectionArea  | N/A              | Layer 1 (Busca especificamente o Player)|

**Nota:** A DetectionArea dos inimigos busca o nó pelo nome "Player". Certifique-se de que o nó raiz da cena do jogador tenha exatamente esse nome.

## 4. Estados do Inimigo
Estas variáveis booleanas podem ser lidas para ajustar a IA do Player:
- `is_dead` (bool): true se o inimigo estiver na animação de morte.
- `chasing` (bool): true se o inimigo estiver perseguindo o jogador.

Exemplo de uso:
```gdscript
if enemy.is_dead:
    # Não interagir com inimigos mortos
```

## 5. Sistema de Partículas e Morte
- Ao morrer, o inimigo executa `die()`.
- Corpo físico e colisões são desativados imediatamente.
- Fragmentos de vidro/morte são gerados e permanecem por 3 segundos antes de serem limpos.
- **Não** use `queue_free()` externamente; a classe Enemy já gerencia sua própria remoção.

## Dica para o Programador
Se precisar criar um efeito de impacto no local exato do hit, use:
```gdscript
enemy.global_position
```

---

Se desejar uma seção específica sobre como o Mago dispara projéteis para orientar desvios do Player, solicite ao responsável pela documentação.

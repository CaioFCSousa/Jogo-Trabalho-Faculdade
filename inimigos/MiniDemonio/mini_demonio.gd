extends Enemy

@onready var dust_particles = $DustParticles

func move_logic(delta):
	super.move_logic(delta)
	
	if player and dust_particles:
		if !dust_particles.emitting:
			dust_particles.emitting = true
		
		var direction_x = (player.global_position - global_position).x
		dust_particles.position.x = -2 if direction_x > 0 else 2

func idle_logic(delta):
	super.idle_logic(delta)
	if dust_particles and dust_particles.emitting:
		dust_particles.emitting = false

func die():
	if dust_particles:
		dust_particles.emitting = false
	super.die()

func _on_detection_area_body_entered(body):
	super._on_detection_area_body_entered(body)

func _on_detection_area_body_exited(body):
	super._on_detection_area_body_exited(body)

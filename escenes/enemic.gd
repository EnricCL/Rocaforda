extends CharacterBody2D

@export var vida: int = 3
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	# Connectar el senyal quan un àrea entra a la Hurtbox
	$Hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func _on_hurtbox_area_entered(area):
	# Si l'àrea que el toca és la de l'atac del jugador
	if area.name == "AttackArea":
		rebre_dany(1)

func rebre_dany(quantitat: int):
	vida -= quantitat
	
	# Flash vermell visual en rebre mal
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.08)
	tween.tween_property(self, "modulate", Color.WHITE, 0.08)

	if vida <= 0:
		queue_free() # Destrueix l'enemic

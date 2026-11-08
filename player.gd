extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0
var direccio_mirada = 1 # 1 per la dreta, -1 per a l'esquerra
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var pot_teletransportar = true
var esta_atacant = false

@onready var attack_area = $AttackArea
@onready var attack_shape = $"AttackArea/CollisionShape2D"

func _ready():
	#La hitbox de l'espasa comença desactivada
	if attack_shape:
		attack_shape.disabled = true

func _physics_process(delta):
	# 1. Aplicar la gravetat si no estàs al terra
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Control de salt
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Moviment horitzontal esquerra/dreta
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		# Actualitzar cap a on mira el personatge
		direccio_mirada = direction
		# Gira el sprite automàticament (true a l'esquerra, false a la dreta)
		$Sprite2D.flip_h = (direction < 0)
		# Orienta l'àrea d'atac a l'esquerra o dreta segons on mira el jugador
		if direction < 0:
			attack_area.scale.x = -1
		else:
			attack_area.scale.x = 1
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# 4. Atac amb l'espasa (Tecla J)
	if Input.is_key_pressed(KEY_J) and not esta_atacant:
		atacar()

	# 5. Mecànica Teletransport (a la torxa en prémer la tecla 'E')
	if Input.is_key_pressed(KEY_E):
		if pot_teletransportar:
			pot_teletransportar = false #Bloquegem fins que deixi anar la tecla
			
			var torxes = get_tree().get_nodes_in_group("punts_llum")
			var millor_torxa = null
			var menor_distancia = 99999.0
		
			for torxa in torxes:
				# Calculem la direcció relativa respecte al jugador
				var desplaçament_x = torxa.global_position.x - global_position.x
			
				# Comprovem si la torxa està a la mateixa direcció on mira el cavaller
				# (Si mira a la dreta, desplaçament_x > 0; si mira a l'esquerra, desplaçament_x < 0)
				if (direccio_mirada > 0 and desplaçament_x >0) or (direccio_mirada < 0 and desplaçament_x < 0):
					var distancia = global_position.distance_to(torxa.global_position)
					if distancia < menor_distancia:
						menor_distancia = distancia
						millor_torxa = torxa
			
			# Si trobem una torxa en la direcció de la mirada, hi saltem
			if millor_torxa != null:
				global_position = millor_torxa.global_position
				# Resetegem la velocitat de caiguda
				velocity.y = 0
				velocity.x = 0
	else:
		# Quan el jugador deixa anar la tecla E, tornem a permetre el teletransport
		pot_teletransportar = true

# Funció d'atacar amb arma d'espasa
func atacar():
	esta_atacant = true
	attack_shape.disabled = false #Activem la col·lisió de l'espasa
	
	# Parpalleig de color ràpid per indicar visualment el cop
	$Sprite2D.modulate = Color.CYAN
	await get_tree().create_timer(0.15).timeout
	$Sprite2D.modulate = Color.WHITE
	
	attack_shape.disabled = true #Desactivem la col·lisió de l'espasa
	esta_atacant = false
	
	

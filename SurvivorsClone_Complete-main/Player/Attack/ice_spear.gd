extends Area2D

var level = 1
var hp = 1
var speed = 100
var damage = 5
var knockback_amount = 100
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var particles = $CPUParticles2D

func _ready():
	level = player.icespear_level  # Obter o nível atual do Ice Spear do jogador
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)
	
	match level:
		1:
			hp = 1
			speed = 100
			damage = 5
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		2:
			hp = 1
			speed = 100
			damage = 5
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		3:
			hp = 2
			speed = 100
			damage = 8
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		4:
			hp = 2
			speed = 100
			damage = 8
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
	
	scale = Vector2.ONE * attack_size  # Ajusta o tamanho do Ice Spear

func _physics_process(delta):
	position += angle * speed * delta

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		_destroy_object()

func _destroy_object():
	# Desativa a sprite e interrompe a emissão de partículas
	sprite.visible = false

	# Aguarda um curto período para as partículas desaparecerem
	await get_tree().create_timer(1.0).timeout
	queue_free()

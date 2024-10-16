extends Area2D

@export var level = 1
@export var damage = 20  # Dano base da arma
@export var area_radius = 100.0  # Raio de dano em área
@export var attack_speed = 5.0  # Velocidade de repetição do ataque
@export var duration = 1.0  # Duração do efeito de dano
@export var cooldown_time = 3.0  # Tempo de recarga entre os ataques
@export var target_position = Vector2.ZERO  # Posição para centralizar o ataque

@onready var collision = $CollisionShape2D
@onready var snd_attack = $snd_attack

@onready var area_damage_shape = get_node("CollisionShape2D")

# Referência ao player
@onready var player = get_tree().get_first_node_in_group("player")

# Timer para cooldown do ataque
var cooldown_timer = Timer.new()

func _ready():
	# Iniciar o tambor
	add_child(cooldown_timer)
	cooldown_timer.one_shot = true
	update_tambor()
	# Ativar o ataque imediatamente ao iniciar
	attack_tambor()

func update_tambor():
	# Atualiza os atributos do tambor de acordo com o nível
	match level:
		1:
			damage = 20
			area_radius = 100.0
			attack_speed = 5.0
		2:
			damage = 25
			area_radius = 120.0
			attack_speed = 4.5
		3:
			damage = 30
			area_radius = 140.0
			attack_speed = 4.0
		4:
			damage = 35
			area_radius = 160.0
			attack_speed = 3.5
	
	# Ajustar o raio da área de dano
	area_damage_shape.scale = Vector2.ONE * (area_radius / 100.0)

func attack_tambor():
	# Executa o ataque em área
	emit_signal("tambor_attack")  # Sinal que pode ser conectado para efeitos visuais
	snd_attack.play()  # Reproduzir o som do tambor
	enable_attack_area(true)

	# Após a duração do ataque, desabilitar a área de dano
	await get_tree().create_timer(duration).timeout
	enable_attack_area(false)

	# Iniciar o cooldown
	cooldown_timer.start(cooldown_time)
	await cooldown_timer.timeout
	
	# Preparar o próximo ataque
	attack_tambor()

func enable_attack_area(enable):
	if enable:
		collision.set_disabled(false)
	else:
		collision.set_disabled(true)

func _on_AreaDamageShape2D_body_entered(body):
	if body.is_in_group("enemy"):  # Checar se o corpo é um inimigo
		var final_damage = damage * player.spell_size  # Escalar o dano com base no tamanho do feitiço
		body.apply_damage(final_damage)  # Supondo que inimigos tenham um método para aplicar dano

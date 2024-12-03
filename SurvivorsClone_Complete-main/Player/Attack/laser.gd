extends Area2D

@export var level = 1
@export var damage = 10  # Dano base
@export var speed = 300.0  # Velocidade do laser
@export var attack_duration = 2.0  # Duração máxima
@export var attack_size = 1.0  # Tamanho inicial do ataque
@export var scale_increase_factor = 2.0  # Fator de aumento da escala

var attack_direction = Vector2.ZERO  # Direção inicial do laser

@onready var collision_shape = $CollisionShape2D
@onready var snd_attack = $snd_attack
@onready var sprite = $Sprite2D  # Referência ao Sprite do laser

# Configurar a referência ao jogador
func set_target(player):
	if player:
		print("\n--- set_target CALLED ---")
		print("Player Position (Before Set):", player.global_position)

		# Configurar a posição inicial e direção
		position = player.global_position
		attack_direction = player.last_movement.normalized()
		if attack_direction == Vector2.ZERO:
			attack_direction = Vector2.UP  # Direção padrão caso o jogador esteja parado

		print("Calculated Laser Position:", position)
		print("Calculated Attack Direction:", attack_direction)
		print("--- END set_target ---\n")

func _ready():
	print("\n--- _ready CALLED ---")
	print("Laser Position at Ready Start:", position)

	# Configura a escala e a rotação inicial
	rotation = attack_direction.angle()  # Ajustar o ângulo para a direção inicial
	scale = Vector2.ONE * attack_size

	print("Laser Rotation Set To:", rotation)
	print("Laser Scale Set To:", scale)

	# Configurar som e aparência inicial do ataque
	snd_attack.play()
	update_attack()

	# Aumentar a escala do sprite gradualmente
	scale_sprite()

	# Timer para controlar o tempo de vida
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = attack_duration
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_attack_timeout"))
	timer.start()

	print("Laser Initialized with Timer (Duration):", attack_duration)
	print("--- END _ready ---\n")

func _physics_process(delta):
	# Movimentar o laser na direção configurada
	position += attack_direction * speed * delta

	# Prints periódicos para depuração
	print("Physics Process - Current Position:", position)
	print("Physics Process - Moving Towards Direction:", attack_direction)

func update_attack():
	# Configurar o tamanho inicial do ataque
	collision_shape.scale = Vector2.ONE * attack_size

func scale_sprite():
	# Criar um Tween usando o método create_tween()
	var tween = create_tween()  # Aqui estamos criando o tween no nó atual (Area2D)
	# Aumentar a escala do sprite ao longo do tempo usando o Tween
	tween.tween_property(sprite, "scale", Vector2.ONE * scale_increase_factor, 0.75)

func _on_attack_timeout():
	# Remover o laser após o tempo configurado
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		print("Laser hit:", body)
		print(damage)
		body.take_damage(damage)  # Aplica dano no inimigo

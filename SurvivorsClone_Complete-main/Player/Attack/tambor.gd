extends Area2D

@export var level = 1
@export var damage = 1  # Dano base da arma, começando com 5
@export var area_radius = 100.0  # Raio de dano em área
@export var attack_speed = 5.0  # Velocidade de repetição do ataque
@export var duration = 1.0  # Duração total do efeito de dano (1 segundo)
@export var cooldown_time = 3.0  # Tempo de recarga entre os ataques
@export var target_position = Vector2.ZERO  # Posição para centralizar o ataque

@onready var collision = $CollisionShape2D
@onready var snd_attack = $snd_attack

# Referência ao jogador para seguir sua posição
var target_player = null

# Timer para limitar a duração do tambor
var active_timer = Timer.new()

func set_target(player):
	target_player = player

func _process(delta):
	if target_player:
		# Obtenha a posição da câmera que é filha do jogador
		var camera_position = target_player.get_node("Camera2D").position
		# Posiciona o tambor na posição da câmera
		position = camera_position

@onready var area_damage_shape = get_node("CollisionShape2D")

# Timer para cooldown do ataque
var cooldown_timer = Timer.new()

func _ready():
	# Configurar e iniciar o tambor
	add_child(cooldown_timer)
	add_child(active_timer)
	cooldown_timer.one_shot = true
	update_tambor()
	
	# Configurar o timer para a duração ativa do tambor
	active_timer.wait_time = 5.0
	active_timer.one_shot = true
	active_timer.connect("timeout", Callable(self, "_on_timer_timeout"))  # Correção feita aqui
	active_timer.start()  # Inicia o timer de 5 segundos
	
	# Ativar o ataque imediatamente com a animação de pulsação
	animate_pulse()

	
func _on_timer_timeout():
	# Desativa o tambor após o tempo de duração
	enable_attack_area(false)
	queue_free()  # Remove o tambor da cena

func update_tambor():
	# Ajusta o dano e a duração do timer de acordo com o nível
	match level:
		1:
			damage = 1
			active_timer.wait_time = 5.0
		2:
			damage = 2
			active_timer.wait_time = 4.0
		3:
			damage = 4
			active_timer.wait_time = 3.5
		4:
			damage = 6
			active_timer.wait_time = 3.0
		5:
			damage = 10
			active_timer.wait_time = 2.5  # Tempo mínimo de 2.5 segundos

	# Ajustar o raio do CollisionShape2D
	area_damage_shape.scale = Vector2.ONE * (area_radius / 100.0)

func animate_pulse():
	# Execute sound and enable area for damage
	snd_attack.play()
	enable_attack_area(true)

	var tween = create_tween()
	
	# Grow to full size over 0.5 seconds
	tween.tween_property(self, "scale", Vector2(1, 1), 0.5)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	
	# Shrink back to minimum size over the next 0.5 seconds with a delay
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.4)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_IN)
	

	# Wait for the animation duration, disable area, and free the tambor
	await get_tree().create_timer(duration).timeout
	enable_attack_area(false)

func enable_attack_area(enable):
	collision.disabled = not enable
	
func _on_body_entered(body):
	# Verifique se o corpo está no grupo "enemy"
	if body.is_in_group("enemy"):
		body.take_damage(damage)  # Aplica dano ao inimigo
		queue_free()  # Remove o tambor após causar o dano

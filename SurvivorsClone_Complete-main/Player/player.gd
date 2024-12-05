extends CharacterBody2D

@export var movement_speed = 80.0
@export var hp = 80
@export var maxhp = 80
@export var last_movement = Vector2.UP
@export var time = 0

@export var experience = 0
@export var experience_level = 1
@export var collected_experience = 0

# Attacks
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")
var javelin = preload("res://Player/Attack/javelin.tscn")
var Tambor = preload("res://Player/Attack/tambor.tscn")
var Laser = preload("res://Player/Attack/laser.tscn")
# AttackNodes (Se não forem mais necessários, podem ser removidos)
# @onready var iceSpearTimer = get_node("%IceSpearTimer")
# @onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")
# @onready var tornadoTimer = get_node("%TornadoTimer")
# @onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var javelinBase = get_node("%JavelinBase")

# UPGRADES
@export var collected_upgrades = []
@export var upgrade_options = []
@export var armor = 0
@export var speed = 0
@export var spell_cooldown = 0
@export var spell_size = 0
@export var additional_attacks = 0

# IceSpear
@export var icespear_ammo = 0
@export var icespear_baseammo = 0
@export var icespear_attackspeed = 1.5
@export var icespear_level = 0

# Tornado
@export var tornado_ammo = 0
@export var tornado_baseammo = 0
@export var tornado_attackspeed = 3
@export var tornado_level = 0

# Javelin
@export var javelin_ammo = 0
@export var javelin_level = 0

#laser
@export var laser_ammo = 0
@export var laser_baseammo = 0
@export var laser_attackspeed = 3.0
@export var laser_level = 0
# Tambor
@export var tambor_ammo = 0
@export var tambor_baseammo = 0
@export var tambor_attackspeed = 3.0
@export var tambor_level = 0
# Enemy Related
var enemy_close = []

@onready var sprite = $Sprite2D
@onready var sprite_shadow = $SpriteShadow
@onready var walkTimer = get_node("%walkTimer")

# GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var itemOptions = preload("res://Utility/item_option.tscn")
@onready var sndLevelUp = get_node("%snd_levelup")
@onready var healthBar = get_node("%HealthBar")
@onready var lblTimer = get_node("%lblTimer")
@onready var collectedWeapons = get_node("%CollectedWeapons")
@onready var collectedUpgrades = get_node("%CollectedUpgrades")
@onready var itemContainer = preload("res://Player/GUI/item_container.tscn")

@onready var deathPanel = get_node("%DeathPanel")
@onready var lblResult = get_node("%lbl_Result")
@onready var sndVictory = get_node("%snd_victory")
@onready var sndLose = get_node("%snd_lose")

# Variáveis para os tempos das notas
var note_times_ice_spear = []
var note_times_tornado = []
var note_times_javelin = []
var note_times_tambor = []
var note_times_laser = []

var current_note_index_ice_spear = 0
var current_note_index_tornado = 0
var current_note_index_javelin = 0
var current_note_index_tambor = 0
var current_note_index_laser = 0
var music_timer = 0.0
var is_playing = false

# Supondo que você tenha um AudioStreamPlayer
@onready var music_player = $snd_Music

signal playerdeath

func _ready():
	# Carregar os tempos das notas
  
	note_times_ice_spear = load_note_times("res://Audio/Musica/json/instrumento 2.json")
	note_times_tornado = load_note_times("res://Audio/Musica/json/instrumento 3.json")
	note_times_javelin = load_note_times("res://Audio/Musica/json/instrumento 1.json")
	note_times_tambor = load_note_times("res://Audio/Musica/json/instrumento 4.json")
	note_times_laser = load_note_times("res://Audio/Musica/json/instrumento 2.json")

	is_playing = true  # Começar a reprodução

	# Desbloquear as armas (se necessário)
	upgrade_character("icespear1")
	upgrade_character("tornado1")
	upgrade_character("javelin1")
	upgrade_character("tambor1")
	upgrade_character("laser1")
	# Configurações iniciais
	set_expbar(experience, calculate_experiencecap())
	_on_hurt_box_hurt(0, 0, 0)

func _physics_process(delta):
	movement()

	if is_playing:
		# Atualizar o temporizador da música
		music_timer = music_player.get_playback_position()
		# Verificar se a música reiniciou
		if music_timer < 0.1 and music_timer < music_player.stream.get_length():
			music_timer = 0.0
			current_note_index_ice_spear = 0
			current_note_index_tornado = 0
			current_note_index_javelin = 0
			current_note_index_tambor = 0
			current_note_index_laser = 0
		# Verificar o Ice Spear
		while current_note_index_ice_spear < note_times_ice_spear.size() and music_timer >= note_times_ice_spear[current_note_index_ice_spear]:
			activate_ice_spear()
			current_note_index_ice_spear += 1
		# Verificar o Tornado
		while current_note_index_tornado < note_times_tornado.size() and music_timer >= note_times_tornado[current_note_index_tornado]:
			activate_tornado()
			current_note_index_tornado += 1
		# Verificar o Javelin
		while current_note_index_javelin < note_times_javelin.size() and music_timer >= note_times_javelin[current_note_index_javelin]:
			activate_javelin()
			current_note_index_javelin += 1
		  # Verificar o Tambor
		while current_note_index_tambor < note_times_tambor.size() and music_timer >= note_times_tambor[current_note_index_tambor]:
			activate_tambor()  # Função que ativa o ataque tambor
			current_note_index_tambor += 1
			# Verificar o laser
		while current_note_index_laser < note_times_laser.size() and music_timer >= note_times_laser[current_note_index_laser]:
			activate_laser()  # Função que ativa o ataque laser
			current_note_index_laser += 1
func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	if mov.x > 0:
		sprite.flip_h = true
		sprite_shadow.flip_h = true
	elif mov.x < 0:
		sprite.flip_h = false
		sprite_shadow.flip_h = false

	if mov != Vector2.ZERO:
		last_movement = mov
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walkTimer.start()

	velocity = mov.normalized() * movement_speed
	move_and_slide()

# Funções para ativar cada arma
func activate_ice_spear():
	if icespear_level > 0:
		var ammo = icespear_baseammo + additional_attacks
		for i in range(ammo):
			var icespear_attack = iceSpear.instantiate()
			icespear_attack.position = position
			icespear_attack.target = get_nearest_target()
			icespear_attack.level = icespear_level
			add_child(icespear_attack)

func activate_tornado():
	if tornado_level > 0:
		var ammo = tornado_baseammo + additional_attacks
		for i in range(ammo):
			var tornado_attack = tornado.instantiate()
			tornado_attack.position = position
			tornado_attack.last_movement = last_movement
			tornado_attack.level = tornado_level
			add_child(tornado_attack)

func activate_javelin():
	if javelin_level > 0:
		var get_javelin_total = javelinBase.get_child_count()
		var calc_spawns = (javelin_ammo + additional_attacks) - get_javelin_total
		while calc_spawns > 0:
			var javelin_spawn = javelin.instantiate()
			javelin_spawn.global_position = global_position
			javelinBase.add_child(javelin_spawn)
			calc_spawns -= 1
		# Upgrade Javelin
		var get_javelins = javelinBase.get_children()
		for i in get_javelins:
			if i.has_method("update_javelin"):
				i.update_javelin()
				i.update_javelin()
func activate_tambor():
	if tambor_level > 0:
		var ammo = tambor_baseammo + additional_attacks
		for i in range(ammo):
			var tambor_attack = Tambor.instantiate()
			# Vincula a posição do tambor com a posição do jogador continuamente
			tambor_attack.level = tambor_level
			tambor_attack.area_radius = 100.0 * (1 + spell_size)
			tambor_attack.damage = tambor_attack.damage * (1 + spell_size)
			tambor_attack.attack_speed = 3.0 * (1 - spell_cooldown)
			tambor_attack.set_target(self)  # Passa a referência do jogador como alvo
			add_child(tambor_attack)
func activate_laser():
	if laser_level > 0:
		var ammo = laser_baseammo + additional_attacks
		for i in range(ammo):
			var laser_attack = Laser.instantiate()

			# Chama set_target antes de adicionar o laser
			laser_attack.set_target(self)
			
			# Adicionar o laser à cena
			get_tree().root.add_child(laser_attack)

			print("\n--- LASER ACTIVATED ---")
			print("Player Position at Activation:", global_position)
			print("--- END LASER ACTIVATION ---\n")




func _on_hurt_box_hurt(damage, _angle, _knockback):
	hp -= clamp(damage - armor, 1.0, 999.0)
	healthBar.max_value = maxhp
	healthBar.value = hp
	if hp <= 0:
		death()

func get_nearest_target():
	if enemy_close.size() > 0:
		var nearest_enemy = null
		var nearest_distance = INF
		var player_position = global_position  # Assumindo que este script está anexado ao jogador

		for enemy in enemy_close:
			var distance = player_position.distance_to(enemy.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_enemy = enemy

		return nearest_enemy.global_position
	else:
		return Vector2.UP

func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)

func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)

func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required:  # Level up
		collected_experience -= exp_required - experience
		experience_level += 1
		experience = 0
		exp_required = calculate_experiencecap()
		levelup()
	else:
		experience += collected_experience
		collected_experience = 0

	set_expbar(experience, exp_required)

func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap += 95 * (experience_level - 19) * 8
	else:
		exp_cap = 255 + (experience_level - 39) * 12

	return exp_cap

func set_expbar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value

func levelup():
	sndLevelUp.play()
	lblLevel.text = str("Level: ", experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "position", Vector2(220, 50), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
	get_tree().paused = true

func upgrade_character(upgrade):
	match upgrade:
		"icespear1":
			icespear_level = 1
			icespear_baseammo += 1
		"icespear2":
			icespear_level = 2
			icespear_baseammo += 1
		"icespear3":
			icespear_level = 3
		"icespear4":
			icespear_level = 4
			icespear_baseammo += 2
		"tornado1":
			tornado_level = 1
			tornado_baseammo += 1
		"tornado2":
			tornado_level = 2
			tornado_baseammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attackspeed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_baseammo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"laser1":
			laser_level = 1
			laser_baseammo += 1	
		"tambor1":
			tambor_level = 1
			tambor_baseammo += 1
		"tambor2":
			tambor_level = 2
			tambor_baseammo += 1
		"tambor3":
			tambor_level = 3
		"tambor4":
			tambor_level = 4
			tambor_baseammo += 2
		"armor1", "armor2", "armor3", "armor4":
			armor += 1
		"speed1", "speed2", "speed3", "speed4":
			movement_speed += 20.0
		"tome1", "tome2", "tome3", "tome4":
			spell_size += 0.10
		"scroll1", "scroll2", "scroll3", "scroll4":
			spell_cooldown += 0.05
		"ring1", "ring2":
			additional_attacks += 1
		"food":
			hp += 20
			hp = clamp(hp, 0, maxhp)
	adjust_gui_collection(upgrade)
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(800, 50)
	get_tree().paused = false
	calculate_experience(0)

func get_random_item():
	var dblist = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades:  # Find already collected upgrades
			pass
		elif i in upgrade_options:  # If the upgrade is already an option
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item":  # Don't pick food
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0:  # Check for PreRequisites
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades:
					to_add = false
			if to_add:
				dblist.append(i)
		else:
			dblist.append(i)
	if dblist.size() > 0:
		var randomitem = dblist.pick_random()
		upgrade_options.append(randomitem)
		return randomitem
	else:
		return null

func change_time(argtime = 0):
	time = argtime
	var get_m = int(time / 60.0)
	var get_s = time % 60
	if get_m < 10:
		get_m = str(0, get_m)
	if get_s < 10:
		get_s = str(0, get_s)
	lblTimer.text = str(get_m, ":", get_s)

func adjust_gui_collection(upgrade):
	var get_upgraded_displayname = UpgradeDb.UPGRADES[upgrade]["displayname"]
	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]
	if get_type != "item":
		var get_collected_displaynames = []
		for i in collected_upgrades:
			get_collected_displaynames.append(UpgradeDb.UPGRADES[i]["displayname"])
		if not get_upgraded_displayname in get_collected_displaynames:
			var new_item = itemContainer.instantiate()
			new_item.upgrade = upgrade
			match get_type:
				"weapon":
					collectedWeapons.add_child(new_item)
				"upgrade":
					collectedUpgrades.add_child(new_item)

func death():
	deathPanel.visible = true
	emit_signal("playerdeath")
	get_tree().paused = true
	var tween = deathPanel.create_tween()
	tween.tween_property(deathPanel, "position", Vector2(220, 50), 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	if time >= 300:
		lblResult.text = "You Win"
		sndVictory.play()
	else:
		lblResult.text = "You Lose"
		sndLose.play()

func _on_btn_menu_click_end():
	get_tree().paused = false
	var _level = get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")

# Parte do menu do jogador
@onready var pause = $GUILayer/GUI/Pause

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if not pause.is_visible():
			_pause_game()
		else:
			_resume_game()

func _pause_game():
	pause.visible = true
	Engine.time_scale = 0

func _resume_game():
	pause.visible = false
	Engine.time_scale = 1

func load_note_times(json_path):
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()

		var json_parser = JSON.new()
		var parse_error = json_parser.parse(json_text)
		if parse_error == OK:
			return json_parser.data  # Retorna a lista de tempos
		else:
			print("Erro ao parsear JSON: ", json_parser.get_error_message())
			return []
	else:
		print("Não foi possível abrir o arquivo JSON: ", json_path)
		return []

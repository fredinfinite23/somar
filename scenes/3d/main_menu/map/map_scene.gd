# SPDX-FileCopyrightText: 2024 2024 Collabora ltd.
#
# SPDX-License-Identifier: BSL-1.0

extends BaseScene

enum AutoMenuStrings {
	OFF = 0,
	Coastal = 1,
	Oceanic = 2
}

# Editor option to select which menu is chosen automatically
# Very handy when in CubeMap mode (no pose, no contoller)
@export_category("Automatic Menu")
@export var menu_option : AutoMenuStrings = AutoMenuStrings.OFF

@onready var ocean_btn : CustomBtn = %OceanBtn
@onready var shore_btn : CustomBtn = %ShoreBtn
@onready var license_lbl : Label3D = %LicenseLbl
@onready var change_language_btn : CustomBtn = %ChangeLanguageBtn
@onready var ui_container : Node3D = %UIContainer
@onready var animation_player : AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	await tree.process_frame
	Global.player.input_enabled = false
	ocean_btn.pressed.connect(_switch_to_scene.bind("ocean"), CONNECT_ONE_SHOT)
	shore_btn.pressed.connect(_switch_to_scene.bind("shore"), CONNECT_ONE_SHOT)
	change_language_btn.pressed.connect(menu_btn_pressed)

	change_with_input(Global.player.controller_input_enabled)

	Global.player.set_glove_caustics(false)
	Global.player.set_sun_rays_enabled(false)

	ui_container.global_position.y = Global.player.camera.global_position.y

	#Global.player.fade(true)

	#await Global.player.fade_finished
	animation_player.play("show_markers")
	await animation_player.animation_finished
	Global.player.input_enabled = true
	
	assert(not Global.player.panorama_mode || (Global.player.panorama_mode && menu_option),\
	"You MUST select a default Automatic menu behavior here in panorama_mode")
	# Add default timout behavior/action
	if menu_option != AutoMenuStrings.OFF :
		await tree.create_timer(1.0).timeout
		if menu_option == AutoMenuStrings.Coastal :
			_switch_to_scene("shore")
		elif menu_option == AutoMenuStrings.Oceanic :
			_switch_to_scene("ocean")


func _switch_to_scene(scene_id : String) -> void:
	#Global.player.fade(false)
	#await Global.player.fade_finished
	SceneManager.switch_to_scene(scene_id)


func menu_btn_pressed() -> void:
	Global.player.fade(false)
	await Global.player.fade_finished
	SceneManager.switch_to_scene("language_menu")


func change_with_input(controller_input : bool) -> void:
	if controller_input:
		change_language_btn.visible = false
		change_language_btn.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		change_language_btn.visible = true
		change_language_btn.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Do not show buttons and labels at the bottom if we're in Cubemap mode
	if menu_option != AutoMenuStrings.OFF :
		license_lbl.visible = false;
		change_language_btn.visible = false;

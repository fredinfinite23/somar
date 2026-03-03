# SPDX-FileCopyrightText: 2024 2024 Collabora ltd.
#
# SPDX-License-Identifier: BSL-1.0

extends BaseScene

@onready var lang_btn_english : CustomBtn = %EnglishBtn
@onready var lang_btn_portuguese : CustomBtn = %PortugueseBtn
@onready var press_instructions_lbl : Label3D = %PressInstructionsLbl
@onready var language_buttons : Node3D = %LanguageButtons

enum AutoMenuStrings {
	OFF = 0,
	English = 1,
	Portuguese = 2
}

# Editor option to select which menu is chosen automatically
# Very handy when in CubeMap mode (no pose, no contoller)
@export_category("Automatic Menu")
@export var menu_option : AutoMenuStrings = AutoMenuStrings.OFF

var listening_to_menu_btn : bool = true

func _ready() -> void:
	await tree.process_frame
	change_with_input(Global.player.controller_input_enabled)

	Global.player.set_glove_caustics(false)
	Global.player.set_sun_rays_enabled(false)

	lang_btn_english.pressed.connect(_set_language.bind("en"))
	lang_btn_portuguese.pressed.connect(_set_language.bind("pt"))

	language_buttons.process_mode = Node.PROCESS_MODE_INHERIT
	if menu_option == AutoMenuStrings.OFF :
		language_buttons.visible = true
	language_buttons.global_position.y = Global.player.camera.global_position.y

	# Global.player.fade(true)

	#await Global.player.fade_finished
	Global.player.input_enabled = true
	
	# Add default timout behavior/action
	assert(not Global.player.panorama_mode || (Global.player.panorama_mode && menu_option),\
	"You MUST select a default Automatic menu behavior here in panorama_mode")
	if menu_option != AutoMenuStrings.OFF :
		await tree.create_timer(1.0).timeout
		if menu_option == AutoMenuStrings.English :
			_set_language("en")
		elif menu_option == AutoMenuStrings.Portuguese :
			_set_language("pt")

func _set_language(lang_code : String) -> void:
	Global.player.input_enabled = false
	TranslationServer.set_locale(lang_code)

	var language_tween : Tween = create_tween()
	language_tween.set_trans(Tween.TRANS_CUBIC)
	language_tween.set_ease(Tween.EASE_IN)

	language_tween.tween_property(
		language_buttons,
		"scale",
		Vector3.ZERO,
		0.3)
	
	await language_tween.finished
	# Disable language selection screen
	language_buttons.visible = false
	language_buttons.process_mode = Node.PROCESS_MODE_DISABLED

	#Global.player.fade(false)
	#await Global.player.fade_finished
	SceneManager.switch_to_scene("map_menu")


func change_with_input(controller_input : bool) -> void:
	if controller_input:
		press_instructions_lbl.visible = false
	else:
		press_instructions_lbl.visible = true

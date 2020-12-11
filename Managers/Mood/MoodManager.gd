extends Node


class_name MoodManager

const INTRO_MOOD = "INTRO"
const EASY_BATTLE_MOOD = "EASY_BATTLE"
const HARD_BATLE_MOOD = "HARD_BATTLE"
const SHELTER_MOOD = "SHELTER"
const VICTORY_MOOD = "VICTORY"

onready var audio_player = $AudioStreamPlayer

export(AudioStream) var intro_song : AudioStream
export(AudioStream) var easy_battle_song : AudioStream
export(AudioStream) var hard_battle_song : AudioStream
export(AudioStream) var shelter_song : AudioStream
export(AudioStream) var victory_song : AudioStream

var current_mood : String

func update_mood():
	match(current_mood):
		INTRO_MOOD:
			audio_player.stream = intro_song
		EASY_BATTLE_MOOD:
			audio_player.stream = easy_battle_song
		HARD_BATLE_MOOD:
			audio_player.stream = hard_battle_song
		SHELTER_MOOD:
			audio_player.stream = shelter_song
		VICTORY_MOOD:
			audio_player.stream = victory_song
	audio_player.play()

func set_mood(mood_type:String):
	if mood_type == current_mood:
		return
	current_mood = mood_type
	update_mood()


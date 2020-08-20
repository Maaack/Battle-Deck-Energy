extends Node


class_name BattlePhase

signal phase_entered
signal phase_exited

func enter():
	emit_signal("phase_entered")

func exit():
	emit_signal("phase_exited")

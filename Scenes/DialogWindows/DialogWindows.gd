extends Control

func report_error(error_text : String):
	$CanvasLayer/ErrorDialog.dialog_text = error_text
	$CanvasLayer/ErrorDialog.popup_centered()

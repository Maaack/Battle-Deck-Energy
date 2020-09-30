extends AnimationQueue


var card_animation_map : Dictionary = {}

func animate_status(character_data:CharacterData, status_data:StatusData, delta:int, wait_time:float = 0.3, anim_type:int = 0):
	var animation_data : StatusAnimationData = StatusAnimationData.new()
	animation_data.character_data = character_data
	animation_data.status_data = status_data
	animation_data.delta = delta
	animation_data.animation_type = anim_type
	animation_data.wait_time = wait_time
	if not animation_data in animation_queue:
		animation_queue.append(animation_data)
	_start_timer(0)

func animate_move(card_data:CardData, new_transform:TransformData, tween_time:float = get_tween_time(), wait_time:float = get_wait_time(), anim_type:int = 0):
	var animation_data : CardAnimationData
	if card_data in card_animation_map and anim_type == card_animation_map[card_data].animation_type:
		animation_data = card_animation_map[card_data]
	else:
		animation_data = CardAnimationData.new()
	animation_data.card_data = card_data
	animation_data.transform_data = new_transform.duplicate()
	animation_data.tween_time = tween_time
	animation_data.animation_type = anim_type
	animation_data.wait_time = wait_time
	card_animation_map[card_data] = animation_data
	if not animation_data in animation_queue:
		animation_queue.append(animation_data)
	_start_timer(0)

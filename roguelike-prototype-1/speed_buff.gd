extends StatusEffect

const SPEED_MULTIPLIER = 1.5

func apply_effect():
	var rect = target.get_node_or_null("ColorRect")
	
	if rect != null:
		rect.color = Color.GREEN
	
	if target and "speed_modifier" in target:
		target.speed_modifier += SPEED_MULTIPLIER


func remove_effect():
	var rect = target.get_node_or_null("ColorRect")
	
	if rect != null:
		rect.color = Color.WHITE
		
	if target and "speed_modifier" in target:
		target.speed_modifier /= SPEED_MULTIPLIER

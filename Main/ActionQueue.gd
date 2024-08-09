extends HBoxContainer


func fill_queue(beat_actions):
	for ba in beat_actions:
		var texture_rect = TextureRect.new()
		texture_rect.size_flags_vertical = TextureRect.SIZE_SHRINK_CENTER
		texture_rect.texture = load(ba.icon)
		self.add_child(texture_rect)
	self.update()

func move_queue(beat):
	var tween = get_tree().create_tween()
	var ml = -12 * (beat % get_child_count())
	tween.tween_property(self, "margin_left", float(ml), 0.1)

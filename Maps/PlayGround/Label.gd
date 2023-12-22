extends Label



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	self.set_text("FPS " + String(Engine.get_frames_per_second()))

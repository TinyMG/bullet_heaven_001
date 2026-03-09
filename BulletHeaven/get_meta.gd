extends SceneTree

func _init():
	var file = FileAccess.open("res://assets/sprites/Gemini_Generated_Image_9luxps9luxps9lux.png", FileAccess.READ)
	var image = Image.new()
	image.load("res://assets/sprites/Gemini_Generated_Image_9luxps9luxps9lux.png")
	
	if image.is_empty():
		print("IMAGE LOAD FAILED")
	else:
		print("SIZE: ", image.get_width(), " x ", image.get_height())
		var bg_color = image.get_pixel(0, 0)
		print("BG COLOR: ", bg_color.r, " ", bg_color.g, " ", bg_color.b, " ", bg_color.a)
		
	quit()

@tool
extends SceneTree

# Natively generates the 4 audio files inside Godot to bypass OS limitations.

func _init() -> void:
	var out_dir = "res://assets/audio"
	
	_generate_shoot(out_dir + "/shoot.wav")
	_generate_hit(out_dir + "/hit.wav")
	_generate_level_up(out_dir + "/level_up.wav")
	_generate_game_over(out_dir + "/game_over.wav")
	
	print("Generations complete!")
	quit()

func _generate_shoot(path: String) -> void:
	var data = PackedByteArray()
	var num_samples = int(44100 * 0.1)
	for i in range(num_samples):
		var t = float(i) / 44100.0
		var freq = 800.0 * exp(-10.0 * t)
		var env = 1.0 - (float(i) / num_samples)
		var val = sin(2.0 * PI * freq * t) * 12000.0 * env
		data.append_array(_short_to_bytes(int(val)))
	_write_wav(path, data)

func _generate_hit(path: String) -> void:
	var data = PackedByteArray()
	var num_samples = int(44100 * 0.15)
	for i in range(num_samples):
		var env = exp(-20.0 * float(i) / num_samples)
		var val = randf_range(-1.0, 1.0) * 16000.0 * env
		data.append_array(_short_to_bytes(int(val)))
	_write_wav(path, data)

func _generate_level_up(path: String) -> void:
	var data = PackedByteArray()
	var num_samples = int(44100 * 0.6)
	var notes = [440.0, 554.37, 659.25, 880.0]
	for i in range(num_samples):
		var t = float(i) / 44100.0
		var note_idx = int(t / 0.15)
		if note_idx >= notes.size(): note_idx = notes.size() - 1
		var env = 1.0 - fmod(t, 0.15) / 0.15
		var val = sin(2.0 * PI * notes[note_idx] * t) * 12000.0 * env
		data.append_array(_short_to_bytes(int(val)))
	_write_wav(path, data)

func _generate_game_over(path: String) -> void:
	var data = PackedByteArray()
	var num_samples = int(44100 * 1.5)
	for i in range(num_samples):
		var t = float(i) / 44100.0
		var freq = 300.0 * exp(-1.5 * t)
		var env = 1.0
		if t > 1.0: env = 1.0 - ((t - 1.0) / 0.5)
		var val = sin(2.0 * PI * freq * t) * 12000.0 * env
		data.append_array(_short_to_bytes(int(val)))
	_write_wav(path, data)

func _short_to_bytes(val: int) -> PackedByteArray:
	var arr = PackedByteArray()
	arr.resize(2)
	arr.encode_s16(0, val)
	return arr

func _int_to_bytes(val: int) -> PackedByteArray:
	var arr = PackedByteArray()
	arr.resize(4)
	arr.encode_s32(0, val)
	return arr

func _write_wav(path: String, pcm_data: PackedByteArray) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		print("Failed to open " + path)
		return
		
	var sample_rate = 44100
	
	# RIFF
	file.store_string("RIFF")
	file.store_buffer(_int_to_bytes(36 + pcm_data.size()))
	file.store_string("WAVE")
	
	# FMT
	file.store_string("fmt ")
	file.store_buffer(_int_to_bytes(16))
	file.store_buffer(_short_to_bytes(1)) # PCM
	file.store_buffer(_short_to_bytes(1)) # Mono
	file.store_buffer(_int_to_bytes(sample_rate))
	file.store_buffer(_int_to_bytes(sample_rate * 2)) # Byte rate
	file.store_buffer(_short_to_bytes(2)) # Block align
	file.store_buffer(_short_to_bytes(16)) # Bits per sample
	
	# DATA
	file.store_string("data")
	file.store_buffer(_int_to_bytes(pcm_data.size()))
	file.store_buffer(pcm_data)
	
	file.close()
	print("Generated " + path)

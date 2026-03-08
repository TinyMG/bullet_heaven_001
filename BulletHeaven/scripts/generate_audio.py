import wave
import math
import struct
import os
import random

def generate_wav(filename, samples, sample_rate=44100):
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        # Convert float samples (-1.0 to 1.0) to 16-bit PCM
        pcm_data = bytearray()
        for sample in samples:
            # clip
            sample = max(-1.0, min(1.0, sample))
            pcm = int(sample * 32767)
            pcm_data.extend(struct.pack('<h', pcm))
        wav_file.writeframes(pcm_data)
    print(f"Generated {filename}")

out_dir = r"C:\Users\rnaci\Documents\Bullet_Hell_Game_NoTitle\BulletHeaven\assets\audio"
os.makedirs(out_dir, exist_ok=True)
sample_rate = 44100

# 1. Shoot (high blip)
shoot = []
duration = 0.1
num_samples = int(sample_rate * duration)
for i in range(num_samples):
    t = i / sample_rate
    freq = 1200.0 * math.exp(-20.0 * t)
    env = 1.0 - (i / num_samples)
    shoot.append(math.sin(2 * math.pi * freq * t) * 0.5 * env)
generate_wav(os.path.join(out_dir, "shoot.wav"), shoot)

# 2. Hit (noise)
hit = []
duration = 0.2
num_samples = int(sample_rate * duration)
for i in range(num_samples):
    env = math.exp(-25.0 * i / num_samples)
    val = random.uniform(-1.0, 1.0)
    hit.append(val * 0.8 * env)
generate_wav(os.path.join(out_dir, "hit.wav"), hit)

# 3. Level Up (arpeggio)
lvl = []
duration = 0.6
num_samples = int(sample_rate * duration)
notes = [440.0, 554.37, 659.25, 880.0]
for i in range(num_samples):
    t = i / sample_rate
    note_idx = int(t / 0.15)
    if note_idx >= len(notes): note_idx = len(notes) - 1
    env = 1.0 - ((t % 0.15) / 0.15)
    lvl.append(math.sin(2 * math.pi * notes[note_idx] * t) * 0.5 * env)
generate_wav(os.path.join(out_dir, "level_up.wav"), lvl)

# 4. Game Over (descending)
go = []
duration = 1.5
num_samples = int(sample_rate * duration)
for i in range(num_samples):
    t = i / sample_rate
    freq = 400.0 * math.exp(-1.5 * t)
    env = 1.0
    if t > 1.0: env = max(0.0, 1.0 - ((t - 1.0) / 0.5))
    val = sum(math.sin(2 * math.pi * freq * h * t) / h for h in [1, 2, 3]) # Simple saw-like
    go.append(val * 0.3 * env)
generate_wav(os.path.join(out_dir, "game_over.wav"), go)

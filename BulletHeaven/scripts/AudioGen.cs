using System;
using System.IO;

namespace AudioGen {
    class Program {
        static void WriteWav(string path, short[] samples, int sampleRate = 44100) {
            using (FileStream fs = new FileStream(path, FileMode.Create))
            using (BinaryWriter bw = new BinaryWriter(fs)) {
                // RIFF header
                bw.Write(new char[] { 'R', 'I', 'F', 'F' });
                bw.Write(36 + samples.Length * 2);
                bw.Write(new char[] { 'W', 'A', 'V', 'E' });

                // fmt chunk
                bw.Write(new char[] { 'f', 'm', 't', ' ' });
                bw.Write(16);
                bw.Write((short)1); // PCM
                bw.Write((short)1); // Mono
                bw.Write(sampleRate);
                bw.Write(sampleRate * 2); // Byte rate
                bw.Write((short)2); // Block align
                bw.Write((short)16); // Bits per sample

                // data chunk
                bw.Write(new char[] { 'd', 'a', 't', 'a' });
                bw.Write(samples.Length * 2);
                foreach (short sample in samples) {
                    bw.Write(sample);
                }
            }
            Console.WriteLine("Generated " + path);
        }

        static void Main() {
            int sampleRate = 44100;
            string outDir = @"C:\Users\rnaci\Documents\Bullet_Hell_Game_NoTitle\BulletHeaven\assets\audio";
            Directory.CreateDirectory(outDir);
            Random rand = new Random();

            // 1. Shoot (high blip)
            short[] shoot = new short[(int)(sampleRate * 0.1)];
            for (int i = 0; i < shoot.Length; i++) {
                double t = (double)i / sampleRate;
                double freq = 800.0 * Math.Exp(-10.0 * t);
                double env = 1.0 - ((double)i / shoot.Length);
                shoot[i] = (short)(Math.Sin(2 * Math.PI * freq * t) * 12000 * env);
            }
            WriteWav(Path.Combine(outDir, "shoot.wav"), shoot);

            // 2. Hit (noise)
            short[] hit = new short[(int)(sampleRate * 0.15)];
            for (int i = 0; i < hit.Length; i++) {
                double env = Math.Exp(-20.0 * i / hit.Length);
                double val = (rand.NextDouble() * 2 - 1);
                hit[i] = (short)(val * 16000 * env);
            }
            WriteWav(Path.Combine(outDir, "hit.wav"), hit);

            // 3. Level Up (arpeggio)
            short[] lvl = new short[(int)(sampleRate * 0.6)];
            double[] notes = { 440.0, 554.37, 659.25, 880.0 };
            for (int i = 0; i < lvl.Length; i++) {
                double t = (double)i / sampleRate;
                int noteIdx = (int)(t / 0.15);
                if (noteIdx >= notes.Length) noteIdx = notes.Length - 1;
                double env = 1.0 - ((t % 0.15) / 0.15);
                lvl[i] = (short)(Math.Sin(2 * Math.PI * notes[noteIdx] * t) * 12000 * env);
            }
            WriteWav(Path.Combine(outDir, "level_up.wav"), lvl);

            // 4. Game Over (descending)
            short[] go = new short[(int)(sampleRate * 1.5)];
            for (int i = 0; i < go.Length; i++) {
                double t = (double)i / sampleRate;
                double freq = 300.0 * Math.Exp(-1.5 * t);
                double env = t > 1.0 ? 1.0 - ((t - 1.0) / 0.5) : 1.0;
                go[i] = (short)(Math.Sin(2 * Math.PI * freq * t) * 12000 * env);
            }
            WriteWav(Path.Combine(outDir, "game_over.wav"), go);
        }
    }
}

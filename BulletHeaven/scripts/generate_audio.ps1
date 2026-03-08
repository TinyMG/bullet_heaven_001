$outDir = "C:\Users\rnaci\Documents\Bullet_Hell_Game_NoTitle\BulletHeaven\assets\audio"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }

function Write-WavFile {
    param([string]$Path, [int16[]]$Samples, [int]$SampleRate=44100)
    $file = [System.IO.File]::Create($Path)
    $writer = New-Object System.IO.BinaryWriter($file)
    
    # RIFF header
    $writer.Write([char[]]"RIFF")
    $writer.Write([int]($Samples.Length * 2 + 36))
    $writer.Write([char[]]"WAVE")
    
    # fmt subchunk
    $writer.Write([char[]]"fmt ")
    $writer.Write([int]16)
    $writer.Write([int16]1) # PCM
    $writer.Write([int16]1) # Mono
    $writer.Write([int]$SampleRate)
    $writer.Write([int]($SampleRate * 2)) # Byte rate
    $writer.Write([int16]2) # Block align
    $writer.Write([int16]16) # Bits per sample
    
    # data subchunk
    $writer.Write([char[]]"data")
    $writer.Write([int]($Samples.Length * 2))
    foreach($sample in $Samples) { $writer.Write([int16]$sample) }
    
    $writer.Close()
    $file.Close()
    Write-Host "Generated $Path"
}

# 1. Shoot (short high pitch noise/square)
$shootSamples = New-Object int16[] (44100 * 0.1)
for($i=0; $i -lt $shootSamples.Length; $i++) {
    $t = $i / 44100.0
    $freq = 800 * [math]::Pow(0.1, $t * 10)
    $val = [math]::Sin(2 * [math]::PI * $freq * $t)
    # envelope
    $env = 1.0 - ($i / $shootSamples.Length)
    $shootSamples[$i] = [int16]($val * 10000 * $env)
}
Write-WavFile "$outDir\shoot.wav" $shootSamples

# 2. Hit (low noise)
$rand = New-Object Random
$hitSamples = New-Object int16[] (44100 * 0.2)
for($i=0; $i -lt $hitSamples.Length; $i++) {
    $env = [math]::Exp(-20.0 * $i / $hitSamples.Length)
    $val = ($rand.NextDouble() * 2 - 1)
    $hitSamples[$i] = [int16]($val * 15000 * $env)
}
Write-WavFile "$outDir\hit.wav" $hitSamples

# 3. Level Up (rising arpeggio)
$lvlSamples = New-Object int16[] (44100 * 0.6)
$notes = @(440.0, 554.37, 659.25, 880.0) # A major arpeggio
for($i=0; $i -lt $lvlSamples.Length; $i++) {
    $t = $i / 44100.0
    $noteIdx = [math]::Floor($t / 0.15)
    if ($noteIdx -ge $notes.Length) { $noteIdx = $notes.Length - 1 }
    $freq = $notes[$noteIdx]
    $val = [math]::Sin(2 * [math]::PI * $freq * $t)
    $env = 1.0 - (($t % 0.15) / 0.15)
    $lvlSamples[$i] = [int16]($val * 12000 * $env)
}
Write-WavFile "$outDir\level_up.wav" $lvlSamples

# 4. Game Over (descending tone)
$goSamples = New-Object int16[] (44100 * 1.5)
for($i=0; $i -lt $goSamples.Length; $i++) {
    $t = $i / 44100.0
    $freq = 300 * [math]::Exp(-1.5 * $t)
    $val = [math]::Sin(2 * [math]::PI * $freq * $t)
    $env = 1.0
    if ($t -gt 1.0) { $env = 1.0 - (($t - 1.0) / 0.5) }
    $goSamples[$i] = [int16]($val * 12000 * $env)
}
Write-WavFile "$outDir\game_over.wav" $goSamples

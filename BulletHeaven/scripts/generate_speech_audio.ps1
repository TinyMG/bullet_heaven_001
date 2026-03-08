Add-Type -AssemblyName System.Speech

$outDir = "C:\Users\rnaci\Documents\Bullet_Hell_Game_NoTitle\BulletHeaven\assets\audio"
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$synth.Rate = 2

function SayToWav {
    param([string]$Filename, [string]$Text)
    $path = "$outDir\$Filename"
    $synth.SetOutputToWaveFile($path)
    $synth.Speak($Text)
    $synth.SetOutputToDefaultAudioDevice()
    Write-Host "Generated $path"
}

SayToWav "shoot.wav" "pew"
SayToWav "hit.wav" "oof"
$synth.Rate = 0
SayToWav "level_up.wav" "Level Up!"
$synth.Rate = -2
SayToWav "game_over.wav" "Game Over..."

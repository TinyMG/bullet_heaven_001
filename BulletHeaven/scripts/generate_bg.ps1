Add-Type -AssemblyName System.Drawing

$outDir = "C:\Users\rnaci\Documents\Bullet_Hell_Game_NoTitle\BulletHeaven\assets\sprites"
$Filename = "$outDir\bg_stars.png"
$Width = 256
$Height = 256

$bmp = New-Object System.Drawing.Bitmap($Width, $Height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::FromArgb(255, 10, 15, 25))

$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$rand = New-Object System.Random

# Draw some random stars
for ($i = 0; $i -lt 50; $i++) {
    $x = $rand.Next(0, $Width)
    $y = $rand.Next(0, $Height)
    $size = $rand.Next(1, 3)
    
    # Dimmer stars sometimes
    if ($rand.Next(0, 100) -lt 30) {
        $b = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120, 200, 200, 255))
        $g.FillRectangle($b, $x, $y, $size, $size)
        $b.Dispose()
    } else {
        $g.FillRectangle($brush, $x, $y, $size, $size)
    }
}

$brush.Dispose()
$g.Dispose()
$bmp.Save($Filename, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "Generated $Filename"

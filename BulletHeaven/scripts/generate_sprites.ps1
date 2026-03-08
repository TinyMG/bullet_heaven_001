Add-Type -AssemblyName System.Drawing

$outDir = "C:\Users\rnaci\Documents\Bullet_Hell_Game_NoTitle\BulletHeaven\assets\sprites"
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}

function Create-Sprite {
    param (
        [string]$Filename,
        [int]$Width,
        [int]$Height,
        [string]$Shape
    )

    $bmp = New-Object System.Drawing.Bitmap($Width, $Height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

    if ($Shape -eq 'player') {
        # Cyan ship
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 25, 178, 230))
        $pts = @(
            (New-Object System.Drawing.PointF(($Width/2), 0)),
            (New-Object System.Drawing.PointF($Width, ($Height/3))),
            (New-Object System.Drawing.PointF($Width, $Height)),
            (New-Object System.Drawing.PointF(0, $Height)),
            (New-Object System.Drawing.PointF(0, ($Height/3)))
        )
        $g.FillPolygon($brush, $pts)
        
        # Dark Blue Cockpit
        $cockpitBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 13, 77, 128))
        $g.FillEllipse($cockpitBrush, [float]($Width/3), [float]($Height/4), [float]($Width/3), [float]($Height/2))
        
        $brush.Dispose()
        $cockpitBrush.Dispose()
    }
    elseif ($Shape -eq 'enemy') {
        # Red spike
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 230, 51, 26))
        $pts = @(
            (New-Object System.Drawing.PointF(($Width/2), 0)),
            (New-Object System.Drawing.PointF($Width, ($Height/2))),
            (New-Object System.Drawing.PointF(($Width/2), $Height)),
            (New-Object System.Drawing.PointF(0, ($Height/2)))
        )
        $g.FillPolygon($brush, $pts)
        
        # Yellow eye
        $eyeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 230, 0))
        $g.FillRectangle($eyeBrush, [float]($Width/3), [float]($Height/3), [float]($Width/3), [float]($Height/3))
        
        $brush.Dispose()
        $eyeBrush.Dispose()
    }
    elseif ($Shape -eq 'projectile') {
        # Light blue bolt
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 102, 217, 255))
        $pts = @(
            (New-Object System.Drawing.PointF(($Width/2), 0)),
            (New-Object System.Drawing.PointF($Width, ($Height/2))),
            (New-Object System.Drawing.PointF(($Width/2), $Height)),
            (New-Object System.Drawing.PointF(0, ($Height/2)))
        )
        $g.FillPolygon($brush, $pts)
        $brush.Dispose()
    }
    elseif ($Shape -eq 'xp_gem') {
        # Green diamond
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 38, 230, 77))
        $pts = @(
            (New-Object System.Drawing.PointF(($Width/2), 0)),
            (New-Object System.Drawing.PointF($Width, ($Height/2))),
            (New-Object System.Drawing.PointF(($Width/2), $Height)),
            (New-Object System.Drawing.PointF(0, ($Height/2)))
        )
        $g.FillPolygon($brush, $pts)
        $brush.Dispose()
    }

    $g.Dispose()
    $bmp.Save($Filename, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Generated $Filename"
}

Create-Sprite -Filename "$outDir\player.png" -Width 32 -Height 32 -Shape "player"
Create-Sprite -Filename "$outDir\enemy.png" -Width 24 -Height 24 -Shape "enemy"
Create-Sprite -Filename "$outDir\projectile.png" -Width 16 -Height 8 -Shape "projectile"
Create-Sprite -Filename "$outDir\xp_gem.png" -Width 12 -Height 12 -Shape "xp_gem"

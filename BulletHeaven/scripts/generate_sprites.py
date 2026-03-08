import os
from PIL import Image, ImageDraw

def create_sprite(filename, size, shape, color, bg_alpha=0):
    img = Image.new('RGBA', size, (0, 0, 0, bg_alpha))
    draw = ImageDraw.Draw(img)
    w, h = size
    
    if shape == 'player':
        # Hexagon/ship shape
        points = [(w//2, 0), (w, h//3), (w, h), (0, h), (0, h//3)]
        draw.polygon(points, fill=(25, 178, 230, 255))
        # cockpit
        draw.ellipse([w//3, h//4, w - w//3, h//2 + 2], fill=(13, 77, 128, 255))
    elif shape == 'enemy':
        # Spiky diamond
        points = [(w//2, 0), (w, h//2), (w//2, h), (0, h//2)]
        draw.polygon(points, fill=(230, 51, 26, 255))
        # evil eye
        draw.rectangle([w//3, h//3, w - w//3, h//2], fill=(255, 230, 0, 255))
    elif shape == 'projectile':
        # Long energy bolt
        draw.polygon([(w//2, 0), (w, h//2), (w//2, h), (0, h//2)], fill=(102, 217, 255, 255))
    elif shape == 'xp_gem':
        # Small diamond
        draw.polygon([(w//2, 0), (w, h//2), (w//2, h), (0, h//2)], fill=(38, 230, 77, 255))
        
    img.save(filename)
    print(f"Generated {filename}")

if __name__ == "__main__":
    out_dir = "assets/sprites"
    os.makedirs(out_dir, exist_ok=True)
    
    create_sprite(f"{out_dir}/player.png", (32, 32), 'player', None)
    create_sprite(f"{out_dir}/enemy.png", (24, 24), 'enemy', None)
    create_sprite(f"{out_dir}/projectile.png", (16, 8), 'projectile', None)
    create_sprite(f"{out_dir}/xp_gem.png", (12, 12), 'xp_gem', None)

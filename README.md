# Rune Storm (Bullet Heaven)

A mobile-targeted **Bullet Heaven** game (Vampire Survivors style) built in **Godot 4.6 (GL Compatibility)**. Features a world map with node-based progression, wave-based combat, an upgrade system, and boss encounters.

## Requirements

- **Godot Engine 4.6** (GL Compatibility renderer) — [download](https://godotengine.org/download)
- **Node.js v18+** (only if using the Godot MCP server for AI tooling)

## Running the Game

1. Open Godot 4.6 and import `BulletHeaven/project.godot`
2. Press **F5** to run — entry scene is `UI/MainMenu.tscn`

## Controls

| Input | Action |
|-------|--------|
| WASD / Arrow keys | Move (8-directional) |
| Shift (hold) | Boost speed (1.5x) |
| Escape | Pause menu |
| Auto-fire | Shoots nearest enemy within range automatically |

## Game Flow

```
MainMenu → World Map → Select Node → Combat (finite waves) → Stage Complete → World Map
                                                            → Game Over → World Map
```

## Architecture

### Autoloads (Global Singletons)

| Autoload | File | Purpose |
|----------|------|---------|
| **GameManager** | `Autoloads/game_manager.gd` | Game state: score, XP, level, kills, elapsed time, game over logic |
| **SkillsManager** | `Autoloads/skills_manager.gd` | 8 upgrade skills with ranks, random upgrade selection |
| **AudioManager** | `Autoloads/AudioManager.tscn` | Centralized SFX playback (shoot, hit, level up, game over) |
| **ProgressManager** | `Autoloads/progress_manager.gd` | World map progress: completed nodes, current node selection |

### Scene Tree (Main.tscn)

```
Main (Node2D)
├── ParallaxBackground / ParallaxLayer / Sprite2D (star field)
├── Camera2D (reparented onto Player at runtime, with ScreenShake component)
├── Player (CharacterBody2D)
├── WaveManager (Node + SpawnTimer, reads map node config)
├── HUD (CanvasLayer — score, HP bar, XP bar, level, timer, wave counter, kills)
├── LevelUpPanel (CanvasLayer — pauses game, shows 3 upgrade choices)
├── GameOverPanel (CanvasLayer — death stats, restart or return to map)
├── WaveCompletePanel (CanvasLayer — victory stats, continue to map)
├── PauseMenu (CanvasLayer — resume or quit to menu)
└── BossHPBar (CanvasLayer — bottom-center boss health bar)
```

### World Map System

- **MapNodeData** (`Data/map_node_data.gd`) — Resource class defining each map node: waves, enemies, difficulty, unlock requirements
- **WorldMapConfig** (`Data/world_map_config.gd`) — Resource holding all nodes and their connections
- Node `.tres` files live in `Data/Nodes/` and are inspector-editable
- Nodes unlock progressively (each node can require completion of other nodes)

### Current Map Nodes

| Node ID | Name | Waves | Difficulty | Boss | Requires |
|---------|------|-------|------------|------|----------|
| forest_01 | Dark Thicket | 3 | Normal | No | — |
| forest_02 | Hollow Glen | 4 | Medium | No | forest_01 |
| forest_boss | Ancient Hollow | 5 | Hard | Yes | forest_02 |

### Physics Layers

| Layer | Name | Used by |
|-------|------|---------|
| 1 | Player | Player body |
| 2 | Enemy | Enemy bodies, hitbox areas |
| 3 | Projectile | Projectile Area2D |
| 4 | Pickup | XP Gem Area2D |

### Node Groups

| Group | Purpose |
|-------|---------|
| `Player` | The player node |
| `Enemy` | All active enemies |
| `EnemyHitbox` | Enemy hitbox Area2D (for player hurtbox collision) |
| `Projectile` | All active projectiles |
| `XPGem` | All active XP gems |

### Upgrade Skills (8 total)

| Skill | Max Rank | Effect per Rank |
|-------|----------|-----------------|
| Fire Rate | 5 | +15% faster |
| Damage | 5 | +5 damage |
| Move Speed | 5 | +20 speed |
| Pickup Radius | 5 | +15px radius |
| Max HP | 5 | +10 HP |
| Multishot | 4 | +1 projectile |
| HP Regen | 5 | +1 HP/sec |
| Pierce | 3 | +1 pierce |

### Key Systems

- **Auto-fire**: Player targets nearest enemy within 500px, fires spread multishot based on skill rank
- **Wave Manager**: Reads `ProgressManager.current_node` for finite wave config; falls back to infinite mode if null
- **Boss**: Spawns on final wave (finite mode) or every 10s (infinite mode). 50 score, 3x death particles, screen flash + shake
- **Sprite Animation**: Player uses 10x4 sprite sheet (idle/run/shoot/boost rows). Enemies use 6x15 sheet with randomized start frame
- **Screen Shake**: Dynamically attached to Camera2D at runtime
- **I-frames**: 1s invincibility with blink effect after taking damage

## Project Structure

```
BulletHeaven/
├── Autoloads/          # Global singletons
├── Components/         # Reusable components (wave_manager, screen_shake)
├── Data/               # Resource classes and .tres node data
│   └── Nodes/          # Individual map node resources + world_map config
├── Entities/
│   ├── DamageNumber/   # Floating damage text
│   ├── Effects/        # Death particles
│   ├── Enemy/          # Enemy + BossEnemy scenes
│   ├── Player/         # Player scene + chroma key shader
│   ├── Projectile/     # Projectile scene
│   └── XPGem/          # XP pickup
├── Scenes/             # Main gameplay scene
├── UI/                 # All UI scenes (menus, HUD, panels, world map)
├── assets/
│   ├── audio/          # Procedurally generated WAV files
│   └── sprites/        # Sprite sheets and textures
├── scripts/            # Utility/tool scripts (audio generation)
└── project.godot
```

## Godot MCP Server

The `godot-mcp/` directory is a Node.js MCP server for AI tool integration.

```bash
# Set environment variable for Godot path
export GODOT_PATH="/path/to/Godot_v4.6-stable"

# Run the MCP server
node godot-mcp/build/index.js
```

The project includes a `.claude/settings.json` that configures this automatically for Claude Code.

## License

MIT License.

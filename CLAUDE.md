# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running the Game

This is a **Godot 4.6 (GL Compatibility)** project. There is no CLI build system — all development is done through the Godot Editor:

1. Open Godot Engine 4.6 and import `BulletHeaven/project.godot`.
2. Press **F5** (or the Play button) to run. The entry scene is `UI/MainMenu.tscn`.
3. The main gameplay scene is `Scenes/Main.tscn`.

The `godot-mcp/` directory is a separate Node.js MCP server for AI tool integration. Run it with `node godot-mcp/build/index.js` if needed.

## Architecture Overview

### Autoloads (Global Singletons)
Three autoloads are registered in `project.godot` and accessible everywhere by name:

- **`GameManager`** (`Autoloads/game_manager.gd`) — Owns all global game state: `score`, `current_xp`, `current_level`, `elapsed_time`, `total_kills`, `total_damage_dealt`, `is_game_over`, and a reference to the `player` node. Emits `score_changed`, `game_over`, and `player_leveled_up` signals. Call `GameManager.reset()` on restart.
- **`SkillsManager`** (`Autoloads/skills_manager.gd`) — Holds the upgrade skill dictionary (8 skills, each with `current_rank`/`max_rank`/`effect_per_rank`). Use `SkillsManager.get_skill_value(skill_name)` to get the cumulative stat bonus anywhere. Emits `skill_upgraded`. Call `SkillsManager.reset_all()` on restart.
- **`AudioManager`** (`Autoloads/AudioManager.tscn` + `audio_manager.gd`) — Centralized sound playback (`play_shoot()`, `play_hit()`, `play_level_up()`, `play_game_over()`). Lives as an autoload so sounds aren't cut off when entities that triggered them are freed.

### Scene/Entity Flow
```
MainMenu.tscn  →  (start game)  →  Main.tscn
                                      ├── Player.tscn        (CharacterBody2D)
                                      ├── Camera2D           (reparented onto Player at runtime)
                                      ├── WaveManager        (Node with SpawnTimer, spawns enemies/boss)
                                      ├── HUD.tscn           (CanvasLayer)
                                      ├── LevelUpPanel.tscn  (CanvasLayer, pauses game on level-up)
                                      ├── GameOverPanel.tscn (CanvasLayer, shown on death)
                                      └── BossHPBar.tscn     (CanvasLayer)
```
Enemies, projectiles, XP gems, damage numbers, and death effects are all spawned dynamically into `get_tree().current_scene` (i.e., `Main.tscn`) at runtime.

### Physics Layers
| Layer | Name | Used by |
|-------|------|---------|
| 1 | Player | Player body |
| 2 | Enemy | Enemy bodies |
| 3 | Projectile | Projectile Area2D |
| 4 | Pickup | XPGem Area2D |

### Node Groups
Nodes are found at runtime via groups rather than direct references:
- `"Player"` — the player node
- `"Enemy"` — all active enemy nodes
- `"EnemyHitbox"` — enemy hitbox Area2D (used by player hurtbox collision)
- `"Projectile"` — all active projectiles
- `"XPGem"` — all active XP gems

### Key Gameplay Systems

**Player auto-fire**: `player.gd` fires at the nearest enemy within 500px via a `FireTimer`. Spread multishot is calculated around the base direction. Skill values are read from `SkillsManager` on each shot and on `skill_upgraded` signal.

**Wave scaling**: `WaveManager` spawns `base_enemies_per_wave + int(current_wave * 0.5)` enemies per wave. Enemy HP scales as `20 + (wave * 2)`. Boss spawns every 10 seconds if no boss is alive.

**Upgrade loop**: `GameManager.add_xp()` handles level-up via a `while` loop for multi-level XP. On `player_leveled_up`, `LevelUpPanel` pauses the tree and calls `SkillsManager.get_random_upgrades(3)` to populate choices.

**Screen shake**: A `screen_shake.gd` component is dynamically attached to the Camera2D child in `main.gd`. Call `child.shake(intensity, duration)` via the camera's children (see `player.gd:take_damage`).

**Sprite animation**: Player sprite uses a 6×15 frame sprite sheet (10 frames per row); rows map to `AnimState` enum: 0=IDLE, 1=RUN, 2=SHOOT, 3=BOOST. Enemy sprites use 6 frames per walk row, randomizing start frame on spawn.

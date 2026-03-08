# Bullet Heaven

A simple, fast-paced "Bullet Heaven" style 2D game built in **Godot 4.6**. The player embodies a ship fighting endlessly spawning waves of enemies, collecting XP to level up, and picking upgrades.

## Project Structure

This repository contains two main projects:
- `BulletHeaven/` : The actual Godot game client and codebase.
- `godot-mcp/` : An experimental LLM Context Protocol (MCP) server used to interface AI tools with the Godot Engine development pipeline.

## Dependencies

To run the game, you will need:
- **Godot Engine 4.6 (GL Compatibility Mode)** or higher.

To run the local MCP Node Server, you will need:
- **Node.js** v18+

## How to Play

1. Download and install [Godot Engine 4.6](https://godotengine.org/download) (or your local build version).
2. Open Godot and select **Import**.
3. Navigate to the `BulletHeaven/project.godot` file in this repository.
4. Hit **Play** (or F5) in the editor to start the game!

### Controls
* **WASD** to move.
* **ESC** to pause the game.
* **Auto-fire:** Your ship will automatically seek and shoot enemies within range.

## Development Features & Codebase

The game utilizes the following custom systems for ease of development:
- **WaveManager:** Spawns increasingly difficult waves of enemies infinitely based on the current time and level.
- **AudioManager:** Global sound effect Autoload managing retro-style synthesized sound effects natively to bypass audio truncation on entity death.
- **GameManager / SkillsManager:** Global singletons managing player states, XP accumulation, levels, and upgrade choices.
- **Procedurally Sliced Sprite-sheets:** Logic in `player.gd` randomly iterates through a 6x12 frame sprite array while moving.

## License
MIT License.

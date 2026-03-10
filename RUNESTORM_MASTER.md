# RUNESTORM — Master Game Bible & Claude Code Prompt Library

> **How to use this file:**
> Place `RUNESTORM_MASTER.md` in your Godot project root folder.
> At the start of every Claude Code session, reference it with:
> `Read @RUNESTORM_MASTER.md before we start. This is the game design bible and prompt library for this project.`

---

## TABLE OF CONTENTS

1. [Game Overview](#1-game-overview)
2. [Complete Mechanics List](#2-complete-mechanics-list)
3. [World Map & Node Design](#3-world-map--node-design)
4. [Monster Drops & Crafting Recipes](#4-monster-drops--crafting-recipes)
5. [Claude Code Prompt Library](#5-claude-code-prompt-library)
6. [Recommended Build Order](#6-recommended-build-order)
7. [Transition Guide](#7-transition-guide)
8. [Session Rules](#8-session-rules)
9. [Multi-Agent Setup](#9-multi-agent-setup)

---

# 1. GAME OVERVIEW

**Rune Storm** is a mobile-first bullet heaven game where players explore a hand-crafted world map, unlock combat nodes using crafted Runes, and survive escalating waves of monsters — collecting drops to craft more powerful Runes and gear.

## Core Fantasy
> *"I need just 3 more Wolf Fangs to craft that Rune and unlock the next region."*

That pull — always one drop away from progress — is the addiction engine of the game.

## Platform
- **Primary:** Mobile (Android + iOS)
- **Target:** 60fps on mid-range devices
- **Engine:** Godot 4.6 (GL Compatibility)

## The Full Game Loop

```
WORLD MAP  →  Choose a Node  →  Insert Rune to Unlock
     ↓
COMBAT NODE  →  Survive Waves  →  Kill Monsters
     ↓
DROPS COLLECTED  →  Craft Runes & Gear  →  Back to Map
     ↓
HARDER NODES  →  Rarer Drops  →  Stronger Builds
```

## Progression Model
- **Map unlocks:** Permanent (nodes stay unlocked forever)
- **Wave modifiers:** Reset on each visit
- **Inventory:** Persistent across all sessions
- **Runes:** Consumed on node entry (one-time use key)

---

# 2. COMPLETE MECHANICS LIST

Every system needed to complete the game loop, ordered by priority.

## CORE (Must work before anything else)

| System | Description |
|---|---|
| Player Movement | 8-directional touch joystick. Mobile optimized virtual thumbstick. |
| Auto-Attack System | Player automatically fires at nearest enemy. Stats scale with gear. |
| Enemy Spawner | Wave-based spawner. Increasing enemy count and speed per wave. Spawns from edges. |
| Enemy AI | Enemies move toward player. Different types have different speeds, HP, behaviors. |
| Collision System | Bullet-enemy collision deals damage. Enemy-player contact drains HP. Circle colliders only. |
| HP System | Player and enemies have HP. Player death triggers run-end screen. Enemy death triggers drops + XP. |
| XP & Level Up | Enemies drop XP orbs. On level up, pause and offer 3 random stat upgrades. |
| Wave Completion | After N waves, show results screen with drops. Return to world map. |

## HIGH (Core game loop depends on these)

| System | Description |
|---|---|
| Monster Drop System | Each enemy has a loot table. On death, spawn collectible item. Player auto-collects by proximity. |
| Inventory System | Stores crafting materials. Persistent across sessions. Shows item name + count. |
| World Map | Hand-crafted map with regions and nodes. Tap to view info. Shows locked/unlocked state. |
| Node System | Each node has: required Rune, wave count, enemy types, modifier data. |
| Rune Unlock System | Player selects node → check inventory for correct Rune → consume Rune → node unlocked. |
| Crafting System | Crafting menu shows all recipes. Grayed out if missing materials. Materials consumed on craft. |
| Rune Item Type | Special craftable items used as node keys. Multiple Rune tiers. |

## MEDIUM (Important but not blocking)

| System | Description |
|---|---|
| Wave Modifiers | Per-node: enemy speed, HP multiplier, spawn rate, special enemy chance. Reset per visit. |
| Boss Waves | Final wave of boss nodes spawns a Boss. Unique drop with higher craft value. |
| Region Unlock | Clearing a Boss node drops a Region Rune that unlocks the next map region. |
| HUD | In-combat: player HP bar, wave number, timer, material counters for current run. |
| Crafting UI | Mobile-friendly panel. Recipe icon, required materials, current count, craft button. |
| Save System | Auto-save: map state, inventory, unlocked nodes. Uses Godot FileAccess. |
| Node Modifiers (Player Choice) | Before entering a node, player can optionally add difficulty modifiers for better loot. |
| Equipment Slots | Player has weapon + armor slots. Crafted gear equips here and changes stats. |

## POLISH (After everything else works)

| System | Description |
|---|---|
| Particle Effects | Death particles, drop sparkle, level-up burst, Rune insertion glow. Minimal for mobile. |
| Screen Shake | Light shake on player hit, bigger shake on boss death. |
| Audio System | SFX: shoot, hit, death, collect, craft, level up. BGM per region. |
| Main Menu | Start, Continue, Settings. Animated logo. |
| Settings Screen | Volume sliders, graphics quality toggle, control sensitivity. |
| Node Preview Screen | Before entering: shows enemy types, wave count, modifiers, required Rune, expected drops. |
| Rune Collection Screen | Gallery of all Runes. Locked/crafted/used states. Acts as soft tutorial. |
| Achievement System | Simple milestones. Minor rewards. |

---

# 3. WORLD MAP & NODE DESIGN

## Region Structure

5 regions, each with 6 standard nodes + 1 boss node. Regions unlock sequentially.

| Region | Theme | Enemy Types | How to Unlock |
|---|---|---|---|
| Region 1 | Ashwood Forest | Slimes, Wolves, Goblins | Unlocked by default |
| Region 2 | Frostpeak Tundra | Ice Wraiths, Frost Bears, Yetis | Rune of the Wild (Region 1 Boss drop) |
| Region 3 | Emberveil Ruins | Fire Elementals, Magma Golems | Rune of the Glacier (Region 2 Boss drop) |
| Region 4 | Shadow Depths | Shadow Stalkers, Void Spawn | Rune of Embers (Region 3 Boss drop) |
| Region 5 | The Rune Nexus | All types + Hybrid Elites | Rune of Shadows (Region 4 Boss drop) |

## How Nodes Work

- Each node has a **required Rune** to unlock
- Player taps locked node → sees "Requires [Rune Name]"
- Player taps unlocked node → sees wave info → taps Enter
- Rune is **consumed** on entry (one-time use)
- Node stays **permanently unlocked** after first entry
- Wave **modifiers reset** on each visit

---

# 4. MONSTER DROPS & CRAFTING RECIPES

## Monster Drop Table

| Monster | Region | Drop Item | Drop Rate |
|---|---|---|---|
| Slime | R1 | Slime Gel | 80% / 1-3 per kill |
| Wolf | R1 | Wolf Fang | 65% / 1-2 per kill |
| Goblin | R1 | Goblin Shard | 50% / 1 per kill |
| Alpha Wolf (Boss) | R1 | Ancient Fang | 100% / 3-5 per kill |
| Ice Wraith | R2 | Frost Wisp | 75% / 1-2 per kill |
| Frost Bear | R2 | Frozen Claw | 60% / 1 per kill |
| Yeti (Boss) | R2 | Yeti Heart | 100% / 2-4 per kill |
| Fire Elemental | R3 | Ember Core | 70% / 1-2 per kill |
| Magma Golem (Boss) | R3 | Magma Crystal | 100% / 2-3 per kill |
| Shadow Stalker | R4 | Void Essence | 65% / 1 per kill |
| Void Boss | R4 | Void Crown | 100% / 1-2 per kill |

## Crafting Recipes

| Crafted Item | Type | Recipe |
|---|---|---|
| Rune of Ash | Node Key | 5x Slime Gel + 3x Wolf Fang |
| Rune of Stone | Node Key | 4x Wolf Fang + 4x Goblin Shard |
| Rune of the Wild | Region Key | 5x Ancient Fang + 6x Goblin Shard + 3x Slime Gel |
| Rune of Frost | Node Key | 5x Frost Wisp + 3x Frozen Claw |
| Rune of the Glacier | Region Key | 4x Yeti Heart + 8x Frost Wisp + 4x Frozen Claw |
| Rune of Embers | Node Key | 6x Ember Core + 4x Magma Crystal |
| Rune of Shadows | Region Key | 5x Magma Crystal + 8x Ember Core |
| Iron Fang Blade | Weapon | 6x Wolf Fang + 4x Goblin Shard |
| Slime Shield | Armor | 8x Slime Gel + 2x Ancient Fang |
| Frost Bow | Weapon | 5x Frost Wisp + 4x Frozen Claw + 2x Yeti Heart |
| Void Mantle | Armor | 6x Void Essence + 3x Void Crown |

---

# 5. CLAUDE CODE PROMPT LIBRARY

> **Instructions:** Copy each prompt block exactly as written and paste into Claude Code.
> Always run the **SESSION OPENER** first at the start of every session before any other prompt.

---

## ⚡ SESSION OPENER — Run This Every Single Session

```
Read my entire Godot project before we do anything.
Understand all existing scenes, scripts, autoloads, and how they connect.
Do NOT modify anything yet.
Briefly tell me:
  1. What the current state of the project is
  2. Any issues you notice at a glance
Then wait for my instruction.
```

---

## PHASE 0 — Bug Fixes (Run Before Any New Features)

### PROMPT 00 — Fix Known Bugs

```
Before we add any new systems, fix these bugs from the audit:

1. Fix EnemyDeathEffect — the ParticleProcessMaterial is malformed
   and never spawned. Fix the .tscn so the process_material is
   correctly assigned, then call it from enemy.gd _die() so enemies
   have a death particle effect.

2. Fix boss death — boss should give bonus score (50 points instead
   of 10), play a bigger death effect, and have a distinct screen
   flash moment.

3. Fix Quit button in GameOverPanel — should return to MainMenu
   scene instead of quitting the app entirely.

4. Remove dead code — clean up the unused area_entered connection
   in projectile.gd.

Fix these one at a time and tell me when each is done.
Do NOT touch anything else.
```

---

## PHASE 1 — Combat Core Improvements

### PROMPT 01 — Object Pooling

```
Read my project first.
My game spawns bullets and enemies constantly.
Implement object pooling for:
- Player bullets (pool size: 100)
- Enemy projectiles (pool size: 50)
- Enemies (pool size: 80)
- Drop items (pool size: 60)
Use a single PoolManager autoload node.
Do NOT instantiate during gameplay - always pull from pool.
This is for mobile - performance is critical.
```

### PROMPT 02 — Wave Spawner System

```
Read my project first.
Build a WaveSpawner system that:
- Reads wave data from a dictionary (wave number → enemy types + counts)
- Spawns enemies from screen edges only (not center)
- Has a delay between each spawn (0.3 seconds)
- Emits a signal when all enemies in a wave are dead
- Shows "Wave X" text briefly when wave starts
- Scales enemy HP and speed by 8% per wave
Make wave data easy to edit as a dictionary at the top of the script.
```

### PROMPT 03 — XP & Level Up

```
Read my project first.
Add an XP and level up system:
- Enemies drop XP orbs that float toward the player automatically within 150px
- XP required per level follows this curve: level * 80 + 40
- On level up, PAUSE the game and show 3 random upgrade cards
- Upgrade options: +15% damage, +10% attack speed, +20% max HP,
  +15% move speed, +1 piercing bullet, +25% pickup radius
- Each card shows an icon placeholder, name, and description
- Player picks one, game resumes
- Show current level and XP bar in HUD
```

---

## PHASE 2 — Monster Drops & Inventory

### PROMPT 04 — Monster Loot Tables

```
Read my project first.
Add a loot table system to enemies:
- Each enemy scene has a 'loot_table' exported variable (array of dicts)
- Each dict has: item_id (String), item_name (String),
  drop_chance (float 0-1), min_qty (int), max_qty (int)
- Example: {item_id: "wolf_fang", item_name: "Wolf Fang",
  drop_chance: 0.65, min_qty: 1, max_qty: 2}
- On enemy death, roll each item separately
- Spawn a DropItem scene at death position for each successful roll
- DropItem shows a colored circle with item initial as placeholder art

Set up loot tables for:
- Slime → Slime Gel (80% / 1-3)
- Wolf → Wolf Fang (65% / 1-2)
- Goblin → Goblin Shard (50% / 1)
- Boss → Ancient Fang (100% / 3-5)
```

### PROMPT 05 — Auto-Collect & Inventory

```
Read my project first.
Build the inventory and collection system:
- DropItems within 120px of player are auto-collected (no tap needed)
- An Inventory autoload stores: Dictionary of item_id → quantity
- Inventory persists using Godot's FileAccess (save to user://inventory.json)
- Show a small HUD panel in bottom-left during combat:
  item icon + count for items collected THIS run
- After wave completion, merge run drops into persistent inventory
- Inventory is never lost on death - only Runes are consumed on node entry
```

---

## PHASE 3 — Crafting System

### PROMPT 06 — Recipe Database

```
Read my project first.
Create a CraftingRecipes autoload with all recipes as a dictionary.
Each recipe has:
- result_id: String
- result_name: String
- result_type: String ("node_key", "region_key", "weapon", "armor")
- ingredients: Array of {item_id, quantity}
- description: String

Add these recipes:
- rune_ash: 5x slime_gel + 3x wolf_fang → "Rune of Ash" (node_key)
- rune_stone: 4x wolf_fang + 4x goblin_shard → "Rune of Stone" (node_key)
- rune_wild: 5x ancient_fang + 6x goblin_shard + 3x slime_gel → "Rune of the Wild" (region_key)
- iron_fang_blade: 6x wolf_fang + 4x goblin_shard → "Iron Fang Blade" (weapon)
- slime_shield: 8x slime_gel + 2x ancient_fang → "Slime Shield" (armor)

Make it easy to add more recipes later.
```

### PROMPT 07 — Crafting UI Screen

```
Read my project first.
Build a CraftingMenu scene (full screen panel, opened from world map):
- Scrollable list of all recipes
- Each recipe card shows: result name, result type badge,
  ingredient list with my current count vs required
- If I have enough materials: craft button is active (green)
- If missing materials: button is grayed out, shows what I'm missing
- On successful craft: deduct materials, add result to inventory,
  show "Crafted!" animation
- Close button returns to world map
Mobile friendly: large tap targets, clear font sizes, no tiny elements
```

---

## PHASE 4 — World Map

### PROMPT 08 — World Map Scene

```
Read my project first.
Create a WorldMap scene that is the main hub between combat runs.
Requirements:
- Full screen background (placeholder color for now)
- 5 regions arranged spatially on the map
- Each region has 6 nodes + 1 boss node (use simple circles as placeholders)
- Region 1 nodes are visible and interactable from the start
- Other regions are grayed out/dimmed until unlocked
- Tapping any node opens a NodeInfoPanel
- Bottom bar: Inventory button, Crafting button, Player Stats button
- Save/load map state using FileAccess (user://map_state.json)
Mobile: all tap targets minimum 80px, smooth camera pan if map is larger than screen
```

### PROMPT 09 — Node Info Panel

```
Read my project first.
Build a NodeInfoPanel that appears when player taps a node on the world map.
Panel shows:
- Node name
- Enemy types that appear (text list)
- Number of waves
- Required Rune name (if locked) or "UNLOCKED" badge (if unlocked)
- Current wave modifiers
- Expected drop types (hint text)
- Two buttons: "INSERT RUNE" (if locked) or "ENTER" (if unlocked) and "CLOSE"

On INSERT RUNE:
- Check if player has the required rune in inventory
- If yes: consume rune, mark node unlocked, save map state, show unlock animation
- If no: show "You need [Rune Name]" message
```

### PROMPT 10 — Node Entry & Return

```
Read my project first.
Handle the flow of entering and exiting combat nodes:
- When player hits ENTER on an unlocked node: save which node they
  entered (node_id), load the combat scene
- Pass node data to combat scene: wave count, enemy types, modifiers
- Combat scene uses this data to configure WaveSpawner
- When all waves complete (or player dies): show EndRun screen
- EndRun screen shows: drops collected this run, XP gained, return to map button
- On return: merge drops into inventory, save everything, return to WorldMap
- Map remembers last camera position
```

---

## PHASE 5 — Boss & Region Unlock

### PROMPT 11 — Boss Enemy

```
Read my project first.
Create a Boss enemy scene that:
- Is 3x the size of normal enemies
- Has 20x the HP of normal enemies
- Has a visible HP bar above it (attached to the boss itself, not HUD)
- Moves slower but deals more damage on contact
- Has 3 phases: at 75% HP, 50% HP, 25% HP — each phase increases speed 20%
- On death: drops guaranteed rare materials (Ancient Fang for Region 1 boss)
- On death: emits a boss_defeated signal
- Spawns a screen flash and particle burst on death
Boss waves are the final wave of boss nodes only.
```

### PROMPT 12 — Region Unlock Flow

```
Read my project first.
When the Region 1 boss (Alpha Wolf) is defeated:
- Drop a special "Rune of the Wild" item (region key)
- Show a special panel: "Region 2 - Frostpeak Tundra Unlocked!"
- On world map, Region 2 nodes become visible and their region brightens
- The connecting path between Region 1 and Region 2 animates open
- Save the region unlock state

Repeat this pattern for all 5 regions.
Make the unlock feel rewarding — this is a major milestone moment.
```

---

## PHASE 6 — Save System

### PROMPT 13 — Complete Save System

```
Read my project first.
Build a SaveManager autoload that handles all game persistence.
Save to user://save_data.json containing:
- inventory: {item_id: quantity} for all items
- map_state: {node_id: {unlocked: bool, region: int}} for all nodes
- region_unlocks: [1, 2, ...] array of unlocked region numbers
- player_stats: {level, xp, equipped_weapon, equipped_armor}
- settings: {sfx_volume, music_volume}

Functions needed:
- save_all() — call after any important change
- load_all() — call on game start
- reset_save() — for new game button

Auto-save after: crafting, node unlock, region unlock, run completion.
Never auto-save mid-combat (only on run end).
```

---

## PHASE 7 — Mobile Polish

### PROMPT 14 — Mobile Controls

```
Read my project first.
Optimize all controls for mobile touch:
- Virtual joystick in bottom-left: 120px outer circle, 50px inner knob
- Joystick appears where finger first touches (dynamic position)
- Joystick input moves player, auto-attack always fires at nearest enemy
- All UI buttons minimum 80x80px tap target
- NodeInfoPanel dismissible by tapping outside it
- Pinch-to-zoom on world map (between 0.7x and 1.5x zoom)
- All text minimum 18sp equivalent in Godot
Test that nothing requires precise tapping on small targets.
```

### PROMPT 15 — Performance Audit

```
Read my project first.
Do a full performance audit for mobile (targeting 60fps on mid-range Android):
1. Check all enemy and bullet scenes use object pooling (not instantiate)
2. Make sure all collision shapes are CircleShape2D (not polygons)
3. Ensure particles have max_particles capped at 30
4. Check WorldMap only renders visible region nodes
5. Make sure save file reads happen once on load (not every frame)
6. Confirm no Node.find_node() calls in _process()
Fix any issues you find and tell me what you changed and why.
```

### PROMPT 16 — UI & Feel Polish

```
Read my project first.
Add game feel polish:
- Screen shake (0.15s, 8px) when player takes damage
- Screen shake (0.3s, 15px) when boss dies
- Level up: radial burst particle effect around player
- Drop pickup: small +item text floats up and fades
- Crafting success: brief green glow on result item
- Node unlock on world map: pulsing golden glow animation
- Wave complete: "WAVE CLEARED" text slides in from top, fades after 1.5s
Keep all effects subtle — this is mobile, not a PC game.
```

---

## 🔧 DEBUG PROMPTS — Use Anytime

### DEBUG — Fix a Crash

```
I'm getting this error in Godot:
[PASTE THE FULL ERROR MESSAGE FROM GODOT OUTPUT PANEL HERE]

1. Find the exact cause of this error
2. Explain it to me in plain English (I don't code)
3. Fix it without breaking anything else
4. Tell me how to verify the fix worked
```

### DEBUG — Balance Pass

```
Read my project.
Review all game balance values and suggest adjustments for a mobile game:
- Enemy HP values
- Drop rates (too generous or too stingy?)
- XP curve (too fast / too slow to level?)
- Crafting recipe costs (too easy / too grindy?)
- Wave difficulty scaling
Give me specific number changes, not vague suggestions.
```

### DEBUG — Add New Monster

```
Read my project.
Add a new enemy type called [MONSTER NAME]:
- Region: [REGION NUMBER]
- HP: [VALUE]
- Speed: [VALUE]
- Drop: [ITEM NAME] with [X]% chance, [MIN]-[MAX] quantity
- Behavior: [moves toward player / charges and retreats / shoots projectile]
- Visual: placeholder [COLOR] circle, size [SMALL/MEDIUM/LARGE]
Connect it to the WaveSpawner so it appears in the correct region nodes.
Add its drop to CraftingRecipes if a recipe uses it.
```

### DEBUG — Add New Recipe

```
Read my project.
Add a new crafting recipe:
- Result: [ITEM NAME]
- Type: [node_key / region_key / weapon / armor]
- Ingredients: [ITEM 1: X qty], [ITEM 2: X qty]
- Description: [FLAVOUR TEXT]
Make sure it appears correctly in the CraftingMenu UI.
```

### DEBUG — Performance Check

```
The game feels slow/laggy on mobile. Audit for performance issues:
1. Are bullets and enemies using object pooling everywhere?
2. Are all collision shapes CircleShape2D (not polygons)?
3. Are particles capped at 30 max_particles?
4. Is anything running expensive logic in _process() that should be a timer?
5. Is the world map rendering offscreen nodes?
Fix every issue you find and tell me what you changed.
```

---

# 6. RECOMMENDED BUILD ORDER

Follow this sequence. Each phase builds on the last. Do not skip phases.

| Week | Phase | Prompts | Goal |
|---|---|---|---|
| Now | Bug Fixes | Prompt 00 | Clean foundation |
| 1 | Combat Core | 01, 02, 03 | Solid wave combat with XP |
| 2 | Drops & Inventory | 04, 05 | Monsters drop items, inventory works |
| 3 | Crafting | 06, 07 | Can craft Runes and gear from drops |
| 4 | World Map | 08, 09, 10 | Full map with nodes, lock/unlock flow |
| 5 | Boss & Regions | 11, 12 | Boss fights, region progression |
| 6 | Save System | 13 | Everything persists between sessions |
| 7 | Mobile Polish | 14, 15, 16 | Feels great on phone, runs at 60fps |
| 8+ | Balance & Content | Debug prompts | Add content, tune numbers, fix bugs |

---

# 7. IMPLEMENTATION STATUS

> Last updated: 2026-03-10

## Completed Systems

### Phase 0 — Bug Fixes ✅
- ✅ Fix EnemyDeathEffect particle material
- ✅ Fix boss death — bonus score (50pts), bigger death effect, screen flash
- ✅ Fix Quit button → returns to WorldMap instead of quitting app
- ✅ Remove dead code in projectile.gd

### Phase 1 — Combat Core ✅
- ✅ ObjectPool autoload (bullets, enemies, XP gems, loot drops)
- ✅ Wave spawner with per-node config, scaling HP/speed
- ✅ "Wave X" text + "BOSS INCOMING!" pulse + "WAVES CLEARED!" slide-in
- ✅ XP gems, level-up with 3 random upgrades, 8 skills
- ✅ HUD: level, XP bar

### Phase 2 — Monster Drops & Inventory ✅
- ✅ Loot tables per node, all 5 regions configured
- ✅ LootDrop magnetize + auto-collect + "+Item Name" float text
- ✅ Inventory persists via save_data.json, not lost on death
- ✅ Drops collected summary on WaveCompletePanel and GameOverPanel

### Phase 3 — Crafting System ✅
- ✅ RecipeDatabase: 20 recipes (5 region runes, 5 node runes, 5 weapons, 5 armor)
- ✅ CraftingPanel: scrollable list, green/red ingredient counts, craft button
- ✅ Crafting success glow with "Crafted [item]!" flash
- ✅ Auto-save after crafting

### Phase 4 — World Map ✅
- ✅ WorldMap.tscn with 15 nodes across 5 regions
- ✅ Connection lines, camera scroll, MapNodeButton (locked/unlocked/completed)
- ✅ Node info panel: name, description, waves, difficulty, rune requirement, drop hints
- ✅ Node unlock golden pulse glow ("NEW" label on available nodes)
- ✅ Inventory, Crafting, Equipment buttons on map
- ✅ Region dimming/brightening on unlock (animated brighten + region-colored connection lines)
- ✅ Detailed node preview screen (full-screen pre-combat panel with drops, equipment, modifiers)

### Phase 5 — Boss & Region Unlock ✅
- ✅ BossEnemy: scaled size, 200 HP, 3-phase system (75%/50%/25%), overhead HP bar
- ✅ Boss death: screen flash, bigger particles, screen shake
- ✅ "NEW REGION UNLOCKED" announcement panel
- ✅ Region unlock tracking + rune key items (forest→tundra→ruins→depths→nexus)

### Phase 6 — Save System ✅
- ✅ save_game/load_game/delete_save/reset via ProgressManager
- ✅ Persists: completed_nodes, inventory, unlocked_regions, equipped_weapon, equipped_armor
- ✅ Auto-save after crafting and equipping
- ✅ Settings saved to user://settings.json (SFX volume)
- ✅ Audio bus layout (Master → SFX + Music buses)
- ✅ Music playback system (AudioManager.play_music/crossfade_music)
- ✅ SFX/Music volume sliders wired to separate buses

### Phase 7 — Mobile Polish ✅
- ✅ Virtual joystick (left side) + Boost button (bottom-right)
- ✅ Player uses Input actions (keyboard + touch compatible)
- ✅ Pinch-to-zoom on world map + single-finger drag scroll

### Phase 8 — UI & Feel Polish ✅
- ✅ Screen shake, damage numbers, level-up burst particles
- ✅ Drop pickup float text, crafting glow, node unlock glow
- ✅ Combat minimap (upper-right, player green, enemies red)
- ✅ Region-themed combat backgrounds (color tint per region)

### Phase 9 — Custom Enemies ✅
- ✅ SlimeEnemy with 3-state sprites (idle/move/death) for forest nodes
- ✅ Multi-sheet animation system in enemy.gd (idle_texture/move_texture/death_texture)
- ✅ Per-node enemy_scene_path in MapNodeData
- ✅ Tundra enemy (FrostEnemy — ice-blue tint, slower/tankier, frost trails)
- ✅ Ruins enemy (EmberEnemy — fiery orange tint, fast/aggressive, dash charge)
- ✅ Depths enemy (ShadeEnemy — purple tint, durable, teleport blink)
- ✅ Nexus enemy (RuneEnemy — golden tint, powerful all-around, fires projectiles)
- ✅ Region-specific boss scenes (BossSlime/BossFrost/BossEmber/BossShade/BossNexus)
- ✅ boss_scene_path support in MapNodeData + wave_manager.gd
- ✅ EnemyProjectile system (red-tinted projectiles, pool-compatible)

### Phase 10 — Weapon Variety ✅
- ✅ weapon_type field on all weapons in ItemDatabase
- ✅ Player _fire_at() dispatches by weapon type (standard/spread/piercing/homing/aoe)
- ✅ HomingProjectile (curves toward nearest enemy)
- ✅ AoEProjectile (explodes on hit, damages enemies in radius)
- ✅ Spread: wider angle, +2 bolts, shorter range, less damage per bolt
- ✅ Piercing: infinite pierce-through

### Phase 11 — Ambient Particles ✅
- ✅ Region-specific ambient particles in combat (forest leaves, tundra snow, ruins embers, depths wisps, nexus sparks)

### Phase 12 — Balance Pass ✅
- ✅ Boss scale fixed (0.35x for slime-based bosses)
- ✅ Enemy speeds balanced per region
- ✅ Contact damage reduced across all region enemies
- ✅ Boss weapon drops (25%→10% scaling by region)
- ✅ Rare weapon drops on regular enemies (1-3% per kill)

### Performance Audit ✅
- ✅ Pooled DamageNumber, FrostTrail, DeathEffect
- ✅ Cached minimap groups, HUD refs, player stats
- ✅ Preloaded music resources

### Rune Collection Gallery ✅
- ✅ Full-screen gallery with locked/crafted/used states, recipe hints, region grouping

## Still TODO
- [ ] Connecting path animation between regions (world map visual polish)
- [ ] Drop .ogg music files into `assets/audio/music/` (system is wired, just needs files)
- [ ] Achievement System (milestones + minor rewards)

---

# 8. SESSION RULES

## Golden Rules

| | Rule |
|---|---|
| ✅ | Always start with the SESSION OPENER — every time, no exceptions |
| ✅ | Tell Claude Code to explain what it plans to change BEFORE it changes it |
| ✅ | Commit to git after every working feature |
| ✅ | Work on one system at a time — finish and test before starting the next |
| ✅ | If something works, say "this is working, do not touch it" |
| ✅ | Test on actual mobile device every week |
| ❌ | Never ask Claude Code to build two major systems in one prompt |
| ❌ | Never skip the session opener |
| ❌ | Never let Claude Code refactor working code unless something is broken |
| ❌ | Never paste a prompt from the middle of the list without completing earlier ones |

## Mobile Performance Constraints

Tell Claude Code these at the start of any combat-related session:

```
This game targets mobile (Android/iOS). Always:
- Use object pooling for bullets and enemies (never instantiate during gameplay)
- Keep particle effects minimal (max 30 particles)
- World map should only render visible nodes
- Maximum 50-80 enemies on screen at once
- Use CircleShape2D only for collision (no polygons)
```

## If Claude Code Breaks Something

```
Something broke after your last change. Please:
1. Tell me exactly what you changed
2. Show me how to revert it
3. Find a different approach that doesn't break existing code

# Git revert if needed:
git diff          # see what changed
git checkout .    # undo ALL changes since last commit
```

---

# 9. MULTI-AGENT SETUP

Run multiple Claude Code terminals simultaneously for faster development.

## Terminal Setup

```bash
# Terminal 1 — Architect (complex systems)
cd C:\Users\rnaci\Documents\Bullet_Hell_Game_NoTitle
claude --model claude-opus-4-6

# Terminal 2 — Builder (focused implementation)
cd C:\Users\rnaci\Documents\Bullet_Hell_Game_NoTitle
claude --model claude-sonnet-4-6

# Terminal 3 — Reviewer (testing & auditing)
cd C:\Users\rnaci\Documents\Bullet_Hell_Game_NoTitle
claude --model claude-sonnet-4-6
```

## File Ownership

| Agent | Owns These Files |
|---|---|
| Architect (Opus) | world_map.gd, crafting_system.gd, save_manager.gd |
| Builder (Sonnet) | enemy_*.gd, drop_*.gd, ui_*.gd |
| Reviewer (Sonnet) | Read-only — never writes |

**Rule: Never have two agents editing the same file at the same time.**

## How to Reference This File in Claude Code

```
Read @RUNESTORM_MASTER.md — this is the complete game design
bible and prompt library. Use it as your reference for all
decisions about architecture, systems, and implementation order.
```

---

*Generated with Claude · claude.ai*
*Place this file in your Godot project root: `Bullet_Hell_Game_NoTitle/RUNESTORM_MASTER.md`*

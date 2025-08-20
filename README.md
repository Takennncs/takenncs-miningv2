# Takenncs Mining V2 (FiveM)

[![FiveM](https://img.shields.io/badge/FiveM-Compatible-brightgreen)](https://fivem.net/)
[![Lua](https://img.shields.io/badge/Lua-Script-blue)](https://www.lua.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow)](#license)

**Takenncs Mining V2** is a mining system for FiveM servers, allowing players to mine rocks, collect ores, and sell them. Works with `ox_inventory` and supports Discord logging.

---

## Features

- Interactive mining zones with cooldowns
- Multiple ores: iron, copper, gold, silver
- Tool requirement (e.g., pickaxe) to mine
- Progress bars with animations while mining
- Discord webhook notifications for mined items
- Server-side item handling and location syncing

---

## Requirements

- FiveM server (latest recommended version)
- `ox_inventory`
- `ox_lib`
- TAKENNCS UI notifications (optional)

---

## Installation

1. Place the `takenncs-miningv2` folder in your server `resources` directory.
2. Add the resource to your `server.cfg`:

```cfg
ensure takenncs-miningv2

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dungeon Helper Continued is a World of Warcraft addon (Interface 120007 / WoW 12.0+). It automates courtesies for Dungeon Finder and Raid Finder runs: auto-greets the party on zone-in, tracks elapsed dungeon time, reports completion time, and offers a quick-leave dialog with a goodbye message.

The addon only activates in queued content (LFG/LFR). It does not trigger in Mythic+, premade groups, battlegrounds, or arenas. This is enforced by checking `IsInGroup(LE_PARTY_CATEGORY_INSTANCE)` (only true for auto-matched groups) and listening to `LFG_COMPLETION_REWARD` (only fires for queued content).

## Development

No build system or external dependencies. No automated tests - all testing is manual/in-game.

- **Install**: Symlink or copy the repo to `World of Warcraft/_retail_/Interface/AddOns/dungeon-helper-continued/`
- **Reload**: `/reload` in-game to pick up code changes
- **Settings UI**: `/dhc` slash command opens the addon settings panel

The `.toc` file defines load order and metadata. New `.lua` files must be listed there.

## Architecture

Two-file structure (~170 lines total):

**`DungeonHelperContinued.lua`** - Core event-driven logic:
- Listens to `ADDON_LOADED` (init DB), `PLAYER_ENTERING_WORLD` (greet + start timer), `LFG_COMPLETION_REWARD` (report time + show leave dialog)
- User settings stored in `DungeonHelperContinuedDB` SavedVariable (persisted by WoW across sessions)
- Defaults merged into SavedVariable on first load; new defaults auto-populate on addon update

**`Options.lua`** - Settings panel:
- Builds UI frame with EditBoxes (greeting/goodbye messages) and CheckButton (report time toggle)
- Registers with WoW 12.0 Settings API (`Settings.RegisterCanvasLayoutCategory`)
- Registers `/dhc` slash command

## WoW API Conventions

- **Lua version**: WoW uses Lua 5.1
- **Modern APIs required** (WoW 12.0+):
  - `C_ChatInfo.SendChatMessage()` (not the deprecated `SendChatMessage`)
  - `Settings.RegisterCanvasLayoutCategory()` / `Settings.RegisterAddOnCategory()` (not the old `InterfaceOptions` system)
- **Event pattern**: `CreateFrame("Frame")` -> `RegisterEvent` -> `SetScript("OnEvent", handler)` -> `UnregisterEvent` after one-time init
- **Namespace**: Both files use `local addonName, ns = ...` (standard addon namespace unpacking)
- **Instance detection**: `GetInstanceInfo()` returns instance type (`"party"`, `"raid"`, `"pvp"`, `"arena"`); `IsInGroup(LE_PARTY_CATEGORY_INSTANCE)` checks queued group membership
- **WoW API reference**: https://warcraft.wiki.gg/wiki/World_of_Warcraft_API

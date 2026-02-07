# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dungeon Helper Continued is a World of Warcraft addon (Interface 120000 / WoW 12.0+). It automates courtesies for Group Finder dungeon runs: auto-greets the party on zone-in, tracks elapsed dungeon time, reports completion time, and offers a quick-leave dialog with a goodbye message.

## Development

This is a standard WoW addon with no build system or external dependencies. Development workflow:

- **Install**: Symlink or copy the repo to `World of Warcraft/_retail_/Interface/AddOns/dungeon-helper-continued/`
- **Reload**: Use `/reload` in-game to pick up code changes
- **Settings UI**: `/dhc` slash command opens the addon settings panel
- **No automated tests** — all testing is manual/in-game

The `.toc` file defines load order and metadata. If you add a new `.lua` file, it must be listed in the `.toc` file.

## Architecture

Two-file structure (~170 lines total):

**`DungeonHelperContinued.lua`** — Core event-driven logic:
- Listens to `ADDON_LOADED` (init DB), `PLAYER_ENTERING_WORLD` (greet + start timer), `LFG_COMPLETION_REWARD` (report time + show leave dialog)
- User settings stored in `DungeonHelperContinuedDB` SavedVariable (persisted by WoW across sessions)
- Defaults merged into SavedVariable on first load; new defaults auto-populate on addon update

**`Options.lua`** — Settings panel:
- Builds UI frame with EditBoxes (greeting/goodbye messages) and CheckButton (report time toggle)
- Registers with WoW 12.0 Settings API (`Settings.RegisterCanvasLayoutCategory`)
- Registers `/dhc` slash command

## WoW API Conventions

- **Lua version**: WoW uses Lua 5.1
- **Modern APIs required** (WoW 12.0+):
  - `C_ChatInfo.SendChatMessage()` (not the deprecated `SendChatMessage`)
  - `Settings.RegisterCanvasLayoutCategory()` / `Settings.RegisterAddOnCategory()` (not the old `InterfaceOptions` system)
- **Event pattern**: `CreateFrame("Frame")` → `RegisterEvent` → `SetScript("OnEvent", handler)` → `UnregisterEvent` after one-time init
- **Namespace**: Both files use `local addonName, ns = ...` (standard addon namespace unpacking)
- **Instance detection**: `GetInstanceInfo()` returns instance type (`"party"`, `"raid"`); `IsInGroup(LE_PARTY_CATEGORY_INSTANCE)` checks group membership
- **WoW API reference**: https://warcraft.wiki.gg/wiki/World_of_Warcraft_API

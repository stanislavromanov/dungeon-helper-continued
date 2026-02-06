# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

DungeonHelperContinued is a World of Warcraft retail addon (Interface 110207) for Dungeon Finder / Raid Finder groups. It auto-greets the party on instance entry, tracks dungeon completion time, and offers a one-click leave popup after the last boss is killed.

## Installation / Testing

No build step. Copy this folder as `DungeonHelperContinued` into `World of Warcraft/_retail_/Interface/AddOns/`. Test in-game with `/dhc` (opens settings) and by queuing Dungeon Finder.

## Architecture

- **DungeonHelperContinued.toc** — Addon manifest. `SavedVariables: DungeonHelperContinuedDB` persists settings across sessions.
- **DungeonHelperContinued.lua** — Core event handler. Listens to `ADDON_LOADED` (init saved vars), `PLAYER_ENTERING_WORLD` (detect LFG entry, start timer, send greeting), and `LFG_COMPLETION_REWARD` (report time, show leave popup). The leave popup is a `StaticPopupDialogs` entry.
- **Options.lua** — Settings UI registered via `Settings.RegisterCanvasLayoutCategory`. Contains two edit boxes (greeting/goodbye messages) and a checkbox (report time to party). Opened via `/dhc` slash command.

All user-configurable state lives in the global `DungeonHelperContinuedDB` table (a SavedVariable). Both files read/write it directly — there is no abstraction layer.

## Key WoW API Patterns

- Messages are sent via `C_ChatInfo.SendChatMessage(msg, "INSTANCE_CHAT")` — this is the LFG instance chat channel.
- LFG group membership is checked with `IsInGroup(LE_PARTY_CATEGORY_INSTANCE)`.
- `PLAYER_ENTERING_WORLD` skips `isInitialLogin` and `isReloadingUi` to avoid greeting on login/reload — only fires greeting on zone transitions (i.e., entering a new instance via the queue).
- Leaving the group uses `C_PartyInfo.LeaveParty(LE_PARTY_CATEGORY_INSTANCE)`.

## Conventions

- Lua with WoW's global API. No external dependencies or libraries.
- Default messages are lowercase ("hi", "thanks, bb").
- The addon namespace `ns` is available but currently unused — prefer it over new globals if shared state between files is needed.

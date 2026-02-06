# Dungeon Helper Continued

A continuation of the Dungeon Helper addon for World of Warcraft, updated for modern WoW (The War Within 12.0+).

## What It Does

Dungeon Helper Continued automates the small courtesies and bookkeeping that come with running dungeons through the Group Finder. It greets your party when you zone in, tracks how long the dungeon takes, and offers a quick-leave option when the final boss is down — so you can focus on playing instead of typing.

## Features

**Auto-Greeting** — When you enter a dungeon or raid instance, the addon automatically sends a greeting message to instance chat. No more forgetting to say hi. The default message is "hi", but you can change it to anything you like.

**Dungeon Timer** — Tracks elapsed time from the moment you zone into the instance until the dungeon is completed. The completion time can be reported to party chat so the whole group can see how fast the run was, or displayed only to you. Time is shown in a human-readable format (e.g. "15m 30s").

**Quick Leave** — When the dungeon completion reward pops up, a confirmation dialog asks if you want to leave the instance. Clicking "Yes" sends a customizable goodbye message (default: "thanks, bb") and leaves the group automatically. One click instead of several.

**Fully Customizable** — All messages and behaviors are configurable through the in-game Settings menu (Add-Ons section) or with the `/dhc` slash command:
- Custom greeting message
- Custom goodbye message
- Toggle whether the completion time is reported to party chat or shown only to you

## Works With All Content

The addon responds to game events rather than targeting specific dungeons, so it works automatically with all current and future instanced content — Heroic dungeons, Mythic+ keystones, LFR raids, and anything else that uses the group instance system.

## Lightweight and Non-Intrusive

- No external dependencies
- Minimal memory footprint
- Only activates inside instances — never fires in the open world
- Smart detection avoids sending duplicate greetings on login or UI reload
- All features are optional and can be turned off

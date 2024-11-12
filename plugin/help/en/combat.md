---
toc: CofD System
summary:
order: 3
aliases:
---

# CofD - Combat

A simple Combat Tracker that allows for initiative and turn tracking.

## Starting Combat

`combat/start` - Starts a combat tracker in the current scene.
`combat/join` - Ends a combat tracker in the current scene.
`combat/init [<modifier>]` - Roll initiative into the combat tracker with an optional modifier to the initiative roll.

## Managing Combat

`combat` - View current combat information on current participants.
`combat/next` - Advance combat to the next character in iniative order.
`combat/prev` - Return to previous character in iniative order.

## Ending Combat

`combat/leave` - Remove yourself from the combat tracker.
`combat/end` - Ends the combat tracker in the current scene.

## Storyteller Commands

> **Permission Required:** The commands below require the Storyteller role.

`combat/init <character> [<modifier>]` - Roll initiative on behalf of another character.

#### Examples

- `combat`
- `combat/start`
- `combat/init`
- `combat/init Shadowheart/+5`

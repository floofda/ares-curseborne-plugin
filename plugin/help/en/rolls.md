---
toc: CofD System
summary:
order: 3
aliases:
  - opposed
  - roll
  - rolls
---

# CofD - System Rolls

## Standard Rolls

`roll <roll>` - Rolls a sheet field, such as attributes and/or skills, or a flat number of dice.
`roll/strict <roll>` - Rolls without the 10-again quality, i.e., no reolls on any dice.
`roll/9 <roll>` - Rolls with the 9-again quality.
`roll/8 <roll>` - Rolls with the 8-again quality.
`roll/rote <roll>` - Reroll all failed dice once when rolling.
`roll/wp <roll>` - Spend one point of Willpower to add a +3 modifier to your roll.

> **Note:** The `wp` switch may be added to any switch (ex: `roll/9/wp` or `roll/wp/8/rote`, etc)

## Opposed Rolls

`roll <roll> vs <character>/<roll>` - Makes a roll from yourself and another character and compares the successes.

## Defended Rolls

`roll <roll> @ <character>/<stat>` - Makes a roll against another character using their specified stat to lower the roll's dice pool.

### Roll Options

Rolls may include any sheet field, such as attributes or skills, e.g., `Strength + Brawl`. Specialties can be rolled using a "`.`" between items, e.g., `Academics.History`. Modifiers are added with a + or -, e.g., `Resolve + Composure + 2` or `Dexterity + Firearms - 1`.

Rolling a flat number of dice is limited to 100 dice.

**Note:**

- Pools that reach zero or below will be made into a chance die.
- The `wp` switch will automatically deduct a point of Willpower and add 3 dice.
- Unskilled skill rolls will automatically have dice deducted and include `Unskilled` in the display.
- The merit `Area of Expertise` will automatically apply its bonus and display with an `Expert` suffix.

#### Examples

- `roll Str + Aca.His + 3`
- `roll Wits - 1`
- `roll Presence + Persuasion vs Cassandra/Composure + Resolve`
- `roll Strength + Brawl @ Karlach/defense`
- `roll/wp Presence + Intimidation + Wyrd @ Tav/Resolve + 2`

## Storyteller Commands

> **Permission Required:** The commands below require the Storyteller role.

`roll <character>/<roll>` - Makes a roll on behalf of another character.
`roll/strict <character>/<roll>` - Makes a roll on behalf of another character without 10-again.
`roll/9 <character>/<roll>` - Rolls on behalf of another character with the 9-again quality.
`roll/8 <character>/<roll>` - Rolls on behalf of another character with the 8-again quality.
`roll/rote <character>/<roll>` - Reroll all failed dice once when rolling on behalf of another character.
`roll/wp <character>/<roll>` - Spend one point of a character's Willpower to add a +3 modifier to a roll on behalf of that character.
`roll <character>/<roll> vs <character>/<roll>` - Makes an opposed roll on behalf of two other characters.
`roll <character>/<roll> @ <character>/<stat>` - Makes a defended roll on behalf of two other characters.

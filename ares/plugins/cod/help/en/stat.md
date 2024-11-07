---
toc: CofD System
summary:
order: 3
aliases:
---

# CofD - Setting Stats

> **Permission Required:** The commands below require the Admin role.

## Setting Stats

`stat/set <character>/<stat>:<value>[=<reason>]` - Sets a character's stat to a new value.
`stat/raise <character>/<stat>:<value>[=<reason>]` - Raises a character's stat by a specified amount.
`stat/lower <character>/<stat>:<value>[=<reason>]` - Lowers a character's stat by a specified amount.

> **Note:** A stat can be an attribute, skill, merit, ability, etc. Setting a stat to 0 will remove the field from a character's sheet.

##### Examples

- `stat/set Halsin/Giant:3=Missed CG merit.`
- `stat/raise Astarion/Manipulation:2`
- `stat/lower Jaheira/Dexterity:1=Getting old.`
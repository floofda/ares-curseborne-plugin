---
toc: CofD System
summary:
order: 3
aliases:
  - gain
  - regain
  - spend
  - resource
---

# CofD - Resources

## Using Resources

`spend/<resource type> [<amount>]` - Spend a specified amount of a resource. Amount defaults to 1 if not specified.
`regain/<resource type> [<amount>]` - Regain a specified amount of a resource. Amount defaults to 1 if not specified.

### Resource Types

Available resource types: `/wp` for willpower and sphere-specific resources like `/glamour`.

## Storyteller Commands

> **Permission Required:** The commands below require the Storyteller role.

`spend/<resource type> <character>/[<amount>]` - Spends a specified amount of a resource on behalf of another character. Amount defaults to 1 if not specified.
`regain/<resource type> <character>/[<amount>]` - Regain a specified amount of a resource on behalf of another character. Amount defaults to 1 if not specified.

#### Examples

- `spend/wp 1`
- `regain/glamour Gale/1`
- `spend/wp`

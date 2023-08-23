# WOTLK Classic 3.4.2

## CritMatic v0.1.4-alpha - Your Personal Damage and Heal Tracker

CritMatic is a lightweight World of Warcraft addon designed to help players keep track of their highest critical and
normal hits (both damage and heal).

### Key Features:

- **Real-time Tracking:** CritMatic monitors your combat logs in real-time and records your highest critical and normal
  hits for each spell you cast. It automatically updates these records when you hit harder.

- **Healing Tracking:** In addition to damage, CritMatic also tracks your healing output, recording the highest heal and
  critical heal for each healing spell you cast.

- **Detailed Tooltip Information:** When you mouse over a spell on your action bar, CritMatic adds additional lines to
  the tooltip showing your highest normal and critical hit with that spell.

- **Display Damage and Heals:** CritMatic will notify you with a message and sound effect whenever you hit a new highest
  normal or critical hit.

- **Persistent Data:** CritMatic saves your highest hits data between sessions, so you can log out or switch characters
  without losing your records. You can also reset the data at any time if you want to start fresh.

- **Slash Command:** Use the `/cmreset` command to reset all your CritMatic saved data. This can be useful if you want
  to start tracking from scratch.

With CritMatic you'll always know when you've hit a new personal best. Happy Criting!

## Planned:

- Configuration options for more fonts, colors and more.
- Chat Messages are gold for crits.

## Change Log:

### [v0.1.4-alpha] - 8/23/2023

#### Added

- Added new Crit animation for crits.
- Added CritMatic tooltip information to the spell-book.

### [v0.1.3-alpha] - 8/20/2023

#### Fixed

- A bug where hit messages disappearing too fast.

### [v0.1.2-alpha] - 8/18/2023

#### Added

- Added a max for crits,heals and normal hits so on some bosses you don't get a 1 million crits.
- Added a check to prevent CritMatic from attempting to track spells that are not in your spell-book.



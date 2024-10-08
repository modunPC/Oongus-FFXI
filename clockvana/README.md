# clockVana

Modification of atom0s's clock addon to add in Vana'diel time elements.  This is basically just the Clock addon from atom0s (https://github.com/AshitaXI/Ashita-v4beta/) combined with functions from the the Ashita v3 lib `vanatime` ([https://git.ashitaxi.com/Ashita/Ashitav3-Release/src/commit/8eb0fde9d462de2da20d68be11ad31cf4fa3787f/addons/libs/ffxi/vanatime.lua](https://git.ashitaxi.com/Ashita/Ashitav3-Release/src/branch/master/addons/libs/ffxi/vanatime.lua)).  Allows you to see Vana'diel time on screen at all times, even when the vanilla clock disappears (e.g. when fishing, or when the target menu is open.)

![image](https://github.com/ConteAlmaviva/clockvana/assets/8880996/d2f67649-1652-4dfc-847b-da417694531e)

![image](https://github.com/ConteAlmaviva/clockvana/assets/8880996/323408b2-80ce-4e5f-96ff-84188daff208)

![image](https://github.com/ConteAlmaviva/clockvana/assets/8880996/897a7bd7-da7f-44b5-b686-8b028de28128)

```
        { '/time help', 'Displays the addons help information.' },
        { '/time save', 'Saves the current settings.' },
        { '/time reload', 'Reloads the settings from disk for the current player. (Or defaults otherwise.)' },
        { '/time reset', 'Resets the settings to defaults.' },
        { '/time add <name> <offset>', 'Adds a clock with the given timezone offset.' },
        { '/time (del | delete | rem | remove) <name>', 'Deletes a clock.' },
        { '/time clear', 'Removes all clocks.' },
        { '/time (f | fmt | format) [format]', 'Displays or sets the timestamp format to be used with the clocks.' },
        { '/time (s | sep | separator) [separator]', 'Displays or sets the separator to be used between each clock.' },
        { '/time (c | col | color) <a> <r> <g> <b>', 'Sets the clock color.' },
        { '/time (h | hide) <day | date | moon>', 'Toggle visible elements of the clock.' }
```

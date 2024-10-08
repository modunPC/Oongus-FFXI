--[[
* Addons - Copyright (c) 2021 Ashita Development Team
* Contact: https://www.ashitaxi.com/
* Contact: https://discord.gg/Ashita
*
* This file is part of Ashita.
*
* Ashita is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Ashita is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Ashita.  If not, see <https://www.gnu.org/licenses/>.
--]]

addon.name      = 'clockvana';
addon.author    = 'atom0s (modified by Almavivaconte & Oongus)';
addon.version   = '1.2';
addon.desc      = 'Allows the player to display various times on screen. (Vana\'diel time elements added by Almavivaconte, toggle added by Oongus)';
addon.link      = 'https://ashitaxi.com/';

require('common');
local chat      = require('chat');
local fonts     = require('fonts');
local scaling   = require('scaling');
local settings  = require('settings');

-- Default Settings
local default_settings = T{
    font = T{
        visible = true,
        font_family = 'Arial',
        font_height = scaling.scale_f(12),
        color = 0xFFFFFFFF,
        position_x = 130,
        position_y = 0,
        background = T{
            visible = true,
            color = 0x80000000,
        },
    },
    format = '[%I:%M:%S]',
    separator = ' - ',
    clocks = T{ },
    hide = T{
        day = false,
        date = false,
        moon = false,
    },
};

-- Clock Variable
local clock = T{
    settings = settings.load(default_settings),
    font = nil,

    -- Calculate and store the current system UTC difference..
    utc_diff =  os.difftime(os.time(), os.time(os.date('!*t', os.time()))),
};

ashita                  = ashita or { };
ashita.ffxi             = ashita.ffxi or { };
ashita.ffxi.vanatime    = ashita.ffxi.vanatime or { };

-- Scan for patterns..
ashita.ffxi.vanatime.pointer = ashita.memory.find('FFXiMain.dll', 0, 'B0015EC390518B4C24088D4424005068', 0x34, 0);

-- Signature validation..
if (ashita.ffxi.vanatime.pointer == 0) then
    error('vanatime.lua -- signature validation failed!');
end

----------------------------------------------------------------------------------------------------
-- func: get_raw_timestamp
-- desc: Returns the current raw Vana'diel timestamp.
----------------------------------------------------------------------------------------------------
local function get_raw_timestamp()
    local pointer = ashita.memory.read_uint32(ashita.ffxi.vanatime.pointer);
    return ashita.memory.read_uint32(pointer + 0x0C);
end 
ashita.ffxi.vanatime.get_raw_timestamp = get_raw_timestamp;

----------------------------------------------------------------------------------------------------
-- func: get_timestamp
-- desc: Returns the current formatted Vana'diel timestamp.
----------------------------------------------------------------------------------------------------
local function get_timestamp()
    local timestamp = get_raw_timestamp();
    local ts = (timestamp + 92514960) * 25;
    local h = (ts / 3600) % 24;
    local m = (ts / 60) % 60
    local s = ((ts - (math.floor(ts / 60) * 60)));
    --if (s >= 45) then
    --    m = m + 1
    --end

    return string.format('%02i:%02i', h, m);
end 
ashita.ffxi.vanatime.get_timestamp = get_timestamp;

----------------------------------------------------------------------------------------------------
-- func: get_current_time
-- desc: Returns a table with the hour, minutes, and seconds in Vana'diel time.
----------------------------------------------------------------------------------------------------
local function get_current_time()
    local timestamp = get_raw_timestamp();
    local ts = (timestamp + 92514960) * 25;
    local h = (ts / 3600) % 24;
    local m = (ts / 60) % 60;
    local s = ((ts - (math.floor(ts / 60) * 60)));

    local vana = { };
    vana.h = h;
    vana.m = m;
    vana.s = s;

    return vana;
end
ashita.ffxi.vanatime.get_current_time = get_current_time;

----------------------------------------------------------------------------------------------------
-- func: get_current_hour
-- desc: Returns the current Vana'diel hour.
----------------------------------------------------------------------------------------------------
local function get_current_hour()
    local timestamp = get_raw_timestamp();
    local ts = (timestamp + 92514960) * 25;
    return (ts / 3600) % 24;
end
ashita.ffxi.vanatime.get_current_hour = get_current_hour;

----------------------------------------------------------------------------------------------------
-- func: get_current_minute
-- desc: Returns the current Vana'diel minute.
----------------------------------------------------------------------------------------------------
local function get_current_minute()
    local timestamp = get_raw_timestamp();
    local ts = (timestamp + 92514960) * 25;
    return (ts / 60) % 60;
end
ashita.ffxi.vanatime.get_current_minute = get_current_minute;

----------------------------------------------------------------------------------------------------
-- func: get_current_second
-- desc: Returns the current Vana'diel second.
----------------------------------------------------------------------------------------------------
local function get_current_second()
    local timestamp = get_raw_timestamp();
    local ts = (timestamp + 92514960) * 25;
    return ((ts - (math.floor(ts / 60) * 60)));
end
ashita.ffxi.vanatime.get_current_second = get_current_second;

----------------------------------------------------------------------------------------------------
-- func: get_current_date
-- desc: Returns a table with the current Vana'diel date.
----------------------------------------------------------------------------------------------------
local function get_current_date()
    local timestamp = get_raw_timestamp();
    local ts = (timestamp + 92514960) * 25;
    local day = math.floor(ts / 86400);

    -- Calculate the moon information..
    local mphase = (day + 26) % 84;
    local mpercent = (((42 - mphase) * 100)  / 42);
    if (0 > mpercent) then
        mpercent = math.abs(mpercent);
    end

    -- Build the date information..
    local vanadate          = { };
    vanadate.weekday        = (day % 8);
    vanadate.day            = (day % 30) + 1;
    vanadate.month          = ((day % 360) / 30) + 1;
    vanadate.year           = (day / 360);
    vanadate.moon_percent   = math.floor(mpercent + 0.5);
    
    local days = {
    "Firesday",
    "Earthsday",
    "Watersday",
    "Windsday",
    "Iceday",
    "Lightningsday",
    "Lightsday",
    "Darksday"
    }
    
    vanadate.weekday = days[vanadate.weekday + 1]
    
    if (38 <= mphase) then  
        vanadate.moon_phase = math.floor((mphase - 38) / 7);
    else
        vanadate.moon_phase = math.floor((mphase + 46) / 7);
    end

    return vanadate;
end
ashita.ffxi.vanatime.get_current_date = get_current_date;

--[[
* Prints the addon help information.
*
* @param {boolean} isError - Flag if this function was invoked due to an error.
--]]
local function print_help(isError)
    -- Print the help header..
    if (isError) then
        print(chat.header(addon.name):append(chat.error('Invalid command syntax for command: ')):append(chat.success('/' .. addon.name)));
    else
        print(chat.header(addon.name):append(chat.message('Available commands:')));
    end

    local cmds = T{
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
        { '/time (h | hide | t | toggle) <day | date | moon>', 'Toggle visible elements of the clock.' },
    };

    -- Print the command list..
    cmds:ieach(function (v)
        print(chat.header(addon.name):append(chat.error('Usage: ')):append(chat.message(v[1]):append(' - ')):append(chat.color1(6, v[2])));
    end);
end

--[[
* Registers a callback for the settings to monitor for character switches.
--]]
settings.register('settings', 'settings_update', function (s)
    if (s ~= nil) then
        clock.settings = s;
    end

    -- Update the font object..
    if (clock.font ~= nil) then
        clock.font:apply(clock.settings.font);
    end

    -- Save the current settings..
    settings.save();
end);

--[[
* event: load
* desc : Event called when the addon is being loaded.
--]]
ashita.events.register('load', 'load_cb', function ()
    -- Prepare the clock font object..
    clock.font = fonts.new(clock.settings.font);
end);

--[[
* event: unload
* desc : Event called when the addon is being unloaded.
--]]
ashita.events.register('unload', 'unload_cb', function ()
    -- Cleanup the clock font object..
    if (clock.font ~= nil) then
        clock.font:destroy();
        clock.font = nil;
    end
end);

--[[
* event: command
* desc : Event called when the addon is processing a command.
--]]
ashita.events.register('command', 'command_cb', function (e)
    -- Parse the command arguments..
    local args = e.command:args();
    if (#args == 0 or not args[1]:any('/time')) then
        return;
    end

    -- Block all related commands..
    e.blocked = true;

    -- Handle: /time help - Displays the addons help information.
    if (#args >= 2 and args[2]:any('help')) then
        print_help();
        return;
    end

    -- Handle: /time save - Saves the current settings.
    if (#args >= 2 and args[2]:any('save')) then
        local positionX = clock.font.position_x;
        local positionY = clock.font.position_y;
        if (positionX ~= clock.settings.font.position_x) or (positionY ~= clock.settings.font.position_y) then
            clock.settings.font.position_x = positionX;
            clock.settings.font.position_y = positionY;
        end
        settings.save();
        print(chat.header(addon.name):append(chat.message('Settings saved.')));
        return;
    end

    -- Handle: /time reload - Reloads the settings from disk for the current player. (Or defaults otherwise.)
    if (#args >= 2 and args[2]:any('reload')) then
        settings.reload();
        print(chat.header(addon.name):append(chat.message('Settings reloaded.')));
        return;
    end

    -- Handle: /time reset - Resets the settings to defaults.
    if (#args >= 2 and args[2]:any('reset')) then
        -- Assuming the player does not want to delete their clocks when this is called..
        local clocks = clock.settings.clocks;
        settings.reset();
        clock.settings.clocks = clocks;
        settings.save();

        print(chat.header(addon.name):append(chat.message('Settings reset.')));
        return;
    end

    -- Handle: /time add <name> <offset> - Adds a clock with the given timezone offset.
    if (#args >= 4 and args[2]:any('add')) then
        -- Ensure the clock name given is valid..
        local name = args[3];
        if (name == nil or name:len() == 0) then
            print(chat.header(addon.name):append(chat.error('Invalid clock name.')));
            return;
        end

        -- Ensure the offset given is valid..
        local offset = args[4]:num_or(nil);
        if (offset == nil) then
            print(chat.header(addon.name):append(chat.error('Invalid timezone offset.')));
            return;
        end

        -- Find any existing clock with the same name..
        local k = clock.settings.clocks:find_if(function (v)
            return v[1]:lower() == name:lower();
        end);

        -- Found an existing entry, update it..
        if (k ~= nil) then
            clock.settings.clocks[k][2] = offset;
            settings.save();

            print(chat.header(addon.name)
                :append(chat.message('Updated clock \''))
                :append(chat.success('%s'))
                :append(chat.message('\' offset to: '))
                :append(chat.success('%s')):fmt(name, tostring(offset)));
            return;
        end

        -- Insert a new clock entry..
        clock.settings.clocks:append({ name, offset });
        settings.save();

        print(chat.header(addon.name):append(chat.message('Added clock: ')):append(chat.success(name)));
        return;
    end

    -- Handle: /time del <name> - Deletes a clock.
    -- Handle: /time delete <name> - Deletes a clock.
    -- Handle: /time rem <name> - Deletes a clock.
    -- Handle: /time remove <name> - Deletes a clock.
    if (#args >= 3 and args[2]:any('del', 'delete', 'rem', 'remove')) then
        -- Ensure the clock name given is valid..
        local name = args[3];
        if (name == nil or name:len() == 0) then
            print(chat.header(addon.name):append(chat.error('Invalid clock name.')));
            return;
        end

        -- Find a matching clock with the given name..
        local k = clock.settings.clocks:find_if(function (v)
            return v[1]:lower() == name:lower();
        end);

        if (k == nil) then
            print(chat.header(addon.name):append(chat.error('No matching clock found with that name.')));
            return;
        end

        -- Delete the clock..
        clock.settings.clocks:remove(k);
        settings.save();

        print(chat.header(addon.name):append(chat.message('Removed clock: ')):append(chat.success(name)));
        return;
    end

    -- Handle: /time clear - Clears all currently set clocks.
    if (#args >= 2 and args[2]:any('clear')) then
        clock.settings.clocks:clear();
        settings.save();

        print(chat.header(addon.name):append(chat.message('Removed all clocks.')));
        return;
    end

    -- Handle: /time f [format] - Displays or sets the timestamp format to be used with the clocks.
    -- Handle: /time fmt [format] - Displays or sets the timestamp format to be used with the clocks.
    -- Handle: /time format [format] - Displays or sets the timestamp format to be used with the clocks.
    if (#args >= 2 and args[2]:any('f', 'fmt', 'format')) then
        -- Print the current format..
        if (#args == 2) then
            print(chat.header(addon.name):append(chat.message('Current clock format: ')):append(chat.success(clock.settings.format)));
            return;
        end

        -- Updates the current format..
        local fmt = args:concat(' ', 3);
        clock.settings.format = fmt;
        settings.save();

        print(chat.header(addon.name):append(chat.message('Clock format set to: ')):append(chat.success(fmt)));
        return;
    end

    -- Handle: /time s [separator] - Displays or sets the separator to be used between each clock.
    -- Handle: /time sep [separator] - Displays or sets the separator to be used between each clock.
    -- Handle: /time separator [separator] - Displays or sets the separator to be used between each clock.
    if (#args >= 2 and args[2]:any('s', 'sep', 'separator')) then
        -- Print the current separator..
        if (#args == 2) then
            print(chat.header(addon.name):append(chat.message('Current clock separator: ')):append(chat.success(clock.settings.separator)));
            return;
        end

        -- Updates the current separator..
        local sep = args:concat(' ', 3);
        clock.settings.separator = sep;
        settings.save();

        print(chat.header(addon.name):append(chat.message('Clock separator set to: ')):append(chat.success(sep)));
        return;
    end

    -- Handle: /time c <a> <r> <g> <b> - Sets the clock display color.
    -- Handle: /time col <a> <r> <g> <b> - Sets the clock display color.
    -- Handle: /time color <a> <r> <g> <b> - Sets the clock display color.
    if (#args >= 6 and args[2]:any('c', 'col', 'color')) then
        local a = args[3]:num_or(128);
        local r = args[4]:num_or(255);
        local g = args[5]:num_or(255);
        local b = args[6]:num_or(255);

        -- Set the clock color..
        clock.settings.font.color = math.d3dcolor(a, r, g, b);
        settings.save();

        -- Reapply the font settings..
        if (clock.font ~= nil) then
            clock.font:apply(clock.settings.font);
        end

        print(chat.header(addon.name):append(chat.message('Clock color set to: '))
            :append(chat.success('%d %d %d %d'))
            :fmt(a, r, g, b));
        return;
    end

    -- Handle: /time h <day | date | moon> - Toggle visible elements of the clock display.
    -- Handle: /time hide <day | date | moon> - Toggle visible elements of the clock display.
    -- Handle: /time t <day | date | moon> - Toggle visible elements of the clock display.
    -- Handle: /time toggle <day | date | moon> - Toggle visible elements of the clock display.
    if (#args >= 3 and args[2]:any('h', 'hide', 't', 'toggle') and args[3]:any('day', 'date', 'moon')) then
        local toggle = args[3];
        local setting = clock.settings.hide[toggle];
        if (setting == false) then
            setting = true;
        else
            setting = false
        end
        clock.settings.hide[toggle] = setting;
        settings.save();

        print(chat.header(addon.name):append(chat.success(toggle)):append(chat.message(' visibility set to: ')):append(chat.success(setting)));
        return;
    end

    -- Unhandled: Print help information..
    print_help(true);
end);

--[[
* event: d3d_present
* desc : Event called when the Direct3D device is presenting a scene.
--]]
ashita.events.register('d3d_present', 'present_cb', function ()
    if (clock.settings.clocks:empty() or clock.font == nil) then
        if (clock.font ~= nil) then
            clock.font.text = '';
        end
        return;
    end

    local clocks = T{ };
    clock.settings.clocks:each(function (v)
        clocks:append(('%s %s'):fmt(os.date(clock.settings.format, (os.time() - clock.utc_diff) + v[2] * 3600), v[1]));
    end);
    -- Build the clock elements based on toggles
    local ffxi_time = tostring(get_timestamp())
    local ffxi_date = get_current_date()
    local ffxi_datetime = ffxi_time
    if (clock.settings.hide.day ~= false) then
        ffxi_datetime = ffxi_datetime .. " " .. tostring(ffxi_date.weekday)
    end
    if (clock.settings.hide.date ~= false) then
        ffxi_datetime = ffxi_datetime .. " " .. tostring(math.floor(ffxi_date.year)) .. "-" .. tostring(math.floor(ffxi_date.month)) .. "-" .. tostring(ffxi_date.day)
    end
    if (clock.settings.hide.moon ~= false) then
        ffxi_datetime = ffxi_datetime .. " " .. tostring(ffxi_date.moon_percent) .. "%"
    end
    clock.font.text = clocks:concat(clock.settings.separator) .. " " .. ffxi_datetime;
end);
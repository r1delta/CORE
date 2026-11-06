<img src="https://github.com/r1delta/core/assets/39478251/de059244-d6b4-4fdc-b45d-88bedb99c861" align="right">

# Core
These are the server scripts and other related files needed for r1delta

Place these files in `Titanfall/r1delta`, make sure you use `-game r1delta` in your launch args

Server-browser and direct-connect commands quote endpoint arguments so the
engine console preserves `ip:port` for NAT transport selection.

<img src="https://github.com/user-attachments/assets/121a9ec2-cba9-4fac-96e0-06472febeb52" align="left">

## Mod compatibility

Script mods that ship their own copy of a stock CORE file pin that file to the CORE version it was copied from. Menu scripts
and their `.menu` files are a pair: `ui/menu_map_select.nut` looks up elements (for example `NextMapPack`) that only the
matching `resource/ui/menus/map_select.menu` defines, and a missing element aborts the whole UI script initialisation
("HudElement ... could not be found on panel ..."), which leaves every menu button dead. Pilot Bots replaces
`ui/menu_mode_select.nut` and `resource/ui/menus/match_settings.menu` with R1Delta 2.14.x copies, so after a CORE update
those two files must be reinstalled from the mod, and any other mod that overrides a menu script, a `.menu` file or
`cl_*`/`_cl_mapspawn.nut` has the same requirement. Script errors whose stack names a file with a different line layout than
the one shipped here (for example `menu_serverbrowser.nut` frames past line 748, or `PMBServerRowFocus`) come from such a copy.

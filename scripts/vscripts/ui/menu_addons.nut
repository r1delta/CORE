
function main()
{
	Globalize( InitAddonsMenu )
	Globalize( UpdateAddonPaths )
	Globalize( ResetUIScript )
}

function InitAddonsMenu( menu )
{
	file.menu <- menu
}

function UpdateAddonPaths( button )
{
    ClientCommand( "update_addon_paths" )
}

function ResetUIScript( button )
{
	ClientCommand( "uiscript_reset" )
}
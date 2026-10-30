function main()
{
	local mapScriptName = "client/levels/cl_" + GetMapName()

	if ( ScriptExists( mapScriptName ) )
	{
		IncludeFile( mapScriptName )
		return
	}

	// No level script: converted R2 maps (no cl_<map>.nut) get their fullscreen map window computed from the overview data.
	IncludeFile( "client/levels/cl_r2port_minimap" )
}

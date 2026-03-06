function main()
{
	IncludeFileAllowMultipleLoads( "client/cl_carrier" ) //Included for skyshow dogfights
	IncludeFileAllowMultipleLoads( "client/objects/cl_hornet_fighter" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_phantom_fighter" )

	SetFullscreenMinimapParameters( 4.9, -1000, 250, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )

	// --- custom classic MP scripting after here ---
	if ( !GetClassicMPMode() )
		return

	IncludeScript( "client/cl_simulation_mp" )
}

main()
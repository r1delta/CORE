function main()
{
	if ( IsLobby() )
		return

	IncludeFileAllowMultipleLoads( "client/objects/cl_crow_dropship" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_crow_dropship_hero" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_goblin_dropship" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_goblin_dropship_hero" )

	IncludeFileAllowMultipleLoads( "client/objects/cl_control_panel" ) // dependent on extract mode
	IncludeFileAllowMultipleLoads( "client/objects/cl_titan_atlas" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_titan_ogre" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_titan_stryder" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_titan_destroyer" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_spectre" )
}

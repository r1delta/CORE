
function main()
{
	IncludeFile( "client/levels/cl_mp_nest2_fx" )

	if ( GetBugReproNum() == 321 )
		AddCreateCallback( "satchel1", TestFunc )

	level.musicEnabled = true //Turn off all music in this level
	
	SetFullscreenMinimapParameters( 3, 0, 0, 90 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )

	IncludeFileAllowMultipleLoads( "client/objects/cl_ai_turret" )
	// IncludeFileAllowMultipleLoads( "client/objects/cl_ai_turret_bb" )
}


function EntitiesDidLoad()
{
	printt("[LJS] call EntitiesDidLoad in nest2 map")

	SetUpHackedFx()	
}

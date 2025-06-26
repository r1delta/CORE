function main()
{
	IncludeFile( "client/levels/cl_mp_mia_fx" )
	IncludeFile( "client/levels/cl_mp_mia_dogfight" )

	SetFullscreenMinimapParameters( 3.5, 500, 3500, -90 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )
}	

function EntitiesDidLoad()
{
	SetupClientSideFx()
	//thread SkyboxSlowFlybys()
}
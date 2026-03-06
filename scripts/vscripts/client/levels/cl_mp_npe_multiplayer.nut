
function main()
{
	IncludeFileAllowMultipleLoads( "client/cl_carrier" ) //Included for skyshow dogfights
	IncludeFileAllowMultipleLoads( "client/objects/cl_hornet_fighter" )
	IncludeFileAllowMultipleLoads( "client/objects/cl_phantom_fighter" )

	SetFullscreenMinimapParameters( 2.7, 1000, 1800, 0 )
	//if ( GAMETYPE == COOPERATIVE ) // Probably not needed?
	//	SetCustomMinimapZoom( 2 )

	level.cabinHoloScreenAlpha <- 1.0

	PrecacheParticleSystem( "flood_light_white" )

	// --- custom classic MP scripting after here ---
	if ( !GetClassicMPMode() )
		return

	IncludeScript( "client/cl_simulation_mp" )
}

function EntitiesDidLoad()
{
	local rotation = Vector( 0.2, 0.5, 0.73 )
	local radius = 300

	local fxLight = CreateClientSideDynamicLight( Vector( -13560, -4768, 64 ), Vector( 0, 0, 0 ), rotation, radius )
	level.vdu_screen_light <- fxLight

	//local fxIndex 	= GetParticleSystemIndex( "flood_light_white" )
	//StartParticleEffectInWorld( fxIndex, Vector( -1055.97, 3183.97, 6404.28 ), Vector( 0, -0.00233459, 0 ) )
}

function VMTCallback_NPE_HoloScreen_Alpha( ent )
{
	return level.cabinHoloScreenAlpha
}
Globalize( VMTCallback_NPE_HoloScreen_Alpha )

main()
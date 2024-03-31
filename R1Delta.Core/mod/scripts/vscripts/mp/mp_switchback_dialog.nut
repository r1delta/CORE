function main()
{
	RegisterConversation( "aoe_trap_shot", VO_PRIORITY_GAMESTATE )

	if ( IsServer() )
		return

	local convRef = AddConversation( "aoe_trap_shot" )
	AddCustomVDUFunction( convRef, AOETrapShotVDU )
}

function AOETrapShotVDU( player )
{
	player.EndSignal( "OnDestroy" )
	local cam = level.camera
	cam.EndSignal( "OnDestroy" )

	cam.SetOrigin( Vector( -1121.0, -127.0, 1140.0 ) )
	cam.SetAngles( Vector( -14.0, 53.5, 0.0 ) )
	cam.SetFOV( 60.0 )

	wait( 3.0 )

	cam.SetOrigin( Vector( -703.0, 2667.0, 1889.0 ) )
	cam.SetAngles( Vector( 32.0, 55.0, 0.0 ) )
	cam.SetFOV( 90.0 )

	wait( 6.0 )
}
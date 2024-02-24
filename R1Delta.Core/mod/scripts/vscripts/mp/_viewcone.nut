function main()
{
	Globalize( ViewConeZero )
	Globalize( ViewConeZeroInstant )
	Globalize( ViewConeTight )
	Globalize( ViewConeTightHigh )
	Globalize( ViewConeDropPod )
	Globalize( ViewConeDropPodFrontR )
	Globalize( ViewConeDropPodFrontL )
	Globalize( ViewConeDropPodBackR )
	Globalize( ViewConeDropPodBackL )
	Globalize( ViewConeNarrow )
	Globalize( ViewConeRampFrontLeft )
	Globalize( ViewConeRampFrontRight )
	Globalize( ViewConeRampBackLeft )
	Globalize( ViewConeRampBackRight )
	Globalize( ViewConeRampFree )
	Globalize( ViewConeFree )
	Globalize( ViewConeFreeLookingForward )
	Globalize( ViewConeSideRightStandFront )
	Globalize( ViewConeSideRightStandBack )
	Globalize( ViewConeSideRightSitFront )
	Globalize( ViewConeSideRightSitBack )
	Globalize( ViewConeSideRightWithHeroStandFront )
	Globalize( ViewConeSideRightWithHeroStandBack )
	Globalize( ViewConeSideRightWithHeroSitFront )
	Globalize( ViewConeSideRightWithHeroSitBack )
	Globalize( SetAllViewConeSideRightNoHero )
	Globalize( InitView )

	AddGlobalAnimEvent( "ViewConeZero"            		, ViewConeZero )
	AddGlobalAnimEvent( "ViewConeTight"           		, ViewConeTight )
	AddGlobalAnimEvent( "ViewConeDropPod"         		, ViewConeDropPod )
	AddGlobalAnimEvent( "ViewConeDropPodFrontR"         , ViewConeDropPodFrontR )
	AddGlobalAnimEvent( "ViewConeDropPodFrontL"         , ViewConeDropPodFrontL )
	AddGlobalAnimEvent( "ViewConeDropPodBackR"         	, ViewConeDropPodBackR )
	AddGlobalAnimEvent( "ViewConeDropPodBackL"         	, ViewConeDropPodBackL )
	AddGlobalAnimEvent( "ViewConeNarrow"          		, ViewConeNarrow )
	AddGlobalAnimEvent( "ViewConeRampFrontLeft"   		, ViewConeRampFrontLeft )
	AddGlobalAnimEvent( "ViewConeRampFrontRight"  		, ViewConeRampFrontRight )
	AddGlobalAnimEvent( "ViewConeRampBackLeft"    		, ViewConeRampBackLeft )
	AddGlobalAnimEvent( "ViewConeRampBackRight"   		, ViewConeRampBackRight )
	AddGlobalAnimEvent( "ViewConeRampFree"        		, ViewConeRampFree )
	AddGlobalAnimEvent( "ViewConeFree"            		, ViewConeFree )
	AddGlobalAnimEvent( "ViewConeFreeLookingForward"	, ViewConeFreeLookingForward )
}

function ViewConeZero( player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.5 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( 0 )
	player.PlayerCone_SetMaxYaw( 0 )
	player.PlayerCone_SetMinPitch( 0 )
	player.PlayerCone_SetMaxPitch( 0 )
}

function ViewConeZeroInstant( player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.0 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( 0 )
	player.PlayerCone_SetMaxYaw( 0 )
	player.PlayerCone_SetMinPitch( 0 )
	player.PlayerCone_SetMaxPitch( 0 )
}

function ViewConeTight( player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.5 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -15 )
	player.PlayerCone_SetMaxYaw( 15 )
	player.PlayerCone_SetMinPitch( -15 )
	player.PlayerCone_SetMaxPitch( 15 )
}

function ViewConeTightHigh( player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.5 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -15 )
	player.PlayerCone_SetMaxYaw( 15 )
	player.PlayerCone_SetMinPitch( -60 )
	player.PlayerCone_SetMaxPitch( 15 )
}

function ViewConeDropPod( player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.5 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -70 )
	player.PlayerCone_SetMaxYaw( 70 )
	player.PlayerCone_SetMinPitch( -30 )
	player.PlayerCone_SetMaxPitch( 30 )
}
const FRONTDIF = -75
const BACKDIF = -30
function ViewConeDropPodFrontR( player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.5 )

	player.PlayerCone_FromAnim()
	//range is 140
	player.PlayerCone_SetMinYaw( -70 - FRONTDIF )
	player.PlayerCone_SetMaxYaw( 70 - FRONTDIF )
	player.PlayerCone_SetMinPitch( -30 )
	player.PlayerCone_SetMaxPitch( 30 )
}

function ViewConeDropPodFrontL( player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.5 )

	player.PlayerCone_FromAnim()
	//range is 140
	player.PlayerCone_SetMinYaw( -70 + FRONTDIF )
	player.PlayerCone_SetMaxYaw( 70 + FRONTDIF )
	player.PlayerCone_SetMinPitch( -30 )
	player.PlayerCone_SetMaxPitch( 30 )
}

function ViewConeDropPodBackR( player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.5 )

	player.PlayerCone_FromAnim()
	//range is 140
	player.PlayerCone_SetMinYaw( -70 - BACKDIF )
	player.PlayerCone_SetMaxYaw( 70 - BACKDIF )
	player.PlayerCone_SetMinPitch( -30 )
	player.PlayerCone_SetMaxPitch( 30 )
}

function ViewConeDropPodBackL( player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.5 )

	player.PlayerCone_FromAnim()
	//range is 140
	player.PlayerCone_SetMinYaw( -70 + BACKDIF )
	player.PlayerCone_SetMaxYaw( 70 + BACKDIF )
	player.PlayerCone_SetMinPitch( -30 )
	player.PlayerCone_SetMaxPitch( 30 )
}

function ViewConeNarrow( player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.5 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -60 )
	player.PlayerCone_SetMaxYaw( 60 )
	player.PlayerCone_SetMinPitch( -60 )
	player.PlayerCone_SetMaxPitch( 60 )
}

function ViewConeFreeLookingForward( player )
{
	if ( !player.IsPlayer() )
		return
	ViewConeFree( player )

	thread InitView( player, 0, 180 )
}

function SetAllViewConeSideRightNoHero()
{
	SetSequenceViewCone( ViewConeSideRightStandFront, 	"jumpSideR", 0, "idle" )
	SetSequenceViewCone( ViewConeSideRightSitFront, 	"jumpSideR", 1, "idle" )
	SetSequenceViewCone( ViewConeSideRightStandBack, 	"jumpSideR", 2, "idle" )
	SetSequenceViewCone( ViewConeSideRightSitBack, 		"jumpSideR", 3, "idle" )
}

function ViewConeSideRightWithHeroStandFront( player )
{
	if ( !player.IsPlayer() )
		return
	ViewConeRampFree( player )

	thread InitView( player, 15, 20 )
}

function ViewConeSideRightWithHeroSitFront( player )
{
	if ( !player.IsPlayer() )
		return
	ViewConeRampFree( player )

	thread InitView( player, 0, 50 )
}

function ViewConeSideRightWithHeroStandBack( player )
{
	if ( !player.IsPlayer() )
		return
	ViewConeRampFree( player )

	thread InitView( player, 15, 45 )
}

function ViewConeSideRightWithHeroSitBack( player )
{
	if ( !player.IsPlayer() )
		return
	ViewConeRampFree( player )

	thread InitView( player, 0, 50 )
}

function ViewConeSideRightStandFront( player )
{
	if ( !player.IsPlayer() )
		return
	ViewConeRampFree( player )

	thread InitView( player, 30, -10 )
}

function ViewConeSideRightSitFront( player )
{
	if ( !player.IsPlayer() )
		return
	ViewConeRampFree( player )

	thread InitView( player, 20, -20 )
}


function ViewConeSideRightStandBack( player )
{
	if ( !player.IsPlayer() )
		return
	ViewConeRampFree( player )

	thread InitView( player, 30, 20 )
}

function ViewConeSideRightSitBack( player )
{
	if ( !player.IsPlayer() )
		return
	ViewConeRampFree( player )

	thread InitView( player, 20, 35 )
}

function ViewConeRampFrontLeft( player )
{
	if ( !player.IsPlayer() )
		return
	ViewConeRampFree( player )

	thread InitView( player, 5, 70 )
}

function ViewConeRampFrontRight( player )
{
	if ( !player.IsPlayer() )
		return
	ViewConeRampFree( player )

	thread InitView( player, 5, -70 )
}

function ViewConeRampBackLeft( player )
{
	if ( !player.IsPlayer() )
		return
	ViewConeRampFree( player )

	thread InitView( player, 5, 100 )
}

function ViewConeRampBackRight( player )
{
	if ( !player.IsPlayer() )
		return
	ViewConeRampFree( player )

	thread InitView( player, 5, -100 )
}

function ViewConeRampFree( player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.5 )

	player.PlayerCone_FromAnim()

	if ( "viewcodeNoLookBehind" in level )	//Set this if you don't want player to turn 360, need this for Colony and this was lowest-impact way to do it
	{
		player.PlayerCone_SetMinYaw( -89 )
		player.PlayerCone_SetMaxYaw( 81 )
	}
	else
	{
		player.PlayerCone_SetMinYaw( -179 )
		player.PlayerCone_SetMaxYaw( 181 )
	}

	player.PlayerCone_SetMinPitch( -30 )
	player.PlayerCone_SetMaxPitch( 60 )
}

function ViewConeFree( player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.5 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -179 )
	player.PlayerCone_SetMaxYaw( 181 )
	player.PlayerCone_SetMinPitch( -60 )
	player.PlayerCone_SetMaxPitch( 60 )
}

function InitView( player, pitch, yaw )
{
	if ( !player.IsPlayer() )
		return
	player.EndSignal( "Disconnected" )

	local dropship = player.GetParent()

	while( !dropship )
	{
		wait 0.05
		dropship = player.GetParent()
	}

	for( local i = 0; i < 5; i++ )
	{
		player.SetLocalAngles( Vector( pitch, yaw, 0) )
		wait 0.1
	}
}


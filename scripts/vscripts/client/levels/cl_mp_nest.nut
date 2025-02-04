function main()
{
	if ( GetBugReproNum() == 321 )
		AddCreateCallback( "satchel1", TestFunc )

	level.musicEnabled = true //Turn off all music in this level
	SetFullscreenMinimapParameters( 1.0, 0, 0, 0 )
	IncludeFileAllowMultipleLoads( "client/objects/cl_ai_turret" )
}

function EntitiesDidLoad()
{
	local prop = CreatePropDynamic( "models/dev/editor_ref.mdl" )
	prop.SetOrigin( Vector(0,0,0) )
	prop.SetAngles( Vector(0,0,0) )
	prop.SetFadeDistance( 150 )
}

function TestFunc( entity, isRecreate )
{
	thread TestThread()
}

function TestThread()
{
	printt( "creation happened" )
	wait 3
	printt( "wait finished" )
}

main()
function main()
{
	IncludeFile( "mp/capture_point" )
}

function EntitiesDidLoad()
{
	SpawnPoints_SetRatingMultipliers_Enemy( TD_AI, -2.0, -0.25, 0.0 )
	SpawnPoints_SetRatingMultipliers_Friendly( TD_AI, 0.0, 0.0, 0.0 )

	if ( !level.hardpointModeInitialized )
		WaitEndFrame() // let capture_point entitiesdidload run first
	if ( !level.hardpointModeInitialized )
		return

	SetupAssaultPointKeyValues()
	if ( IsNPCSpawningEnabled() )
		thread SetupCapturePointNPCs( level.hardpoints )
}

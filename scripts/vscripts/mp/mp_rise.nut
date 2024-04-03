
const crateMdl = "models/IMC_base/cargo_container_imc_01_white_open.mdl"

function main()
{
	IncludeFile( "mp_rise_shared" )
	if ( reloadingScripts )
		return

	PrecacheModel( crateMdl )

	//PrecacheModel( "models/vehicle/goblin_dropship/goblin_dropship.mdl" )
	//PrecacheEntity( "npc_dropship" )
	//FlagSet( "Zipline_Spawning" )
	//FlagSet( "Enable_Instamissions" )
	//FlagSet( "DisableDropships" )

	if ( reloadingScripts )
		return

	FlagSet( "DogFights" ) // tells flightpath to bake these into the ain

//	AddSpawnCallback( "trigger_multiple", SpawnRiseTrigger )

	GM_AddEndRoundFunc( EndRoundMain )
}

function EntitiesDidLoad()
{
	//level.defenseTeam = TEAM_MILITA

	switch ( GameRules.GetGameMode() )
	{
		case BIG_BROTHER:
		case HEIST:
			CreateBigBrotherPanel( Vector(-2840, 692, 448), Vector(0, 90, 0 ) )
			CreateBigBrotherPanel( Vector(-1672, -704, 364), Vector(0, -90, 0 ) )
	}

	if ( EvacEnabled() )
		EvacSetup()

	if ( GetClassicMPMode() )
		delaythread ( CLASSIC_MP_SKYSHOW_DOGFIGHTS_DELAY ) StratonHornetDogfights()

	local bug80138 = [	Vector( 1443.0, -628.0, 548.0 ),
						Vector( 1317.0, -628.0, 548.0 ),
						Vector( 1191.0, -628.0, 548.0 ),
						Vector( 1065.0, -628.0, 548.0 ),
						Vector( 1443.0, -736.0, 548.0 ),
						Vector( 1317.0, -736.0, 548.0 ),
						Vector( 1191.0, -736.0, 548.0 ),
						Vector( 1065.0, -736.0, 548.0 ),
						Vector( 2094.0, -628.0, 540.0 ),
						Vector( 1968.0, -628.0, 540.0 ),
						Vector( 1842.0, -628.0, 540.0 ),
						Vector( 1716.0, -628.0, 540.0 ),
						Vector( 2094.0, -736.0, 540.0 ),
						Vector( 1968.0, -736.0, 540.0 ),
						Vector( 1842.0, -736.0, 540.0 ),
						Vector( 1716.0, -736.0, 540.0 )	]

	foreach ( pos in bug80138 )
	{
		local prop = CreatePropDynamic( crateMdl, pos, Vector( 0.0, 0.0, 0.0 ), 6 )
		prop.MakeInvisible()
	}
}


function SpawnRiseTrigger( trigger )
{
	if ( trigger.GetName() != "trigger_groundhurt" )
		return

	trigger.ConnectOutput( "OnStartTouch", TriggerGroundHurt )
}

function TriggerGroundHurt( trigger, activator, caller, value )
{
	thread GuyTouchingHurtTrigger( activator, trigger )
}

function GuyTouchingHurtTrigger( guy, trigger )
{
	if ( !IsAlive( guy ) )
		return

	if ( !guy.IsHuman() )
		return

	if ( !guy.IsPlayer() )
		return

	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "Disconnected" )

	for ( ;; )
	{
		wait 0.1
		if ( !guy.IsOnGround() )
			continue

		if ( !trigger.IsTouching( guy ) )
			return

		local damage = RandomInt( 9, 13 )
		guy.TakeDamage( damage, trigger, trigger, { scriptType = DF_NO_INDICATOR, damageSourceId=eDamageSourceId.mp_extreme_environment } )
	}
}

function EvacSetup()
{
	local spectatorNode1 = GetEnt( "spec_cam1" )
	local spectatorNode2 = GetEnt( "spec_cam2" )

	Evac_AddLocation( "escape_node1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles() )
	Evac_AddLocation( "escape_node2", spectatorNode2.GetOrigin(), spectatorNode2.GetAngles() )

	local spacenode = CreateScriptRef( Vector( -3818.79, 9986.7, 12600 ), Vector( 0, 90, 0 ) )

	Evac_SetSpaceNode( spacenode )
	Evac_SetupDefaultVDUs()
}

function EndRoundMain()
{
	if ( EvacEnabled() )
		GM_SetObserverFunc( EvacObserverFunc )
}

function EvacObserverFunc( player )
{
	player.SetObserverModeStaticPosition( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorPos )
	player.SetObserverModeStaticAngles( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorAng )

	player.StartObserverMode( OBS_MODE_CHASE )
	player.SetObserverTarget( null )
}



main()
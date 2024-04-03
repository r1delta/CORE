function main()
{
}

function EntitiesDidLoad()
{
	StartPatrolGuys()
	StartSaluteGuys()
	StartWavemarvins()
}

function StartPatrolGuys()
{
	// Guy near railing conversation
	local path1 = []
	path1.append( { origin = Vector( 807, -4450, 120 ), angles = Vector( 0, -145, 0 ) } )
	path1.append( { origin = Vector( 88, -4101, 120 ), angles = Vector( 0, -26, 0 ) } )
	local guy1 = SpawnSkitGuy( "mcor_walking_1", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_CAPTAIN_MDL, "mp_weapon_g2" )
	thread PatrolForever( guy1, path1, 1.1, "patrol_walk_highport" )

	// Guy on farside dock patrol
	local path1 = []
	path1.append( { origin = Vector( 1377, -4852, 120 ), angles = Vector( 0, 0, 0 ) } )
	path1.append( { origin = Vector( 1951, -4853, 120 ), angles = Vector( 0, -146, 0 ) } )
	local guy1 = SpawnSkitGuy( "mcor_walking_2", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_CAPTAIN_MDL, "mp_weapon_g2" )
	thread PatrolForever( guy1, path1, 1.0, "patrol_walk_lowport" )

	// Sniper1 hangar on roof
	local path2 = []
	path2.append( { origin = Vector( 1338, -4091, 440 ), angles = Vector( 0, -69, 0 ) } )
	path2.append( { origin = Vector( 1194, -4082, 440 ), angles = Vector( 0, 160, 0 ) } )
	path2.append( { origin = Vector( 998, -4104, 440), angles = Vector( 0, -142, 0 ) } )
	local guy2 = SpawnSkitGuy( "mcor_walking_3", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_GRUNT_MDL, "mp_weapon_sniper" )
	thread PatrolForever( guy2, path2, 0.8, "patrol_walk_lowport" )

	// Sniper2 hangar on roof
	local path2 = []
	path2.append( { origin = Vector( 1231, -3798, 440), angles = Vector( 0, 166, 0 ) } )
	path2.append( { origin = Vector( 1011, -3634, 440 ), angles = Vector( 0, 132, 0 ) } )
	path2.append( { origin = Vector( 1322, -3646, 440 ), angles = Vector( 0, 91, 0 ) } )
	local guy2 = SpawnSkitGuy( "mcor_walking_4", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_GRUNT_MDL, "mp_weapon_dmr" )
	thread PatrolForever( guy2, path2, 1.0, "patrol_walk_highport" )

	// Guy on turret dock patrol
	local path1 = []
	path1.append( { origin = Vector( 1160, -5161, 120 ), angles = Vector( 0, 180, 0 ) } )
	path1.append( { origin = Vector( 822, -5159, 120 ), angles = Vector( 0, 0, 0 ) } )
	local guy1 = SpawnSkitGuy( "mcor_walking_5", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_CAPTAIN_MDL, "mp_weapon_rspn101" )
	thread PatrolForever( guy1, path1, 0.8, "patrol_walk_lowport" )

	// Guard1 on prisoner patrol
	local path1 = []
	path1.append( { origin = Vector( 670, -3188, 112 ), angles = Vector( 0, 86, 0 ) } )
	path1.append( { origin = Vector( 690, -2619, 112 ), angles = Vector( 0, 87, 0 ) } )
	path1.append( { origin = Vector( 986, -2364, 112 ), angles = Vector( 0, -17, 0 ) } )
	path1.append( { origin = Vector( 1320, -2633, 112 ), angles = Vector( 0, -73, 0 ) } )
	path1.append( { origin = Vector( 1396, -3074, 112 ), angles = Vector( 0, -139, 0 ) } )
	local guy1 = SpawnSkitGuy( "mcor_walking_6", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_GRUNT_MDL, "mp_weapon_shotgun" )
	thread PatrolForever( guy1, path1, 1.1, "patrol_walk_lowport" )

	// Guard2 on prisoner patrol
	local path1 = []
	path1.append( { origin = Vector( 986, -2364, 112 ), angles = Vector( 0, -17, 0 ) } )
	path1.append( { origin = Vector( 1320, -2633, 112 ), angles = Vector( 0, -73, 0 ) } )
	path1.append( { origin = Vector( 1396, -3074, 112 ), angles = Vector( 0, -139, 0 ) } )
	path1.append( { origin = Vector( 670, -3188, 112 ), angles = Vector( 0, 86, 0 ) } )
	path1.append( { origin = Vector( 690, -2619, 112 ), angles = Vector( 0, 87, 0 ) } )
	local guy1 = SpawnSkitGuy( "mcor_walking_7", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_GRUNT_MDL, "mp_weapon_rspn101" )
	thread PatrolForever( guy1, path1, 1.1, "patrol_walk_lowport" )

	// Titan on bay patrol
	local path1 = []
	path1.append( { origin = Vector( 2350, -5029, -19 ), angles = Vector( 0, -158, 0 ) } )
	path1.append( { origin = Vector( 1665, -5417, -16 ), angles = Vector( 0, 145, 0 ) } )
	path1.append( { origin = Vector( 444, -5582, 2 ), angles = Vector( 0, -172, 0 ) } )
	path1.append( { origin = Vector( -334, -5672, -14 ), angles = Vector( 0, -156, 0 ) } )
	path1.append( { origin = Vector( -750, -6150, -20 ), angles = Vector( 0, -106, 0 ) } )
	path1.append( { origin = Vector( 320, -6473, -10 ), angles = Vector( 0, 40, 0 ) } )
	local guy1 = SpawnSkitGuy( "mcor_titan_1", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, ATLAS_MODEL, "mp_titanweapon_40mm" )
	thread PatrolForever( guy1, path1, 0.7, "Walk_all_forward" )

	// Titan on harbor patrol
	local path1 = []
	path1.append( { origin = Vector( -392, -5234, -20 ), angles = Vector( 0, 74, 0 ) } )
	path1.append( { origin = Vector( -148, -4123, 6 ), angles = Vector( 0, 97, 0 ) } )
	path1.append( { origin = Vector( -165, -3497, -16 ), angles = Vector( 0, 89, 0 ) } )
	path1.append( { origin = Vector( -161, -3113, -19 ), angles = Vector( 0, 89, 0 ) } )
	path1.append( { origin = Vector( 201, -2890, 34 ), angles = Vector( 0, 26, 0 ) } )
	path1.append( { origin = Vector( 632, -2625, 112 ), angles = Vector( 0, 74, 0 ) } )
	path1.append( { origin = Vector( 543, -2207, 112 ), angles = Vector( 0, 103, 0 ) } )
	path1.append( { origin = Vector( 375, -1750, 112 ), angles = Vector( 0, 148, 0 ) } )
	path1.append( { origin = Vector( 153, -1419, 112 ), angles = Vector( 0, 85, 0 ) } )
	path1.append( { origin = Vector( 177, -1228, 105 ), angles = Vector( 0, 6, 0 ) } )
	path1.append( { origin = Vector( 626, -1286, 112 ), angles = Vector( 0, -122, 0 ) } )
	local guy1 = SpawnSkitGuy( "mcor_titan_2", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, OGRE_MODEL, "mp_titanweapon_xo16" )
	thread PatrolForever( guy1, path1, 0.5, "Walk_all_forward" )

	// ADD MOAR DUDEZ HERE!!!!
	// local guy3 = SpawnSkitGuy( "mcor_walking_3", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_GRUNT_MDL, "mp_weapon_hemlock" )

}


function StartSaluteGuys()
{
	SetupSaluteGuy( SpawnSkitGuy( "mcor_salute_1", "", Vector( 883, -5012, 112 ), Vector( 0, -137, 0 ), TEAM_MILITIA, TEAM_MILITIA_GRUNT_MDL, "mp_weapon_rspn101" ), false )
	SetupSaluteGuy( SpawnSkitGuy( "mcor_salute_2", "", Vector( 545, -4105, 112 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_ROCKET_GRUNT_MDL, "mp_weapon_rspn101" ), false )
	//SetupSaluteGuy( SpawnSkitGuy( "mcor_salute_3", "", Vector( 601, -4105, 112 ), Vector( 0, 90, 0 ), TEAM_MILITIA, TEAM_MILITIA_ROCKET_GRUNT_MDL, "mp_weapon_car" ), false )
	SetupSaluteGuy( SpawnSkitGuy( "mcor_salute_4", "", Vector( 1161, -4593, 112 ), Vector( 0, -90, 0 ), TEAM_MILITIA, TEAM_MILITIA_CAPTAIN_MDL, "mp_weapon_car" ), true )

	// ADD MOAR DUDEZ HERE!!!!
	// NOTE: To add more, change "mcor_salute_1" to something unique, 1st Vector is origin, 2nd Vector is angles.  true/false at the far right is if they should speak or not



}


function StartWavemarvins()
{
	//SetupWaveMarvin( SpawnSkitGuy( "marvin_1", "", Vector( 1121, -4689, 112 ), Vector( 0, -40, 0 ), TEAM_MILITIA, MARVIN_MODEL, "mp_weapon_rspn101" ), "mv_idle_SMG2" )

	// ADD MOAR DUDEZ HERE!!!!
	// Change "mv_idle_unarmed" to be something else maybe: mv_idle_weld, mv_fireman_idle, mv_idle_wash_window_noloop, mv_idle_buff_window_noloop


}


//--------------------------------------------------------------
//--------------------------------------------------------------
//--------------------------------------------------------------

function SetupWaveMarvin( guy, idleAnim )
{
	PlayAnimOnSkitGuy( guy, idleAnim )

    local trigger = CreateScriptCylinderTrigger( guy.GetOrigin(), 150 ) // origin, radius
    trigger.s.guy <- guy
    guy.s.idleAnim <- idleAnim

    AddCallback_ScriptTriggerEnter( trigger, OnWaveMarvinTriggerEnter )
    ScriptTriggerEnable( trigger, true )
}

function OnWaveMarvinTriggerEnter( trigger, player )
{
	thread DoWave( trigger.s.guy )
}

function DoWave( guy )
{
	PlayAnimOnSkitGuy( guy, "mv_wave_unarmed" )

	local animLen = guy.GetSequenceDuration( "mv_wave_unarmed" )

	wait animLen - 0.25

	PlayAnimOnSkitGuy( guy, guy.s.idleAnim )
}

function SetupSaluteGuy( guy, shouldSpeak = false )
{
	PlayAnimOnSkitGuy( guy, "CQB_Idle_Casual" )

    local trigger = CreateScriptCylinderTrigger( guy.GetOrigin(), 150 ) // origin, radius
    trigger.s.guy <- guy
    guy.s.shouldSpeak <- shouldSpeak

    AddCallback_ScriptTriggerEnter( trigger, OnSaluteEnterTrigger )
    ScriptTriggerEnable( trigger, true )
}

function OnSaluteEnterTrigger( trigger, player )
{
	//printt("OnSaluteEnterTrigger")
	thread DoSalute( trigger.s.guy )
}

function DoSalute( guy )
{
	PlayAnimOnSkitGuy( guy, "React_salute")

	local animLen = guy.GetSequenceDuration( "React_salute" )

	if( guy.s.shouldSpeak )
		EmitSoundOnEntity( guy, "diag_mcor_grunt1_gs_addressplayer_03_1" )

	wait animLen - 0.25

	PlayAnimOnSkitGuy( guy, "CQB_Idle_Casual" )
}

function PlayAnimOnSkitGuy( guy, anim )
{
	local origin = HackGetDeltaToRef(guy.GetOrigin(), guy.GetAngles(), guy, anim )
	thread PlayAnimGravity( guy, anim, origin, guy.GetAngles() )
}


function PatrolForever( guy, path, walkSpeedScale = 0.8, walkAnim = "patrol_walk_bored" )
{
	guy.EndSignal( "OnDeath" )

	guy.DisableStarts()
	guy.SetMoveSpeedScale( walkSpeedScale )
	guy.SetMoveAnim( walkAnim )

	local waitSignal = "OnEnterAssaultTolerance" //"OnFinishedAssault"
	local pathfindingFailTimeout = 200

	OnThreadEnd(
		function() : ( guy )
		{
			if ( IsAlive( guy ) )
				DeleteSkitGuy( guy.s.skitGuyName )
		}
	)

	guy.SetOrigin( path[ 0 ].origin )
	guy.SetAngles( path[ 0 ].angles )

	while(1)
	{
		foreach ( idx, pathpoint in path )
		{
			local goalradius = 36 //STANDARDGOALRADIUS
			guy.DisableArrivalOnce( true )  // always want arrivals disabled because they are blended from run anim, not walking

			local assaultEnt = CreateStrictAssaultEnt( pathpoint.origin, pathpoint.angles, goalradius )
			guy.AssaultPointEnt( assaultEnt )

			local result = WaitSignalTimeout( guy, pathfindingFailTimeout, waitSignal )
			if ( result == null || result.signal != waitSignal )
			{
				printt( guy, "'s scripted walk pathfinding stopped, quitting." )
				//break
			}
		}

/*
		wait 1.75

		local lastpath = path[ path.len() - 1 ]
		local origin = HackGetDeltaToRef( lastpath.origin, lastpath.angles, guy, "CQB_Idle_Casual" )
		thread PlayAnimGravity( guy, "CQB_Idle_Casual", origin, guy.GetAngles() )

		wait 5

		guy.Anim_Stop()

		wait 1

		path.reverse()
*/

	}

}

function SpawnSkitGuy( name, anim, origin, angles, team = TEAM_IMC, model = TEAM_IMC_GRUNT_MDL, weapon = "mp_weapon_semipistol" )
{
	if ( !( "skitguys" in level ) )
		level.skitguys <- {}

	if ( name in level.skitguys )
		DeleteSkitGuy( name )
	else
		level.skitguys[ name ] <- null

	local guyType = "grunt"
	if ( StringContains( name, "marvin" ) )
		guyType = "marvin"

	// spawn the guy
	local guy = null
	if ( guyType == "marvin" )
	{
		guy = CreateEntity( "npc_marvin" )
		guy.kv.additionalequipment = "Nothing"
		guy.SetModel( MARVIN_MODEL )

		DispatchSpawn( guy, true )

		guy.SetTeam( TEAM_SPECTATOR )
		guy.SetMoveSpeedScale( 0.6 )

		TakeAllJobs( guy )
	}
	else
	{
		guy = CreateGrunt( team, model, weapon )
		DispatchSpawn( guy, true )
	}

	guy.SetTitle( "" )

	local ref = CreateScriptMover( guy, origin, angles )
	ref.SetOrigin( origin )
	ref.SetAngles( angles )
	guy.s.skitRef <- ref

	guy.SetOrigin( ref.GetOrigin() )
	guy.SetAngles( ref.GetAngles() )
	guy.StayPut( true )

	MakeInvincible( guy )
	guy.SetEfficientMode( true )
	guy.AllowHandSignals( false )
	guy.AllowFlee( false )

	guy.s.skitAnim <- anim
	guy.s.skitGuyName <- name

	level.skitguys[ name ] = guy

	return guy
}

function DeleteSkitGuy( name )
{
	if ( !( name in level.skitguys ) )
	{
		printt( "WARNING tried to clear a skit slot that was already clear, name:", name )
		return
	}

	KillSkitGuy( name )

	level.skitguys[ name ] = null
}

function KillSkitGuy( name )
{
	Assert( ( name in level.skitguys ), "couldn't find index in level.skitguys: " + name )

	local guy = level.skitguys[ name ]

	if ( IsAlive( guy ) )
	{
		if ( "skitRef" in guy.s && IsValid( guy.s.skitRef ) )
		{
			guy.s.skitRef.Kill()
		}

		guy.Anim_Stop()
		ClearInvincible( guy )
		guy.Kill()
	}
	else if ( IsValid( guy ) )
	{
		guy.Destroy()
	}
}







main()
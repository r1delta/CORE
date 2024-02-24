const SAFETY_BATON_MODEL 		= "models/industrial/safety_baton.mdl"
const PISTOL_MODEL 				= "models/weapons/p2011sp/w_p2011sp.mdl"

PrecacheModel( SAFETY_BATON_MODEL )
PrecacheModel( PISTOL_MODEL )


function main()
{
	FlagSet( "DisableDropships" )

	level.loadoutCrateManagedEntArrayID <- CreateScriptManagedEntArray()

	AddCallback_OnClientConnecting( SetupInteractiveProps )
}


function EntitiesDidLoad()
{
	StartPatrolGuys()
	StartSaluteGuys()
	StartWavemarvins()

	// Give Bish pistols
	local bish = GetEnt( "prop_dynamic_4" )  // TODO: Rename Bish prop to something more bishlike
 	CreateAndEquipProp( bish, "L_HAND", Vector( 90, 90, 0 ), PISTOL_MODEL, "bish_pistol_l" )
	CreateAndEquipProp( bish, "R_HAND", Vector( 90, 90, 0 ), PISTOL_MODEL, "bish_pistol_r" )

	// Give Marvin baton
	local marvin_baton = GetEnt( "marvin_titan_controller" )  // TODO: Rename Bish prop to something more bishlike
 	CreateAndEquipProp( marvin_baton, "L_HAND", Vector( 0, 0, 0 ), SAFETY_BATON_MODEL, "marvin_safety_baton_l" )
	CreateAndEquipProp( marvin_baton, "R_HAND", Vector( 0, 0, 180 ), SAFETY_BATON_MODEL, "marvin_safety_baton_r" )
}


function SetupInteractiveProps( player )
{
	// HACK - If we want to get this working with multiplayer, this needs changed
	local playerTeam = player.GetTeam()

	AddLoadoutCrate( playerTeam, Vector( -221, 436, 6 ), Vector( 0, -45, 0), "titan", false )
	AddLoadoutCrate( playerTeam, Vector( 206.77, 845, 32 ), Vector( 0, 90, 180), "pilot", false )


	// Start Map Drop Pods
	AddMapStartPod( playerTeam, Vector( -790, 378, 6.5 ),  Vector( 0, 0, 0 ) , "mp_outpost_207", "Stealth Raid on Outpost 207" )
	AddMapStartPod( playerTeam, Vector( -790, 603, 6.5 ),  Vector( 0, 0, 0 ) , "mp_smugglers_cove", "Defend The Dam on Smugglers Cove" )
	AddMapStartPod( playerTeam, Vector( -790, 828, 6.5 ),  Vector( 0, 0, 0 ) , "mp_airbase", "Use this Marvin to Steal IMC Plans on Airbase" )

	// Start Map Titanfall
	AddMapStartPod( playerTeam, Vector( -189, 492, 6.5 ),  Vector( 0, 0, 0 ) , "mp_corporate", "Hijack IMC Titan Prototype on Corporate" )

}




function CreateAndEquipProp( owner, attachment, hackAngles, modelName, uniqueName )
{
	local attachIdx = owner.LookupAttachment( attachment )
	local angles = owner.GetAttachmentAngles( attachIdx )

	// HACK!  Adjust the angles because the tags don't match
	angles += hackAngles

	local pistol = CreatePropPhysics( modelName, owner.GetAttachmentOrigin( attachIdx ), angles )
	pistol.SetName( UniqueString( uniqueName ) )
	pistol.SetParent( owner, attachment, true )
}

function StartPatrolGuys()
{
	// Shotgun Patrol Captain
	local path1 = []
	path1.append( { origin = Vector( -694, 358, 6 ), angles = Vector( 0, -56, 0 ) } )
	path1.append( { origin = Vector( -205, 357, 6 ), angles = Vector( 0, 0, 0 ) } )
	path1.append( { origin = Vector( -111, 461, 6 ), angles = Vector( 0, 90, 0 ) } )
	path1.append( { origin = Vector( -113, 639, 6 ), angles = Vector( 0, 90, 0 ) } )
	path1.append( { origin = Vector( -243, 722, 6 ), angles = Vector( 0, 160, 0 ) } )
	path1.append( { origin = Vector( -677, 705, 6 ), angles = Vector( 0, -90, 0 ) } )
	local guy1 = SpawnSkitGuy( "mcor_walking_1", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_CAPTAIN_MDL, "mp_weapon_shotgun" )
	thread PatrolForever( guy1, path1, 1.1, "patrol_walk_lowport" )

	// Shotgun Patrol Captain
	local path1 = []
	path1.append( { origin = Vector( 222, 92, 9 ), angles = Vector( 0, 86, 0 ) } )
	path1.append( { origin = Vector( 212, 377, 1 ), angles = Vector( 0, 2, 0 ) } )
	path1.append( { origin = Vector( 392, 379, 1 ), angles = Vector( 0, 5, 0 ) } )
	path1.append( { origin = Vector( 493, 483, 1 ), angles = Vector( 0, 81, 0 ) } )
	path1.append( { origin = Vector( 498, 674, 7 ), angles = Vector( 0, 45, 0 ) } )
	path1.append( { origin = Vector( 656, 847, 9 ), angles = Vector( 0, 166, 0 ) } )
	path1.append( { origin = Vector( 498, 674, 7 ), angles = Vector( 0, 45, 0 ) } )
	path1.append( { origin = Vector( 493, 483, 1 ), angles = Vector( 0, 81, 0 ) } )
	path1.append( { origin = Vector( 392, 379, 1 ), angles = Vector( 0, 5, 0 ) } )
	path1.append( { origin = Vector( 212, 377, 1 ), angles = Vector( 0, 2, 0 ) } )
	local guy1 = SpawnSkitGuy( "mcor_walking_2", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_GRUNT_MDL, "mp_weapon_rspn101" )
	thread PatrolForever( guy1, path1, 1.1, "patrol_walk_lowport" )

	// ADD MOAR DUDEZ HERE!!!!
	// local guy3 = SpawnSkitGuy( "mcor_walking_3", "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_GRUNT_MDL, "mp_weapon_hemlock" )

}


function StartSaluteGuys()
{
	SetupSaluteGuy( SpawnSkitGuy( "mcor_salute_1", "", Vector( -8, 456, 6 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_GRUNT_MDL, "mp_weapon_car" ), false )
	SetupSaluteGuy( SpawnSkitGuy( "mcor_salute_2", "", Vector( -8, 624, 6 ), Vector( 0, 0, 0 ), TEAM_MILITIA, TEAM_MILITIA_GRUNT_MDL, "mp_weapon_car" ), false )

	// ADD MOAR DUDEZ HERE!!!!
	// NOTE: To add more, change "mcor_salute_1" to something unique, 1st Vector is origin, 2nd Vector is angles.  true/false at the far right is if they should speak or not



}


function StartWavemarvins()
{
	//SetupWaveMarvin( SpawnSkitGuy( "marvin_1", "", Vector( 1121, -4689, 112 ), Vector( 0, -40, 0 ), TEAM_MILITIA, MARVIN_MODEL, "mp_weapon_rspn101" ), "mv_idle_SMG2" )

	// ADD MOAR DUDEZ HERE!!!!
	// Change "mv_idle_unarmed" to be something else maybe: mv_idle_weld, mv_fireman_idle, mv_idle_wash_window_noloop, mv_idle_buff_window_noloop


}



// -------------------------------------------------------------------------------------------
// AI Patrol
// Borrowed & modified from Wargames
// -------------------------------------------------------------------------------------------
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
// -------------------------------------------------------------------------------------------
// End AI Patrol
// -------------------------------------------------------------------------------------------


// -------------------------------------------------------------------------------------------
// Ammo crates
// Borrowed & modified from co-op
// -------------------------------------------------------------------------------------------
function AddLoadoutCrate( team, origin, angles, loadoutType = "pilot", showOnMinimap = true )
{
	local crateCount = GetScriptManagedEntArray( level.loadoutCrateManagedEntArrayID ).len()
	Assert( crateCount < 10, "Can't have more then 10 Loadout Crates" )

	angles += Vector( 0, -90, 0 )

	local crate = CreatePropDynamic( LOADOUT_CRATE_MODEL, origin, angles, 6 )
	crate.SetName( "loadoutCrate" )
	crate.SetTeam( team )
	crate.SetUsable()
	crate.SetUsableByGroup( "friendlies" )
	crate.SetUsePrompts( "Hold %use% to select new loadout", "Hold %use% To Select New Loadout" )
	crate.s.loadoutType <- loadoutType

	if ( showOnMinimap )
	{
		crate.Minimap_SetDefaultMaterial( "vgui/hud/coop/coop_ammo_locker_icon" )
		crate.Minimap_SetObjectScale( MINIMAP_LOADOUT_CRATE_SCALE )
		crate.Minimap_SetAlignUpright( true )
		crate.Minimap_AlwaysShow( TEAM_IMC, null )
		crate.Minimap_AlwaysShow( TEAM_MILITIA, null )
		crate.Minimap_SetFriendlyHeightArrow( true )
		crate.Minimap_SetZOrder( 5 )
	}

	AddToScriptManagedEntArray( level.loadoutCrateManagedEntArrayID, crate )

	SetMarker( "LoadoutCrateMarker" + crateCount.tostring(), crate )

	thread LoadoutCrateThink( crate )
	thread LoadoutCrateRestockAmmoThink( crate )
}

function LoadoutCrateThink( crate )
{
	crate.EndSignal( "OnDestroy" )
	while( true )
	{
		local results = crate.WaitSignal( "OnPlayerUse" )
		local player = results.activator

		if ( player.IsPlayer() )
		{
			thread UsingLoadoutCrate( crate, player )
			wait 1	// debounce on using the crate to minimize the risk of using it twice before the menu opens.
		}
	}
}

function LoadoutCrateRestockAmmoThink( crate )
{
	crate.EndSignal( "OnDestroy" )
	local distSqr
	local crateOrigin = crate.GetOrigin()
	local triggerDistSqr = 96 * 96
	local resetDistSqr = 768 * 768

	while( true )
	{
		wait 1 // check every second
		local playerArray = GetLivingPlayers()
		foreach( player in playerArray )
		{
			distSqr = DistanceSqr( crateOrigin, player.GetOrigin() )
			if ( distSqr <= triggerDistSqr && player.s.restockAmmoTime < Time() )
			{
				player.s.restockAmmoCrate = crate
				player.s.restockAmmoTime = Time() + 30 // debounce time before you can get new ammo again if you stay next to the crate.
				EmitSoundOnEntityOnlyToPlayer( player, player, "BurnCard_GrenadeRefill_Refill" )
				RestockPlayerAmmo( player )
			}
			if ( distSqr > resetDistSqr && player.s.restockAmmoTime > 0 && player.s.restockAmmoCrate == crate )
			{
				player.s.restockAmmoCrate = null
				player.s.restockAmmoTime = 0
			}
		}
	}
}

function UsingLoadoutCrate( crate, player )
{
	player.s.usedLoadoutCrate = true

	if( crate.s.loadoutType == "pilot" )
		Remote.CallFunction_UI( player, "ServerCallback_OpenPilotLoadoutMenu" )
	else
		Remote.CallFunction_UI( player, "ServerCallback_DevOpenTitanLoadoutMenu" )
}

function DestroyAllLoadoutCrates()
{
	local crateArray = GetScriptManagedEntArray( level.loadoutCrateManagedEntArrayID )
	foreach( crate in crateArray )
		crate.Destroy()
}
// -------------------------------------------------------------------------------------------
// End Ammo crate script
// -------------------------------------------------------------------------------------------


// -------------------------------------------------------------------------------------------
// Start map drop pods
// -------------------------------------------------------------------------------------------
function AddMapStartPod( team, origin, angles, mapName, displayedMapName )
{
	//local crateCount = GetScriptManagedEntArray( level.loadoutCrateManagedEntArrayID ).len()
	//Assert( crateCount < 10, "Can't have more then 10 Loadout Crates" )

	//angles += Vector( 0, -90, 0 )

	local pod = CreatePropDynamic( MODEL_CONTROL_PANEL, origin, angles, 6 )
	pod.SetName( "loadoutCrate" )
	pod.SetTeam( team )
	pod.SetUsable()
	pod.SetUsableByGroup( "friendlies" )

	local usePrompt = "Hold %use% to deploy to " + displayedMapName

	pod.SetUsePrompts( usePrompt, usePrompt )
	pod.s.mapName <- mapName

	thread MapStartPodThink( pod )
}

function MapStartPodThink( pod )
{
	pod.EndSignal( "OnDestroy" )
	while( true )
	{
		local results = pod.WaitSignal( "OnPlayerUse" )
		local player = results.activator

		if ( player.IsPlayer() )
		{
			thread UsingMapStartPod( pod, player )
			wait 1	// debounce on using the pod to minimize the risk of Fcusing it twice before the menu opens.
		}
	}
}

function UsingMapStartPod( pod, player )
{
	ClientCommand( player, "map " + pod.s.mapName )
}

// -------------------------------------------------------------------------------------------
// End start map drop pods
// -------------------------------------------------------------------------------------------







main()
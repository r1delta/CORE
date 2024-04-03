const SPAWNWINDOWCUTOFF = 1.0

PrecacheParticleSystem( SCREENFX_WARPJUMP )
PrecacheParticleSystem( SCREENFX_WARPJUMPDLIGHT )


function main()
{
	level.cinematicSlots <- {}
	level.cinematicSlots[ TEAM_IMC ] <- []
	level.cinematicSlots[ TEAM_MILITIA ] <- []

	level.cinematicEventStates <- 1 //0 is reserved by code for "no state"
	level.cinematicEventStateFuncs <- {}

	level.customPlayerCinematicFunctions <- {}
	level.customPlayerCinematicFunctions[ TEAM_MILITIA ] <- {}
	level.customPlayerCinematicFunctions[ TEAM_IMC ] <- {}
	level.customIntroLength <- null


	FlagInit( "CinematicIntro" )
	FlagInit( "CinematicOutro" )
	FlagInit( "Cinematic_MilitiaSpawnOnGround" )
	FlagInit( "Cinematic_IMCSpawnOnGround" )

	RegisterSignal( "PlayerCinematicDone" )
	RegisterSignal( "CinematicEventAnim" )
	RegisterSignal( "CalculatedWaitTime" )
	RegisterSignal( "closeSpawnWindow" )
	RegisterSignal( "CE_FLAGS_CHANGED" )

	RegisterSignal( "sRampOpen" )
	RegisterSignal( "sRampClose" )
	RegisterSignal( "stopDPRun" )
	RegisterSignal( "ReturningPlayerWeaponAndHud" )

	Globalize( GetAttachedPlayers )
	Globalize( AddCinematicFlag )
	Globalize( RemoveCinematicFlag )
	Globalize( HasCinematicFlag )
	Globalize( TryAddPlayerToCinematic )
	Globalize( IsPlayerInCinematic )
	Globalize( CreateSlotsForRef )
	Globalize( AddCinematicSlotGroup )
	Globalize( IsCinematicSlot )
	Globalize( GetPlayerSlot )
	Globalize( GetPlayerFromSlot )
	Globalize( GetSlotsFromRef )
	Globalize( GetSlotGroupIndex )
	Globalize( DebugSkipCinematicSlots )
	Globalize( DebugSkipCinematicSlotsWithBugRepro )
	Globalize( AddAllPlayersToCinematicSlots )
	Globalize( AddCustomPlayerCinematicFunc )
	Globalize( RemoveCustomPlayerCinematicFunc )
	Globalize( AddCustomCinematicRefFunc )
	Globalize( RemoveCustomCinematicRefFunc )
	Globalize( SetSkyBoxForAttachedPlayers )
	Globalize( RunCurrentServerStateFuncs )
	Globalize( RunServerStateFuncsForAttachedPlayers )
	Globalize( SpawnGuyForIntroPreview )
	Globalize( PlayerCinematicDone )

	Globalize( DoLaptopFxPerPlayer )
	Globalize( BeginSlotAnimTracking )

	Globalize( GetCustomIntroLength )
	Globalize( SetCustomIntroLength )
	Globalize( ClearCustomIntroLength )

	Globalize( CreateCinematicRef )
	Globalize( SpawnCinematicRefCommon )
	Globalize( SpawnCinematicDropPod )
	Globalize( DebugDropshipGuyGo )

	Globalize( SpawnPlayerIntoRide )
	Globalize( SpawnPlayerOnGround )
	Globalize( CreateCinematicEvent )
	Globalize( Event_AddFlagWaitToStart )
	Globalize( Event_GetFlagWaitToStartArray )
	Globalize( Event_AddFlagSetOnStart )
	Globalize( Event_GetFlagSetOnStartArray )
	Globalize( Event_AddFlagSetOnWarp )
	Globalize( Event_GetFlagSetOnWarpArray )
	Globalize( Event_AddFlagSetOnClouds )
	Globalize( Event_GetFlagSetOnCloudsArray )
	Globalize( Event_AddFlagWaitToEnd )
	Globalize( Event_GetFlagWaitToEndArray )
	Globalize( Event_AddFlagSetOnEnd )
	Globalize( Event_GetFlagSetOnEndArray )
	Globalize( Event_AddAnimStartFunc )
	Globalize( Event_GetAnimStartFuncArray )
	Globalize( Event_AddServerStateFunc )
	Globalize( Event_GetServerStateFuncArray )
	Globalize( Event_AddClientStateFunc )

	Globalize( CE_PlayerSkyScaleDefault )
	Globalize( CE_PlayerSkyScaleSpace )
	Globalize( CE_PlayerSkyScaleDropshipInterior )
	Globalize( CE_PlayerSkyScaleEvacDropshipEnter )
	Globalize( CE_PlayerSkyScaleOnRampOpen )
	Globalize( CE_PlayerSkyScaleOnDoorClose )
	Globalize( playerLerpSkyScaleOnSignal )

	Globalize( PlaySoundToAttachedPlayers )
	Globalize( PlaySoundToAttachedPlayersOnEnt )
	Globalize( FadeSoundOnAttachedPlayers )
	Globalize( FadeSoundOnAttachedPlayersOnEnt )

	//AddClientCommandCallback( "FinishedCinematicMenu", ClientCommand_FinishedCinematicMenu )

	RegisterServerVarChangeCallback( "gameState", Cinematic_GameState_Changed )

	file.debugModelVal <- 0
	file.debugModel <- {}
	file.debugModel[ TEAM_MILITIA ] <- {}
	file.debugModel[ TEAM_IMC ] <- {}
	file.debugModel[ TEAM_MILITIA ][ "male" ] <- [
		MILITIA_MALE_BR,
		MILITIA_MALE_CQ,
		MILITIA_MALE_DM,
	]
	file.debugModel[ TEAM_MILITIA ][ "female" ] <- [
		MILITIA_FEMALE_BR,
		MILITIA_FEMALE_CQ,
		MILITIA_FEMALE_DM,
	]
	file.debugModel[ TEAM_IMC ][ "male" ] <- [
		IMC_MALE_BR,
		IMC_MALE_CQ,
		IMC_MALE_DM,
	]
	file.debugModel[ TEAM_IMC ][ "female" ] <- [
		IMC_FEMALE_BR,
		IMC_FEMALE_CQ,
		IMC_FEMALE_DM,
	]
}

function EntitiesDidLoad()
{
	local skycam = GetEnt( SKYBOXLEVEL )
	if ( skycam )
		skycam.Fire( "ActivateSkybox" )
}

function Cinematic_GameState_Changed()
{
	switch ( level.nv.gameState )
	{
		case eGameState.Prematch:
			thread CloseSpawnWindow()
			break
	}
}

function CloseSpawnWindow()
{
	//wait for the nv variable to be set
	wait 1.0

	local delay = GetTimeTillGameStarts() - SPAWNWINDOWCUTOFF

	wait delay

	level.ent.Signal( "closeSpawnWindow" )
}

function TryAddPlayerToCinematic( player, slotGroupIndex = null )
{
	if ( level.nv.gameState <= eGameState.Prematch )
	{
		player.EndSignal( "Disconnected" )

		FlagWait( "ReadyToStartMatch" )
		WaitEndFrame()//->make sure all the refs and slots have been created

		ScreenFadeFromBlack( player )

		if ( ( Flag( "Cinematic_MilitiaSpawnOnGround" ) && player.GetTeam() == TEAM_MILITIA ) || ( Flag( "Cinematic_IMCSpawnOnGround" ) && player.GetTeam() == TEAM_IMC ) )
		{
			thread SpawnPlayerOnGroundDuringIntro( player )
			return false
		}
	}

	local slot = GetNextCinematicSlot( player, slotGroupIndex )

	if ( !slot )
		return false

	TakeSlot( player, slot )

	foreach ( func in level.customPlayerCinematicFunctions[ player.GetTeam() ] )
		thread func( player )

	switch ( GetSlotType( slot ) )
	{
		case "evac":
			Assert( IsAlive( player ) )
			thread AddPlayerToSlotWrapper( AddPlayerToSlot, slot, player, true )
			break

		default:
			waitthread SpawnPlayerForCinematic( player )
			thread AddPlayerToSlotWrapper( AddPlayerToSlot, slot, player )
			thread FreezeControls( player )
			break
	}

	return true
}

function FreezeControls( player )
{
	player.EndSignal( "Disconnected" )

	player.FreezeControlsOnServer( false )

	wait 2.25

	player.UnfreezeControlsOnServer()
}

function PlayerCinematicDone( player )
{
	player.Signal( "PlayerCinematicDone" )
	Remote.CallFunction_Replay( player, "ServerCallback_PlayerCinematicDone" )

	SetupPostLoaderPlayer( player )

	player.ClearAnimViewEntity( 1.25 )
	player.UnforceStand()
	player.ClearParent()
	player.Anim_Stop()
}

function ReturnWeaponAndHud( player )
{
	level.ent.Signal( "ReturningPlayerWeaponAndHud" )

	player.DeployWeapon()
	player.EnableWeaponViewModel()
}

function ReturnWeaponAndHudOnLand( player )
{
	player.EndSignal( "Disconnected" )

	local timeout = 5.0
	local interval = 0.1
	//hack! need to get signal instead of polling
	while( !player.IsOnGround() && timeout > 0.0 )
	{
		timeout -= interval

		wait interval
	}

	//wait for the bob head anim
	wait 0.25

	ReturnWeaponAndHud( player )
}

function ClientCommand_FinishedCinematicMenu( player )
{
	if ( !IsPlayerInCinematic( player ) )
		return true

	TakeAllWeapons( player )

	local pilotDataTable = GetPlayerClassDataTable( player, level.pilotClass )
	local pilotSettings = pilotDataTable.playerSetFile
	player.SetPlayerSettings( pilotSettings )
	player.SetPlayerPilotSettings( pilotSettings )

	Wallrun_OnPlayerSpawn( player )
	player.EnableWeapon()			//-> because of TakeAllWeapons, need to call this to have 3rd person model show gun
	player.DisableWeaponViewModel()	//-> take players gun away from his view.
	return true
}


/*--------------------------------------------------------------------------------------------------------------*\
|																												 |
|													 SLOTS														 |
|																												 |
\*--------------------------------------------------------------------------------------------------------------*/
function AddPlayerToSlotWrapper( func, slot, player, noAnimTracking = false )
{
	Assert( IsNewThread(), "Must be threaded off" )

	AddAnimEvent( player, "SkyScaleDefault", 	SkyScaleDefault, slot.s.ref )

	OnThreadEnd(
		function() : ( slot, player )
		{
			if ( IsValid( player ) )
			{
				DeleteAnimEvent( player, "SkyScaleDefault", 	SkyScaleDefault )
			}

			FreeSlot( slot, player )
		}
	)

	player.EndSignal( "Disconnected" )

	player.DisableWeaponViewModel()
	player.ForceStand()

	//do any functions specific to the player and ref
	RunCustomCinematicRefFuncs( player, slot.s.ref )

	//set these before
	player.SetCinematicEventRef( slot.s.ref )

	if ( GameRules.GetGameMode() != EXFILTRATION )
		AddCinematicFlag( player, CE_FLAG_INTRO )

	SetSkyBoxToCurrentEvent( slot, player )
	RunCurrentServerStateFuncs( player, slot.s.ref, slot.s.ref.s.serverStateFuncs )
	PlayCurrentSoundEvents( slot )
	waitthread func( slot, player, noAnimTracking )

	//clear these after
	if ( GameRules.GetGameMode() != EXFILTRATION )
		RemoveCinematicFlag( player, CE_FLAG_INTRO )
	else
		player.EnableWeaponViewModel()

	player.ClearCinematicEventRef()
}

function HasCinematicFlag( player, flag )
{
	Assert( player.IsPlayer() )
	Assert( IsValid( player ) )
	return player.GetCinematicEventFlags() & flag
}

function AddCinematicFlag( player, flag )
{
	Assert( player.IsPlayer() )
	Assert( IsValid( player ) )
	player.SetCinematicEventFlags( player.GetCinematicEventFlags() | flag )
	player.Signal( "CE_FLAGS_CHANGED" )
}

function RemoveCinematicFlag( player, flag )
{
	Assert( player.IsPlayer() )
	Assert( IsValid( player ) )
	player.SetCinematicEventFlags( player.GetCinematicEventFlags() & ( ~flag ) )
	player.Signal( "CE_FLAGS_CHANGED" )
}


function ShowPlayer( player )
{
	player.EndSignal( "Disconnected" )

	wait 0.5
	player.kv.VisibilityFlags = 7
}

function BeginSlotAnimTracking( slot )
{
	local modelname = IMC_MALE_BR
	local dummy = CreatePropDynamic( modelname )
	dummy.Hide()
	dummy.NotSolid()

	OnThreadEnd(
		function() : ( dummy )
		{
			if ( IsValid( dummy ) )
				dummy.Kill()
		}
	)

	slot.EndSignal( "OnDeath" )
	slot.EndSignal( "OnDestroy" )

	local ref = slot.s.ref

	foreach ( index, sequence in slot.s.sequences )
	{
		//are we waitting to sync anims with the ref?
		WaitForSyncWithRef( sequence, ref )

		slot.s.currSequenceIndex = index
		slot.s.currSequenceStartTime = Time()

		thread PlayAnim( dummy, sequence.thirdPersonAnim )

		WaitForSequenceEnd( slot.s.sequences, dummy, index, ref )
	}
}

function AddPlayerToSlot( slot, player, noAnimTracking )
{
	local ref 			= slot.s.ref
	local startIndex 	= slot.s.currSequenceIndex
	local startTime		= slot.s.currSequenceStartTime

	if ( noAnimTracking )
	{
		startIndex = 0
		startTime = Time() + 1
	}

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
				PlayerCinematicDone( player )
		}
	)

	for ( local i = startIndex; i < slot.s.sequences.len(); i++ )
	{
		local sequence 		= slot.s.sequences[ i ]
		local partialAnim 	= false

		//are we on the first anim we entered with?
		if ( startIndex == i )
		{
			//are we partially into the anim?
			local initialTime = Time() - startTime

			if ( initialTime > 0.0 )
			{
				sequence.setInitialTime = initialTime
				sequence.noParent = null //need to parent to the ref
				sequence.blendTime = 0 //so the player parents instantly
				sequence.teleport = true //pop it into position
				partialAnim = true
				player.kv.VisibilityFlags = 4
				thread ShowPlayer( player )
			}
		}

		//are we waitting to sync anims with the ref?
		WaitForSyncWithRef( sequence, ref, partialAnim )

		//Play the Anim
		thread FirstPersonSequence( sequence, player, ref )

		//run any custom functions
		if ( sequence.customSlotFuncs.len() )
		{
			foreach( func in sequence.customSlotFuncs )
				func( slot, player )
		}

		WaitForSequenceEnd( slot.s.sequences, player, i, ref )
	}

	switch ( GetSlotType( slot ) )
	{
		case "jump":
			thread ReturnWeaponAndHudOnLand( player )
			break
		default:
			ReturnWeaponAndHud( player )
			break
	}
}

/*--------------------------------------------------------------------------------------------------------------*\
|																												 |
|													UTILITY														 |
|																												 |
\*--------------------------------------------------------------------------------------------------------------*/
function AddCinematicSlotGroup( team, slots, ref )
{
	Assert( typeof( slots ) == "array", "slots passed into AddCinematicSlotGroup not an array" )
	Assert( slots.len() > 0, "slots passed into AddCinematicSlotGroup is an array of size 0" )
	Assert( "isCinematicSlot" in slots[ 0 ].s, "tried to pass in something other than a slot, use CreateCinematicSlot first to create a slot" )

	Assert( ! ( "slotGroupIndex" in ref.s ) )

	local group = {}
	group.slots <- slots

	level.cinematicSlots[ team ].append( group )

	ref.s.slotGroupIndex <- level.cinematicSlots[ team ].len() - 1
}

function CreateCinematicSlot( ref, style, seat )
{
	local slot = CreateScriptRef( ref.GetOrigin() )

	slot.s.cinematicPlayer 			<- null
	slot.s.isCinematicSlot			<- true
	slot.s.ref						<- ref
	slot.s.type						<- GetAnimGroupType( style, seat )

	slot.s.sequences <- GetAnimGroupSequences( style, seat )
	slot.s.currSequenceIndex		<- 0
	slot.s.currSequenceStartTime 	<- null
	slot.s.soundEvents				<- {}

	thread DeleteSlotOnWindowClose( slot, ref )

	AddSlotToRef( ref, slot )

	return slot
}

function DeleteSlotOnWindowClose( slot, ref )
{
	slot.EndSignal( "OnDeath" )
	ref.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( slot )
		{
			if ( IsValid( slot ) )
			{
				slot.Kill()
			}
		}
	)

	level.ent.WaitSignal( "closeSpawnWindow" )
}

function IsCinematicSlot( slot )
{
	if ( "isCinematicSlot" in slot.s )
		return slot.s.isCinematicSlot
	else
		return false
}

function TakeSlot( player, slot )
{
	Assert( "isCinematicSlot" in slot.s, "tried to pass in something other than a slot, use CreateCinematicSlot first to create a slot" )

	slot.s.cinematicPlayer	= player
	player.s.cinematicSlot	= slot
}

function IsFreeSlot( slot )
{
	Assert( "isCinematicSlot" in slot.s, "tried to pass in something other than a slot, use CreateCinematicSlot first to create a slot" )

	if ( slot.s.cinematicPlayer )
		return false

	return true
}

function FreeSlot( slot, player )
{
	Assert( "isCinematicSlot" in slot.s, "tried to pass in something other than a slot, use CreateCinematicSlot first to create a slot" )

	if ( IsValid( player ) )
		player.s.cinematicSlot = null

	if ( IsValid( slot ) )
		slot.s.cinematicPlayer = null
}

function GetSlotType( slot )
{
	Assert( slot.s.type, "slot: " + slot + " of type: " + typeof( slot ) + "hasn't been setup yet as a valid slot type for cinematics" )

	return slot.s.type
}

function IsPlayerInCinematic( player )
{
	return player.s.cinematicSlot
}

function GetSlotGroupIndex( ref )
{
	Assert( "slotGroupIndex" in ref.s )
	return ref.s.slotGroupIndex
}

function GetPlayerSlot( player )
{
	return player.s.cinematicSlot
}

function GetPlayerFromSlot( slot )
{
	Assert( "isCinematicSlot" in slot.s, "tried to pass in something other than a slot, use CreateCinematicSlot first to create a slot" )

	return slot.s.cinematicPlayer
}

function GetNextCinematicSlot( player, slotGroupIndex = null )
{
	local slot = null
	local team = player.GetTeam()

	if ( slotGroupIndex )
	{
		Assert( slotGroupIndex < level.cinematicSlots[ team ].len() )
		local group = level.cinematicSlots[ team ][ slotGroupIndex ]

		slot = GetNextCinematicSlotInGroup( player, group )
	}
	else
	{
		foreach( group in level.cinematicSlots[ team ] )
		{
			slot = GetNextCinematicSlotInGroup( player, group )
			if ( slot )
				break
		}
	}

	return slot
}

function GetNextCinematicSlotInGroup( player, group )
{
	foreach( index, slot in group.slots )
	{
		//deleted slot
		if ( !IsValid( slot ) )
			continue

		//skip if already taken
		if ( !IsFreeSlot( slot ) )
			continue

		return slot
	}

	return null
}

function GetNextCinematicSlotPairs( team )
{
	local minslots 	= 2 //group players up in pairs before making larger groups
	local validloop	= true

	while( validloop )
	{
		validloop = false

		foreach( group in level.cinematicSlots[ team ] )
		{
			if ( minslots <= group.slots.len() )
			{
				foreach( index, slot in group.slots )
				{
					//lets try another group
					if ( index >= minslots )
						break

					//skip if already taken
					if ( !IsFreeSlot( slot ) )
						continue

					return slot
				}

				validloop = true
			}
		}

		minslots++
	}

	return null
}

function DebugSkipCinematicSlots( team,  num )
{
	for ( local i = 0; i < num; i++ )
	{
		local fake = CreateScriptRef()
		fake.SetTeam( team )

		local slot = GetNextCinematicSlot( fake )
		slot.s.cinematicPlayer = fake
	}

	Assert( num == 0, "you're skipping intro slots - don't check in")
}


function AddAllPlayersToCinematicSlots()
{
	local players = GetPlayerArray()
	foreach ( player in players )
	{
		if ( player.GetPlayerSettings() != "spectator" )
			continue
		if ( IsValid( player.s.cinematicSlot ) )
			continue
		thread TryAddPlayerToCinematic( player )
	}
}

function SpawnPlayerOnGroundDuringIntro( player )
{
	// spawn the player at an info_spawnpoint_human_start, wait min-max time or until he moves, then raise weapon
	ResetTitanBuildCompleteCondition( player )

	DecideRespawnPlayer( player )
	player.DisableWeaponViewModel()
	AddCinematicFlag( player, CE_FLAG_INTRO )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				player.EnableWeaponViewModel()
				RemoveCinematicFlag( player, CE_FLAG_INTRO )
			}
		}
	)

	FlagWait( "ReadyToStartMatch" )
	WaitEndFrame() //delay a bit so we can get all settings for intro times and what not.
	
	player.UnfreezeControlsOnServer()

	wait GetTimeTillGameStarts()
}

function SpawnPlayerOnGround( player, minTime = 17, maxTime = 19 )
{
	// somewhere out there, something is spawning the player first sometimes
	if ( IsAlive( player ) )
		return

	// spawn the player at an info_spawnpoint_human_start, wait min-max time or until he moves, then raise weapon
	DecideRespawnPlayer( player )
	player.DisableWeaponViewModel()
	AddCinematicFlag( player, CE_FLAG_INTRO )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				player.EnableWeaponViewModel()
				RemoveCinematicFlag( player, CE_FLAG_INTRO )
			}
		}
	)

	local endTime = Time() + RandomFloat( minTime, maxTime )
	local org = player.GetOrigin()
	local distBreak = 50
	local distBreakSqr = distBreak * distBreak

	for ( ;; )
	{
		if ( Time() > endTime )
			break

		if ( DistanceSqr( org, player.GetOrigin() ) > distBreakSqr )
			break

		wait 0
	}
}

function SpawnPlayerIntoRide( ship, player, sequence, flagToStart = null )
{
	// spawns player into a ride, and plays a sequence

	// dont show hud during intro
	AddCinematicFlag( player, CE_FLAG_INTRO )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )

	local pilotDataTable = GetPlayerClassDataTable( player, level.pilotClass )
	local pilotSettings = pilotDataTable.playerSetFile
	player.SetPlayerSettings( pilotSettings )

	if ( !IsAlive( player ) ) // jfs, don't know how a player could be alive already.
		player.RespawnPlayer( ship )

	player.DisableWeaponViewModel()

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
				RemoveCinematicFlag( player, CE_FLAG_INTRO )
		}
	)

	if ( flagToStart )
		FlagWait( flagToStart )

	thread FirstPersonSequence( sequence, player, ship )

	if ( "localAnglesYaw" in sequence )
	{
		local angles = player.GetLocalAngles()
		local vec = Vector( 12, sequence.localAnglesYaw, 0 )
		angles = angles.AnglesCompose( vec )
		player.SetLocalAngles( angles )
	}

	player.WaittillAnimDone()
	player.ClearParent()
	player.ClearAnimViewEntity()

	for ( ;; )
	{
		if ( player.IsOnGround() )
			break
		wait 0
	}

	player.EnableWeaponViewModel()
}



function SkyScaleDefault( player, ref = null )
{
	player.LerpSkyScale( SKYSCALE_DEFAULT, 1.0 )

	if ( !IsValid( ref ) )
		return

	local handle = ref.GetEncodedEHandle()
	Remote.CallFunction_Replay( player, "ServerCallback_ResetRefSkyScale", handle )
}

function AddCustomPlayerCinematicFunc( func, team = TEAM_BOTH )
{
	Assert( type( func ) == "function" )
	Assert( team == TEAM_BOTH || team == TEAM_MILITIA || team == TEAM_IMC )

	if ( team == TEAM_BOTH )
	{
		level.customPlayerCinematicFunctions[ TEAM_MILITIA ][ func ] <- func
		level.customPlayerCinematicFunctions[ TEAM_IMC ][ func ] <- func
	}
	else
		level.customPlayerCinematicFunctions[ team ][ func ] <- func
}

function RemoveCustomPlayerCinematicFunc( func, team = TEAM_BOTH )
{
	Assert( type( func ) == "function" )
	Assert( team == TEAM_BOTH || team == TEAM_MILITIA || team == TEAM_IMC )

	if ( team == TEAM_BOTH )
	{
		Assert( func in level.customPlayerCinematicFunctions[ TEAM_MILITIA ] )
		delete level.customPlayerCinematicFunctions[ TEAM_MILITIA ][ func ]

		Assert( func in level.customPlayerCinematicFunctions[ TEAM_IMC ] )
		delete level.customPlayerCinematicFunctions[ TEAM_IMC ][ func ]
	}
	else
	{
		Assert( func in level.customPlayerCinematicFunctions[ team ] )
		delete level.customPlayerCinematicFunctions[ team ][ func ]
	}
}

function AddCustomCinematicRefFunc( ref, func )
{
	if ( !( "cinematicRefFuncs" in ref.s ) )
		ref.s.cinematicRefFuncs <- {}

	Assert( !( func in ref.s.cinematicRefFuncs ), "that func already exists" )
	ref.s.cinematicRefFuncs[ func ] <- func
}

function RemoveCustomCinematicRefFunc( ref, func )
{
	Assert( "cinematicRefFuncs" in ref.s )
	Assert( func in ref.s.cinematicRefFuncs, "that func doesn't exist" )

	delete ref.s.cinematicRefFuncs[ func ]
}

function RunCustomCinematicRefFuncs( player, ref )
{
	if ( !( "cinematicRefFuncs" in ref.s ) )
		return

	foreach ( func in ref.s.cinematicRefFuncs )
		thread func( player, ref )
}

function AddSlotToRef( ref, slot )
{
	if ( !( "cinematicSlots" in ref.s ) )
		ref.s.cinematicSlots <- []

	ref.s.cinematicSlots.append( slot )
}

function GetSlotsFromRef( ref )
{
	Assert( "cinematicSlots" in ref.s )

	return ref.s.cinematicSlots
}

function SetSkyBoxForAttachedPlayers( ref, skycam )
{
	foreach( slot in GetSlotsFromRef( ref ) )
	{
		local player = GetPlayerFromSlot( slot )

		if ( !IsAlive( player ) )
			continue

		//because of debug skipping - check for this
		if ( !player.IsPlayer() )
			continue

		player.SetSkyCamera( skycam )
	}
}

function GetAttachedPlayers( ref )
{
	local players = []
	foreach( slot in GetSlotsFromRef( ref ) )	//"ref" is usually the dropship/droppod/whatever
	{
		local player = GetPlayerFromSlot( slot )

		if ( !IsAlive( player ) )
			continue

		//because of debug skipping - check for this
		if ( !player.IsPlayer() )
			continue

		players.append( player )
	}

	return players
}

function SetSkyBoxToCurrentEvent( slot, player )
{
	local ref 		= slot.s.ref
	local skyCam 	= ref.s.lastSkyCam

	if ( !skyCam )
		return

	player.SetSkyCamera( skyCam )
}

function RunServerStateFuncsForAttachedPlayers( ref, funcs )
{
	if ( IntroPreviewOn() )
	{
		foreach( guy in ref.s.guys )
		{
			if ( !IsAlive( guy ) )
				continue

			RunCurrentServerStateFuncs( guy, ref, funcs )
		}
	}

	foreach( slot in GetSlotsFromRef( ref ) )
	{
		local player = GetPlayerFromSlot( slot )

		if ( !IsAlive( player ) )
			continue

		//because of debug skipping - check for this
		if ( !player.IsPlayer() )
			continue

		RunCurrentServerStateFuncs( player, ref, funcs )
	}
}

function RunCurrentServerStateFuncs( player, ref, funcs )
{
	foreach ( func in funcs )
		thread func( player, ref )
}

function CreateCinematicRef()
{
	local table = {}
	table.origin			<- null
	table.angles			<- null
	table.team				<- null
	table.count 			<- null
	table.style				<- null

	return table
}

function SpawnCinematicRefCommon( ref, table )
{
	ref.SetTeam( table.team )
	ref.s.lastSkyCam 		<- null
	ref.s.serverStateFuncs 	<- []

	if ( "side" in table )
	{
		ref.s.style <- table.side
		ref.s.side 	<- table.side
	}
	else
	{
		ref.s.style <- table.style
		ref.s.side 	<- table.style
	}

	ref.s.GetZipLineData 	<- null
	switch( ref.s.style )
	{
		case "left":
		case "right":
		case "both":
			ref.s.GetZipLineData = true
			break
		default:
			ref.s.GetZipLineData = false
			break
	}

	//create the slots
	local slots = CreateSlotsForRef( ref, ref.s.style, table.count )

	if ( IntroPreviewOn() )
	{
		foreach ( index, guy in ref.s.guys )
		{
			thread debugKillGuyOnSlotTaken( guy, slots[ index ] )
			AddAnimEvent( guy, "SkyScaleDefault", SkyScaleDefault )
		}
	}
}

function SpawnCinematicDropPod( table )
{
	local dropPod = CreateEntity( "npc_dropship" )//CreatePropDynamic( DROPPOD_MODEL )
		dropPod.kv.spawnflags = 0
		//dropPod.kv.vehiclescript = "scripts/vehicles/airvehicle_default.txt"
		dropPod.kv.teamnumber = table.team
		dropPod.SetModel( DROPPOD_MODEL )
		dropPod.SetOrigin( table.origin )
		dropPod.kv.squadname = UniqueString( "dropPod_squad" )
		DispatchSpawn( dropPod, false )
		dropPod.SetHealth( 10000 )
		dropPod.SetMaxHealth( 10000 )
		dropPod.EnableRenderAlways()
		dropPod.SetTouchTriggers( false )

	if ( IntroPreviewOn() )
		dropPod.s.guys <- CreateDebugSlotsForDropPod( dropPod, table.style, table.count )

	SpawnCinematicRefCommon( dropPod, table )

	return dropPod
}

function CreateSlotsForRef( ref, style, count = null )
{
	local animGroupArray = GetAnimGroupAllSeats( style )

	if ( count == null )
		count = animGroupArray.len()
	else
	if ( count >= animGroupArray.len() )
		count = animGroupArray.len()

	local team 		= ref.GetTeam()
	local slots = []

	for ( local i = 0; i < count; i++ )
	{
		local seat 	= i
		local slot = CreateCinematicSlot( ref, style, seat )
		slots.append( slot )
	}

	//add slots to the level in groups
	AddCinematicSlotGroup( team, slots, ref )

	return slots
}

function CreateGroupAnimTable( ref, style, seat )
{
	local table = {}

	table.animGroups 		<- {}
	table.attachIndex 		<- null
	table.shipAttach 		<- null
	table.ship 				<- null
	table.side				<- null

	local name = null

	foreach( index, sequence in GetAnimGroupSequences( style, seat ) )
	{
		name = sequence.name
		table.animGroups[ name ] <- {}
		table.animGroups[ name ].anim3rd		<- GetAnimGroup3rd( style, seat, name )
	}

	table.shipAttach 	= GetAnimGroupAttachment( style, seat, name )
	table.ship 			= ref
	table.side 			= style

	return table
}

function CreateDebugSlotsForDropPod( ship, style, count = null )
{
	local animGroupArray = GetAnimGroupAllSeats( style )

	if ( count == null )
		count = animGroupArray.len()
	else
	if ( count >= animGroupArray.len() )
		count = animGroupArray.len()

	local team = ship.GetTeam()
	local squadName = "debugSquad" + team
	local origin = ship.GetOrigin()
	local angles = ship.GetAngles()

	local guys = []
	local guy
	for ( local i = 0; i < count; i++ )
	{
		local guy = SpawnGuyForIntroPreview( SpawnGrunt, team, squadName, origin, angles, i )

		guys.append( guy )

		local seat 	= i
		local sequences = GetAnimGroupSequences( style, i )

		thread DebugDropshipGuyGo( guy, sequences, ship )
	}

	return guys
}

function DebugDropshipGuyGo( guy, sequences, ref )
{
	local slot = {}
	slot.s <- {}
	slot.s.sequences <- sequences
	slot.s.ref <- ref

	foreach ( index, sequence in sequences )
	{
		//are we waitting to sync anims with the ref?
		WaitForSyncWithRef( sequence, ref )

		if ( sequence.noParent == null )
			guy.SetParent( ref, sequence.attachment )

		thread PlayAnim( guy, sequence.thirdPersonAnim, ref, sequence.attachment )

		//run any custom functions
		if ( sequence.customSlotFuncs.len() )
		{
			foreach( func in sequence.customSlotFuncs )
				func( slot, guy )
		}

		WaitForSequenceEnd( sequences, guy, index, ref )
	}

	guy.ClearParent()
	guy.Kill()
}

function WaitForSyncWithRef( sequence, ref, partialAnim = false )
{
	if ( !sequence.syncWithRef )
		return
	if ( partialAnim )
		return

	if ( sequence.syncWithRefSignal )
		ref.WaitSignal( sequence.syncWithRefSignal )
	else
		ref.WaitSignal( "CinematicEventAnim" )
}

function DoLaptopFxPerPlayer( player, dropship )
{
	local eHandle = dropship.s.laptop.GetEncodedEHandle()
	Remote.CallFunction_Replay( player, "ServerCallback_FractureLaptopFx", eHandle )
}

function GetNextSequence( sequences, index )
{
	if ( ( index + 1 ) < sequences.len() )
		return sequences[ index + 1 ]

	return null
}

function GetProceduralWaitTime( sequence, ref )
{
	if ( !( "proceduralWaitTime" in ref.s ) )
		ref.WaitSignal( "CalculatedWaitTime" )

	local time = ref.s.proceduralWaitTime - Time()

	if ( sequence.proceduralLengthAdjustment )
		time += sequence.proceduralLengthAdjustment

	return time
}

function WaitForSequenceEnd( sequences, actor, index, ref )
{
	actor.EndSignal( "OnDeath" )

	local sequence = sequences[ index ]
	local nextSequence = GetNextSequence( sequences, index )

	//are we waiting for a procedural cue to end?
	if ( sequence.proceduralLength )
	{
		local time = GetProceduralWaitTime( sequence, ref )
		//printt( "procedural wait time for player team: ", ref.GetTeam(), ": ", time )

		if ( time > 0 )
			wait time
	}
	else if ( nextSequence && nextSequence.syncWithRef )
	{
		//the next sequence is waiting to sync up with the ref anim, so lets not wait on this sequence
		if ( index == 0 )
			wait 0	//->the very first anim actually plays a frame after we've started - so if we move forward, we'll immediately hit the signal.
		return
	}
	else
	{
		//default - wait for anim to finish
		actor.WaittillAnimDone()
	}
}

function SetCustomIntroLength( time )
{
	level.customIntroLength = time
}

function GetCustomIntroLength()
{
	return level.customIntroLength
}

function ClearCustomIntroLength()
{
	if ( level.customIntroLength != null )
		level.customIntroLength = null
}

function CreateCinematicEvent()
{
	local event = {}
	event.origin			<- null		// origin of the animation ref
	event.angles			<- null		// angles of the animation ref -- overrides the yaw value
	event.yaw				<- null		// yaw of animation ref, used to fill in angles
	event.anim				<- null		// the animation to play for the ship
	event.teleport			<- false	// whether to teleport the ship to the anim or blend
	event.blendTime			<- DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME
	event.preAnimFPSWarp	<- false	// do a First and third person warp jump effect before playing the animation
	event.postAnimFPSWarp	<- false	// do a First and third person warp jump effect near the end of the animation
	event.preAnimWarp		<- false	// do a third person only warp jump effect before playing the animation
	event.preAnimFPSClouds	<- false	// do a First person Clouds effect to cover up anim pop
	event.skycam			<- null		// change the skycamera for this ship to this ent name
	event.proceduralLength	<- false	// Set to true to dynamically figure out when to stop playing the intro idle

	event.flagWaitToStart	<- []		// waits for this flag before starting this event
	event.flagSetOnStart	<- []		// sets this flag when this event starts
	event.flagSetOnWarp		<- []		// sets this flag after warpjump
	event.flagSetOnClouds	<- []		// sets this flag in the middle of flying through cloud cover
	event.flagWaitToEnd		<- []		// waits for this flag before ending this event ( for looping anims )
	event.flagSetOnEnd		<- []		// sets this flag when this event ends
	event.animStartFunc		<- []		// runs a custom dropship function passing the dropship, ref, and table as variables.
	event.serverStateFunc	<- []		// runs a custom STATE persistent function on the player, passing the player and the dropship

	//internal variable... DO NOT EDIT
	event.eventState 		<- null
	return event
}

function Event_AddFlagWaitToStart( event, flag )
{
	event.flagWaitToStart.append( flag )
}
function Event_GetFlagWaitToStartArray( event )
{
	return event.flagWaitToStart
}

function Event_AddFlagSetOnStart( event, flag )
{
	event.flagSetOnStart.append( flag )
}
function Event_GetFlagSetOnStartArray( event )
{
	return event.flagSetOnStart
}

function Event_AddFlagSetOnWarp( event, flag )
{
	event.flagSetOnWarp.append( flag )
}
function Event_GetFlagSetOnWarpArray( event )
{
	return event.flagSetOnWarp
}

function Event_AddFlagSetOnClouds( event, flag )
{
	event.flagSetOnClouds.append( flag )
}
function Event_GetFlagSetOnCloudsArray( event )
{
	return event.flagSetOnClouds
}

function Event_AddFlagWaitToEnd( event, flag )
{
	event.flagWaitToEnd.append( flag )
}
function Event_GetFlagWaitToEndArray( event )
{
	return event.flagWaitToEnd
}

function Event_AddFlagSetOnEnd( event, flag )
{
	event.flagSetOnEnd.append( flag )
}
function Event_GetFlagSetOnEndArray( event )
{
	return event.flagSetOnEnd
}

function Event_AddAnimStartFunc( event, func )
{
	event.animStartFunc.append( func )
}
function Event_GetAnimStartFuncArray( event )
{
	return event.animStartFunc
}

function Event_AddServerStateFunc( event, func )
{
	event.serverStateFunc.append( func )
}

function Event_GetServerStateFuncArray( event )
{
	return event.serverStateFunc
}

function Event_AddClientStateFunc( event, funcName )
{
	thread Event_AddClientStateFuncThread( event, funcName )
}

function Event_AddClientStateFuncThread( event, funcName )
{
	FlagWait( "CinematicFunctionsRegistered" )

	local eventState = RecordEventState( event )

	if ( !( eventState in level.cinematicEventStateFuncs ) )
		level.cinematicEventStateFuncs[ eventState ] <- []

	level.cinematicEventStateFuncs[ eventState ].append( funcName )

	local handle = GetClientFunctionHandle( funcName )
	foreach ( player in GetPlayerArray() )
		Remote.CallFunction_Replay( player, "ServerCallback_AddCinematicEventClientFunc", eventState, handle )
}

function RecordEventState( event )
{
	if ( !event.eventState )
	{
		event.eventState = level.cinematicEventStates
		level.cinematicEventStates++
	}

	return event.eventState
}

function CE_PlayerSkyScaleDefault( player, ref )
{
	player.LerpSkyScale( SKYSCALE_DEFAULT, 1.0 )
}

function CE_PlayerSkyScaleSpace( player, ref )
{
	player.LerpSkyScale( SKYSCALE_SPACE, 0.01 )
}

function CE_PlayerSkyScaleDropshipInterior( player, ref )
{
	player.LerpSkyScale( SKYSCALE_FRACTURE_WARP, 0.01 )
}

function CE_PlayerSkyScaleEvacDropshipEnter( player, ref )
{
	player.LerpSkyScale( SKYSCALE_FRACTURE_DOOROPEN_PLAYER, 1.0 )
}

function CE_PlayerSkyScaleOnRampOpen( player, ref )
{
	thread playerLerpSkyScaleOnSignal( player, ref, "sRampOpen", SKYSCALE_FRACTURE_DOOROPEN_PLAYER, 1.0 )
}

function CE_PlayerSkyScaleOnDoorClose( player, ref )
{
	thread playerLerpSkyScaleOnSignal( player, ref, "sRampClose", SKYSCALE_FRACTURE_WARP, 1.0 )
}

function playerLerpSkyScaleOnSignal( player, ref, signal, scale, time )
{
	player.EndSignal( "Disconnected" )
	ref.EndSignal( "OnDeath" )

	ref.WaitSignal( signal )

	if ( !IsValid( player ) )
		return

	player.LerpSkyScale( scale, time )
}

function PlaySoundToAttachedPlayers( ref, snd, fade = null, fadeTime = 1.0 )
{
	//no ent - which means play on player
	PlaySoundToAttachedPlayersWrapper( ref, null, snd, fade, fadeTime )
}

function PlaySoundToAttachedPlayersOnEnt( ref, ent, snd, fade = null, fadeTime = 1.0 )
{
	//pass an ent to player on
	PlaySoundToAttachedPlayersWrapper( ref, ent, snd, fade, fadeTime )
}

function PlaySoundToAttachedPlayersWrapper( ref, ent, snd, fade, fadeTime )
{
	foreach( slot in GetSlotsFromRef( ref ) )
	{
		Internal_AddSoundToCinematicSlot( slot, snd, ent )
		Internal_PlaySoundToAttachedPlayer( slot, snd )

		if ( fade )
		{
			Internal_FadeSoundOnAttachedPlayer( slot, fade, fadeTime )
			Internal_RemoveSoundOnCinematicSlot( slot, fade )
		}
	}
}

function FadeSoundOnAttachedPlayers( ref, fade, fadeTime = 1.0 )
{
	//no ent - which means play on player
	FadeSoundOnAttachedPlayersWrapper( ref, null, fade, fadeTime )
}

function FadeSoundOnAttachedPlayersOnEnt( ref, ent, fade, fadeTime = 1.0 )
{
	//pass an ent to player on
	FadeSoundOnAttachedPlayersWrapper( ref, ent, fade, fadeTime )
}

function FadeSoundOnAttachedPlayersWrapper( ref, ent, fade, fadeTime )
{
	foreach( slot in GetSlotsFromRef( ref ) )
	{
		Internal_FadeSoundOnAttachedPlayer( slot, fade, fadeTime )
		Internal_RemoveSoundOnCinematicSlot( slot, fade )
	}
}

function Internal_PlaySoundToAttachedPlayer( slot, snd )
{
	local player 	= GetSoundEventPlayer( slot )
	local ent 		= GetSoundEventEntity( slot, snd )
	local seek 		= GetSoundEventSeekTime( slot, snd )

	if ( !player || !ent )
		return

	if ( seek > 0 )
		EmitSoundOnEntityOnlyToPlayerWithSeek( ent, player, snd, seek )
	else
		EmitSoundOnEntityOnlyToPlayer( ent, player, snd )
}

function Internal_FadeSoundOnAttachedPlayer( slot, snd, fadeTime )
{
	local ent = GetSoundEventEntity( slot, snd )
	if ( !ent )
		return

	FadeOutSoundOnEntity( ent, snd, fadeTime )
	delaythread( fadeTime + 0.1 ) Internal_StopSoundOnEntity( ent, snd )
}

function Internal_StopSoundOnEntity( ent, snd )
{
	if ( IsValid( ent ) )
		StopSoundOnEntity( ent, snd )
}

function PlayCurrentSoundEvents( slot )
{
	foreach( snd, event in slot.s.soundEvents )
		Internal_PlaySoundToAttachedPlayer( slot, snd )
}

function Internal_AddSoundToCinematicSlot( slot, snd, ent )
{
	Assert( !( snd in slot.s.soundEvents ), "tried to add sound: " + snd + " twice."  )

	slot.s.soundEvents[ snd ] <- CreateSoundEvent( snd, ent, Time() )
}

function Internal_RemoveSoundOnCinematicSlot( slot, snd )
{
	if ( !( snd in slot.s.soundEvents ) )
		return

	delete slot.s.soundEvents[ snd ]
}

function GetSoundEventSeekTime( slot, snd )
{
	Assert ( snd in slot.s.soundEvents )

	return ( Time() - slot.s.soundEvents[ snd ].time )
}

function GetSoundEventEntity( slot, snd )
{
	Assert( snd in slot.s.soundEvents )

	local ent = slot.s.soundEvents[ snd ].ent
	if ( ent )
	{
		if ( IsValid( ent ) )
			return ent
		else
			return null //there was an ent, but now it's not valid
	}
	else
		return GetPlayerFromSlot( slot ) //there never was an ent, which means it's the player
}

function GetSoundEventPlayer( slot )
{
	local player = GetPlayerFromSlot( slot )

	if ( !IsAlive( player ) )
		return null
	//make sure not debug skipping
	if ( !IsPlayer( player ) )
		return	null

	return player
}

function CreateSoundEvent( snd, ent, time )
{
	local soundEvent = {}
	soundEvent.snd 	<- snd
	soundEvent.ent 	<- ent
	soundEvent.time <- time

	return soundEvent
}
function DebugSkipCinematicSlotsWithBugRepro( team )
{
	local index = 0
	local bugNum = GetBugReproNum()
	if ( bugNum > 0 && bugNum < 8 )
		index = bugNum

	DebugSkipCinematicSlots( team, index )
}

function SpawnGuyForIntroPreview( spawnFunc, team, squadName, origin, angles, i )
{
	local guy = spawnFunc( team, squadName, origin, angles )
	HideName( guy )

	SetIntroPreviewModel( guy, team )
	SetIntroPreviewHead( guy, i )

	return guy
}

function GetIntroPreviewGender()
{
	switch( IntroPreviewOn() )
	{
		case 1337:
		case 13371:
		case 13372:
		case 13373:
			return "male"

		case 1338:
		case 13381:
		case 13382:
		case 13383:
			return "female"
	}
}

function SetIntroPreviewHead( guy, i )
{
	local headIndex = guy.FindBodyGroup( "head" )
	if ( headIndex != -1 )
	{
		local headNum = i - 1
		if ( headNum < 0 )
			headNum = 0
		guy.SetBodygroup( headIndex, headNum )
	}
}

function SetIntroPreviewModel( guy, team )
{
	local model = null
	local gender = GetIntroPreviewGender()

	switch( IntroPreviewOn() )
	{
		case 1337:
		case 1338:
			file.debugModelVal++
			if ( file.debugModelVal >= file.debugModel[ team ][ gender ].len() )
				file.debugModelVal = 0
			model = file.debugModel[ team ][ gender ][ file.debugModelVal ]
			break

		case 13371:
		case 13381:
			model = file.debugModel[ team ][ gender ][ 0 ]
			break

		case 13372:
		case 13382:
			model = file.debugModel[ team ][ gender ][ 1 ]
			break

		case 13373:
		case 13383:
			model = file.debugModel[ team ][ gender ][ 2 ]
			break
	}

	guy.SetModel( model )
	if( gender == "female" && team == TEAM_MILITIA )
		guy.SetSkin( 1 )
}
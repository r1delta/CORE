const DROPSHIP_SEAT	= 0 //For paul to switch seats on dropship, set 0-7

function main()
{
	if ( reloadingScripts )
		return

	level.dropshipDisabledTeams <- {}
	level.classicMPDropshipIntroLength <- CLASSIC_MP_DROPSHIP_IDLE_ANIM_TIME + 3.0

	level.classicMP_introPlayerSpawnFunc 		<- null
	level.classicMP_prematchSpawnPlayersFunc 	<- null
	level.classicMP_introLevelSetupFunc 		<- null

	level.canStillSpawnIntoIntro <- false
	level.classicMP_levelSetupForIntro <- false

	level.dropship_start_spawns <- []
	level.customDropshipSpawns 	<- {}
	level.dropshipSpawnTime 	<- null

	level.classicMPDropships 					<- {}
	level.classicMPDropships[ TEAM_IMC ] 		<- []
	level.classicMPDropships[ TEAM_MILITIA ] 	<- []

	//Players on this list will spawn on a dropship at start of classic MP or for wave respawn
	level.dropshipSpawnPlayerList 					<- {}
	level.dropshipSpawnPlayerList[ TEAM_IMC ] 		<- {}
	level.dropshipSpawnPlayerList[ TEAM_MILITIA ] 	<- {}

	level.dropshipIdleAnimsList <- [ 	"Classic_MP_flyin_exit_playerA_idle",
										"Classic_MP_flyin_exit_playerB_idle",
										"Classic_MP_flyin_exit_playerC_idle",
										"Classic_MP_flyin_exit_playerD_idle"
								  ]

	level.dropshipIdlePOVAnimsList <- [ "Classic_MP_flyin_exit_povA_idle",
									   	"Classic_MP_flyin_exit_povB_idle",
									   	"Classic_MP_flyin_exit_povC_idle",
									   	"Classic_MP_flyin_exit_povD_idle"
								  ]

	level.dropshipJumpAnimsList <- [ 	"Classic_MP_flyin_exit_playerA_jump",
										"Classic_MP_flyin_exit_playerB_jump",
										"Classic_MP_flyin_exit_playerC_jump",
										"Classic_MP_flyin_exit_playerD_jump"
								  ]

	level.dropshipJumpPOVAnimsList <- [ "Classic_MP_flyin_exit_povA_jump",
									   	"Classic_MP_flyin_exit_povB_jump",
									   	"Classic_MP_flyin_exit_povC_jump",
									   	"Classic_MP_flyin_exit_povD_jump"
								     ]

	level.dropshipAnimsYawList <- [ -18,
									8,
									8,
								   -16
								 ]

	level.debugTestingSpawns <- false

	level.dropshipAnimInitialTime <- 0.0 //TODO: Probably unneeded. Clean up next game.

	// HACK - wanted to put this in ClassicMP_TryDefaultIntroSetup() but the VPK precache couldn't find it
	PrecacheModel( MARVIN_NO_JIGGLE_MODEL )
	PrecacheModel( IMC_SPECTRE_MODEL )

	FlagInit( "ClassicMP_UsingCustomIntro", false )
	FlagInit( "GameModeAlwaysAllowsClassicIntro", false )

	AddCallback_GameStateEnter( eGameState.SwitchingSides, ClearCustomIntroLength ) // for CTF
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, ClearCustomIntroLength )  // for LTS

	level.onWaveSpawnDropshipSpawned <- {}
}

// ---- CLASSIC MP DROPSHIP INTRO FUNCTIONS (DEFAULT) ----
// called from _mapspawn after level scripts have inited
function ClassicMP_TryDefaultIntroSetup()
{
	Assert( GetClassicMPMode() )

	// If player spawn function hasn't been set yet, we know we have to use the default dropship intro setup
	if ( level.classicMP_introPlayerSpawnFunc )
	{
		FlagSet( "ClassicMP_UsingCustomIntro" )
		printt( "ClassicMP_TryDefaultIntroSetup: Not doing dropship intro for classic MP")
		return
	}

	// ---- CALLBACKS AND CUSTOM POINTERS FOR THIS INTRO STYLE ----

	AddSpawnCallback( "info_spawnpoint_dropship_start", OnDropshipStartSpawn )
	AddCallback_GameStateEnter( eGameState.SwitchingSides, ClearClassicDropships )
	AddCallback_GameStateEnter( eGameState.Prematch, ClassicMP_Dropship_PrematchCallback )

	if ( IsRoundBased() && Flag( "GameModeAlwaysAllowsClassicIntro" ) && GAMETYPE != COOPERATIVE )
		AddCallback_GameStateEnter( eGameState.WinnerDetermined, ClearClassicDropships )

	ClassicMP_SetIntroLevelSetupFunc( ClassicMP_Dropship_IntroLevelSetupFunc )
	ClassicMP_SetIntroPlayerSpawnFunc( ClassicMP_DropshipIntro_IntroPlayerSpawnFunc )  			// all players (including late connectors) run this one
	ClassicMP_SetPrematchSpawnPlayersFunc( ClassicMP_DropshipIntro_PrematchSpawnPlayersFunc )  	// run when prematch starts- only applies for players connected by then. (Prematch state happens more than once in round based games)

	AddCallback_OnClientConnected( ClassicMP_DropshipIntro_OnClientConnectedFunc )
	AddCallback_OnClientDisconnected( RemovePlayerFromDropshipSpawnPlayerList )
}
Globalize( ClassicMP_TryDefaultIntroSetup )


function ClassicMP_Dropship_IntroLevelSetupFunc()
{
	// move spawnpoint to custom locations if they have been changed
	CustomPlayerDropshipSpawn()

	// If riffs are set to be a Titan immediately, just drop in as a titan
	if ( ShouldIntroSpawnAsTitan() )
		return false

	// these are pruned by GameModeRemove()
	local imcSpawns = GetDropshipStartSpawnsForTeam( TEAM_IMC )
	local militiaSpawns = GetDropshipStartSpawnsForTeam( TEAM_MILITIA )

	//Assume 2 on each team. This restriction can be loosened later ( might want to randomize, etc )
	if ( imcSpawns.len() != 2 )
	{
		printt( "***************" )
		printt( "IMC Dropship start spawnpoints not equal to 2! Not using DropshipStartSpawn" )
		printt(  "***************" )
		return false
	}

	if ( militiaSpawns.len() != 2 )
	{
		printt( "***************" )
		printt( "Militia Dropship start spawnpoints not equal to 2! Not using DropshipStartSpawn" )
		printt(  "***************" )
		return false
	}

	return true
}

function ClassicMP_DropshipIntro_IntroPlayerSpawnFunc( player )
{
	if ( !CanSpawnIntoIntroDropship( player ) )
		return false

	Assert( GetGameState() != eGameState.Playing )

	if ( PlayerWillSpawnOnDropship( player ) )
		return true

	SpawnPlayerIntoSlotInDropship( player )
	Assert( PlayerWillSpawnOnDropship( player ) )

	return true
}

function ClassicMP_DropshipIntro_PrematchSpawnPlayersFunc( players )
{
	if ( !ClassicMP_CanUseIntroStartSpawn() )
		return false

	TryStartSpawnPlayersIntoDropship( players )
}

function ClassicMP_DropshipIntro_OnClientConnectedFunc( player )
{
	if ( !CanSpawnIntoIntroDropship( player ) )
		return

	if ( GetGameState() >= eGameState.Prematch )
		return

	AddPlayerToDropshipSpawnPlayerList( player )
	AddCinematicFlag( player, CE_FLAG_INTRO )
}

function OnDropshipStartSpawn( spawnPoint )
{
	if ( GameModeRemove( spawnPoint ) )
		return

	level.dropship_start_spawns.append( spawnPoint )
}
Globalize( OnDropshipStartSpawn )


function GetDropshipStartSpawnsForTeam( team )
{
	local teamDropshipSpawns = []

	foreach ( spawnpoint in level.dropship_start_spawns )
	{
		if ( spawnpoint.GetTeam() != team )
			continue

		teamDropshipSpawns.append( spawnpoint )
	}

	return teamDropshipSpawns
}
Globalize( GetDropshipStartSpawnsForTeam )

function ClassicMP_IsLevelSetupForIntro()
{
	Assert( GetClassicMPMode() )

	//return level.classicMP_introSetupDone
	return level.classicMP_levelSetupForIntro
}
Globalize( ClassicMP_IsLevelSetupForIntro )


function ClassicMP_CanUseIntroStartSpawn()
{
	Assert( GetClassicMPMode() )

	if ( !ClassicMP_IsLevelSetupForIntro() )
		return false

	if ( GetGameState() > eGameState.Prematch )
		return false

	// gets set to true in _gamestate::EntitiesDidLoad() if intro setup is successful
	if ( !level.canStillSpawnIntoIntro )
		return false

	return true
}
Globalize( ClassicMP_CanUseIntroStartSpawn )


// ========== CLASSIC MP INTRO CALLBACKS ==========
function ClassicMP_CallIntroPlayerSpawnFunc( player )
{
	Assert( GetClassicMPMode() )

	local callbackInfo = level.classicMP_introPlayerSpawnFunc
	return callbackInfo.func.acall( [ callbackInfo.scope, player ] )
}
Globalize( ClassicMP_CallIntroPlayerSpawnFunc )


function ClassicMP_CallPrematchSpawnPlayersFunc( players )
{
	Assert( GetClassicMPMode() )

	local callbackInfo = level.classicMP_prematchSpawnPlayersFunc
	callbackInfo.func.acall( [ callbackInfo.scope, players ] )
}
Globalize( ClassicMP_CallPrematchSpawnPlayersFunc )


function ClassicMP_CallIntroLevelSetupFunc()
{
	Assert( GetClassicMPMode() )

	local callbackInfo = level.classicMP_introLevelSetupFunc
	return callbackInfo.func.acall( [ callbackInfo.scope ] )
}
Globalize( ClassicMP_CallIntroLevelSetupFunc )


function ClassicMP_SetIntroPlayerSpawnFunc( func )
{
	Assert( GetClassicMPMode() )

	level.classicMP_introPlayerSpawnFunc = ClassicMP_CreateCallbackTable( func )
}
Globalize( ClassicMP_SetIntroPlayerSpawnFunc )


function ClassicMP_SetPrematchSpawnPlayersFunc( func )
{
	Assert( GetClassicMPMode() )

	level.classicMP_prematchSpawnPlayersFunc = ClassicMP_CreateCallbackTable( func )
}
Globalize( ClassicMP_SetPrematchSpawnPlayersFunc )


// setup your function to return false if a level isn't correctly set up to support the intro
function ClassicMP_SetIntroLevelSetupFunc( func )
{
	Assert( GetClassicMPMode() )

	level.classicMP_introLevelSetupFunc = ClassicMP_CreateCallbackTable( func )
}
Globalize( ClassicMP_SetIntroLevelSetupFunc )


function AddPlayerToDropshipSpawnPlayerList( player )
{
	local team = player.GetTeam()

 	level.dropshipSpawnPlayerList[ team ][ player ] <- true
}
Globalize( AddPlayerToDropshipSpawnPlayerList )


function RemovePlayerFromDropshipSpawnPlayerList( player )
{
	local team = player.GetTeam()
	if ( player in level.dropshipSpawnPlayerList[ team ] )
		delete level.dropshipSpawnPlayerList[ team ][ player ]
}

function ClearDropshipSpawnPlayerList( team = null )
{
	if ( team != null )
	{
		Assert( team == TEAM_IMC || team == TEAM_MILITIA, "team must be IMC or Militia" )
		level.dropshipSpawnPlayerList[ team ].clear()
	}
	else
	{
		level.dropshipSpawnPlayerList[ TEAM_IMC ].clear()
		level.dropshipSpawnPlayerList[ TEAM_MILITIA ].clear()
		level.canStillSpawnIntoIntro = false //Used as a defensive fix against 1 frame stuff.
	}
}

function ClearClassicDropships()
{
	level.classicMPDropships[ TEAM_IMC ].clear()
	level.classicMPDropships[ TEAM_MILITIA ].clear()
}
Globalize( ClearClassicDropships )

function ClassicMP_Dropship_PrematchCallback()
{
	if ( GameModeAlwaysAllowsClassicIntro() )
		level.canStillSpawnIntoIntro = true  // For later rounds, toggle this to see the dropship intro again

	// by default, classic MP clears the custom intro length after the first time it runs
	if ( ClassicMP_CanUseIntroStartSpawn() && !ShouldIntroSpawnAsTitan() )  // Spawning as titan uses default intro length
		SetCustomIntroLength( level.classicMPDropshipIntroLength )  // affects gamestate switch to "playing"
}

function PlayerWillSpawnOnDropship( player )
{
	if ( !level.canStillSpawnIntoIntro )
		return false

	return ( player in ( level.dropshipSpawnPlayerList[ player.GetTeam() ] ) )
}

function TryStartSpawnPlayersIntoDropship( players )
{
	delaythread( CLASSIC_MP_DROPSHIP_IDLE_ANIM_TIME )  ClearDropshipSpawnPlayerList()  //Clear out the players that are on this list after the window for spawning on the dropship has passed

	level.dropshipSpawnTime = Time()

	if ( GAMETYPE == COOPERATIVE )
	{
		local playerTeam = level.nv.attackingTeam
		Assert( playerTeam == TEAM_MILITIA || playerTeam == TEAM_IMC )

		local playerTeamSpawns = GetDropshipStartSpawnsForTeam( playerTeam )  // these are pruned by GameModeRemove()
		SpawnTeamPlayersIntoDropships( playerTeam, playerTeamSpawns )  //Only one player team in coop
	}
	else
	{
		// these are pruned by GameModeRemove()
		local militiaSpawns = GetDropshipStartSpawnsForTeam( TEAM_MILITIA )
		local imcSpawns = GetDropshipStartSpawnsForTeam( TEAM_IMC )

		SpawnTeamPlayersIntoDropships( TEAM_MILITIA, militiaSpawns )
		SpawnTeamPlayersIntoDropships( TEAM_IMC, imcSpawns )
		
	}
	
	foreach ( player in players )
	{
		player.UnfreezeControlsOnServer()
	}
}

function DoWaveSpawnByDropship( player )
{
	local team = player.GetTeam()

	Assert( WaveDropshipSpawnIsJoinable( team ) )

	player.UnfreezeControlsOnServer()

	level.dropshipSpawnPlayerList[ team ][ player ] <- true
	local waveSpawn = true
	SpawnPlayerIntoSlotInDropship( player, waveSpawn )
}
Globalize( DoWaveSpawnByDropship )


// if a joinable dropship wave spawn is happening right now return true
function WaveDropshipSpawnIsJoinable( team )
{
	if ( GetGameState() != eGameState.Playing )
		return false

	if ( level.dropshipSpawnTime == null )
		return false

	if ( !level.classicMPDropships[ team ].len() )
		return false

	// Need to make sure that we're not trying to wave spawn into a normal intro dropship
	foreach ( ship in level.classicMPDropships[ team ] )
	{
		if ( !IsWaveSpawnDropship( ship ) )
			return false
	}

	local animTime
	if ( GetWaveSpawnCustomDropshipAnim() )
	{
		local deployTime = GetAnimEventTimeR2( DROPSHIP_MODEL, GetWaveSpawnCustomDropshipAnim(), "dropship_deploy" )
		animTime = deployTime - GetWaveSpawnWindowTimeDropshipGone()
	}

	else
		animTime = CLASSIC_MP_DROPSHIP_IDLE_ANIM_TIME

	if ( Time() > level.dropshipSpawnTime + animTime )
		return false

	return true
}
Globalize( WaveDropshipSpawnIsJoinable )

//Taken from Angel City pretty much
function SpawnTeamPlayersIntoDropships( team, dropshipSpawns, seatOverride = null  )
{
	local initialTime = level.dropshipAnimInitialTime

	local idleAnims = []

	// third person, first person, yaw offset
	AddRideAnims( idleAnims, initialTime, level.dropshipIdleAnimsList[ 0 ], level.dropshipIdlePOVAnimsList[ 0 ], level.dropshipAnimsYawList[ 0 ] )
	AddRideAnims( idleAnims, initialTime, level.dropshipIdleAnimsList[ 1 ], level.dropshipIdlePOVAnimsList[ 1 ], level.dropshipAnimsYawList[ 1 ] )
	AddRideAnims( idleAnims, initialTime, level.dropshipIdleAnimsList[ 2 ], level.dropshipIdlePOVAnimsList[ 2 ], level.dropshipAnimsYawList[ 2 ] )
	AddRideAnims( idleAnims, initialTime, level.dropshipIdleAnimsList[ 3 ], level.dropshipIdlePOVAnimsList[ 3 ], level.dropshipAnimsYawList[ 3 ] )

	local jumpAnims = []
	AddRideAnims( jumpAnims, 0.0, level.dropshipJumpAnimsList[ 0 ], level.dropshipJumpPOVAnimsList[ 0 ], level.dropshipAnimsYawList[ 0 ] )
	AddRideAnims( jumpAnims, 0.0, level.dropshipJumpAnimsList[ 1 ], level.dropshipJumpPOVAnimsList[ 1 ], level.dropshipAnimsYawList[ 1 ] )
	AddRideAnims( jumpAnims, 0.0, level.dropshipJumpAnimsList[ 2 ], level.dropshipJumpPOVAnimsList[ 2 ], level.dropshipAnimsYawList[ 2 ] )
	AddRideAnims( jumpAnims, 0.0, level.dropshipJumpAnimsList[ 3 ], level.dropshipJumpPOVAnimsList[ 3 ], level.dropshipAnimsYawList[ 3 ] )

	local players = TableKeysToArray( level.dropshipSpawnPlayerList[ team ] )
	local ship1Players = []
	local ship2Players = []

	if ( seatOverride == null )
		seatOverride = DROPSHIP_SEAT

	if ( seatOverride > 0 && players.len() == 1 )
	{
		// debugging dropship seats
		Assert( seatOverride >= 0 && seatOverride < 8, "Illegal seatOverride value " + seatOverride )
		if ( seatOverride < 4 )
		{
			ship1Players.append( players[0] )
		}
		else
		{
			ship2Players.append( players[0] )
		}
	}
	else
	{
		for ( local i = 0; i < 4; i++ )
		{
			if ( i >= players.len() )
				break
			ship1Players.append( players[i] )
		}

		for ( local i = 4; i < 8; i++ ) //Assuming we never have more than 8 players...
		{
			if ( i >= players.len() )
				break
			ship2Players.append( players[i] )
		}
	}

		thread SpawnDropshipAndPlayers( team, initialTime, dropshipSpawns[0].GetOrigin(), dropshipSpawns[0].GetAngles(), idleAnims, jumpAnims, ship1Players, "dropship_classic_mp_flyin", seatOverride )
		thread SpawnDropshipAndPlayers( team, initialTime, dropshipSpawns[1].GetOrigin(), dropshipSpawns[1].GetAngles(), idleAnims, jumpAnims, ship2Players, "dropship_classic_mp_flyin", seatOverride )
}

function SpawnDropshipAndPlayers( team, initialTime, origin, angles, idleAnims, jumpAnims, players, anim, seatOverride = null )
{
	local robotAssistant

	OnThreadEnd(
		function() : ( robotAssistant )
		{
			ClearClassicDropships()

			if ( IsValid( robotAssistant ) )
			{
				//printt( "Killing robot assistant" )
				robotAssistant.Kill()
			}
		}
	)

	local ship = SpawnAnimatedDropship( origin, team )
	if ( team == TEAM_IMC )
		ship.SetModel( DROPSHIP_HERO_MODEL )
	else if ( team == TEAM_MILITIA)
		ship.SetModel( CROW_HERO_MODEL )

	ship.EndSignal( "OnDestroy" ) // this thread didn't seem to end before? Maybe we should make ent.WaittillAnimDone() return when the ent is destroyed
	level.classicMPDropships[ team ].append( ship )

	if ( seatOverride == null ) //Debugging dropship seats
		seatOverride = DROPSHIP_SEAT

	for ( local i = 0; i < players.len(); i++ )
	{
		local player = players[i]
		local idleAnim
		local jumpAnim
		if ( seatOverride > 0 )
		{
			idleAnim = idleAnims[ seatOverride % 4 ]
			jumpAnim = jumpAnims[ seatOverride % 4 ]
		}
		else
		{
			idleAnim = idleAnims[i]
			jumpAnim = jumpAnims[ i ]
		}

		thread SpawnPlayerIntoDropship( ship, player, idleAnim, jumpAnim )
	}

	PlayerSpawnDropship_RunSpawnCallbacks( ship, anim )

	thread PlayAnim( ship, anim, origin, angles )
	ship.Anim_SetInitialTime( initialTime )

	if ( team == TEAM_IMC )
	{
		robotAssistant = CreatePropDynamic( IMC_SPECTRE_MODEL )
		robotAssistant.SetParent( ship, "ORIGIN" )
		robotAssistant.MarkAsNonMovingAttachment()
		thread PlayAnim( robotAssistant, "sp_classic_flyin", ship, "ORIGIN" )
		robotAssistant.Anim_SetInitialTime( initialTime )
		robotAssistant.LerpSkyScale( SKYSCALE_CLASSIC_ACTOR, 0.1 )

		EmitSoundOnEntity( ship, "Goblin_IMC_ClassicMP_FlyIn" )
		EmitSoundOnEntity( ship, "Goblin_IMC_ClassicMP_FlyAway" )
	}
	else if ( team == TEAM_MILITIA )
	{
		robotAssistant = CreatePropDynamic( MARVIN_MODEL )
		robotAssistant.SetParent( ship, "ORIGIN" )
		robotAssistant.MarkAsNonMovingAttachment()
		thread PlayAnim( robotAssistant, "mv_classic_flyin", ship, "ORIGIN" )
		robotAssistant.Anim_SetInitialTime( initialTime )
		MarvinSetFace( robotAssistant, "happy" ) //Make smiley face come up
		robotAssistant.LerpSkyScale( SKYSCALE_CLASSIC_ACTOR, 0.1 )

		EmitSoundOnEntity( ship, "Crow_MCOR_ClassicMP_FlyIn" )
		EmitSoundOnEntity( ship, "Crow_MCOR_ClassicMP_FlyAway" )
	}


	ship.WaittillAnimDone()
}

function SpawnPlayerIntoDropship( ship, player, idleAnim, jumpAnim, waveSpawn = false )
{
	if ( level.debugTestingSpawns && player.IsBot() )
		return

	// spawns player into a ride, and plays a sequence
	// dont show hud during intro
	if ( waveSpawn )
		AddCinematicFlag( player, CE_FLAG_WAVE_SPAWNING )
	else
		AddCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING )

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )

	local pilotDataTable = GetPlayerClassDataTable( player, level.pilotClass )
	local pilotSettings = pilotDataTable.playerSetFile
	player.SetPlayerSettings( pilotSettings )

	// fix for a bug #80566 - should not be needed in R2 when the code bug requiring replays to last at least 1 sec is gone.
	local replayDelay = player.GetReplayDelay()
	local minKillReplayRemaining = GetConVarFloat( "replay_minWaitBetweenTransitions" ) - ( Time() - player.GetLastTimeReplayDelayChanged() )
	if ( minKillReplayRemaining > 0 && replayDelay > 0 )
	{
		// printt( "minKillReplayRemaining", minKillReplayRemaining )
		wait minKillReplayRemaining
	}

	if ( !level.debugTestingSpawns ) //Check to see if we are testing spawns, if we are, don't respawn them.
		player.RespawnPlayer( ship )

	if ( waveSpawn )
		SetWaveSpawnProtection( player )

	player.SetIsValidChaseObserverTarget( false )

	player.DisableWeaponViewModel()
	player.LerpSkyScale( SKYSCALE_CLASSIC_PLAYER, 0.1 )
	local handle = ship.GetEncodedEHandle()
	Remote.CallFunction_Replay( player, "ServerCallback_SetClassicSkyScale", handle, SKYSCALE_CLASSIC_SHIP )

	if ( !( HasAnimEvent( player, "SkyScaleDefault" ) ) )
		AddAnimEvent( player, "SkyScaleDefault", ClassicSkyScaleDefault, ship )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				player.SetIsValidChaseObserverTarget( true )

				if ( HasAnimEvent( player, "SkyScaleDefault" ) )
					DeleteAnimEvent( player, "SkyScaleDefault", ClassicSkyScaleDefault )

				thread ClearWaveSpawnProtectionOnPrimaryAttackOrDelay( player, WAVESPAWN_PROTECTION_TIME )
			}
		}
	)

	//Check how much we should skip forward ahead in during the idle animation

	if ( !level.debugTestingSpawns )  //Check to see if we are testing spawns, if we are, don't auto adjust idle time
	{
		local timeDifference = Time() - level.dropshipSpawnTime
		//printt( "Time difference: " + timeDifference )
		idleAnim.setInitialTime += timeDifference
	}

	//this is the path for regular classic mp ( not the way we should do it for R2 )
	if ( !GetWaveSpawnCustomDropshipAnim() || !waveSpawn )
	{
		local idleAnimDuration = player.GetSequenceDuration( idleAnim.thirdPersonAnim )

		//printt( "idleInitialTime: " + idleAnim.setInitialTime + ", idleAnimDuration: " +  idleAnimDuration )

		if ( idleAnim.setInitialTime < idleAnimDuration )
		{
			//printt( "Playing Idle Anim " + idleAnim.thirdPersonAnim + " for player: " + player )
			thread FirstPersonSequence( idleAnim, player, ship )

			if ( "localAnglesYaw" in idleAnim )
			{
				local angles = player.GetLocalAngles()
				local vec = Vector( 12, idleAnim.localAnglesYaw, 0 )
				angles = angles.AnglesCompose( vec )
				player.SetLocalAngles( angles )
			}

			player.WaittillAnimDone()
		}
	}
	else //this takes into account start times and lengths of anims
	{
		//find the length of the ship anim left
		local dropshipAnim = GetWaveSpawnCustomDropshipAnim()
		local duration 	= ship.GetSequenceDuration( dropshipAnim )
		local frac 		= ship.GetScriptedAnimEventCycleFrac( dropshipAnim, "dropship_deploy" )
		Assert( frac > 0.0 )
		Assert( frac < 1.0 )
		local deployTime 	= duration * frac
		local initialTime = Time() - ship.s.animStartTime
		local totalAnimTime = deployTime - initialTime

		//find the length of the player anim
		local duration 	= player.GetSequenceDuration( jumpAnim.thirdPersonAnim )
		local frac 		= player.GetScriptedAnimEventCycleFrac( jumpAnim.thirdPersonAnim, "dropship_deploy" )
		Assert( frac > 0.0 )
		Assert( frac < 1.0 )
		local exitTime 	= duration * frac

		//we're about to start our animation logic - bring out the gun on a delayed beat
		thread DelayedWeaponDeploy( player )
		local fadeTime = 0.5
		local holdTime = 0.5
		ScreenFadeFromBlack( player, fadeTime, holdTime )

		//if the ship anim is longer than the exit - play a looping idle
		if ( totalAnimTime > exitTime )
		{
			thread FirstPersonSequence( idleAnim, player, ship )
			wait ( totalAnimTime - exitTime )
		}
		else if ( exitTime > totalAnimTime )
		{
			jumpAnim.setInitialTime = ( exitTime - totalAnimTime )
			//if both the idle and the jump have view cone functions, and if the jump's is ViewCone*Free ( which doesn't turn the players view )
			//...then make sure to grab the idles viewcone func ( which should turn the players view )
			if ( idleAnim.viewConeFunction != null && ( jumpAnim.viewConeFunction == ViewConeRampFree || jumpAnim.viewConeFunction == ViewConeFree ) )
				jumpAnim.viewConeFunction = idleAnim.viewConeFunction
		}
	}

	waitthread PlayJumpoutAnims( player, ship, jumpAnim )
}

function DelayedWeaponDeploy( player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )

	wait 1.0
	player.EnableWeaponViewModel()
}

function ClassicSkyScaleDefault( player, ship )
{
	player.LerpSkyScale( SKYSCALE_DEFAULT, 1.0 )

	if ( !IsValid( ship ) )
		return

	local handle = ship.GetEncodedEHandle()
	Remote.CallFunction_Replay( player, "ServerCallback_ResetClassicSkyScale", handle )
}
Globalize( ClassicSkyScaleDefault )


//Inherits end signals from calling function SpawnPlayerIntoDropship
function PlayJumpoutAnims( player, ship, jumpAnim )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				//printt( "Removing cinematic flags from classic mp" )

				if ( IsValid( player.GetParent() ) )
					player.ClearParent()

				RemoveCinematicFlag( player, CE_FLAG_INTRO )
				RemoveCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING )
				RemoveCinematicFlag( player, CE_FLAG_WAVE_SPAWNING )
			}
		}
	)

	//printt( "Playing Jump Anim " + jumpAnim.thirdPersonAnim + " for player: " + player )
	thread FirstPersonSequence( jumpAnim, player, ship )
	player.WaittillAnimDone()
	player.ClearParent()
	player.ClearAnimViewEntity()
	for ( ;; )
	{
		if ( player.IsOnGround() || player.IsWallRunning() || player.IsWallHanging() )
			break
		wait 0
	}

	player.EnableWeaponViewModel()
}
Globalize( PlayJumpoutAnims )


function CanSpawnIntoWaveSpawnDropship( player )
{
	if ( GetGameState() < eGameState.Playing )
		return false

	if ( ShouldSpawnAsTitan( player ) )
		return false

	local team = player.GetTeam()

	if ( !WaveDropshipSpawnIsJoinable( team ) )
		return false

	return true
}
Globalize( CanSpawnIntoWaveSpawnDropship )


function CanSpawnIntoIntroDropship( player )
{
	if ( !ClassicMP_CanUseIntroStartSpawn() )
		return false

	if ( ShouldIntroSpawnAsTitan() )
		return false

	if ( player.GetTeam() in level.dropshipDisabledTeams )
		return false

	//If more than 8 players have tried to connect to this server at this time,
	//just say you can't spawn in the dropship. Easier than having to keep track of
	//what is the next available slot, due to people connecting and then disconnecting during the idle anim time.

	/*
	mo: this is an overly complicated system -> this function for example gets run when a player connects. He sees that he has room in the list and then is added to the list.
	then DecidePlayerRespawn() runs and checks this function again... which checks to see the number of people on the list
	keep in mind that the value here used to be 7, not 8.  Keeping that in mind...
	Players 15 and 16 are the last to be added to this list, so they think there is no room on the dropship, even though they've been added. so they respawn on the ground
	then the thread for spawning players into the dropship runs and sees them on the list and tries to respawn them, causing a bug. the change from 7 to 8 is really just a work around

	this system could be re-written to be much simpler.  if your ent index is less than 16 you spawn in the dropship, ( assuming 4 ships of 4 ), otherwise you spawn on the ground. simple as that
	the ent index will decide the seat position since even if a player disconnects, the player that replaces him will have the same ent index.  For R2 - we should re-write it to do that.
	*/

	local team = player.GetTeam()

	if ( level.dropshipSpawnPlayerList[ team ].len() > 8 )
	{
		return false
	}

	return true
}
Globalize( CanSpawnIntoIntroDropship )


function DisableDropshipSpawnForTeam( team )
{
	if ( !( team in level.dropshipDisabledTeams ) )
		level.dropshipDisabledTeams[ team ] <- true
	else
		level.dropshipDisabledTeams[ team ] = true
}
Globalize( DisableDropshipSpawnForTeam )


function EnableDropshipSpawnForTeam( team )
{
	if ( team in level.dropshipDisabledTeams )
		delete level.dropshipDisabledTeams[ team ]
}
Globalize( EnableDropshipSpawnForTeam )


function SpawnPlayerIntoSlotInDropship( player, waveSpawn = false )
{
	local team = player.GetTeam()

	Assert( level.classicMPDropships[ team ].len(), "Tried to spawn player into dropship in progress but no dropship is active!" )

	local numOfDropshipSpawningTeammates = level.dropshipSpawnPlayerList[ team ].len()
	//printt( "numOfDropshipSpawningTeammates " + numOfDropshipSpawningTeammates )

	if ( !waveSpawn )
		ScreenFadeFromBlack( player, 1.0, 2.75 ) //Since this player joined halfway, he doesn't have the team logo black screen. Do a short fade from black to mask any sudden pops due to us immediately playing an animation on him onto the dropship.

	AddPlayerToDropshipSpawnPlayerList( player )

	local shipToSpawnIn
	local maxPerShip = 4

	//Assume we never have more than 8 players...
	if ( numOfDropshipSpawningTeammates <= maxPerShip )
	{
		//printt( "First ship" )
		local index = level.classicMPDropships[ team ].len() - 1
		shipToSpawnIn = level.classicMPDropships[ team ][ index ] //1st ship
	}
	else
	{
		//printt( "Second ship" )
		local index = level.classicMPDropships[ team ].len() - 2
		shipToSpawnIn = level.classicMPDropships[ team ][ index ] //2nd ship
	}

	local seatNumber = numOfDropshipSpawningTeammates % 4

	//printt( "SeatNumber: " + seatNumber )

	local initialTime = level.dropshipAnimInitialTime

	local idleAnim = CreateRideAnim( initialTime, level.dropshipIdleAnimsList[ seatNumber ], level.dropshipIdlePOVAnimsList[ seatNumber ], level.dropshipAnimsYawList[ seatNumber ] )
	local jumpAnim = CreateRideAnim( 0.0, level.dropshipJumpAnimsList[ seatNumber ], level.dropshipJumpPOVAnimsList[ seatNumber ], level.dropshipAnimsYawList[ seatNumber ] )

	if ( GetWaveSpawnCustomPlayerRideAnimIdle( seatNumber ) && waveSpawn )
		idleAnim = clone GetWaveSpawnCustomPlayerRideAnimIdle( seatNumber )
	if ( GetWaveSpawnCustomPlayerRideAnimJump( seatNumber ) && waveSpawn )
		jumpAnim = clone GetWaveSpawnCustomPlayerRideAnimJump( seatNumber )

	thread SpawnPlayerIntoDropship( shipToSpawnIn, player, idleAnim, jumpAnim, waveSpawn )
}

function DebugTestDropshipStartSpawns()
{
	local result
	for ( local i = 0; i < 8; ++i )
	{
		result = DebugTestDropshipSpecificSpawn( i )
		if ( !result )
			break
		level.debugTestingSpawns = true //Set it true and false later to fix problem with testin dropship spawns in levels with out of bounds triggers

		wait 15.0
	}

	level.debugTestingSpawns = false
}
Globalize( DebugTestDropshipStartSpawns )


function GameModeAlwaysAllowsClassicIntro()
{
	return Flag( "GameModeAlwaysAllowsClassicIntro" )
}
Globalize( GameModeAlwaysAllowsClassicIntro )


function DebugTestDropshipSpecificSpawn( seat )
{
	level.debugTestingSpawns = true

	local players = GetPlayerArray()

	local player = players[ 0 ]
	local team = player.GetTeam()

	AddPlayerToDropshipSpawnPlayerList( player )

	local dropshipNum = 1

	if ( seat > 3 )
		dropshipNum = 2

	local teamStr
	if ( team == TEAM_IMC )
		teamStr = "imc"
	else if ( team == TEAM_MILITIA )
		teamStr = "militia"

	printt( "Dropship Start spawn: dropshipNum: " +  dropshipNum + ", team: " + teamStr + ", seatNumber: " + seat  )

	local spawns = GetDropshipStartSpawnsForTeam( team )
	if ( spawns.len() != 2 )
	{
		printt( "Warning! Need exactly 2 dropship spawns for team: " + teamStr + " . " + spawns.len() + " detected. Returning"  )
		return false
	}
	SpawnTeamPlayersIntoDropships( team, spawns, seat )

	level.debugTestingSpawns = false

	RemovePlayerFromDropshipSpawnPlayerList( player )

	return true
}
Globalize( DebugTestDropshipSpecificSpawn )

function SetCustomPlayerDropshipSpawn( team, origin_1, angles_1, origin_2 = null, angles_2 = null )
{
	Assert( "customDropshipSpawns" in level )

	local data = []
	data.append( { origin = origin_1, angles = angles_1 } )
	data.append( { origin = origin_2, angles = angles_2 } )

	level.customDropshipSpawns[ team ] <- data
}
Globalize( SetCustomPlayerDropshipSpawn )

function CustomPlayerDropshipSpawn()
{
	foreach( team, data in level.customDropshipSpawns )
	{
		local index = 0
		foreach( spawnpoint in level.dropship_start_spawns )
		{
			if ( spawnpoint.GetTeam() == team && data[ index ].origin != null )
			{
				spawnpoint.SetOrigin( data[ index ].origin )
				spawnpoint.SetAngles( data[ index ].angles )
				index++
			}
		}
	}
}


//this just spawns the dropship - players will be added to this later
function CreateWaveSpawnDropship( team )
{
	//wait the proper ammount of time
	local anim = "dropship_classic_mp_flyin"
	if ( GetWaveSpawnCustomDropshipAnim() )
		anim = GetWaveSpawnCustomDropshipAnim()

	local deployTime = GetAnimEventTimeR2( DROPSHIP_MODEL, anim, "dropship_deploy" )
	local totalDeployTime = deployTime + WARPINFXTIME
	local waveSpawnTime = level.waveSpawnTime[ team ]
	local timeFromNow = waveSpawnTime - Time()

	Assert( totalDeployTime <= timeFromNow, "The deploy time for the wavespawn dropship is longer than the amount of time available in the wavespawn" )
	local waitTime = timeFromNow - totalDeployTime - 0.1//the 0.1 is just to make sure it is on the field when the players try to get on it
	if ( waitTime > 0 )
		wait waitTime

	//find a spawnpoint
	local spawnpoints = GetDropshipStartSpawnsForTeam( team )
	if ( GetWaveSpawnCustomSpawnPoints( team ).len() )
		spawnpoints = GetWaveSpawnCustomSpawnPoints( team )
	local origin = spawnpoints[ 0 ].GetOrigin()
	local angles = spawnpoints[ 0 ].GetAngles()

	//warp in the ship
	local model = null
	if ( team == TEAM_IMC )
		model = DROPSHIP_HERO_MODEL
	else if ( team == TEAM_MILITIA )
		model = CROW_HERO_MODEL
	Assert( model != null )

	waitthread WarpinEffect( model, anim, origin, angles )

	//spawn and animation the dropship
	local ship = SpawnAnimatedDropship( origin, team )
	ship.SetModel( model )

	ArrayRemoveInvalid( level.classicMPDropships[ team ] )
	level.classicMPDropships[ team ].append( ship )
	ship.s.animStartTime <- Time()
	ship.s.waveSpawnDropship <- 1
	level.dropshipSpawnTime = Time()
	ship.SetInvulnerable()
	ship.SetNoTarget( true )

	AddAnimEvent( ship, "dropship_deploy", Bind( CleanupWaveSpawnDropship ) )

	PlayerSpawnDropship_RunSpawnCallbacks( ship, anim )

	waitthread PlayAnimTeleport( ship, anim, origin, angles )
}
Globalize( CreateWaveSpawnDropship )


function IsWaveSpawnDropship( ship )
{
	return ( "waveSpawnDropship" in ship.s )
}
Globalize( IsWaveSpawnDropship )


function CleanupWaveSpawnDropship( ship )
{
	local team = ship.GetTeam()
	ArrayRemove( level.classicMPDropships[ team ], ship )
	ClearDropshipSpawnPlayerList( team )
}

function SetWaveSpawnProtection( player )
{
	Assert( IsAlive( player ) && player.s.waveSpawnProtection == false )

	player.s.waveSpawnProtection = true
	player.SetNoTarget( true )
	player.SetInvulnerable()
}

function ClearWaveSpawnProtectionOnPrimaryAttackOrDelay( player, delay )
{
	if ( player.s.waveSpawnProtection == false )
		return

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				player.s.waveSpawnProtection = false
				player.SetNoTarget( false )
				player.ClearInvulnerable()
			}
		}
	)

	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnPrimaryAttack" )

	wait delay
}

function PlayerSpawnDropship_RunSpawnCallbacks( dropship, anim )
{
	// Added via AddCallback_OnWaveSpawnDropshipSpawned
	foreach ( callbackInfo in level.onWaveSpawnDropshipSpawned )
	{
		callbackInfo.func.acall( [ callbackInfo.scope, dropship, anim ] )
	}
}

function AddCallback_OnWaveSpawnDropshipSpawned( callbackFunc )
{
	Assert( "onWaveSpawnDropshipSpawned" in level )
	Assert( type( this ) == "table", "AddCallback_OnWaveSpawnDropshipSpawned can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "dropship, anim" )

	local name = FunctionToString( callbackFunc )
	Assert( !( name in level.onWaveSpawnDropshipSpawned ), "Already added " + name + " with AddCallback_OnWaveSpawnDropshipSpawned" )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onWaveSpawnDropshipSpawned[ name ] <- callbackInfo
}
Globalize( AddCallback_OnWaveSpawnDropshipSpawned )


function WaveSpawnDropship_AddBish( dropship, anim )
{
	local bish 		= CreatePropDynamic( BISH_MODEL )
	local laptop 	= CreatePropDynamic( LAPTOP_MODEL_SMALL )
	bish.SetParent( dropship, "ORIGIN" )
	laptop.SetParent( bish, "PROPGUN" )
	bish.MarkAsNonMovingAttachment()
	laptop.MarkAsNonMovingAttachment()
	bish.LerpSkyScale( SKYSCALE_CLASSIC_ACTOR, 0.1 )
	laptop.LerpSkyScale( SKYSCALE_CLASSIC_ACTOR, 0.1 )

	thread PlayAnimTeleport( bish, "coop_dropship_bish", dropship, "ORIGIN" )

	OnThreadEnd(
		function() : ( laptop, bish )
		{
			if ( IsValid_ThisFrame( laptop ) )
				laptop.Destroy()
			if ( IsValid_ThisFrame( bish ) )
				bish.Destroy()
		}
	)

	dropship.EndSignal( "OnDestroy" )
	dropship.EndSignal( "OnDeath" )

	WaitForever()
}
Globalize( WaveSpawnDropship_AddBish )

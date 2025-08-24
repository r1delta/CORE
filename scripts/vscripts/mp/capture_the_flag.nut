//const CTF_FLAG_MODEL = "models/japanese/hanging_japanese_flag_black.mdl"
const CTF_DROP_TIMEOUT = 20.0
const CTF_DROP_TIMEOUT_QUICK = 2.0

function main()
{
	if ( "CodeCallback_OnTouchHealthKit" in getroottable() )
		delete getroottable().CodeCallback_OnTouchHealthKit
	Globalize( CodeCallback_OnTouchHealthKit )
	Globalize( GiveFlagToPlayer )
	Globalize( TakeFlagFromPlayer )
	Globalize( ReturnFlagFromPlayer )

	Assert( !GetCinematicMode(), "Cannot play ctf in cinematic mode" )

	SetSwitchSidesBased( true )
	FlagSet( "GameModeAlwaysAllowsClassicIntro" )  // Each round starts with the dropship intro

	AddCallback_PlayerOrNPCKilled( CTF_OnPlayerOrNPCKilled )
	level.spawnRatingFunc_Pilot = RateFrontLinePlayerSpawnpoint
	level.spawnRatingFunc_Generic = RateFrontLinePlayerSpawnpoint

	RegisterSignal( "DropTimeoutThink" )
	RegisterSignal( "CTF_OnPlayerSettingsChanged" )

	level.flagSpawnPoints <- {}
	level.flagSpawnPoints[TEAM_IMC] <- null
	level.flagSpawnPoints[TEAM_MILITIA] <- null

	level.teamFlags <- {}
	level.teamFlags[TEAM_IMC] <- null
	level.teamFlags[TEAM_MILITIA] <- null

	level.flagMinZ <- null

	AddCallback_OnPlayerKilled( DropFlagOnDeath )
	AddCallback_OnClientDisconnected( DropFlagOnDisconnect )
	AddCallback_OnClientConnected( UpdateClientFlagInfo )

	AddCallback_OnPreAutoBalancePlayer( DropFlagOnAutoBalance )

	AddCallback_GameStateEnter( eGameState.Playing, CTFRoundStart )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, CTFRoundEnd ) // should be a "leave" callback
	AddCallback_GameStateEnter( eGameState.SwitchingSides, CTFRoundEnd )

	level.titanFlagInteraction <- false
	level.titanFlagCarry <- false

	file.flagKillBounds <- []

	FlagInit( "DefendersWinDraw" )

	Globalize( DropFlag )
	Globalize( AnyPlayerHasEnemyFlag )
}


function EntitiesDidLoad()
{
	level.titanFlagInteraction = GetCurrentPlaylistVarInt( "ctf_titan_flag_interation", 0 ) ? true : false

	if ( Riff_FloorIsLava() )
	{
		FlagWait( "SafeSpawnpointsInitialized" ) // make sure floor is lava has updated spawnpoints and flag locations
	}

	local imcFlag = GetFlagSpawnPoint( TEAM_IMC )
	local militiaFlag = GetFlagSpawnPoint( TEAM_MILITIA )

	foreach ( spawnpoint in level.allSpawnpoints )
	{
		if ( !IsValid( spawnpoint ) )
			continue

		local distToIMC = Distance( imcFlag.GetOrigin(), spawnpoint.GetOrigin() )
		local distToMilitia = Distance( militiaFlag.GetOrigin(), spawnpoint.GetOrigin() )

		local totalDist = (imcFlag.GetOrigin() - militiaFlag.GetOrigin()).Length()

		if ( distToMilitia > distToIMC )
			spawnpoint.SetTeam( TEAM_IMC )
		else if ( distToIMC > distToMilitia )
			spawnpoint.SetTeam( TEAM_MILITIA )
		else
			spawnpoint.SetTeam( TEAM_UNASSIGNED )
	}

	SetupAssaultPointKeyValues()

	//monitor population and respawns
	thread SetupTeamDeathmatchNPCs()
}


function FlagTrackerThink( team )
{
	printt( "FlagTracker" )
	local spawnpoint = GetFlagSpawnPoint( team )
	level.flagSpawnPoints[team] <- spawnpoint

	local spawnpointMinimap = CreateScriptRefMinimap( spawnpoint.GetOrigin(), spawnpoint.GetAngles() )
	if ( !( "spawnpointMinimap" in spawnpoint.s ) )
		spawnpoint.s.spawnpointMinimap <- null

	spawnpoint.s.spawnpointMinimap = spawnpointMinimap

	spawnpointMinimap.Minimap_SetFriendlyMaterial( "vgui/HUD/ctf_flag_friendly_missing" )
	spawnpointMinimap.Minimap_SetAlignUpright( true )
	spawnpointMinimap.Minimap_SetObjectScale( 0.15 )
	spawnpointMinimap.Minimap_SetClampToEdge( true )
	spawnpointMinimap.Minimap_SetZOrder( 99 )
	spawnpointMinimap.Minimap_AlwaysShow( team, null )

	local baseModel = CreatePropDynamic( CTF_FLAG_BASE_MODEL, spawnpoint.GetOrigin(), spawnpoint.GetAngles(), 6 )
	baseModel.SetTeam( team )

	{
		local traceStart = spawnpoint.GetOrigin() + Vector( 0, 0, 32 )
		local traceEnd = spawnpoint.GetOrigin() + Vector( 0, 0, -32 )
		local traceResults = TraceLineHighDetail( traceStart, traceEnd, baseModel, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS), TRACE_COLLISION_GROUP_NONE )

		if ( traceResults.hitEnt )
		{
			local angles = traceResults.surfaceNormal.GetAngles()
			angles = angles.AnglesCompose( Vector( 90, 0, 0 ) )
			baseModel.SetAngles( angles )
		}
	}


	while ( GamePlayingOrSuddenDeath() )
	{
		local flag = CreateFlagForTeam( team, baseModel )

		if ( GetMapName() == "mp_sandtrap" ) // only running this for Sandtrap since it's common in this map for the flag to fall into unreachable areas
			thread SandtrapFlagOutOfBoundsThink( flag )

		level.teamFlags[team] = flag

		flag.WaitSignal( "OnDestroy" )
	}

	baseModel.Destroy()

	spawnpointMinimap.Minimap_Hide( team, null )
}


function CTFRoundStart()
{
	if ( GAMETYPE != CAPTURE_THE_FLAG_PRO || ( GAMETYPE == CAPTURE_THE_FLAG_PRO && level.nv.attackingTeam == TEAM_MILITIA ) )
		thread FlagTrackerThink( TEAM_IMC )
	if ( GAMETYPE != CAPTURE_THE_FLAG_PRO || ( GAMETYPE == CAPTURE_THE_FLAG_PRO && level.nv.attackingTeam == TEAM_IMC ) )
		thread FlagTrackerThink( TEAM_MILITIA )

	local players = GetPlayerArray()
	foreach ( player in players )
	{
		player.SetForceCrosshairNameDraw( false )
		UpdateClientFlagInfo( player )
	}
}

function CTFRoundEnd()
{
	foreach ( flag in level.teamFlags )
	{
		if ( IsValid( flag ) )
			flag.Destroy()
	}

	local players = GetPlayerArray()
	foreach ( player in players )
	{
		player.SetForceCrosshairNameDraw( false )
	}

	MessageToTeam( TEAM_IMC, -1 )
	MessageToTeam( TEAM_MILITIA, -1 )

	// --- Lógica especial para CTF PRO empate / Special logic for CTF PRO draws ---
	local imcScore = GameRules.GetTeamScore( TEAM_IMC )
	local militiaScore = GameRules.GetTeamScore( TEAM_MILITIA )

	if ( GAMETYPE == CAPTURE_THE_FLAG_PRO && imcScore == militiaScore && !level.ctf_pro_evac_started )
	{
		if ( !AnyPlayerHasEnemyFlag() )
		{
			local winningTeam = GetOtherTeam( level.nv.attackingTeam )
			SetWinLossReasons( "#GAMEMODE_DEFENDERS_WIN", "#GAMEMODE_DEFENDERS_WIN" )
			SetWinner( winningTeam )
			return // Detenemos aquí para evitar que siga el flujo normal
		}
	}
}


function AwardCaptureToPlayer( player, flag )
{
	GameScore.AddTeamScore( player.GetTeam(), 1 )

	AddPlayerScore( player, "FlagCapture" )
	Stats_IncrementStat( player, "misc_stats","flagsCaptured",1.0 )
	player.SetAssaultScore( player.GetAssaultScore() + 1 )

	Assert( "carriers" in flag.s )
	foreach( assistPlayer in flag.s.carriers )
	{
		if ( !IsValid( assistPlayer ) )
			continue
		if ( assistPlayer == player )
			continue
		if ( assistPlayer.GetTeam() != player.GetTeam() )
			continue
		AddPlayerScore( assistPlayer, "FlagCaptureAssist" )
	}
}


function UpdateClientFlagInfo( player )
{
	foreach ( team, spawnpoint in level.flagSpawnPoints )
	{
		if ( !spawnpoint )
			continue

		local flagOrigin = spawnpoint.GetOrigin()
		Remote.CallFunction_NonReplay( player, "ServerCallback_SetFlagHomeOrigin", team, flagOrigin.x, flagOrigin.y, flagOrigin.z )
	}

	thread CTF_OnPlayerSettingsChanged( player )
}


function CTF_OnPlayerOrNPCKilled( victim, attacker, damageInfo )
{
	if ( !( victim.IsPlayer() ) )
		return

	if ( !attacker.IsPlayer() )
		return

	local attackerTeam = attacker.GetTeam()
	if ( victim.GetTeam() == attackerTeam )
		return

	if ( !PlayerHasEnemyFlag( victim ) )
		return

	AddPlayerScore( attacker, "FlagCarrierKill" )
}

function CTF_OnPlayerSettingsChanged( player )
{
	player.Signal( "CTF_OnPlayerSettingsChanged" )
	player.EndSignal( "CTF_OnPlayerSettingsChanged" )

	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDestroy" )

	while ( true )
	{
		player.WaitSignal( "SettingsChanged" )

		if ( PlayerHasEnemyFlag( player ) && IsAlive( player ) )
			MessageToPlayer( player, eEventNotifications.YouHaveTheEnemyFlag )
	}
}


function CodeCallback_OnTouchHealthKit( player, flag )
{
	if ( flag.GetParent() )
		return false

	if ( flag.s.disableTouch )
		return false

	if ( !level.titanFlagInteraction && player.IsTitan() )
		return false

	if ( player.s.forceDisableFlagTouch == true )
		return false

	local flagTeam = flag.GetTeam()
	local otherFlagTeam = GetOtherTeam(flagTeam)
	local playerTeam = player.GetTeam()

	if ( playerTeam != flagTeam )
	{
		MessageToTeam( flagTeam, eEventNotifications.PlayerHasFriendlyFlag, null, player )
		EmitSoundOnEntityToTeamExceptPlayer( flag, "UI_CTF_Enemy_FlagUpdate", flagTeam, player )

		MessageToTeam( otherFlagTeam, eEventNotifications.PlayerHasEnemyFlag, player, player )
		EmitSoundOnEntityToTeamExceptPlayer( flag, "UI_CTF_Team_FlagUpdate", otherFlagTeam, player )

		MessageToPlayer( player, eEventNotifications.YouHaveTheEnemyFlag )
		EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CTF_1P_FlagGrab" )

		PlayConversationToTeam( "enemy_took_flag", flagTeam )
		PlayConversationToTeamExceptPlayer( "friendly_took_flag", otherFlagTeam, player )
		PlayConversationToPlayer( "player_took_flag", player )

		GiveFlagToPlayer( flag, player )

		if ( GAMETYPE == CAPTURE_THE_FLAG_PRO && level.ctf_pro_evac_started == false )
		{
			level.ctf_pro_evac_started = true
			thread CTF_Pro_Evac()
			level.nv.gameStateChangeTime = Time() + 300.0
			level.nv.roundEndTime = Time() + 55.0
		}
	}
	else if ( playerTeam == flagTeam )
	{
		if ( !IsFlagHome( flag ) )
		{
			MessageToTeam( flagTeam, eEventNotifications.PlayerReturnedFriendlyFlag, null, player )
			EmitSoundOnEntityToTeamExceptPlayer( flag, "UI_CTF_Enemy_FlagUpdate", flagTeam, player )
			EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CTF_1P_FlagGrab" )

			MessageToTeam( otherFlagTeam, eEventNotifications.PlayerReturnedEnemyFlag, null, player )
			EmitSoundOnEntityToTeamExceptPlayer( flag, "UI_CTF_Team_FlagUpdate", flagTeam, player )

			MessageToPlayer( player, eEventNotifications.YouReturnedFriendlyFlag )

			PlayConversationToTeam( "friendly_returned_flag", flagTeam )
			PlayConversationToTeam( "enemy_returned_flag", otherFlagTeam )

			AddPlayerScore( player, "FlagReturn" )
			Stats_IncrementStat( player, "misc_stats","flagsReturned",1.0 )

			player.SetDefenseScore( player.GetDefenseScore() + 1 )

			ReturnFlagToHome( flag )
		}
		else if ( PlayerHasEnemyFlag( player ) )
		{
			local enemyFlag = TakeFlagFromPlayer( player )

			MessageToTeam( otherFlagTeam, eEventNotifications.PlayerCapturedFriendlyFlag, null, player )
			EmitSoundOnEntityToTeamExceptPlayer( flag, "UI_CTF_Enemy_Score", flagTeam, player )

			MessageToTeam( flagTeam, eEventNotifications.PlayerCapturedEnemyFlag, player, player )
			EmitSoundOnEntityToTeamExceptPlayer( flag, "UI_CTF_Team_Score", flagTeam, player )

			MessageToPlayer( player, eEventNotifications.YouCapturedTheEnemyFlag )
			EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CTF_1P_Score" )

			PlayConversationToTeam( "friendly_captured_flag", flagTeam )
			PlayConversationToTeam( "enemy_captured_flag", otherFlagTeam )

			AwardCaptureToPlayer( player, enemyFlag )

			ReturnFlagToHome( enemyFlag )
		}
	}

	return false
}


function ReturnFlagToHome( flag )
{
	flag.Destroy()
}


function GiveFlagToPlayer( flag, player )
{
	Assert( !flag.GetParent() )
	Assert( flag.GetTeam() != player.GetTeam() )

	local attachmentName = "FLAG"

	player.SetForceCrosshairNameDraw( true )

	flag.SetParent( player, attachmentName )
	flag.Signal( "DropTimeoutThink" )

	Assert( "carriers" in flag.s )
	if ( !ArrayContains( flag.s.carriers, player ) )
		flag.s.carriers.append( player )
}


function TakeFlagFromPlayer( player )
{
	local flag = GetFlagForTeam(GetOtherTeam(player.GetTeam()))

	Assert( flag.GetParent() == player )
	Assert( flag.GetTeam() != player.GetTeam() )

	player.SetForceCrosshairNameDraw( false )

	flag.s.disableTouch = true
	flag.ClearParent()
	flag.SetOrigin( player.GetOrigin() )
	flag.SetAngles( player.GetAngles() )
	flag.s.disableTouch = false

	return flag
}


function ReturnFlagFromPlayer( player, returner )
{
	local flag = GetFlagForTeam(GetOtherTeam(player.GetTeam()))
	local flagTeam = flag.GetTeam()
	local otherFlagTeam = GetOtherTeam(flagTeam)

	Assert( flag.GetParent() == player )
	Assert( flag.GetTeam() != player.GetTeam() )

	player.SetForceCrosshairNameDraw( false )

	if ( IsValid( returner ) )
	{
		MessageToTeam( flagTeam, eEventNotifications.PlayerReturnedFriendlyFlag, null, returner )
		EmitSoundOnEntityToTeamExceptPlayer( flag, "UI_CTF_Enemy_FlagUpdate", flagTeam, returner )

		MessageToTeam( otherFlagTeam, eEventNotifications.PlayerReturnedEnemyFlag, null, returner )
		EmitSoundOnEntityToTeamExceptPlayer( flag, "UI_CTF_Team_FlagUpdate", flagTeam, returner )

		MessageToPlayer( returner, eEventNotifications.YouReturnedFriendlyFlag )

		PlayConversationToTeam( "friendly_returned_flag", flagTeam )
		PlayConversationToTeam( "enemy_returned_flag", otherFlagTeam )

		AddPlayerScore( returner, "FlagReturn" )
		returner.SetDefenseScore( returner.GetDefenseScore() + 1 )
	}

	ReturnFlagToHome( flag )
}


function GetFlagSpawnPoint( team )
{
	local flagSpawns = GetEntArrayByClass_Expensive( "info_spawnpoint_flag" )

	if ( flagSpawns.len() )
	{
		foreach ( spawnPoint in flagSpawns )
		{
			if ( spawnPoint.GetTeam() != team )
				continue

			return spawnPoint
		}
	}

	local spawnpoints = GetEntArrayByClass_Expensive( "info_spawnpoint_titan_start" )
	Assert( spawnpoints.len(), "Map has no valid flag spawns: if this is a shipping map bug this to the designer" )

	FilterSpawnpointsByTeam( spawnpoints, team ) // inline array modify BS...

	local randomVal = RandomInt( spawnpoints.len() - 1 )
	return spawnpoints[randomVal]
}
Globalize( GetFlagSpawnPoint )

function CreateFlagForTeam( team, spawnpoint )
{
	local teamFlag = CreateEntity( "item_healthcore" )
	teamFlag.kv.model = CTF_FLAG_MODEL
	teamFlag.kv.fadedist = 10000
	//teamFlag.kv.PassDamageToParent = true

	local offsetZ = spawnpoint.GetBoundingMaxs().z
	offsetZ *= 2

	teamFlag.SetOrigin( spawnpoint.GetOrigin() + Vector( 0, 0, offsetZ ) )
	teamFlag.SetTeam( team )
	teamFlag.MarkAsNonMovingAttachment()
	DispatchSpawn( teamFlag, true )
	teamFlag.SetModel( CTF_FLAG_MODEL )

	teamFlag.Minimap_SetFriendlyMaterial( "vgui/HUD/ctf_flag_friendly_minimap" )
	teamFlag.Minimap_SetEnemyMaterial( "vgui/HUD/ctf_flag_enemy_minimap" )
	teamFlag.Minimap_SetAlignUpright( true )
	teamFlag.Minimap_SetObjectScale( 0.15 )
	teamFlag.Minimap_SetClampToEdge( true )
	teamFlag.Minimap_SetZOrder( 100 )
	teamFlag.Minimap_AlwaysShow( TEAM_IMC, null )
	teamFlag.Minimap_AlwaysShow( TEAM_MILITIA, null )

	teamFlag.s.disableTouch <- false
	teamFlag.s.carriers <- []

	return teamFlag
}

function DropFlagOnDisconnect( player )
{
	DropFlag( player )
}

function DropFlagOnDeath( player, damageInfo )
{
	DropFlag( player, damageInfo )
}

function DropFlagOnAutoBalance( player, currentTeam, otherTeam )
{
	// Prevent player from automatically picking up the flag right after dropping it
	player.s.forceDisableFlagTouch = true

	DropFlag( player )
}

function DropFlag( player, damageInfo = null )
{
	if ( !PlayerHasEnemyFlag( player ) )
		return

	local dropTimeout = CTF_DROP_TIMEOUT

	if ( damageInfo != null )
	{
		local attacker = damageInfo.GetAttacker()

		if ( IsValid( attacker ) )
		{
			local attackerClassname = attacker.GetClassname()

			if ( attackerClassname == "trigger_hurt" || attackerClassname == "trigger_multiple" )
				dropTimeout = CTF_DROP_TIMEOUT_QUICK
		}
	}

	local flag = TakeFlagFromPlayer( player )

	flag.SetAngles( Vector( 0, 0, 0 ) )
	flag.SetOrigin( player.GetOrigin() )
	flag.SetVelocity( Vector( 0, 0, 1 ) )

	local flagTeam = flag.GetTeam()
	local otherFlagTeam = GetOtherTeam(flagTeam)

	MessageToTeam( flagTeam, eEventNotifications.PlayerDroppedFriendlyFlag, null, player )
	EmitSoundOnEntityToTeamExceptPlayer( flag, "UI_CTF_Team_FlagUpdate", flagTeam, player )

	MessageToTeam( otherFlagTeam, eEventNotifications.PlayerDroppedEnemyFlag, player, player )
	EmitSoundOnEntityToTeamExceptPlayer( flag, "UI_CTF_Enemy_FlagUpdate", otherFlagTeam, player )

	MessageToPlayer( player, eEventNotifications.YouDroppedTheEnemyFlag )
	EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CTF_1P_FlagDrop" )

	PlayConversationToTeam( "enemy_dropped_flag", flagTeam )
	PlayConversationToTeam( "friendly_dropped_flag", otherFlagTeam )

	if ( !IsValid( flag ) )
		return

	thread DropTimeoutThink( flag, dropTimeout )
}

function DropTimeoutThink( flag, dropTimeout )
{
	flag.EndSignal( "OnDestroy" )

	flag.Signal( "DropTimeoutThink" )
	flag.EndSignal( "DropTimeoutThink" )

	local flagTeam = flag.GetTeam()
	local otherFlagTeam = GetOtherTeam(flagTeam)

	wait dropTimeout

	if ( flag.GetParent() )
		return

	MessageToTeam( flagTeam, eEventNotifications.ReturnedFriendlyFlag )
	EmitSoundOnEntityToTeam( flag, "UI_CTF_Enemy_FlagUpdate", flagTeam )

	MessageToTeam( otherFlagTeam, eEventNotifications.ReturnedEnemyFlag )
	EmitSoundOnEntityToTeam( flag, "UI_CTF_Team_FlagUpdate", otherFlagTeam )

	ReturnFlagToHome( flag )
}

function SandtrapFlagOutOfBoundsThink( flag )
{
	flag.EndSignal( "OnDestroy" )

	local flagOrg = Vector( 0.0, 0.0, 0.0 )

	while ( true )
	{
		flagOrg = flag.GetOrigin()

		if ( flagOrg.z < -1152.0 && flag.GetParent() == null ) // -1152 is below the water level in mp_sandtrap
		{
			flag.Destroy()
			return
		}

		wait 0.0
	}
}

function CTF_Pro_Evac()
{
	local defendingTeam = GetOtherTeam(level.nv.attackingTeam)
	SetEvacShipArrivalTimeAndDistanceFromFlagPoint()
	thread EvacOnDemand( defendingTeam, null, 7000, 5000 )
}

function SetEvacShipArrivalTimeAndDistanceFromFlagPoint()
{
	switch( GetMapName() )
	{

		case "mp_angel_city":
		case "mp_outpost_207":
		{
			Evac_SetDropshipArrivalWaitTime( 20.0 )
			Evac_SetDropshipArrivalIdleTime( 30.0 )
			return //Depend on level script to pick a random evac node. Main reason for this is that the 2 maps don't use AddEvacLocation
			break
		}

		case "mp_airbase":
		{
			Evac_SetDropshipArrivalWaitTime( 20.0 )
			Evac_SetDropshipArrivalIdleTime( 30.0 )
			local distance = 4500
			ReselectEvacNode( distance * distance )
			return
		}

		default:
		{
			Evac_SetDropshipArrivalWaitTime( 20.0 )
			Evac_SetDropshipArrivalIdleTime( 30.0 )
			local distance = 4500
			ReselectEvacNode( distance * distance )
			return
		}

	}

}

function ReselectEvacNode( distanceSqrThreshold )
{
	local map = GetMapName()
	if ( map == "mp_angel_city" || map == "mp_outpost_207" ) //Those 2 maps didn't use Evac_AddLocation. Go ahead and make them use Evac_AddLocation if we move ahead with the mode
		return

	local defendingTeam = GetOtherTeam(level.nv.attackingTeam)
	local defendingFlagPointOrigin = level.flagSpawnPoints[ defendingTeam ].GetOrigin()

	local resultArray = []

	foreach( index, table in level.ExtractLocations )
	{
		local node = table.node
		local distanceSqr = DistanceSqr( node.GetOrigin(), defendingFlagPointOrigin )
		if ( distanceSqr < distanceSqrThreshold ) //Should do sqrdistance < threshold, append to resultArray
			resultArray.append( index )
	}

	Assert( resultArray.len() >= 1 )

	local selectedNodeIndex = Random( resultArray )

	local evacNode = level.ExtractLocations[ selectedNodeIndex ]

	level.SelectedExtractLocationIndex = selectedNodeIndex

	level.evacNode = level.ExtractLocations[ level.SelectedExtractLocationIndex ].node

}

function AnyPlayerHasEnemyFlag()
{
    foreach ( player in GetPlayerArray() )
    {
        if ( PlayerHasEnemyFlag( player ) )
        {
            return true
        }
    }
    return false
}

/*function DidAttackingTeamGetAwayWithFlag() //Not used currently
{
	if ( level.playersOnDropship.len() == 0 )
		return 0

	Assert( level.playersOnDropship.len() == 1, "More than one player got on the ship? How strange" )

	local someoneHasTheFlag = false

	foreach( player, _ in level.playersOnDropship )
	{
		if ( PlayerHasEnemyFlag( player ) )
		{
			someoneHasTheFlag = true
			break
		}
	}

	return someoneHasTheFlag
}*/
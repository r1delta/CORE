function main()
{
	level.nv.spawnAsTitan = eSpawnAsTitan.Never
	level.nv.titanAvailability = eTitanAvailability.Never
	level.nv.eliminationMode = eEliminationMode.Pilots

	SetGameModeAnnouncement( "GameModeAnnounce_TDM" )
	SetRoundBased( true )
	SetSwitchSidesBased( true )

	level.flagReturnPoint <- null
	level.flagSpawnPoint <- null
	level.teamFlag <- null

	level.nv.attackingTeam = TEAM_MILITIA

	AddCallback_GameStateEnter( eGameState.Playing, CTTRoundStart )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, CTTRoundEnd ) // should be a "leave" callback
	AddCallback_GameStateEnter( eGameState.SwitchingSides, CTTRoundEnd )

	AddCallback_OnPlayerKilled( TE_OnPlayerOrNPCKilled )

}


function EntitiesDidLoad()
{
	local imcFlag = SpawnPoints_GetTitanStart( TEAM_IMC )[0]
	local militiaFlag = SpawnPoints_GetTitanStart( TEAM_MILITIA )[0]

	local imcOrigin = imcFlag.GetOrigin()
	local militiaOrigin = militiaFlag.GetOrigin()

	if ( GetMapName() == "mp_rise" )
	{
		imcOrigin = Vector( 1504, -752, 272 )
		militiaOrigin = Vector( -3696, -464, 384 )
	}

	AddTitanfallBlocker( imcOrigin, 700, 200 )
	AddTitanfallBlocker( militiaOrigin, 700, 200 )

	foreach ( spawnpoint in level.allSpawnpoints )
	{
		if ( !IsValid( spawnpoint ) )
			continue

		local distToIMC = Distance( imcOrigin, spawnpoint.GetOrigin() )
		local distToMilitia = Distance( militiaOrigin, spawnpoint.GetOrigin() )

		spawnpoint.SetTeam( TEAM_UNASSIGNED )

		if ( distToMilitia > distToIMC )
			spawnpoint.s.baseTeam <- TEAM_IMC
		else if ( distToIMC > distToMilitia )
			spawnpoint.s.baseTeam <- TEAM_MILITIA
		else
			spawnpoint.s.baseTeam <- TEAM_UNASSIGNED

		spawnpoint.SetTeam( spawnpoint.s.baseTeam )

		spawnpoint.s.spawnpointTeamOverrideFunc <- Bind( GetSpawnpointTeamOverride )
	}

	foreach ( spawnpoint in level.allSpawnpoints )
	{
		if ( !IsValid( spawnpoint ) )
			continue

		if ( spawnpoint.GetTeam() == level.defenseTeam )
			spawnpoint.SetTeam(GetOtherTeam(level.nv.attackingTeam))
		else
			spawnpoint.SetTeam( level.nv.attackingTeam )
	}

	SetupAssaultPointKeyValues()

	//no turrets in TDM for now
	local turrets = GetNPCArrayByClass( "npc_turret_sentry" )
	foreach( turret in turrets )
	{
		turret.DisableTurret()
	}

	//monitor population and respawns
	thread SetupTeamDeathmatchNPCs()
}

function GetSpawnpointTeamOverride( spawnpointTeam, spawningTeam )
{
	if ( spawningTeam == level.nv.attackingTeam )
		return spawnpointTeam

	local soul = GetTitanFlag()
	if ( !IsValid( soul ) )
		return spawnpointTeam

	local titan = soul.GetTitan()
	if ( !IsValid( titan ) )
		return spawnpointTeam

	if ( !titan.IsPlayer() )
		return spawnpointTeam

	return spawningTeam
}


function CTTRoundStart()
{
	if ( level.nv.attackingTeam == TEAM_IMC )
	{
		FlagSet( "Disable_MILITIA" )
		FlagClear( "Disable_IMC" )
	}
	else
	{
		FlagClear( "Disable_MILITIA" )
		FlagSet( "Disable_IMC" )
	}

	thread FlagTrackerThink(GetOtherTeam(level.nv.attackingTeam))
	thread CreateFlagReturnBase( level.nv.attackingTeam )
}


function CTTRoundEnd()
{
	if ( IsValid( level.teamFlag ) )
	{
		local titan = level.teamFlag.GetTitan()
	}

	local players = GetPlayerArray()
	foreach ( player in players )
	{
		player.Minimap_AlwaysShow( TEAM_INVALID, null )
		player.SetForceCrosshairNameDraw( false )
	}

	MessageToTeam( TEAM_IMC, -1 )
	MessageToTeam( TEAM_MILITIA, -1 )
}


function CreateFlagReturnBase( team )
{
	local spawnpoint = SpawnPoints_GetTitanStart( team )[0]

	local spawnOrigin = spawnpoint.GetOrigin()
	local spawnAngles = spawnpoint.GetAngles()

	if ( GetMapName() == "mp_rise" )
	{
		spawnOrigin = Vector( -3696, -464, 384 )
	}

	local returnPointMinimap = CreateScriptRefMinimap( spawnOrigin, spawnAngles )
	if ( !( "returnPointMinimap" in spawnpoint.s ) )
		spawnpoint.s.returnPointMinimap <- null

	returnPointMinimap.SetTeam( team )
	returnPointMinimap.Minimap_SetFriendlyMaterial( "vgui/HUD/ctf_flag_friendly_missing" )
	returnPointMinimap.Minimap_SetAlignUpright( true )
	returnPointMinimap.Minimap_SetObjectScale( 0.15 )
	returnPointMinimap.Minimap_SetClampToEdge( true )
	returnPointMinimap.Minimap_SetZOrder( 99 )
	returnPointMinimap.Minimap_AlwaysShow( team, null )

	local baseModel = CreatePropDynamic( CTF_FLAG_BASE_MODEL, spawnOrigin, spawnAngles, 0 )
	baseModel.SetTeam( team )

	level.flagReturnPoint = baseModel

	{
		local traceStart = spawnOrigin + Vector( 0, 0, 32 )
		local traceEnd = spawnOrigin + Vector( 0, 0, -32 )
		local traceResults = TraceLineHighDetail( traceStart, traceEnd, baseModel, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS), TRACE_COLLISION_GROUP_NONE )

		local angles = traceResults.surfaceNormal.GetAngles()
		angles = angles.AnglesCompose( Vector( 90, 0, 0 ) )
		baseModel.SetAngles( angles )
	}

	while ( GetGameState() == eGameState.Playing )
	{
		wait 0.1
	}

	baseModel.Destroy()
	returnPointMinimap.Destroy()
}


function FlagTrackerThink( team )
{
	local otherTeam = GetOtherTeam(team)
	local spawnpoint = SpawnPoints_GetTitanStart( team )[0]

	local spawnOrigin = spawnpoint.GetOrigin()
	local spawnAngles = spawnpoint.GetAngles()

	if ( GetMapName() == "mp_rise" )
	{
		spawnOrigin = Vector( 1504, -752, 272 )
	}

	local spawnpointMinimap = CreateScriptRefMinimap( spawnOrigin, spawnAngles )
	if ( !( "spawnpointMinimap" in spawnpoint.s ) )
		spawnpoint.s.spawnpointMinimap <- null

//	spawnpointMinimap.SetTeam( team )
	spawnpointMinimap.Minimap_SetFriendlyMaterial( "vgui/HUD/ctf_flag_friendly_missing" )
	spawnpointMinimap.Minimap_SetAlignUpright( true )
	spawnpointMinimap.Minimap_SetObjectScale( 0.15 )
	spawnpointMinimap.Minimap_SetClampToEdge( true )
	spawnpointMinimap.Minimap_SetZOrder( 99 )
	spawnpointMinimap.Minimap_AlwaysShow( team, null )

	/*
	local ent = CreateScriptRefMinimap( spawnOrigin, spawnAngles )
	ent.kv.spawnflags = 3 //Transmit to client
	ent.SetTeam( team )
	ent.Minimap_SetDefaultMaterial( EVAC_MINIMAP_ICON_FRIENDLY )
	ent.Minimap_SetEnemyMaterial( EVAC_MINIMAP_ICON_ENEMY )
	ent.Minimap_SetFriendlyMaterial( EVAC_MINIMAP_ICON_FRIENDLY )
	ent.Minimap_SetAlignUpright( true )
	ent.Minimap_SetClampToEdge( true )
	ent.Minimap_SetObjectScale( 0.2 )
	ent.Minimap_SetZOrder( 10 )
	*/

	local baseModel = CreatePropDynamic( CTF_FLAG_BASE_MODEL, spawnOrigin, spawnAngles, 0 )
	baseModel.SetTeam( team )

	level.flagSpawnPoint = baseModel

	{
		local traceStart = spawnOrigin + Vector( 0, 0, 32 )
		local traceEnd = spawnOrigin + Vector( 0, 0, -32 )
		local traceResults = TraceLineHighDetail( traceStart, traceEnd, baseModel, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS), TRACE_COLLISION_GROUP_NONE )

		local angles = traceResults.surfaceNormal.GetAngles()
		angles = angles.AnglesCompose( Vector( 90, 0, 0 ) )
		baseModel.SetAngles( angles )
	}

	while ( GetGameState() == eGameState.Playing )
	{
		local titan = CreateTitanForTeam( otherTeam, spawnOrigin, spawnAngles )
		titan.Minimap_AlwaysShow( TEAM_IMC, null )
		titan.Minimap_AlwaysShow( TEAM_MILITIA, null )

		local soul = titan.GetTitanSoul()
		soul.SetTeam( otherTeam )
		level.teamFlag = soul
		level.nv.cttTitanSoul = soul.GetEncodedEHandle()

		thread FlagCaptureThink( soul )
		thread FlagTakeThink( titan )

		soul.WaitSignal( "OnDestroy" )
	}

	baseModel.Destroy()
	spawnpointMinimap.Destroy()
}


function FlagTakeThink( titan )
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )

	while ( GetGameState() == eGameState.Playing )
	{
		if ( !titan.GetBossPlayer() )
		{
			local players = GetPlayerArrayOfTeam( level.nv.attackingTeam )

			foreach ( player in players )
			{
				if ( !IsAlive( player ) )
					continue

				local flagDistance = (titan.GetOrigin() - player.GetOrigin()).Length()

				if ( flagDistance > 256 )
					continue

				SetupFollowTitan( titan, player )
				break
			}

		}

		wait 0.1
	}
/*
	while ( true )
	{
		results = soul.WaitSignal( "PlayerEmbarkedTitan" )
		MessageToTeam( TEAM_IMC, eEventNotifications.PlayerHasTheTitan, null, results.player )
		MessageToTeam( TEAM_MILITIA, eEventNotifications.PlayerHasTheTitan, null, results.player )

		EmitSoundOnEntityToTeamExceptPlayer( results.player, "UI_CTF_Enemy_FlagUpdate", TEAM_IMC, results.player )
		EmitSoundOnEntityToTeamExceptPlayer( results.player, "UI_CTF_Team_FlagUpdate", TEAM_MILITIA, results.player )
		EmitSoundOnEntityOnlyToPlayer( results.player, results.player, "UI_CTF_1P_FlagGrab" )

		results = soul.WaitSignal( "PlayerDisembarkedTitan" )

		if ( "captured" in soul.s )
			return

		MessageToTeam( TEAM_IMC, eEventNotifications.PlayerLeftTheTitan, null, results.player )
		MessageToTeam( TEAM_MILITIA, eEventNotifications.PlayerLeftTheTitan, null, results.player )
	}
*/
}


function FlagCaptureThink( soul )
{
	soul.EndSignal( "OnDestroy" )
	level.flagReturnPoint.EndSignal( "OnDestroy" )
	local otherTeam = GetOtherTeam(soul.GetTeam())

	local beganAssault = false

	while ( GetGameState() == eGameState.Playing )
	{
		local titan = soul.GetTitan()

		if ( !IsAlive( titan ) )
		{
			SetWinner(GetOtherTeam(level.nv.attackingTeam))
			return
		}

		if ( IsValid( titan ) )
		{
			local flagDistance = (titan.GetOrigin() - level.flagReturnPoint.GetOrigin()).Length()

			if ( flagDistance < 256 )
			{
				if ( titan.GetBossPlayer() )
					AwardCaptureToPlayer( titan.GetBossPlayer() )
				return
			}
			else if ( flagDistance < 768 )
			{
				local bossPlayer = titan.GetBossPlayer()
				if ( bossPlayer && bossPlayer.GetPetTitanMode() == eNPCTitanMode.FOLLOW && !beganAssault )
				{
					SendFlagTitanToReturn( titan )
					beganAssault = true
				}
			}
		}

		wait 0.1
	}
}


function SendFlagTitanToReturn( npcTitan )
{
	Assert( "guardModePoint" in npcTitan.s )
	npcTitan.s.guardModePoint.SetOrigin( level.flagReturnPoint.GetOrigin() )
	npcTitan.DisableBehavior( "Follow" )
	npcTitan.AssaultPointEnt( npcTitan.s.guardModePoint )
}


function AwardCaptureToPlayer( player )
{
	local soul = player.GetTitanSoul()

	AddPlayerScore( player, "FlagCapture" )
	player.SetAssaultScore( player.GetAssaultScore() + 1 )

	MessageToTeam( TEAM_IMC, eEventNotifications.PlayerCapturedTheTitan, null, player )
	MessageToTeam( TEAM_MILITIA, eEventNotifications.PlayerCapturedTheTitan, null, player )

	EmitSoundOnEntityToTeam( player, "UI_CTF_Enemy_Score", GetOtherTeam(level.nv.attackingTeam))
	EmitSoundOnEntityToTeam( player, "UI_CTF_1P_Score", level.nv.attackingTeam )

	SetWinner( level.nv.attackingTeam )
}


function CreateTitanForTeam( team, spawnOrigin, spawnAngles )
{
	local titanDataTable = GetPresetTitanLoadout( 0 )
	titanDataTable.setFile = "titan_ctt"
	local settings = titanDataTable.setFile

	local titan = CreateNPCTitanFromSettings( settings, team, spawnOrigin, spawnAngles )
	titan.GetTitanSoul().followOnly = true
	GiveTitanWeaponsForLoadoutData( titan, titanDataTable )
	waitthread SuperHotDropGenericTitan( titan, spawnOrigin, spawnAngles )

	thread CreateGenericBubbleShield( titan, spawnOrigin, spawnAngles )

	return titan
}


function TE_OnPlayerOrNPCKilled( player, damageInfo )
{
	if ( player.GetTeam() != level.nv.attackingTeam )
		return

	if ( !IsValid( level.teamFlag ) )
		return

	if ( level.teamFlag.GetBossPlayer() != player )
		return

	local titan = level.teamFlag.GetTitan()
	if ( !IsValid( titan ) )
		return

	FreeAutoTitan( titan )
}



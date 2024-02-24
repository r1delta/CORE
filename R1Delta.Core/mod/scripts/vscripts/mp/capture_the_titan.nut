function main()
{
	Globalize( ScriptCallback_OnClientConnecting )
	Globalize( ClearFlagCarrierStatus )

	// level.spawnRatingFunc_Pilot = Bind( RateSpawnpoint_CaptureTheTitan )
	// level.spawnRatingFunc_Generic = Bind( RateSpawnpoint_CaptureTheTitan )
	level.spawnRatingFunc_Pilot = RateFrontLinePlayerSpawnpoint
	level.spawnRatingFunc_Generic = RateFrontLinePlayerSpawnpoint

	SetSwitchSidesBased( true )
	SetRoundBased( true )
	//SetWaveSpawnType( eWaveSpawnType.FIXED_INTERVAL )

	level.pilotRespawnDelay = 15.0

	level.flagReturnPoint <- null
	level.flagSpawnPoint <- null
	level.teamFlag <- null

	level.distanceBetweenTitanSpawnAndFlagReturn <- null

	level.timeAnnouncedTriggerEnter <- 0

	RegisterSignal( "TrackPlayerInTrigger" )

	level.nv.attackingTeam = TEAM_MILITIA

	AddCallback_PlayerOrNPCKilled( CTT_OnPlayerOrNPCKilled )

	AddDamageCallback( "player", CTT_PlayerTookDamage )

	AddCallback_GameStateEnter( eGameState.Playing, CTTRoundStart )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, CTTRoundEnd ) // should be a "leave" callback
	AddCallback_GameStateEnter( eGameState.SwitchingSides, CTTRoundEnd )
}


function SpawnPoint_CaptureTheTitanScore( checkclass, spawnpoint, team, player = null )
{
	local soul = GetTitanFlag()
	if ( !IsValid( soul ) )
		return 0

	local titan = soul.GetTitan()
	if ( !IsValid( titan ) )
		return 0

	if ( !titan.IsPlayer() )
		return 0

	if ( team == level.nv.attackingTeam )
		return 0

	local returnOrigin = GetTitanFlagReturnOrigin()
	if ( !returnOrigin )
		return 0

	local goalVec = returnOrigin - titan.GetOrigin()
	local vecToSpawnPoint = returnOrigin - spawnpoint.GetOrigin()
	goalVec.Normalize()
	vecToSpawnPoint.Normalize()

	local dotDiff = goalVec.Dot( vecToSpawnPoint )

	return dotDiff * 10.0
}


function RateSpawnpoint_CaptureTheTitan( checkclass, spawnpoint, team, player = null )
{
	local cttRating = SpawnPoint_CaptureTheTitanScore( checkclass, spawnpoint, team, player )
	local ratingWithPetTitan = cttRating

	// if we have a pet rating lower the influence of some other ratings
	if ( 0.0 > cttRating && cttRating > -3.5 )
		ratingWithPetTitan = cttRating * 0.25

	local rating = spawnpoint.CalculateRating( checkclass, team, cttRating, ratingWithPetTitan )
//	printt( rating, cttRating, team, savedTeam )
}


function EntitiesDidLoad()
{
	local imcFlag = SpawnPoints_GetTitanStart( TEAM_IMC )[0]
	local militiaFlag = SpawnPoints_GetTitanStart( TEAM_MILITIA )[0]

	local imcOrigin = imcFlag.GetOrigin()
	local militiaOrigin = militiaFlag.GetOrigin()

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

		//spawnpoint.s.spawnpointTeamOverrideFunc <- Bind( GetSpawnpointTeamOverride )
	}

	foreach ( spawnpoint in level.allSpawnpoints )
	{
		if ( !IsValid( spawnpoint ) )
			continue

		if ( spawnpoint.GetTeam() == level.defenseTeam )
			spawnpoint.SetTeam(GetTeamIndex(GetOtherTeams(1 << level.nv.attackingTeam)))
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
	thread FlagTrackerThink(GetTeamIndex(GetOtherTeams(1 << level.nv.attackingTeam)))
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
		player.Minimap_AlwaysShow( 0, null )
		player.SetForceCrosshairNameDraw( false )
	}

	MessageToTeam( TEAM_IMC, -1 )
	MessageToTeam( TEAM_MILITIA, -1 )
}


function CreateFlagReturnBase( team )
{
	local otherTeam = GetTeamIndex(GetOtherTeams(1 << team))
	local spawnpoint = SpawnPoints_GetTitanStart( otherTeam )[0]

	local spawnOrigin = spawnpoint.GetOrigin()
	local spawnAngles = spawnpoint.GetAngles()

	if ( GetMapName() == "mp_smugglers_cove" )
	{
		spawnOrigin = Vector( -1031.166382, 1810.152100, 336.031250 )
		spawnAngles = Vector( 0, 90, 0 )
	}
	else if ( GetMapName() == "mp_rise" )
	{
		spawnOrigin = Vector( 1696, 2128, 32 )
		spawnAngles = Vector( 0, 90, 0 )
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

	local baseModel = CreatePropDynamic( CTF_FLAG_BASE_MODEL, spawnOrigin, spawnAngles, 6 )
	baseModel.SetTeam( team )

	level.flagReturnPoint = baseModel

	{
		local traceStart = spawnpoint.GetOrigin() + Vector( 0, 0, 32 )
		local traceEnd = spawnpoint.GetOrigin() + Vector( 0, 0, -32 )
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
	local otherTeam = GetTeamIndex(GetOtherTeams(1 << team))
	local spawnpoint = SpawnPoints_GetTitanStart( otherTeam )[0]

	local spawnOrigin = spawnpoint.GetOrigin()
	local spawnAngles = spawnpoint.GetAngles()

	if ( GetMapName() == "mp_smugglers_cove" )
	{
		spawnOrigin = Vector( -617.907166, -5414.525391, -23.562424 )
		spawnAngles = Vector( 0, 90, 0 )
	}
	else if ( GetMapName() == "mp_rise" )
	{
		spawnOrigin = Vector( -3696, -464, 384 )
		spawnAngles = Vector( 0, -90, 0 )
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
		local traceStart = spawnpoint.GetOrigin() + Vector( 0, 0, 32 )
		local traceEnd = spawnpoint.GetOrigin() + Vector( 0, 0, -32 )
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

		level.distanceBetweenTitanSpawnAndFlagReturn = Distance( spawnOrigin, GetTitanFlagReturnOrigin() )

		local soul = titan.GetTitanSoul()
		soul.SetTeam( otherTeam )
		level.teamFlag = soul
		level.nv.cttTitanSoul = soul.GetEncodedEHandle()

		local trigger = CreateScriptCylinderTrigger( level.flagReturnPoint.GetOrigin(), 256 )
		AddCallback_ScriptTriggerEnter( trigger, CTTTriggerEnter )
		AddCallback_ScriptTriggerLeave( trigger, CTTTriggerLeave )

		ScriptTriggerEnable( trigger, true )

		thread TrackDistanceToFlagReturn( soul )
		thread TrackTitanHealth( soul )

		//thread FlagCaptureThink( soul, trigger )
		thread FlagTakeThink( soul )

		soul.WaitSignal( "OnDestroy" )
		level.nv.cttPlayerCaptureEndTime = 99999

		if ( IsRoundBased() )
			break
	}

	baseModel.Destroy()
	spawnpointMinimap.Destroy()
}


function FlagTakeThink( soul )
{
	soul.EndSignal( "OnDestroy" )

	local results

	while ( true )
	{
		results = soul.WaitSignal( "PlayerEmbarkedTitan" )

		local titanPilot = results.player

		if ( !("embarked" in soul.s) )
		{
			local titanDataTable = GetPresetTitanLoadout( 0 )
			//GiveTitanWeaponsForLoadoutData( soul.GetSoulOwner(), titanDataTable )
			GiveTitanWeaponsForPlayer( titanPilot, titanPilot )
			soul.s.embarked <- true
		}

		MessageToTeam( TEAM_IMC, eEventNotifications.PlayerHasTheTitan, null, titanPilot )
		MessageToTeam( TEAM_MILITIA, eEventNotifications.PlayerHasTheTitan, null, titanPilot )

		EmitSoundOnEntityToTeamExceptPlayer( titanPilot, "UI_CTF_Enemy_FlagUpdate", TEAM_IMC, titanPilot )
		EmitSoundOnEntityToTeamExceptPlayer( titanPilot, "UI_CTF_Team_FlagUpdate", TEAM_MILITIA, titanPilot )
		EmitSoundOnEntityOnlyToPlayer( titanPilot, titanPilot, "UI_CTF_1P_FlagGrab" )

		PlayConversationToPlayer( "CTT_TitanEmbarked", titanPilot )

		results = soul.WaitSignal( "PlayerDisembarkedTitan" )
		level.nv.cttPlayerCaptureEndTime = 99999

		if ( "captured" in soul.s )
			return

		titanPilot = results.player

		MessageToTeam( TEAM_IMC, eEventNotifications.PlayerLeftTheTitan, null, titanPilot )
		MessageToTeam( TEAM_MILITIA, eEventNotifications.PlayerLeftTheTitan, null, titanPilot )
	}
}

function TrackDistanceToFlagReturn( soul ) //Assume one point for now, shouldn't be hard to extend if we do more than one point
{
	soul.EndSignal( "OnDestroy" )
	local previousProportionalthreshold = 1.0

	local firstThreshold = 0.6
	local secondThreshold = 0.3
	while( true )
	{
		local titan = soul.GetTitan()

		if ( !IsValid( titan ) )
			return

		if ( !titan.IsPlayer() )
		{
			wait 1.0
			continue
		}

		local distance = Distance( titan.GetOrigin(), GetTitanFlagReturnOrigin() )

		local proportionalDistance = distance / level.distanceBetweenTitanSpawnAndFlagReturn

		local titanTeam = titan.GetTeam()
		local defendingTeam = GetTeamIndex(GetOtherTeams(1 << titanTeam))

		if ( proportionalDistance <= firstThreshold && previousProportionalthreshold > firstThreshold )  //Just do this the simple way. If we need to add a lot more distance thresholds update we can do the fancier way later
		{
			PlayConversationToPlayer( "CTT_TitanHalfway_TitanPilotUpdate", titan )
			PlayConversationToTeamExceptPlayer( "CTT_TitanHalfway_AttackTeamUpdate", titanTeam, titan)
			PlayConversationToTeam( "CTT_TitanHalfway_DefendTeamUpdate", defendingTeam )
			previousProportionalthreshold = firstThreshold

		}
		else if (  proportionalDistance <= secondThreshold && previousProportionalthreshold > secondThreshold )
		{
			PlayConversationToPlayer( "CTT_TitanThreeQuarterMark_TitanPilotUpdate", titan )
			PlayConversationToTeamExceptPlayer( "CTT_TitanThreeQuarterMark_AttackTeamUpdate", titanTeam, titan)
			PlayConversationToTeam( "CTT_TitanThreeQuarterMark_DefendTeamUpdate", defendingTeam )
			previousProportionalthreshold = secondThreshold
		}

		//Reset previousProportionalthreshold if we've drifted backwards too far
		if ( previousProportionalthreshold == firstThreshold && proportionalDistance > firstThreshold + 0.2 )
		{
			previousProportionalthreshold = 1.0
		}
		else if ( previousProportionalthreshold == secondThreshold && proportionalDistance > secondThreshold + 0.2 )
		{
			previousProportionalthreshold = firstThreshold
		}

		wait 1.0 //Every second should be often enough

	}
}

function TrackTitanHealth( soul ) //Could do this on a OnTookDamage callback too, but since we need to store data about previous health etc it's more convenient to do it here
{
	soul.EndSignal( "OnDestroy" )
	local previousProportionalthreshold = 1.0

	local firstThreshold = 0.6
	local secondThreshold = 0.3

	while( true )
	{
		if ( soul.IsDoomed() )
			return

		local titan = soul.GetTitan()

		if ( !IsValid( titan ) )
			return

		local currentHealth = titan.GetHealth().tofloat()

		local proportionalHealth = currentHealth / titan.GetMaxHealth()

		local titanTeam = titan.GetTeam()
		local defendingTeam = GetTeamIndex(GetOtherTeams(1 << titanTeam))

		if ( proportionalHealth <= firstThreshold && previousProportionalthreshold > firstThreshold )  //Just do this the simple way. If we need to add a lot more distance thresholds update we can do the fancier way later
		{
			PlayConversationToTeam( "CTT_TitanHalfHealth_AttackTeamAnnouncement", titanTeam )
			PlayConversationToTeam( "CTT_TitanHalfHealth_DefendTeamAnnouncement", defendingTeam )
			previousProportionalthreshold = firstThreshold


		}
		else if ( proportionalHealth <= secondThreshold && previousProportionalthreshold > secondThreshold )
		{
			PlayConversationToTeam( "CTT_TitanQuarterHealth_AttackTeamAnnouncement", titanTeam )
			PlayConversationToTeam( "CTT_TitanQuarterHealth_DefendTeamAnnouncement", defendingTeam )
			previousProportionalthreshold = secondThreshold
		}

		wait 1.0 //Every second should be often enough
	}

}


function CTTTriggerEnter( trigger, player )
{
	thread TrackPlayerInTrigger( player, trigger )

	if ( !PlayerIsTitanFlag( player ) )
		return

	local currentTime = Time()

	if ( currentTime - level.timeAnnouncedTriggerEnter > 15 ) //15s debounce on entering trigger announcemenents
	{
		local playerTeam = player.GetTeam()
		PlayConversationToPlayer( "CTT_TitanAtPoint_TitanPilotUpdate", player )
		PlayConversationToTeamExceptPlayer( "CTT_TitanHalfway_AttackTeamUpdate", playerTeam, player )
		PlayConversationToTeam( "CTT_TitanAtPoint_DefendTeamUpdate", GetTeamIndex(GetOtherTeams(1 << playerTeam)))
		level.timeAnnouncedTriggerEnter = currentTime
	}


}


function CTTTriggerLeave( trigger, player )
{
	if ( !IsAlive( player ) )
		return

	player.Signal( "TrackPlayerInTrigger" )

	if ( !PlayerIsTitanFlag( player ) )
		return

	level.nv.cttPlayerCaptureEndTime = 99999
}


function TrackPlayerInTrigger( player, trigger )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )
	player.EndSignal( "TrackPlayerInTrigger" )

	local wasPlayerTitanFlag = false
	local wasPlayerRodeod = false
	local captureStartTime = 0

	const CTT_CAPTURE_TIME = 5.0

	while ( IsValid( player ) )
	{
		if ( PlayerIsTitanFlag( player ) )
		{
			local isPlayerRodeod = (GetEnemyRodeoPlayer( player ) != null)

			if ( !wasPlayerTitanFlag )
			{
				level.nv.cttPlayerCaptureEndTime = Time() + CTT_CAPTURE_TIME
				captureStartTime = Time()
			}

			printt( Time() - level.nv.cttPlayerCaptureEndTime )

			if ( !isPlayerRodeod && Time() > level.nv.cttPlayerCaptureEndTime )
			{
				level.nv.cttPlayerCaptureEndTime = 99999
				AwardCaptureToPlayer( player )
				return
			}
		}

		wasPlayerRodeod = player.IsTitan() && (GetEnemyRodeoPlayer( player ) != null)
		wasPlayerTitanFlag = PlayerIsTitanFlag( player )
		wait 0
	}
}


function AwardCaptureToPlayer( player )
{
	local soul = player.GetTitanSoul()
	soul.s.captured <- true

	AddPlayerScore( player, "FlagCapture" )
	player.SetAssaultScore( player.GetAssaultScore() + 1 )

	thread TitanEjectPlayer( player, true )

	MessageToTeam( TEAM_IMC, eEventNotifications.PlayerCapturedTheTitan, null, player )
	MessageToTeam( TEAM_MILITIA, eEventNotifications.PlayerCapturedTheTitan, null, player )

	EmitSoundOnEntityToTeam( player, "UI_CTF_Enemy_Score", GetTeamIndex(GetOtherTeams(1 << level.nv.attackingTeam)))
	EmitSoundOnEntityToTeam( player, "UI_CTF_1P_Score", level.nv.attackingTeam )

	if ( IsRoundBased() )
	{
		wait 1.0
		// SetWinLossReasons( winReason, lossReason )
		SetWinner( player.GetTeam() )
	}
	else
	{
		GameScore.AddTeamScore( player.GetTeam(), 1 )
	}
}


function ScriptCallback_OnClientConnecting( player )
{
}



function CreateTitanForTeam( team, origin, angles )
{
	local titanDataTable = GetPresetTitanLoadout( 0 )
	titanDataTable.setFile = "titan_ogre"
	local settings = titanDataTable.setFile

	local titan = CreateNPCTitanFromSettings( settings, team, origin, angles )
	titan.GetTitanSoul().capturable = true
	//GiveTitanWeaponsForLoadoutData( titan, titanDataTable )
	waitthread SuperHotDropGenericTitan( titan, origin, angles )

	if ( IsRoundBased() )
		thread CreateGenericBubbleShield( titan, origin, angles, 15 )
	else
		thread CreateGenericBubbleShield( titan, origin, angles )

	titan.SetUsableByGroup( "friendlies pilot" )

	return titan
}



function CTT_OnPlayerOrNPCKilled( victim, attacker, damageInfo )
{
	if ( !victim.IsTitan() )
		return

	if ( victim.GetTitanSoul() != GetTitanFlag() )
		return

	local attacker = damageInfo.GetAttacker()

	ClearFlagCarrierStatus( victim, null )

	if ( !attacker.IsPlayer() )
		return

	if ( "captured" in victim.GetTitanSoul().s )
		return

	MessageToTeam( TEAM_IMC, eEventNotifications.PlayerDestroyedTheTitan, null, attacker )
	MessageToTeam( TEAM_MILITIA, eEventNotifications.PlayerDestroyedTheTitan, null, attacker )

	EmitSoundOnEntityToTeam( victim, "UI_CTF_1P_Score", GetTeamIndex(GetOtherTeams(1 << level.nv.attackingTeam)))
	EmitSoundOnEntityToTeam( victim, "UI_CTF_Team_FlagUpdate", level.nv.attackingTeam )

	if ( IsRoundBased() )
	{
		// SetWinLossReasons( winReason, lossReason )
		SetWinner(GetTeamIndex(GetOtherTeams(1 << level.nv.attackingTeam)))
	}
	else
	{
		GameScore.AddTeamScore(GetTeamIndex(GetOtherTeams(1 << level.nv.attackingTeam)), 1 )
	}

	local attackerTeam = attacker.GetTeam()
	local victimTeam = victim.GetTeam()

	PlayConversationToTeam( "CTT_TitanDestroyed_AttackTeamAnnouncement", victimTeam ) //Currently supressed by "You lost the round!" conversation
	if ( victimTeam == attackerTeam )
		return

	PlayConversationToPlayer( "CTT_TitanDestroyedByPlayer", attacker ) //Currently supressed by "You won the round!" conversation
	PlayConversationToTeamExceptPlayer( "CTT_TitanDestroyed_DefendTeamAnnouncement", attackerTeam, attacker ) //Currently supressed by "You won the round!" conversation

	AddPlayerScore( attacker, "FlagCarrierKill" )
}


function CTT_PlayerTookDamage( player, damageInfo )
{
	if ( !player.IsTitan() )
		return

	if ( player.GetTitanSoul() != GetTitanFlag() )
		return

	local damage = damageInfo.GetDamage()

	//Damage_SlowPlayer( )
}


function Damage_SlowPlayer( player, scale, duration )
{
	Assert( IsValid( player ) )

	player.EndSignal( "OnEMPPilotHit" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Doomed" )
	player.EndSignal( "Disconnected" )

	player.SetMoveSpeedScale( scale )

	wait duration

	player.SetMoveSpeedScale( 1.0 )
}


function ClearFlagCarrierStatus( player, titan )
{
	player.Minimap_AlwaysShow( 0, null )
	player.SetForceCrosshairNameDraw( false )
	if ( !IsValid( titan ) )
		return
	titan.Minimap_AlwaysShow( TEAM_IMC, null )
	titan.Minimap_AlwaysShow( TEAM_MILITIA, null )
}

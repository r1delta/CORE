function main()
{
	IncludeFile( "mp/_replacement_titans_drop" )
//	PrecacheModel( "models/robots/marvin/marvin_shooter.mdl" )
//	PrecacheModel( "models/robots/marvin/marvin_worker.mdl" )
	PrecacheModel( "models/robots/marvin/marvin.mdl" )

	RegisterSignal( "titan_impact" )
	Globalize( EmptyTitanPlaysAnim )
	Globalize( TryReplacementTitanReadyAnnouncement )
	Globalize( DropTitanHealthPod )

	Globalize( DropReplacementTitan)
	Globalize( ForceReplacementTitan )
	Globalize( IsReplacementTitanAvailable )

	RegisterSignal( "SetTitanRespawnTimer" )
	RegisterSignal( "CalledInReplacementTitan" )
	Globalize( DecrementBuildCondition )
	Globalize( DecrementCoreTimer )
	Globalize( GetAttachmentAtTimeFromModel )
	Globalize( TryETATitanReadyAnnouncement )

	PrecacheEffect( TURBO_WARP_FX )
	PrecacheEffect( TURBO_WARP_COMPANY )


	Globalize( req )
	Globalize( ClientCommand_ReplacementTitan )

	Globalize( SetTitanCoreTimer )

	AddCallback_OnClientConnecting( ReplacementTitan_InitPlayer )

	AddClientCommandCallback( "ReplacementTitan", ClientCommand_ReplacementTitan ) //

	AddSoulDeathFunc( ResetTitanReplacementAnnouncements )

	file.ETATimeThresholds <- [ 120, 60, 30, 15 ]
	file.ETA2MinUpperBound <- 123
	file.ETA2MinLowerBound <- 115
	file.ETA60sUpperBound <- 63
	file.ETA60sLowerBound <- 55
	file.ETA30sUpperBound <- 33
	file.ETA30sLowerBound <- 25
	file.ETA15sUpperBound <- 18
	file.ETA15sLowerBound <- 12
	file.ETAAnnouncementAllowanceTime <- 6.0

	file.buildTimerDisabled <- false

	file.warpFallDebounce <- {}

	const nagInterval = 40
}


function ReplacementTitan_InitPlayer( player )
{
	player.s.replacementTitanETATimer <- GetTimeLimit_ForGameMode() * 60.0
	player.s.replacementTitanReady_lastNagTime <- 0
}


function IsReplacementTitanAvailable( player, timeBuffer = 0 )
{
	if ( !IsReplacementTitanAvailableForGameState() )
		return false

	if ( IsAlive( player.GetPetTitan() ) )
		return false

	if ( player.isSpawning )
		return false

	if ( Riff_TitanAvailability() != eTitanAvailability.Default )
	{
		return Riff_IsTitanAvailable( player )
	}

	if ( player.IsBot() )
		return true

	return player.IsTitanReady()
}

function IsReplacementTitanAvailableForGameState()
{
	local currentGameState = GetGameState()

	switch( currentGameState ) //need to add a new entry in here for every new game state we make
	{
		case eGameState.WaitingForCustomStart:
		case eGameState.WaitingForPlayers:
		case eGameState.PickLoadout:
		case eGameState.Prematch:
		case eGameState.SwitchingSides:
		case eGameState.Postmatch:
			return false

		case eGameState.Playing:
		case eGameState.SuddenDeath:
			return true

		case eGameState.WinnerDetermined:
		case eGameState.Epilogue:
		{
			if ( IsRoundBased() )
		 	{
		 		if ( !IsRoundBasedGameOver() )
		 			return false

		 		if ( !ShouldRunEvac() )
		 			return false
		 	}

		 	return true
		}

		default:
			Assert( false, "Unknown Game State!" )
			return false
	}
	/* Older style of doing this
	if ( currentGameState < eGameState.Playing )
	  return false

	 if ( currentGameState >= eGameState.Postmatch )
	 	return false

	 if ( currentGameState > eGameState.Playing )
	 {
	 	if ( IsRoundBased() )
	 	{
	 		if ( !IsRoundBasedGameOver() )
	 			return false

	 		if ( !ShouldRunEvac() )
	 			return false
	 	}

	 	if ( IsSwitchSidesBased() )
	 	{
	 		//Don't let titans be called in during switching sides gamestate. Written in this way to try to make it easy to add new game states after switching sides if necessary
	 		if ( currentGameState >= eGameState.SwitchingSides && currentGameState < eGameState.WinnerDetermined )
	 			return false
	 	}
	 }

	 return true*/
}

function GetTitanCoreTimer( titan )
{
	Assert( titan.IsTitan() )
	local soul = titan.GetTitanSoul()
	Assert( soul )

	return soul.GetNextCoreChargeAvailable() - Time()
}

function DecrementBuildCondition( player, amount )
{
	printt("[LJS] timerCredit: ", amount)
	if ( player.IsTitan() )
	{
		// core ability in use
		if ( TitanCoreInUse( player ) )
			return

		if ( !IsAlive( player ) )
			return
	}
	else
	{
		if ( player.GetPetTitan() )
			return
	}

	amount = ModifyBuildTimeForPlayerBonuses( player, amount )

	if ( player.IsTitan() )
	{
		SetTitanCoreTimer( player, GetTitanCoreTimer( player ) - amount )
	}
	else
	{
		DecrementBuild( player, amount )
	}
}

function DecrementCoreTimer( player, ent, savedDamage, shieldDamage )
{
	if( !player.IsTitan() )
		return

	// core ability in use
	if ( TitanCoreInUse( player ) )
		return

	if ( !IsAlive( player ) )
		return

	local amount = GetCoreTimeCredit(player, ent, savedDamage, shieldDamage)

	SetTitanCoreTimer( player, GetTitanCoreTimer( player ) - amount )

	Remote.CallFunction_NonReplay( player, "ServerCallback_UpdateTitanModeHUD" )
}

function GetCoreTimeCredit( player, ent, savedDamage, shieldDamage )
{
	if( !player.IsTitan() )
		return

	// core ability in use
	if ( TitanCoreInUse( player ) )
		return

	if ( !IsAlive( player ) )
		return

	local timerCredit = 0

	if ( IsAlive( ent ) )
	{
		if ( ent.IsTitan() )
		{
			// ATDM AI Titan
			if( ent.IsNPC() && IsAtdmFreeTitan( ent ) )
			{
				timerCredit = 45
			}
			else
			{
				timerCredit = GetCurrentPlaylistVarFloat( "titan_kill_credit", 0.5 )
				if ( PlayerHasServerFlag( player, SFLAG_HUNTER_TITAN ) )
					timerCredit *= 2.0
			}
		}
		else
		{
			if ( ent.IsPlayer() )
			{
				timerCredit = GetCurrentPlaylistVarFloat( "player_kill_credit", 0.5 )
				if ( PlayerHasServerFlag( player, SFLAG_HUNTER_PILOT ) )
					timerCredit *= 2.5
			}
			else
			{
				if ( ent.IsSoldier() )
				{
					timerCredit = GetCurrentPlaylistVarFloat( "ai_kill_credit", 0.5 )
					if ( PlayerHasServerFlag( player, SFLAG_HUNTER_GRUNT ) )
						timerCredit *= 2.5
				}
				else
				if ( ent.IsSpectre() )
				{
					timerCredit = GetCurrentPlaylistVarFloat( "spectre_kill_credit", 0.5 )
					if ( PlayerHasServerFlag( player, SFLAG_HUNTER_SPECTRE ) )
						timerCredit *= 2.5
				}
				else
				if ( ent.IsTurret() && ent.GetTeam() != TEAM_UNASSIGNED)
				{

					timerCredit = GetCurrentPlaylistVarFloat( "megaturret_kill_credit", 0.5 )
					//No 2x burn card for shooting mega turret
				}
				else
				if ( IsEvacDropship( ent ) )
				{
					timerCredit = GetCurrentPlaylistVarFloat( "evac_dropship_kill_credit", 0.5 )
				}
			}
		}

		if ( PlayerHasPassive( player, PAS_HYPER_CORE ) )
			timerCredit *= 2.0

		local dealtDamage = min( ent.GetHealth(), savedDamage + shieldDamage )
		timerCredit = timerCredit * (dealtDamage / ent.GetMaxHealth().tofloat())
		//printt("[digm][GetCoreTimeCredit] - timerCredit = " + timerCredit + " dealtDamage = " + dealtDamage + " MaxHealth = " + ent.GetMaxHealth())
	}

	return timerCredit
}

function ModifyBuildTimeForPlayerBonuses( player, amount )
{
	if ( PlayerHasServerFlag( player, SFLAG_FAST_BUILD2 ) )
	{
		amount *= 2.0
	}
	else
	if ( PlayerHasServerFlag( player, SFLAG_FAST_BUILD1 ) )
	{
		amount *= 1.5
	}

	return amount
}

if (GAMETYPE == "tutorial" || GAMETYPE == "titan_tutorial")
{
	function SetTitanCoreTimer( titan, timeDiff )
	{
	}
}
else
{
	function SetTitanCoreTimer( titan, timeDiff )
	{
		Assert( titan.IsTitan() )
		local soul = titan.GetTitanSoul()
		Assert( soul )

		local newTime = Time() + timeDiff
		soul.SetNextCoreChargeAvailable( max( Time() - 1, newTime ) )
	}
}


function SetTitanRespawnContition_Internal( player, titanBuildCondition )
{
	player.EndSignal( "Disconnected" )
	player.Signal( "SetTitanRespawnTimer" )
	player.EndSignal( "SetTitanRespawnTimer" )
	player.EndSignal( "CalledInReplacementTitan" )
	player.EndSignal( "ChoseToSpawnAsTitan" )


	if ( titanBuildCondition > 0 )
	{
		wait GetTimeTillNextETAAnnouncement( player, titanBuildCondition )
	}

	TryETATitanReadyAnnouncement( player )
}

function GetTimeTillNextETAAnnouncement( player, titanBuildCondition )
{
	if ( titanBuildCondition <= 0 )
	{
		//printt( "Waiting 0, Titan Ready" )
		return 0
	}

	if ( titanBuildCondition >= file.ETA2MinUpperBound && player.s.replacementTitanETATimer > 120 )  //Give some leadup time to conversation starting
	{
		//printt( "Waiting " + ( timeTillNextTitan - file.ETA2MinUpperBound ) + " till 2 min announcement" )
		return titanBuildCondition - file.ETA2MinUpperBound
	}

	if ( titanBuildCondition >= file.ETA2MinLowerBound && player.s.replacementTitanETATimer > 120 )
	{
		//printt( "Waiting 0 till 2 min announcement" )
		return 0 //Play 2 min ETA announcement immediately
	}

	if ( titanBuildCondition >= file.ETA60sUpperBound && player.s.replacementTitanETATimer > 60 )
	{
		//printt( "Waiting " + ( timeTillNextTitan - file.ETA60sUpperBound ) + " till 60s announcement" )
		return titanBuildCondition - file.ETA60sUpperBound
	}

	if ( titanBuildCondition >= file.ETA60sLowerBound && player.s.replacementTitanETATimer > 60 )
	{
		//printt( "Waiting 0 till 60s announcement" )
		return 0
	}

	if ( titanBuildCondition >= file.ETA30sUpperBound && player.s.replacementTitanETATimer > 30 )
	{
		//printt( "Waiting " + ( timeTillNextTitan - file.ETA30sUpperBound ) + " till 30s announcement" )
		return titanBuildCondition - file.ETA30sUpperBound
	}

	if ( titanBuildCondition >= file.ETA30sLowerBound && player.s.replacementTitanETATimer > 30 )
	{
		//printt( "Waiting 0 till 30 announcement" )
		return 0
	}

	if ( titanBuildCondition >= file.ETA15sUpperBound && player.s.replacementTitanETATimer > 15 )
	{
		//printt( "Waiting " + ( timeTillNextTitan - file.ETA15sUpperBound ) + " till 15s announcement" )
		return titanBuildCondition - file.ETA15sUpperBound
	}

	if ( titanBuildCondition >= file.ETA15sLowerBound  && player.s.replacementTitanETATimer > 15 )
	{
		//printt( "Waiting 0 till 15s announcement" )
		return 0
	}

	//printt( "Waiting " + timeTillNextTitan + " till next Titan" )
	return titanBuildCondition


}

function TryETATitanReadyAnnouncement( player )
{
	//printt( "TryETATitanReadyAnnouncement" )
	if ( !IsAlive( player ) )
		return

	if ( GetPlayerTitanInMap( player ) )
		return

	if ( player.IsTitanBuildStarted() == false )
		return

	if ( GetGameState() > eGameState.SuddenDeath )
		return

	if ( GameTime.PlayingTime() < 5.0 )
		return

	local remainNextTitan = GetRemain( player )

	if ( floor(remainNextTitan) <= 0 )
	{
		//Titan is ready, let TryReplacementTitanReadyAnnouncement take care of it
		TryReplacementTitanReadyAnnouncement( player )
		return
	}

	//This entire loop is probably too complicated now for what it's doing. Simplify next game!
	//Loop might be pretty hard to read, a particular iteration of the loop is written in comments below
	for ( local i = 0; i < file.ETATimeThresholds.len(); ++i )
	{
		if ( fabs( remainNextTitan - file.ETATimeThresholds[ i ] ) < file.ETAAnnouncementAllowanceTime )
		{
			if ( player.s.replacementTitanETATimer > file.ETATimeThresholds[ i ] )
			{
				if ( player.titansBuilt )
					PlayConversationToPlayer( "TitanReplacementETA" + file.ETATimeThresholds[ i ] + "s" , player )
				else
					PlayConversationToPlayer( "FirstTitanETA" + file.ETATimeThresholds[ i ] + "s", player )

				//player.s.replacementTitanETATimer = file.ETATimeThresholds[ i ]
				//wait remainNextTitan - file.ETATimeThresholds[ i ]
				//if ( IsAlive( player ) )
				//{
					//SetTitanRespawnTimer( player, player.GetNextTitanRespawnAvailable() - Time() )
				//}
				return
			}
		}
	}

	/*if ( fabs( timeTillNextTitan - 120 ) < ETAAnnouncementAllowanceTime && player.s.replacementTitanETATimer > 120 )
	{
		if ( player.titansBuilt )
			PlayConversationToPlayer( "TitanReplacementETA120s", player )
		else
			PlayConversationToPlayer( "FirstTitanETA120s", player )
		player.s.replacementTitanETATimer = 120
		wait timeTillNextTitan - 120
		SetTitanRespawnTimer( player, player.GetNextTitanRespawnAvailable() - Time()  )
		return
	}
	*/

}

function TryReplacementTitanReadyAnnouncement( player )
{
	while( true )
	{
		//printt( "TryReplacementTitanReadyAnnouncementLoop" )
		if ( !IsAlive( player ) )
			return

		if ( GetGameState() > eGameState.SuddenDeath )
			return

		if ( GetPlayerTitanInMap( player ) )
			return

		if ( level.nv.titanDropEnabledForTeam != TEAM_BOTH && level.nv.titanDropEnabledForTeam != player.GetTeam() )
			return

		if ( player.s.replacementTitanReady_lastNagTime == 0 || Time() - player.s.replacementTitanReady_lastNagTime >= nagInterval )
		{
			if ( player.titansBuilt )
			{
				//Don't play Titan Replacement Announcements if you don't have it ready
				if ( ( Riff_TitanAvailability() != eTitanAvailability.Default ) && ( !Riff_IsTitanAvailable( player ) ) )
					return

				PlayConversationToPlayer( "TitanReplacementReady", player )
			}
			else
			{
				PlayConversationToPlayer( "FirstTitanReady", player )
			}
			player.s.replacementTitanReady_lastNagTime = Time()
		}

		wait 5.0 // Once every 5 seconds should be fine
	}
}

function ResetTitanReplacementAnnouncements( soul )
{
	local player = soul.GetBossPlayer()

	if ( !IsValid( player ) )
		return

	player.s.replacementTitanETATimer = level.nv.gameEndTime
}

function req()
{
	ClientCommand_ReplacementTitan( GetPlayerArray()[0] )
}

//function RequestReplacementTitan()
function ClientCommand_ReplacementTitan( player )
{
	if ( !IsReplacementTitanAvailable( player ) )
	{
		printt( "ClientCommand_ReplacementTitan", player, player.entindex(), "failed", "IsReplacementTitanAvailable was false" )
		return true
	}

	local titan = GetPlayerTitanInMap( player )
	if ( IsAlive( titan ) )
	{
		printt( "ClientCommand_ReplacementTitan", player, player.entindex(), "failed", "GetPlayerTitanInMap was true" )
		return true
	}

	if ( !IsAlive( player ) )
	{
		printt( "ClientCommand_ReplacementTitan", player, player.entindex(), "failed", "IsAlive( player ) was false" )
		return true
	}

	if ( player in file.warpFallDebounce )
	{
		if ( Time() - file.warpFallDebounce[ player ] < 3.0 )
		{
			printt( "ClientCommand_ReplacementTitan", player, player.entindex(), "failed", "player in file.warpFallDebounce was true" )
			return
		}
	}

	local spawnPoint = GetTitanReplacementPoint( player, false )
	local origin = spawnPoint.origin
	Assert( origin )

	// TitanBuild Progress Reset
	TitanDeployed( player )

	thread DropReplacementTitan( player, spawnPoint )

	SetUpNPCTitanCurrentMode( player, eNPCTitanMode.WAIT )
	return true
}

function DropReplacementTitan( player, spawnPoint )
{
	Assert( IsValid( player ) )

	if ( player.isSpawning )
	{
		printt( "DropReplacementTitan", player, player.entindex(), "failed", "player.isSpawning was true" )
		return
	}

	if ( player.s.replacementDropInProgress )
	{
		printt( "DropReplacementTitan", player, player.entindex(), "failed", "player.s.replacementDropInProgress was true" )
		return
	}

	player.s.replacementDropInProgress = true
	OnThreadEnd(
		function() : ( player )
		{
			if ( !IsValid( player ) )
				return

			player.s.replacementDropInProgress = false
			player.ClearHotDropImpactTime()
		}
	)

	player.EndSignal( "Disconnected" )

	//tell player one is en route
	if ( player.titansBuilt )
		PlayConversationToPlayer( "TitanReplacement", player )
	else
		PlayConversationToPlayer( "FirstTitanInbound", player )

	local origin = spawnPoint.origin
	local angles
	if ( spawnPoint.angles )
		angles = spawnPoint.angles
	else
		angles = VectorToAngles( FlattenVector( player.GetViewVector() ) * -1 )	// face the player

	printt( "Dropping replacement titan at " + origin + " with angles " + angles )

	if ( !level.firstTitanfall )
	{
		AddPlayerScore( player, "FirstTitanfall" )
		level.firstTitanfall = true
	}
	else
	{
		AddPlayerScore( player, "Titanfall" )
	}


	player.Signal( "CalledInReplacementTitan" )

	local otherTeam = GetTeamIndex(GetOtherTeams(1 << player.GetTeam()))
	TryAnnounceTitanfallWarningToTeam( origin, otherTeam )

	local titan
	local animation
	if ( PlayerHasPassive( player, PAS_TURBO_DROP ) )
	{
		file.warpFallDebounce[ player ] <- Time()
		animation = "at_hotdrop_drop_2knee_turbo_upgraded"
		local settings = GetTitanForPlayer( player )
		local model = GetPlayerSettingsFieldForClassName( settings, "bodymodel" )
		local warpAttach = GetAttachmentAtTimeFromModel( model, animation, "offset", origin, angles, 0 )

		local fakeTitan = CreatePropDynamic( model )
		local impactTime = GetHotDropImpactTime( fakeTitan, animation )
		fakeTitan.Kill()

		local impactStartTime = Time()
		impactTime += 2.4

		player.HotDropImpactDelay( impactTime )
		Remote.CallFunction_Replay( player, "ServerCallback_ReplacementTitanSpawnpoint", origin.x, origin.y, origin.z, Time() + impactTime )

//		if (GAMETYPE != "tutorial" && GAMETYPE != "titan_tutorial")
//			SetPlayerActiveObjective( player, "Titan_Status_Drop", Time() + impactTime + 1.0 )

		EmitDifferentSoundsAtPositionForPlayerAndWorld( "Titan_1P_Warpfall_CallIn", "Titan_3P_Warpfall_CallIn", origin, player )

		wait 1.5

		//	"Titan_1P_Warpfall_Start" 			- for first person warp calls, starting right on the button press
		//	"Titan_3P_Warpfall_Start"  			- for any 3P other player or NPC when they call in a warp, starting right on their button press
		EmitSoundAtPositionOnlyToPlayer( origin, player, "Titan_1P_Warpfall_Start" )
		EmitSoundAtPositionExceptToPlayer( origin, player, "Titan_3P_Warpfall_Start" )

		PlayFX( TURBO_WARP_FX, warpAttach.position + Vector(0,0,-104), warpAttach.angle )

		wait 0.9

		titan = CreateNPCTitanForPlayer( player, origin, angles )
		thread PlayFXOnEntity( TURBO_WARP_COMPANY, titan, "offset" )
	}
	else
	{
		animation = "at_hotdrop_drop_2knee_turbo"

		titan = CreateNPCTitanForPlayer( player, origin, angles )

		local impactTime = GetHotDropImpactTime( titan, animation )
		player.HotDropImpactDelay( impactTime )
		Remote.CallFunction_Replay( player, "ServerCallback_ReplacementTitanSpawnpoint", origin.x, origin.y, origin.z, Time() + impactTime )

//		if (GAMETYPE != "tutorial" && GAMETYPE != "titan_tutorial")
//			SetPlayerActiveObjective( player, "Titan_Status_Drop", Time() + impactTime + 1.0 )
	}

	if ( player in file.warpFallDebounce )
		delete file.warpFallDebounce[ player ]

	titan.EndSignal( "OnDeath" )
	Assert( IsAlive( titan ) )

	thread ReplacementTitanMinimapThink( player, titan, origin )

	waitthread SuperHotDropReplacementTitan( titan, origin, angles, player, animation )

	player.Signal( "titan_impact" )

	player.OnSpawnTitan()

	thread TitanNPC_PostHotDrop_Think( titan )
}

function TryAnnounceTitanfallWarningToTeam( origin, team )
{
	local innerDistance = TITANFALL_OUTER_RADIUS * TITANFALL_OUTER_RADIUS
	local outerDistance = innerDistance * 4

	local teamPlayers = GetPlayerArrayOfTeam( team )
	foreach ( teamPlayer in teamPlayers )
	{
		local distSqr = DistanceSqr( origin, teamPlayer.GetOrigin() )

		if ( distSqr > outerDistance )
			continue

		if ( distSqr < innerDistance )
			Remote.CallFunction_NonReplay( teamPlayer, "ServerCallback_TitanFallWarning", true )
		else
			Remote.CallFunction_NonReplay( teamPlayer, "ServerCallback_TitanFallWarning", false )
	}
}
Globalize( TryAnnounceTitanfallWarningToTeam )


function ForceReplacementTitan( player, spawnPoint )
{
	Assert( IsValid( player ) )

	OnThreadEnd(
		function() : ( player )
		{
			if ( !IsValid( player ) )
				return

			player.ClearHotDropImpactTime()
		}
	)

	player.EndSignal( "Disconnected" )

	local origin = spawnPoint.origin
	local angles
	if ( spawnPoint.angles )
		angles = spawnPoint.angles
	else
		angles = VectorToAngles( FlattenVector( player.GetViewVector() ) * -1 )	// face the player

	printt( "Dropping replacement titan at " + origin + " with angles " + angles )

	local otherTeam = GetTeamIndex(GetOtherTeams(1 << player.GetTeam()))
	TryAnnounceTitanfallWarningToTeam( origin, otherTeam )

	local titan
	local animation
	if ( PlayerHasPassive( player, PAS_TURBO_DROP ) )
	{
		file.warpFallDebounce[ player ] <- Time()
		animation = "at_hotdrop_drop_2knee_turbo_upgraded"
		local settings = GetTitanForPlayer( player )
		local model = GetPlayerSettingsFieldForClassName( settings, "bodymodel" )
		local warpAttach = GetAttachmentAtTimeFromModel( model, animation, "offset", origin, angles, 0 )

		local fakeTitan = CreatePropDynamic( model )
		local impactTime = GetHotDropImpactTime( fakeTitan, animation )
		fakeTitan.Kill()

		local impactStartTime = Time()
		impactTime += 2.4

		player.HotDropImpactDelay( impactTime )
		Remote.CallFunction_Replay( player, "ServerCallback_ReplacementTitanSpawnpoint", origin.x, origin.y, origin.z, Time() + impactTime )

//		if (GAMETYPE != "tutorial" && GAMETYPE != "titan_tutorial")
//			SetPlayerActiveObjective( player, "Titan_Status_Drop", Time() + impactTime + 1.0 )

		EmitDifferentSoundsAtPositionForPlayerAndWorld( "Titan_1P_Warpfall_CallIn", "Titan_3P_Warpfall_CallIn", origin, player )

		wait 1.5

		//	"Titan_1P_Warpfall_Start" 			- for first person warp calls, starting right on the button press
		//	"Titan_3P_Warpfall_Start"  			- for any 3P other player or NPC when they call in a warp, starting right on their button press
		EmitSoundAtPositionOnlyToPlayer( origin, player, "Titan_1P_Warpfall_Start" )
		EmitSoundAtPositionExceptToPlayer( origin, player, "Titan_3P_Warpfall_Start" )

		PlayFX( TURBO_WARP_FX, warpAttach.position + Vector(0,0,-104), warpAttach.angle )

		wait 0.9

		titan = CreateNPCTitanForPlayer( player, origin, angles )
		thread PlayFXOnEntity( TURBO_WARP_COMPANY, titan, "offset" )
	}
	else
	{
		animation = "at_hotdrop_drop_2knee_turbo"

		titan = CreateNPCTitanForPlayer( player, origin, angles )

		local impactTime = GetHotDropImpactTime( titan, animation )
		player.HotDropImpactDelay( impactTime )
		Remote.CallFunction_Replay( player, "ServerCallback_ReplacementTitanSpawnpoint", origin.x, origin.y, origin.z, Time() + impactTime )

//		if (GAMETYPE != "tutorial" && GAMETYPE != "titan_tutorial")
//			SetPlayerActiveObjective( player, "Titan_Status_Drop", Time() + impactTime + 1.0 )
	}

	if ( player in file.warpFallDebounce )
		delete file.warpFallDebounce[ player ]

	titan.EndSignal( "OnDeath" )
	Assert( IsAlive( titan ) )

	thread ReplacementTitanMinimapThink( player, titan, origin )

	waitthread SuperHotDropReplacementTitan( titan, origin, angles, player, animation )

	player.Signal( "titan_impact" )

	player.OnSpawnTitan()

	thread TitanNPC_PostHotDrop_Think( titan )
}


function GetTitanForPlayer( player )
{
	local titanDataTable = GetPlayerClassDataTable( player, "titan" )
	return titanDataTable.playerSetFile
}
Globalize( GetTitanForPlayer )

function GetAttachmentAtTimeFromModel( model, animation, attachment, origin, angles, time )
{
	printt("KILL " + model + " " + animation + " " + attachment + " " + origin + " " + angles + " " + time)
	local dummy = CreatePropDynamic( model, origin, angles )
	local start = dummy.Anim_GetAttachmentAtTime( animation, attachment, time )
	dummy.Destroy()
	return start
}


function ReplacementTitanMinimapThink( player, titan, impactOrigin )
{
	player.EndSignal( "titan_impact" )
	player.EndSignal( "Disconnected" )
	titan.EndSignal( "OnDeath" )

	titan.Minimap_Hide( TEAM_IMC, null )
	titan.Minimap_Hide( TEAM_MILITIA, null )

	OnThreadEnd(
		function() : ( player, titan )
		{
			if ( !IsAlive( titan ) )
				return

			titan.Minimap_DisplayDefault( TEAM_IMC, null )
			titan.Minimap_DisplayDefault( TEAM_MILITIA, null )
		}
	)

	while ( true )
	{
		Minimap_CreatePingForPlayer( player, impactOrigin, "vgui/HUD/threathud_titan_friendlyself", 0.5 )
		wait 0.4
	}
}

function EmptyTitanPlaysAnim( titan )
{
	local idleAnimAlias = "at_atlas_getin_idle"
	if ( titan.HasKey( "idleAnim" ) )
		idleAnimAlias = titan.GetValueForKey( "idleAnim" )

	thread PlayAnim( titan, idleAnimAlias )
}

function FreeSpawnpointOnEnterTitan( spawnpoint, titan )
{
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "TitanEntered" )

	OnThreadEnd(
		function() : ( spawnpoint, titan )
		{
			Assert( IsValid( titan ) )
			spawnpoint.s.inUse = false
		}
	)

	titan.WaitSignal( "TitanBeingEntered" )
}


function DebugText( origin, text, time )
{
	local endTime = Time() + time

	while( Time() < endTime )
	{
		DebugDrawText( origin, text, true, 1 )
		wait 1
	}
}


function DropTitanHealthPod( player )
{
//	local playerEyePos = Vector(-382.369293, 1003.443848, 988.031250)
//	local playerEyeAngles = Vector(7.014771, -166.827393, 0.000000)

	local playerEyePos = player.EyePosition()
	local playerEyeAngles = player.EyeAngles()

	printt( "Requested titan health pod from eye pos " + playerEyePos + " view angles " + playerEyeAngles )
	local playerView = playerEyeAngles.AnglesToForward()

	// use the analysis to find a position
	local analysis = GetAnalysisForModel( DROPPOD_MODEL, DROPPOD_DROP_ANIM )

	local drop = CreateCallinTable()
	drop.style = eDropStyle.HOTDROP // NEAREST_YAW_FALLBACK
	drop.ownerEyePos = playerEyePos
	drop.dist = 800
	drop.origin = playerEyePos + playerView * 250
	drop.yaw = playerEyeAngles.y

 	local spawnPoint = GetSpawnPointForStyle( analysis, drop )
	if ( spawnPoint )
	{
		Assert( spawnPoint.origin )
		DrawArrow( spawnPoint.origin, spawnPoint.angles, 15, 250 )
	}
}

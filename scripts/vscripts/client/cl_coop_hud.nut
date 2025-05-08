const MAX_LOADOUT_CRATE_COUNT = 3
const MAX_EOG_STARS	= 3
const HEALTH_BLINK_TIME 	= 1.5
const COLOR_RED 	= "255 0 0"
const COLOR_WHITE 	= "255 255 255"

enum eBlinkState {
	shield
	health
}
function main()
{
	if ( IsLobby() )
		return

	RegisterServerVarChangeCallback( "objMax", 					TDHudCallback_Update )
	RegisterServerVarChangeCallback( "objCount", 				TDHudCallback_Update )
	RegisterServerVarChangeCallback( "missionTypeID", 			TDHudCallback_Update )
	RegisterServerVarChangeCallback( "objStartTime", 			TDHudCallback_Update )
	RegisterServerVarChangeCallback( "objEndTime", 				TDHudCallback_Update )
	RegisterServerVarChangeCallback( "TDGeneratorHealth", 		TDHudCallback_UpdateGeneratorHealth )
	RegisterServerVarChangeCallback( "TDGeneratorShieldHealth", TDHudCallback_UpdateGeneratorHealth )
	RegisterServerVarChangeCallback( "TDCurrentTeamScore", 		TDHudCallback_UpdateTeamScore )
	RegisterServerVarChangeCallback( "TDStoredTeamScore", 		TDHudCallback_UpdateTeamScore )
	RegisterServerVarChangeCallback( "TDNumWaves", 				TDHudCallback_UpdateWaveInfo )
	RegisterServerVarChangeCallback( "TDCurrWave", 				TDHudCallback_UpdateWaveInfo )
	RegisterServerVarChangeCallback( "TDWaveStartTime", 		TDHudCallback_UpdateWaveInfo )
	RegisterServerVarChangeCallback( "TDWaveTimer", 			TDHudCallback_UpdateWaveInfo )
	RegisterServerVarChangeCallback( "TD_numTitans", 			TDHudCallback_UpdateWaveInfo )
	RegisterServerVarChangeCallback( "TD_numNukeTitans", 		TDHudCallback_UpdateWaveInfo )
	RegisterServerVarChangeCallback( "TD_numMortarTitans", 		TDHudCallback_UpdateWaveInfo )
	RegisterServerVarChangeCallback( "TD_numEMPTitans", 		TDHudCallback_UpdateWaveInfo )
	RegisterServerVarChangeCallback( "TD_numGrunts", 			TDHudCallback_UpdateWaveInfo )
	RegisterServerVarChangeCallback( "TD_numSpectres", 			TDHudCallback_UpdateWaveInfo )
	RegisterServerVarChangeCallback( "TD_numSuicides", 			TDHudCallback_UpdateWaveInfo )
	RegisterServerVarChangeCallback( "TD_numSnipers", 			TDHudCallback_UpdateWaveInfo )
	RegisterServerVarChangeCallback( "TD_numCloakedDrone", 		TDHudCallback_UpdateWaveInfo )
	RegisterServerVarChangeCallback( "TD_numTotal", 			TDHudCallback_UpdateWaveInfo )
	RegisterServerVarChangeCallback( "coopRestartsAllowed", 	TDHudCallback_WaveReset )
	RegisterServerVarChangeCallback( "coopPlayersRodeoing", 	TDHudCallback_UpdatePlayerOverHeadIconOnRodeo )
	RegisterServerVarChangeCallback( "gameEndTime", 			TDHudCallback_Update )

	//markers
	AddMarkerChangeCallback( MARKER_TOWERDEFENSEGENERATOR, MarkerCallback_TD_Generator )
	for( local i = 0; i < MAX_LOADOUT_CRATE_COUNT; i++ )
		AddMarkerChangeCallback( "LoadoutCrateMarker" + i, MarkerCallback_TD_LoadoutCrate )

	RegisterSignal( "UpdatingCoopHud" )
	RegisterSignal( "UpdatingGeneratorHealth" )
	RegisterSignal( "UpdatingWaveInfo" )

	AddCallback_OnPlayerLifeStateChanged( Bind( CallbackUpdatePlayerOverHeadIcon ) )
	AddCallback_OnPlayerLifeStateChanged( CallbackUpdatePlayerStatusCounts )
	AddCallback_OnPlayerDisconnected( Bind( CallbackUpdatePlayerOverHeadIconOnDisconnect ) )
	AddCreateCallback( "npc_titan", TDHudCallback_TitanSpawned )
	AddOnDeathOrDestroyCallback( "npc_titan", TDHudCallback_TitanDestroyed )
	AddCreateCallback( "npc_turret_sentry", TDHudCallback_SentryTurretSpawned )
	AddOnDeathOrDestroyCallback( "npc_turret_sentry", TDHudCallback_SentryTurretDestroyed )

	AddCreateMainHudCallback( TD_MainHud )
	AddCreatePilotCockpitCallback( TD_Cockpit )
	AddCreateTitanCockpitCallback( TD_Cockpit )
	AddOnModelChangedCallback( OnPlayerLoadoutChanged )

	level.td_genlastHealth <- TD_GENERATOR_HEALTH
	level.td_genlastShield <- TD_GENERATOR_SHIELD_HEALTH
	level.indexedFaceIcons <- [ null, null, null, null,null,null,null ]
	level.petSentryTurrets <- 0
	level.lastWaveIdx 	   <- null

	level.healthIsBlinking <- 0
	file.starRequirements  <- GetStarScoreRequirements( COOPERATIVE, GetMapName() )
	file.currentStarEarned <- 0

	TimerInit( "Nag_TurretKilledTitan", 8.0 )
	TimerInit( "Nag_TurretKillstreak", 45.0 )
}

function EntitiesDidLoad()
{
	if ( IsLobby() )
		return

	local player 	= GetLocalClientPlayer()
	CallbackUpdatePlayerOverHeadIcon( player, player.GetLifeState(), player.GetLifeState() )
}

function TDHudCallback_Update()
{
	local player = GetLocalViewPlayer()
	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	UpdateCoopHud( cockpit, player )
}

function TDHudCallback_UpdateGeneratorHealth()
{
	local player = GetLocalViewPlayer()
	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return
	local vgui = cockpit.GetMainVGUI()
	if ( !IsValid( vgui ) )
		return

	UpdateGeneratorHealth( vgui, player )
}

function TDHudCallback_UpdateWaveInfo()
{
	local player = GetLocalViewPlayer()
	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return
	local vgui = cockpit.GetMainVGUI()
	if ( !IsValid( vgui ) )
		return

	UpdateWaveInfo( vgui, player )
}

function TDHudCallback_UpdateTeamScore()
{
	local clientPlayer = GetLocalClientPlayer()
	if ( IsCvHudValid( clientPlayer ) )
		UpdateTeamScore( clientPlayer.cv.clientHud.s.mainVGUI, clientPlayer )//update the killcam main hud

	local player = GetLocalViewPlayer()
	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return
	local vgui = cockpit.GetMainVGUI()
	if ( !IsValid( vgui ) )
		return

	local currentScore = level.nv.TDCurrentTeamScore + level.nv.TDStoredTeamScore

	if ( file.currentStarEarned < 3 && currentScore >= file.starRequirements[ file.currentStarEarned ] )
	{
		ServerCallback_DisplayCoopNotification( eCoopTeamScoreEvents.star_reward )
		SetFullScoreboardStar( file.currentStarEarned )
		file.currentStarEarned++
	}

	UpdateTeamScore( vgui, player )
}

function TDHudCallback_WaveReset()
{
	ResetCurrentStarState()
}

function ResetCurrentStarState()
{
	file.currentStarEarned = 0
	for( local i = 0; i < 3; i++ )
	{
		if ( level.nv.TDCurrentTeamScore < file.starRequirements[ i ] )
		{
			SetEmptyScoreboardStar( i )
		}
		else
		{
			file.currentStarEarned = i + 1
			SetFullScoreboardStar( i )
		}
	}
}
Globalize( ResetCurrentStarState )

function TDHudCallback_TitanSpawned( titan, isRecreate )
{
	SetCoopTitanIcon( titan )
	AddAnimEvent( titan, "cl_event_hideoverheadicon", ClearWorldIcon, "TowerDefenseTitan" )
	AddAnimEvent( titan, "cl_event_showoverheadicon", SetCoopTitanIcon )
}

function TDHudCallback_TitanDestroyed( titan )
{
	ClearWorldIcon( titan, "TowerDefenseTitan" )
}

function TDHudCallback_SentryTurretSpawned( turret, isRecreate )
{
	SetSentryTurretIcon( turret )

	thread DelayedTurretHudUpdate()
}

function TDHudCallback_SentryTurretDestroyed( turret )
{
	ClearWorldIcon( turret, "CoopPlayerTurret" )

	thread DelayedTurretHudUpdate()
}

//need a delay because this turret is still alive this frame
function DelayedTurretHudUpdate()
{
	wait 0.1

	if ( IsWatchingKillReplay() )
		return

	local player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	UpdateEquipmentHud( cockpit, player )
}

function CallbackUpdatePlayerStatusCounts( player, oldLifeState, newLifeState )
{
	thread UpdatePlayerStatusCountsOnWaveSpawnFinished( player, oldLifeState, newLifeState )
}

function UpdatePlayerStatusCountsOnWaveSpawnFinished( player, oldLifeState, newLifeState )
{
	if ( newLifeState != LIFE_ALIVE )
		return

	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	wait 0.5

	while( player.GetParent() && player.GetParent().GetClassname() == "npc_dropship" )
		wait 1.0

	UpdatePlayerStatusCounts()
}

/************************************************************************************************\

##     ## ##     ## ########        ##     ## ########  ########     ###    ######## ########
##     ## ##     ## ##     ##       ##     ## ##     ## ##     ##   ## ##      ##    ##
##     ## ##     ## ##     ##       ##     ## ##     ## ##     ##  ##   ##     ##    ##
######### ##     ## ##     ##       ##     ## ########  ##     ## ##     ##    ##    ######
##     ## ##     ## ##     ##       ##     ## ##        ##     ## #########    ##    ##
##     ## ##     ## ##     ##       ##     ## ##        ##     ## ##     ##    ##    ##
##     ##  #######  ########         #######  ##        ########  ##     ##    ##    ########

\************************************************************************************************/
function UpdateCoopHud( cockpit, player )
{
	player.Signal( "UpdatingCoopHud" )

	local vgui = cockpit.GetMainVGUI()

	UpdateWaveInfo( vgui, player  )
	UpdateGeneratorHealth( vgui, player )
	UpdateTeamScore( vgui, player )
	if ( IsCvHudValid( player ) )
		UpdateTeamScore( player.cv.clientHud.s.mainVGUI, player )//update the killcam main hud
}

function UpdateTeamScore( vgui, player )
{
	local storedTeamScore = level.nv.TDStoredTeamScore
	local maxTeamScore = level.nv.TDMaxTeamScore
	local currentTeamScore = level.nv.TDCurrentTeamScore

	local ratio = ( currentTeamScore - storedTeamScore ) / maxTeamScore
	local storedRatio = ( storedTeamScore + currentTeamScore ) / maxTeamScore
	vgui.s.scoreboardProgressBars.ScoreBarCoop.SetBarProgress( ratio )
	vgui.s.scoreboardProgressBars.StoredScoreBarCoop.SetBarProgress( storedRatio )
	vgui.s.scoreboardProgressBars.ScoreCountCoop.SetText( currentTeamScore.tostring() )

	//display the correct time
	if ( level.nv.gameEndTime != null )
	{
		if ( vgui.s.scoreboardProgressBars.GameInfo_Label.IsAutoText() )
 	 		vgui.s.scoreboardProgressBars.GameInfo_Label.DisableAutoText()
	}
	else if ( level.nv.coopStartTime != null )
	{
		vgui.s.scoreboardProgressBars.GameInfo_Label.SetAutoText( "", HATT_UPTIME, level.nv.coopStartTime )
		vgui.s.scoreboardProgressBars.GameInfo_Label.Show()
	}
	else
	{
		vgui.s.scoreboardProgressBars.GameInfo_Label.Hide()
	}
}

function UpdateWaveInfo( vgui, player )
{
	player.Signal( "UpdatingWaveInfo" )

	local waveDescription 	= vgui.s.coopInfo.waveDescription
	local totalWaves 		= level.nv.TDNumWaves
	local currWave 			= level.nv.TDCurrWave
	local waveTimer 		= level.nv.TDWaveTimer

	local time = Time()
	local elapsedTime 		= Time() - level.nv.TDWaveStartTime
	local timeRemaining 	= waveTimer - elapsedTime
	local waveTimeRatio 	= timeRemaining / waveTimer
	local totalEnemyNum 	= GetTotalEnemyNum()

	local landingTime = 8
	local timeSinceWave = elapsedTime - waveTimer

	//vgui.s.waveIconGroup.Hide()
	if ( currWave == null || GetGameState() != eGameState.Playing )
	{
		vgui.s.coopInfoGroup.Hide()
	}
	else
	{
		level.lastWaveIdx = currWave

		//UpdateWaveEnemyIcons( vgui, player )
		vgui.s.coopInfoGroup.Show()

		if ( level.nv.TDGeneratorHealth <= 0 )
		{
			waveDescription.text.SetText( "#COOP_WAVE_DESC_FAILED", currWave, totalWaves )
		}
		else if ( waveTimeRatio >= 0 )
		{
			waveDescription.text.SetText( "#COOP_WAVE_DESC_INBOUND", currWave, totalWaves )
			local endTime = Time() + timeRemaining
			thread DelayedUpdateWaveInfo( vgui, player, ( timeRemaining + 0.1 ) )
		}
		else if ( !totalEnemyNum )
		{
			waveDescription.text.SetText( "#COOP_WAVE_DESC_DEFEATED", currWave, totalWaves )
		}
		else
		{
			waveDescription.text.SetText( "#COOP_WAVE_DESC_INPROGRESS", currWave, totalWaves )
		}

		waveDescription.enemyCount.SetText( "#COOP_WAVE_DESC_COUNT", totalEnemyNum )

	}
}

function DelayedUpdateWaveInfo( vgui, player, time )
{
	player.EndSignal( "UpdatingCoopHud" )
	player.EndSignal( "UpdatingGeneratorHealth" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	vgui.EndSignal( "OnDestroy" )

	wait time
	UpdateWaveInfo( vgui, player )
}

function UpdateWaveEnemyIcons( vgui, player )
{
	local TD_numTitans 			= level.nv.TD_numTitans
	local TD_numNukeTitans 		= level.nv.TD_numNukeTitans
	local TD_numMortarTitans	= level.nv.TD_numMortarTitans
	local TD_numEMPTitans 		= level.nv.TD_numEMPTitans
	local TD_numSuicides 		= level.nv.TD_numSuicides
	local TD_numSnipers 		= level.nv.TD_numSnipers
	local TD_numSpectres 		= level.nv.TD_numSpectres
	local TD_numGrunts 			= level.nv.TD_numGrunts
	local TD_numCloakedDrone 	= level.nv.TD_numCloakedDrone

	local waveIcons = vgui.s.waveIcons

	//the order here desides the display order and priority
	local iconIndex = 0
	if ( TD_numEMPTitans > 0 && iconIndex < waveIcons.len() )
	{
		SetWaveIcon( waveIcons, iconIndex, SCOREBOARD_MATERIAL_COOP_EMP_TITAN, TD_numEMPTitans )
		iconIndex++
	}
	if ( TD_numNukeTitans > 0 && iconIndex < waveIcons.len() )
	{
		SetWaveIcon( waveIcons, iconIndex, SCOREBOARD_MATERIAL_COOP_NUKE_TITAN, TD_numNukeTitans )
		iconIndex++
	}
	if ( TD_numMortarTitans > 0 && iconIndex < waveIcons.len() )
	{
		SetWaveIcon( waveIcons, iconIndex, SCOREBOARD_MATERIAL_COOP_MORTAR_TITAN, TD_numMortarTitans )
		iconIndex++
	}
	if ( TD_numTitans > 0 && iconIndex < waveIcons.len() )
	{
		SetWaveIcon( waveIcons, iconIndex, SCOREBOARD_MATERIAL_COOP_TITAN, TD_numTitans )
		iconIndex++
	}
	if ( TD_numCloakedDrone > 0 && iconIndex < waveIcons.len() )
	{
		SetWaveIcon( waveIcons, iconIndex, SCOREBOARD_MATERIAL_COOP_CLOAK_DRONE, TD_numCloakedDrone )
		iconIndex++
	}
	if ( TD_numSuicides > 0 && iconIndex < waveIcons.len() )
	{
		SetWaveIcon( waveIcons, iconIndex, SCOREBOARD_MATERIAL_COOP_SUICIDE_SPECTRE, TD_numSuicides )
		iconIndex++
	}
	if ( TD_numSnipers > 0 && iconIndex < waveIcons.len() )
	{
		SetWaveIcon( waveIcons, iconIndex, SCOREBOARD_MATERIAL_COOP_SNIPER_SPECTRE, TD_numSnipers )
		iconIndex++
	}
	if ( TD_numSpectres > 0 && iconIndex < waveIcons.len() )
	{
		SetWaveIcon( waveIcons, iconIndex, SCOREBOARD_MATERIAL_COOP_SPECTRE, TD_numSpectres )
		iconIndex++
	}
	if ( TD_numGrunts > 0 && iconIndex < waveIcons.len() )
	{
		SetWaveIcon( waveIcons, iconIndex, SCOREBOARD_MATERIAL_COOP_GRUNT, TD_numGrunts )
		iconIndex++
	}

	local offsetIndex = waveIcons.len() - iconIndex
	waveIcons[ 0 ].icon.ReturnToBasePos()
	local pos = waveIcons[ 0 ].icon.GetBasePos()
	waveIcons[ 0 ].icon.SetPos( pos[ 0 ] - ( offsetIndex * 19 ), pos[ 1 ] )
}

function SetWaveIcon( waveIcons, index, image, num )
{
	//just early out
	if ( index >= waveIcons.len() )
		return

	waveIcons[ index ].icon.SetImage( image )
	waveIcons[ index ].icon.Show()
	waveIcons[ index ].text.SetText( "x " + num )
	waveIcons[ index ].text.Show()
}

function UpdateGeneratorHealth( vgui, player )
{
	player.Signal( "UpdatingGeneratorHealth" )

	local health 			= level.nv.TDGeneratorHealth
	local shieldHealth 		= level.nv.TDGeneratorShieldHealth

	if ( health == null )
		return
	if ( shieldHealth == null )
		return

	local color_Full 	= level.generatorColor_Full
	local color_Med 	= level.generatorColor_Med
	local color_Low 	= level.generatorColor_Low

	local GeneratorHealthBar	= vgui.s.coopInfo.GeneratorHealthBar
	local GeneratorShieldBar	= vgui.s.coopInfo.GeneratorShieldBar
	local GeneratorHealthDesc 	= vgui.s.coopInfo.GeneratorHealthDesc
//	local damageGlow 			= vgui.s.coopInfo.GeneratorHealthBarDamageGlow
//	damageGlow.Hide()

	local totalHealth 		= TD_GENERATOR_HEALTH
	local healthRatio 		= health.tofloat() / totalHealth.tofloat()
	local shieldMaxHealth 	= TD_GENERATOR_SHIELD_HEALTH
	local shieldRatio 		= shieldHealth / shieldMaxHealth.tofloat()

	if ( healthRatio > 0.0  )
		healthRatio = max( 0.056, healthRatio ) //to always show a sliver of health

	//printt( "health:", health, "shieldHealth:", shieldHealth )
	//printt( "ratios:", shieldRatio, healthRatio )

	local damaged = false
	if ( level.td_genlastHealth > health )
		damaged = true

	local shieldDamage = false
	local shieldRecharging = false

	if ( level.td_genlastShield > shieldHealth )
		shieldDamage = true
	else if ( shieldHealth > level.td_genlastShield )
		shieldRecharging = true

	level.td_genlastHealth = health
	level.td_genlastShield = shieldHealth

	local waitingToRegen = false

	// Full shields, maybe not full health
	if ( shieldRatio == 1.0 )
	{
		GeneratorHealthDesc.Show()
		GeneratorShieldBar.Show()
		GeneratorShieldBar.SetBarProgress( shieldRatio )
		GeneratorHealthBar.Show()
		GeneratorHealthBar.SetBarProgress( healthRatio )

		local text = "#COOP_GENERATOR_HEALTH_FULL"
		if ( healthRatio < 1.0 )
		{
			if ( healthRatio >= 0.8 )
				text = "#COOP_GENERATOR_HEALTH_OK"
			else if ( healthRatio >= 0.4 )
				text = "#COOP_GENERATOR_HEALTH_DAMAGED"
			else
				text = "#COOP_GENERATOR_HEALTH_LOW"
		}

		GeneratorHealthDesc.SetText( text )
		SetGeneratorHealthGroupColors( [ GeneratorHealthDesc, GeneratorShieldBar ], color_Full )

		// if perfect health, health bar and status text should match color
		if ( healthRatio == 1.0 )
			GeneratorHealthBar.SetColor( color_Full.r, color_Full.g, color_Full.b, 255 )
	}
	// Shields failing/recharging
	else if ( shieldHealth > 0 )
	{
		GeneratorHealthDesc.Show()
		GeneratorShieldBar.Show()
		GeneratorShieldBar.SetBarProgress( shieldRatio )
		GeneratorHealthBar.Show()
		GeneratorHealthBar.SetBarProgress( healthRatio )

		// "Harvester Shield: Recovering..."
		local text = "#COOP_GENERATOR_SHIELD_WAITING_TO_REGEN"
		waitingToRegen = true

		if ( shieldDamage )
		{
			SetHealthIsBlinking()

			if ( shieldRatio >= 0.65 )
				text = "#COOP_GENERATOR_SHIELD_DROPPING"
			else if ( shieldRatio >= 0.35 )
				text = "#COOP_GENERATOR_SHIELD_DAMAGED"
			else
				text = "#COOP_GENERATOR_SHIELD_LOW"
		}
		else if ( shieldRecharging )
		{
			text = "#COOP_GENERATOR_SHIELD_RECHARGING"
			ClearHealthIsBlinking()
		}

		GeneratorHealthDesc.SetText( text )

		// blend colors as shield goes down
		if ( IsHealthBlinking() )
		{
			thread BlinkGeneratorHealthRed( vgui, player, eBlinkState.shield )
		}
		else
		{
			local colors = Generator_GetShieldStatusColorTable()
			SetGeneratorHealthGroupColors( [ GeneratorHealthDesc, GeneratorShieldBar ], colors )
			local colors = Generator_GetHealthStatusColorTable()
			SetGeneratorHealthGroupColors( [ GeneratorHealthBar ], colors )
		}
	}
	// No shields left, only health remaining
	else if ( shieldHealth <= 0 && health > 0 )
	{
		GeneratorHealthDesc.Show()
		GeneratorShieldBar.Hide()
		GeneratorHealthBar.Show()
		GeneratorHealthBar.SetBarProgress( healthRatio )

		// "Harvester Shield: Recovering..."
		local text = "#COOP_GENERATOR_SHIELD_WAITING_TO_REGEN"
		waitingToRegen = true

		if ( damaged )
		{
			SetHealthIsBlinking()

			if ( healthRatio >= 0.65 )
				text = "#COOP_HARVESTER_LOSING_HEALTH"
			else if ( healthRatio >= 0.3 )
				text = "#COOP_HARVESTER_HEALTH_CRITICAL"
			else
				text = "#COOP_HARVESTER_DEATH_IMMINENT"
		}

		GeneratorHealthDesc.SetText( text )

		// blend colors as health goes down
		if ( IsHealthBlinking() )
		{
			thread BlinkGeneratorHealthRed( vgui, player, eBlinkState.health )
		}
		else
		{
			local colors = Generator_GetHealthStatusColorTable()
			SetGeneratorHealthGroupColors( [ GeneratorHealthDesc, GeneratorHealthBar ], colors )
		}
	}
	// nothing left
	else if ( shieldHealth <= 0 && health <= 0 )
	{
		GeneratorShieldBar.SetBarProgress( shieldRatio )
		GeneratorHealthBar.SetBarProgress( healthRatio )

		GeneratorHealthDesc.SetText( "#COOP_GENERATOR_DESTROYED" )

		SetGeneratorHealthGroupColors( [ GeneratorHealthDesc, GeneratorHealthBar ], color_Low )
		ClearHealthIsBlinking()
	}

	if ( shieldDamage || damaged || waitingToRegen || IsHealthBlinking() )
		thread DelayedUpdateGeneratorHealth( vgui, player )
}

function DelayedUpdateGeneratorHealth( vgui, player )
{
	player.EndSignal( "UpdatingCoopHud" )
	player.EndSignal( "UpdatingGeneratorHealth" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	vgui.EndSignal( "OnDestroy" )

	wait 1.0
	thread UpdateGeneratorHealth( vgui, player )
}

function BlinkGeneratorHealthRed( vgui, player, blinkState )
{
	player.EndSignal( "UpdatingGeneratorHealth" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	vgui.EndSignal( "OnDestroy" )

	local GeneratorHealthBar	= vgui.s.coopInfo.GeneratorHealthBar
	local GeneratorShieldBar	= vgui.s.coopInfo.GeneratorShieldBar
	local GeneratorHealthDesc 	= vgui.s.coopInfo.GeneratorHealthDesc
//	local damageGlow 			= vgui.s.coopInfo.GeneratorHealthBarDamageGlow

	local elems, colors

	while( IsHealthBlinking() )
	{
		switch ( blinkState )
		{
			case eBlinkState.shield:
				elems = [ GeneratorHealthDesc, GeneratorShieldBar ]
				colors = ShouldBlinkRed() ? StringToColors( COLOR_RED ) : Generator_GetShieldStatusColorTable()
				break

			case eBlinkState.health:
				elems = [ GeneratorHealthDesc, GeneratorHealthBar ]
				colors = ShouldBlinkRed() ? Generator_GetDamageColorTable() : Generator_GetHealthStatusColorTable()
				break

			default:
				break
		}

		SetGeneratorHealthGroupColors( elems, colors )
	/*	if ( ShouldBlinkRed() )
			damageGlow.Show()
		else
			damageGlow.Hide()*/

		wait 0.2
	}

	thread UpdateGeneratorHealth( vgui, player )
}

function Generator_GetDamageColorTable()
{
	local health 			= level.nv.TDGeneratorHealth
	local totalHealth 		= TD_GENERATOR_HEALTH
	local healthRatio 		= health.tofloat() / totalHealth.tofloat()

	if ( healthRatio > 0.25 )
		return StringToColors( COLOR_RED )
	else
		return StringToColors( COLOR_WHITE )
}

function SetHealthIsBlinking()
{
	level.healthIsBlinking = Time()
}

function ClearHealthIsBlinking()
{
	level.healthIsBlinking = 0
}

function IsHealthBlinking()
{
	return Time() - level.healthIsBlinking < HEALTH_BLINK_TIME
}

function SetGeneratorHealthGroupColors( elems, colors )
{
	foreach ( elem in elems )
		elem.SetColor( colors.r, colors.g, colors.b, 255 )
}

function ShouldBlinkRed()
{
	local value = Time() * 4
	value = floor( value )
	return IsOdd( value )
}

/************************************************************************************************\

##      ##  #######  ########  ##       ########        ########    ###     ######  ########       ####  ######   #######  ##    ##  ######
##  ##  ## ##     ## ##     ## ##       ##     ##       ##         ## ##   ##    ## ##              ##  ##    ## ##     ## ###   ## ##    ##
##  ##  ## ##     ## ##     ## ##       ##     ##       ##        ##   ##  ##       ##              ##  ##       ##     ## ####  ## ##
##  ##  ## ##     ## ########  ##       ##     ##       ######   ##     ## ##       ######          ##  ##       ##     ## ## ## ##  ######
##  ##  ## ##     ## ##   ##   ##       ##     ##       ##       ######### ##       ##              ##  ##       ##     ## ##  ####       ##
##  ##  ## ##     ## ##    ##  ##       ##     ##       ##       ##     ## ##    ## ##              ##  ##    ## ##     ## ##   ### ##    ##
 ###  ###   #######  ##     ## ######## ########        ##       ##     ##  ######  ########       ####  ######   #######  ##    ##  ######

\************************************************************************************************/
function CallbackUpdatePlayerOverHeadIconOnDisconnect( player )
{
	CallbackUpdatePlayerOverHeadIcon( player, player.GetLifeState(), LIFE_DEAD )
}

function TDHudCallback_UpdatePlayerOverHeadIconOnRodeo()
{
	local localPlayer = GetLocalClientPlayer()
	if ( !IsValid( localPlayer ) )
		return

	local playerArray	= GetPlayerArrayOfTeam( localPlayer.GetTeam() )

	foreach( player in playerArray )
	{
		if ( localPlayer != player )
			CallbackUpdatePlayerOverHeadIcon( player, player.GetLifeState(), player.GetLifeState() )
	}
}

function CallbackUpdatePlayerOverHeadIcon( player, oldLifeState, newLifeState )
{
	local localPlayer = GetLocalClientPlayer()
	if ( !IsValid( localPlayer ) )
		return

	local pIndex	= GetPlayerIconIndex( localPlayer )
	local team 		= localPlayer.GetTeam()
	if ( player == localPlayer )
	{
		if ( IsWatchingKillReplay() || newLifeState != LIFE_ALIVE )
		{
			//hide all icons
			foreach( index, iconTable in level.indexedFaceIcons )
			{
				if ( iconTable == null || iconTable.group )
					continue
				//don't touch the players bottom left icon
				if ( pIndex != index )
					iconTable.group.Hide()
			}
		}
		else
		{
			//show all icons
			local otherPlayers = GetPlayerArrayOfTeam( team )
			foreach( friend in otherPlayers )
			{
				if ( friend == player )
					continue

				if ( !IsAlive( friend ) )
					continue

				ShowPlayerWorldIcon( friend )
			}
		}
	}
	else
	{
		switch( newLifeState )
		{
			case LIFE_ALIVE:
				if ( !IsCoopPlayerRodeoing( player ) )
				{
					ShowPlayerWorldIcon( player )
				}
				else
				{
					local iconTable = GetPlayerWorldIcon( player )
					if ( iconTable.group != null )
						iconTable.group.Hide()
				}

				break

			case LIFE_DYING:
			case LIFE_DEAD:
			case LIFE_DISCARDBODY:
			default:
				local iconTable = GetPlayerWorldIcon( player )
				if ( iconTable.group != null )
					iconTable.group.Hide()
				break
		}
	}
}

function IsCoopPlayerRodeoing( player )
{
	Assert( IsValid( player ) )

	local entIndex = player.GetEntIndex()
	local data = level.nv.coopPlayersRodeoing
	local playerBit = 1 << ( entIndex - 1 )

	if ( playerBit & data )	// is the player bit set in the data
		return true
	return false
}

function ShowPlayerWorldIcon( player )
{
	local iconTable = GetPlayerWorldIcon( player )
	if ( iconTable.frame == null )
		return

	if ( IsValid( player ) )
	{
		iconTable.frame.SetEntityOverhead( player, Vector( 0, 0, 0 ), 0.5, 1.2 )
		iconTable.icon.SetEntityOverhead( player, Vector( 0, 0, 0 ), 0.5, 1.2 )
		iconTable.group.Show()
	}
	else
		iconTable.group.Hide()
}

function GetPlayerWorldIcon( player )
{
	local index = GetPlayerIconIndex( player )
	Assert( index in level.indexedFaceIcons )
	return level.indexedFaceIcons[ index ]
}

function GetPlayerIconIndex( player )
{
	local index = player.GetEntIndex() - 1
	Assert( index >= 0 )
	Assert( index < 4 )
	return index
}

function GetCharacterFrameImage( player )
{
	local index = GetPlayerIconIndex( player )
	return "HUD/coop/coop_char_frame_p" + ( index + 1 )
}

function GetCharacterFaceImage( player )
{
	Assert( player.GetModelName(), "player has no model" )
	switch( player.GetModelName() )
	{
		case MILITIA_MALE_BR:
		case IMC_MALE_BR:
			return "HUD/coop/coop_char_brp_m"
		case MILITIA_MALE_CQ:
		case IMC_MALE_CQ:
			return "HUD/coop/coop_char_cqp_m"
		case MILITIA_MALE_DM:
		case IMC_MALE_DM:
			return "HUD/coop/coop_char_dmp_m"
		case MILITIA_FEMALE_BR:
		case IMC_FEMALE_BR:
			return "HUD/coop/coop_char_brp_f"
		case MILITIA_FEMALE_CQ:
		case IMC_FEMALE_CQ:
			return "HUD/coop/coop_char_cqp_f"
		case MILITIA_FEMALE_DM:
		case IMC_FEMALE_DM:
			return "HUD/coop/coop_char_dmp_f"
		case ATLAS_MODEL:
			return "HUD/coop/coop_char_atlas"
		case OGRE_MODEL:
			return "HUD/coop/coop_char_ogre"
		case STRYDER_MODEL:
			return "HUD/coop/coop_char_stryder"
		case IMC_SPECTRE_MODEL:
		case MILITIA_SPECTRE_MODEL:
			return "HUD/coop/coop_char_spectre"

		default:
			Assert( 0, "model " + player.GetModelName() + " not setup in GetCharacterFaceImage" )
	}
}

function OnPlayerLoadoutChanged( player )
{
	Assert( IsValid( player ) )

	if ( !player.IsPlayer() )
		return

	local image = GetCharacterFaceImage( player )
	local index = GetPlayerIconIndex( player )

	//on player connection - the hud hasn't been created yet
	if ( level.indexedFaceIcons[ index ] == null )
		return

	//on respawn when observing - the hud hasn't been created, and the old one is invalid
	if ( !IsValid( GetLocalViewPlayer().GetCockpit() ) )
		return

	level.indexedFaceIcons[ index ].icon.SetImage( image )
}


/************************************************************************************************\

##      ##  #######  ########  ##       ########        ####  ######   #######  ##    ##  ######
##  ##  ## ##     ## ##     ## ##       ##     ##        ##  ##    ## ##     ## ###   ## ##    ##
##  ##  ## ##     ## ##     ## ##       ##     ##        ##  ##       ##     ## ####  ## ##
##  ##  ## ##     ## ########  ##       ##     ##        ##  ##       ##     ## ## ## ##  ######
##  ##  ## ##     ## ##   ##   ##       ##     ##        ##  ##       ##     ## ##  ####       ##
##  ##  ## ##     ## ##    ##  ##       ##     ##        ##  ##    ## ##     ## ##   ### ##    ##
 ###  ###   #######  ##     ## ######## ########        ####  ######   #######  ##    ##  ######

\************************************************************************************************/
function SetWorldIconIndex( ent, name )
{
	foreach ( index, value in level.worldIconIndex[ name ] )
	{
		//if it already exists send it
		if ( value == ent )
			return index

		if ( IsAlive( value ) )
			continue

		level.worldIconIndex[ name ][ index ] = ent
		return index
	}
	Assert( 0, "no free index found for " + name )
}

function ClearWorldIconIndex( ent, name )
{
	foreach ( index, value in level.worldIconIndex[ name ] )
	{
		if ( value != ent )
			continue

		level.worldIconIndex[ name ][ index ] = null
		return index
	}

	return null
}

function GetWorldIconIndex( ent, name )
{
	foreach ( index, value in level.worldIconIndex[ name ] )
	{
		if ( value != ent )
			continue

		return index
	}

	return null
}

function ClearWorldIcon( ent, name )
{
	local index = ClearWorldIconIndex( ent, name )
	if ( index == null )
		return

	local icon = level.worldIcons.GetElement( name + index )
	icon.Hide()
}

/******************************\
	titan icons
\******************************/
function SetCoopTitanIcon( titan )
{
	if ( !IsAlive( titan ) )
		return

	if ( titan.GetTeam() == level.nv.attackingTeam )
		return

	local name 	= "TowerDefenseTitan"
	local index = SetWorldIconIndex( titan, name )
	local icon 	= level.worldIcons.GetElement( name + index )

	icon.SetDistanceFade( 96, 128, 0, 1.0 ) // This should hide the icon when you rodeo a titan

	icon.SetEntityOverhead( titan, Vector( 0, 0, 0 ), 0.5, 1.25 )
	local image = GetTitanSubclassHudIcon( titan )
	icon.SetImage( image )
	icon.Show()
}

/******************************\
	turret icons
\******************************/
function SetSentryTurretIcon( turret )
{
	if ( !IsAlive( turret ) )
		return

	if (  turret.GetTeam() != GetLocalViewPlayer().GetTeam() )
		return

	local player = turret.GetBossPlayer()
	if ( !player )
		return

	local name 	= "CoopPlayerTurret"
	local index = SetWorldIconIndex( turret, name )
	local elem 	= level.worldIcons.GetElement( name + index )

	local elemName 	= elem.GetChild( "CoopPlayerTurretName" )
	local elemCount = elem.GetChild( "CoopPlayerTurretCount" )
	local elemIcon 	= elem.GetChild( "CoopPlayerTurretIcon" )
	local elemHealth = elem.GetChild( "CoopPlayerTurretHealth" )

	elem.SetEntityOverhead( turret, Vector( 0, 0, 0 ), 0.5, 0.9 )
	elem.Show()

	elemName.SetText( "#SENTRY_TURRET_PLAYERNAME", player.GetPlayerName() )
	elemCount.SetText( "#SENTRY_TURRET_KILLCOUNT", 0 )
	elemIcon.Hide()

	if ( player == GetLocalClientPlayer() )
	{
		elemHealth.Show()
		elemName.SetColor( 180, 205, 255 )
	}
	else
	{
		elemHealth.Hide()
		elemName.SetColor( 55, 233, 255 )
	}

	thread SentryTurretKillCountThread( turret, elemCount, elemHealth )
}

function SentryTurretKillCountThread( turret, elemCount, elemHealth )
{
	turret.EndSignal( "OnDestroy" )
	turret.EndSignal( "OnDeath" )

	local maxhealth = turret.GetMaxHealth().tofloat()
	local blendStartVal 	= 0.9
	local blendEndVal 		= 0.25
	local midFrac 			= 0.75
	local color1 = { r = 255, 	g = 255, 	b = 255 } 	// blue
	local color2 = { r = 242, 	g = 172, 	b = 50 } 	// orange
	local color3 = { r = 255, 	g = 50, 	b = 25 } 	// red-orange

	local oldtotalKills = turret.kv.killCount.tointeger()
	local oldtitanKills = turret.kv.titanKillCount.tointeger()

	while( 1 )
	{
		local totalKills = turret.kv.killCount.tointeger()
		local titanKills = turret.kv.titanKillCount.tointeger()

		//HUD STUFF
		if ( titanKills > 0 )
			elemCount.SetText( "#SENTRY_TURRET_KILLCOUNT_PLUSTITAN", totalKills, titanKills )
		else
			elemCount.SetText( "#SENTRY_TURRET_KILLCOUNT", totalKills )

		local healthRatio = max( 0.05, turret.GetHealth().tofloat() / maxhealth )

		elemHealth.SetBarProgress( healthRatio )

		local color

		if ( healthRatio > midFrac )
			color = GraphCapped_GetColorBlend( healthRatio, blendStartVal, midFrac, color1, color2 )
		else
			color = GraphCapped_GetColorBlend( healthRatio, midFrac, blendEndVal, color2, color3 )

		elemHealth.SetColor( color.r, color.g, color.b )

		//VO STUFF
		local bossPlayer = turret.GetBossPlayer()
		if ( IsAlive( bossPlayer ) && bossPlayer == GetLocalClientPlayer() )
		{
			// try kill announcement
			local alias = null
			if ( titanKills > oldtitanKills  && TimerCheck( "Nag_TurretKilledTitan" ) )
			{
				alias = "CoopTD_TurretKilledTitan"
				if ( titanKills > 1 )
					alias = "CoopTD_TurretKilledTitan_Multi"

				TimerReset( "Nag_TurretKilledTitan" )
			}
			else if ( totalKills > oldtotalKills && totalKills >= COOP_TURRET_TOTAL_KILLS_TO_LEVEL_UP && TimerCheck( "Nag_TurretKillstreak" ) )
			{
				alias = "CoopTD_TurretKillstreak"
				TimerReset( "Nag_TurretKillstreak" )
			}

			if ( alias != null )
			{
				PlayConversationToLocalClient( alias )
			}
		}

		oldtotalKills = totalKills
		oldtitanKills = titanKills

		wait 0.5
	}
}

function ServerCallback_TurretWorldIconHide( ehandle )
{
	local turret = GetEntityFromEncodedEHandle( ehandle )
	local name 	= "CoopPlayerTurret"
	local index = GetWorldIconIndex( turret, name )
	local elem 	= level.worldIcons.GetElement( name + index )

	SetTurretIconForActiveWave( elem )
}
Globalize( ServerCallback_TurretWorldIconHide )

function ServerCallback_TurretWorldIconShow( ehandle )
{
	local turret = GetEntityFromEncodedEHandle( ehandle )
	local name 	= "CoopPlayerTurret"
	local index = GetWorldIconIndex( turret, name )
	local elem 	= level.worldIcons.GetElement( name + index )

	SetTurretIconForBetweenWave( elem )
}
Globalize( ServerCallback_TurretWorldIconShow )

function SetTurretIconForActiveWave( elem )
{
	local distMin = 2500
	local distMax = 3000
	local opacMin = 0.0
	local opacMax = 1.0

	elem.SetFOVFade( deg_cos( 30 ), deg_cos( 20 ), 0.25, 1.0 )
	//elem.SetADSFade( deg_cos( 10 ), deg_cos( 5 ), 0, 1 )
	elem.SetDistanceFade( distMax, distMin, opacMin, opacMax )
	elem.UseFriendlyVisibilityAlpha( 1.0 )

	local distMin = 2500
	local distMax = 2000
	local opacMin = 0.0
	local opacMax = 1.0
	elem.GetChild( "CoopPlayerTurretCount" ).SetDistanceFade( distMax, distMin, opacMax, opacMin )
	elem.GetChild( "CoopPlayerTurretHealth" ).SetDistanceFade( distMax, distMin, opacMax, opacMin )

	elem.GetChild( "CoopPlayerTurretIcon" ).Hide()
}

function SetTurretIconForBetweenWave( elem )
{
	local distMin = 7000
	local distMax = 7050
	local opacMin = 0.0
	local opacMax = 1.0

	elem.SetFOVFade( deg_cos( 30 ), deg_cos( 20 ), 1.0, 1.0 )
	//elem.SetADSFade( deg_cos( 10 ), deg_cos( 5 ), 0, 1 )
	elem.SetDistanceFade( distMax, distMin, opacMin, opacMax )
	elem.ClearFriendlyVisibilityAlpha()

	local distMin = 6000
	local distMax = 5500
	local opacMin = 0.0
	local opacMax = 1.0
	elem.GetChild( "CoopPlayerTurretCount" ).SetDistanceFade( distMax, distMin, opacMax, opacMin )
	elem.GetChild( "CoopPlayerTurretHealth" ).SetDistanceFade( distMax, distMin, opacMax, opacMin )

	elem.GetChild( "CoopPlayerTurretIcon" ).Show()
}

/************************************************************************************************\

##    ##  #######  ##    ##          ######   #######   ######  ##    ## ########  #### ########
###   ## ##     ## ###   ##         ##    ## ##     ## ##    ## ##   ##  ##     ##  ##     ##
####  ## ##     ## ####  ##         ##       ##     ## ##       ##  ##   ##     ##  ##     ##
## ## ## ##     ## ## ## ## ####### ##       ##     ## ##       #####    ########   ##     ##
##  #### ##     ## ##  ####         ##       ##     ## ##       ##  ##   ##         ##     ##
##   ### ##     ## ##   ###         ##    ## ##     ## ##    ## ##   ##  ##         ##     ##
##    ##  #######  ##    ##          ######   #######   ######  ##    ## ##        ####    ##

\************************************************************************************************/
function TD_MainHud( mainVGUI, player )
{
	CreateCoopScoresGroup( mainVGUI, player )

	level.worldIcons <- HudElementGroup( "WorldIcons" )
	level.worldIconIndex <- {}

	//player turret kill update
	local name = "CoopPlayerTurret"
	level.worldIconIndex[ name ] <- []
	for ( local i = 0; i < 12; i++ )
	{
		level.worldIconIndex[ name ].append( null )
		local elem = level.worldIcons.CreateElement( name + i )
		elem.GetChild( "CoopPlayerTurretName" ).Show()
		elem.GetChild( "CoopPlayerTurretCount" ).Show()

	//	elem.SetWorldSpaceScale( 2.0, 0.5, 100, 300 ) // -> this makes the nested panel scale but not the elements inside of it
	//	elem.GetChild( "CoopPlayerTurretName" ).SetWorldSpaceScale( 2.0, 0.5, 100, 300 ) // -> this doesn't work at all

		SetTurretIconForActiveWave( elem )
	}

	//world enemy titan icons
	local name = "TowerDefenseTitan"
	level.worldIconIndex[ name ] <- []
	for ( local i = 0; i < COOP_MAX_ACTIVE_TITANS; i++ )
	{
		level.worldIconIndex[ name ].append( null )
		local elem = level.worldIcons.CreateElement( name + i )
		elem.SetHideOnEntityOverheadCloak( true )
		//elem.SetADSFade( deg_cos( 10 ), deg_cos( 5 ), 0, 1 )
		elem.SetFOVFade( deg_cos( 30 ), deg_cos( 10 ), 1, 0.6 )
	}

	//world loadout crate icons
	level.loadoutCrateIcons <- []
	for ( local index = 0; index < MAX_LOADOUT_CRATE_COUNT; index++ )
	{
		local icon 	= HudElement( "LoadoutCrateIcon_" + index )

		icon.SetWorldSpaceScale( 1.75, 0.75, 0, 900 )
		icon.SetDistanceFade( 2000, 2500, 0.5, 0 )
		icon.SetADSFade( deg_cos( 10 ), deg_cos( 5 ), 0, 1.0 )
		icon.SetFOVFade( deg_cos( 45 ), deg_cos( 35 ), 0, 1.0 )

		icon.Hide()
		level.loadoutCrateIcons.append( icon )
	}

	//turret placement hints
	level.turretPlacementHints <- {}
	level.turretPlacementHints.keyboard <- HudElement( "TurretPlacementHint_Keyboard" )
	level.turretPlacementHints.keyboard.EnableKeyBindingIcons()
	level.turretPlacementHints.gamepad <- HudElement( "TurretPlacementHint_Gamepad" )
	level.turretPlacementHints.gamepad.EnableKeyBindingIcons()
	level.turretPlacementHints.invalid <- HudElement( "TurretPlacementHint_Invalid" )

	level.EOGStars <- {}
	level.EOGEmptyStars <- {}

	for( local i = 0; i < MAX_EOG_STARS; i++ )
	{
		level.EOGStars[ i ] <- HudElement( "EOGStar_" + i )
		level.EOGEmptyStars[ i ] <- HudElement( "EOGEmptyStar_" + i )
	}

	local width = level.EOGStars[ 0 ].GetWidth()

	//Reposition stars based on the number of stars being displayed.
	level.EOGStarXOffets <- {}
	level.EOGStarXOffets[ 1 ] <- [ 0 ]
	level.EOGStarXOffets[ 2 ] <- [ -width, width ]
	level.EOGStarXOffets[ 3 ] <- [ -(width * 2), 0, (width * 2) ]

	InitCoopEOGHUD()

	//world friendly face icons ( not the players bottom left cockpit elem )
	local pIndex = GetPlayerIconIndex( player )
	for ( local index = 0; index < 4; index++ )
	{
		//skip the local player... he doesn't need a world icon
		if ( pIndex == index )
			continue

		local group = HudElementGroup( "CoopHeroCharGroup_" + index )
		local icon 	= group.CreateElement( "CoopHeroCharIcon_" + index )
		local frame = group.CreateElement( "CoopHeroCharFrame_" + index )

		SetupWorldCharIcon( icon )
		SetupWorldCharIcon( frame )

		//add them to the array that holds both the 3 world icons and the players bottom left icon
		local table = { group = group, icon = icon, frame = frame }
		level.indexedFaceIcons[ index ] = table
	}

	//generator world icon
	local objectiveTDFade_distMin 			= 1500
	local objectiveTDFade_distMax 			= 2500
	local objectiveTDFade_opacityFracMin 	= 0.5
	local objectiveTDFade_opacityFracMax 	= 0.8

	local group = HudElementGroup( "TD_GeneratorGroup" )
	local elem 	= group.CreateElement( "TD_GeneratorIcon" )
	elem.SetClampToScreen( CLAMP_ELLIPSE )
	elem.SetClampBounds( 0.82, 0.77 )
	elem.SetDistanceFade( objectiveTDFade_distMin, objectiveTDFade_distMax, objectiveTDFade_opacityFracMin, objectiveTDFade_opacityFracMax )
	elem.SetADSFade( deg_cos( 10 ), deg_cos( 5 ), 0, 1 )

	local elem 	= group.CreateElement( "TD_GeneratorLabel" )
	elem.SetClampToScreen( CLAMP_ELLIPSE )
	elem.SetClampBounds( 0.82, 0.77 )
	elem.SetDistanceFade( objectiveTDFade_distMin, objectiveTDFade_distMax, 0.8, 1 )
	elem.SetADSFade( deg_cos( 10 ), deg_cos( 5 ), 0, 1 )
	elem.SetFOVFade( deg_cos( 45 ), deg_cos( 40 ), 0, 1 )

	local elem 	= group.CreateElement( "TD_GeneratorIconArrow" )
	elem.SetClampToScreen( CLAMP_ELLIPSE )
	elem.SetClampBounds( 0.85, 0.8 )
	elem.SetOffscreenArrow( true )
	elem.SetDistanceFade( objectiveTDFade_distMin, objectiveTDFade_distMax, objectiveTDFade_opacityFracMin, objectiveTDFade_opacityFracMax )

	group.Hide()
	level.TD_GeneratorGroupIcon <- group
}

function SetupWorldCharIcon( icon )
{
	icon.SetClampToScreen( CLAMP_RECT )
	icon.SetClampBounds( 0.95, 0.90 )
	icon.SetColor( 255, 255, 255, 255 )
	icon.SetWorldSpaceScale( 2.0, 0.75, 0, 900 )
	icon.SetADSFade( deg_cos( 10 ), deg_cos( 5 ), 0, 1 )
	icon.SetFOVFade( deg_cos( 30 ), deg_cos( 10 ), 1, 0.7 )
}

function MarkerCallback_TD_Generator( markedEntity, marker )
{
	local group = level.TD_GeneratorGroupIcon
	if ( IsValid( markedEntity ) )
	{
		local iconOffsetZ = 300

		group.GetElement( "TD_GeneratorIcon" ).SetEntity( markedEntity, Vector( 0, 0, iconOffsetZ ), 0.5, 0.5 )
		group.GetElement( "TD_GeneratorLabel" ).SetEntity( markedEntity, Vector( 0, 0, iconOffsetZ ), 0.5, 2.25 )
		group.GetElement( "TD_GeneratorIconArrow" ).SetEntity( markedEntity, Vector( 0, 0, iconOffsetZ ), 0.5, 0.5 )
		group.Show()
	}
	else
		group.Hide()
}

function MarkerCallback_TD_LoadoutCrate( markedEntity, marker )
{
	local icon
	for( local index = 0; index < MAX_LOADOUT_CRATE_COUNT; index++ )
	{
		local name = "LoadoutCrateMarker" + index.tostring()
		if ( marker != name )
			continue

		icon = level.loadoutCrateIcons[ index ]
		break
	}

	if ( IsValid( markedEntity ) )
	{
		icon.SetEntity( markedEntity, Vector( 0, 0, 48 ), 0.5, 0.5 )
		icon.Show()
	}
	else
		icon.Hide()
}

/************************************************************************************************\

 ######   #######   ######  ##    ## ########  #### ########
##    ## ##     ## ##    ## ##   ##  ##     ##  ##     ##
##       ##     ## ##       ##  ##   ##     ##  ##     ##
##       ##     ## ##       #####    ########   ##     ##
##       ##     ## ##       ##  ##   ##         ##     ##
##    ## ##     ## ##    ## ##   ##  ##         ##     ##
 ######   #######   ######  ##    ## ##        ####    ##

\************************************************************************************************/
function TD_Cockpit( cockpit, player )
{
	Assert( cockpit.GetMainVGUI() )
	local vgui = cockpit.GetMainVGUI()
	local panel = vgui.GetPanel()

	/*********************************************************\
		BOTTOM LEFT HUD ( SCOREBOARD AND SUCH )
	\*********************************************************/
	CreateCoopScoresGroup( vgui, player )

	//update all living players
	local allPlayers = GetPlayerArrayOfTeam( player.GetTeam() )
	foreach ( guy in allPlayers )
	{
		if ( IsAlive( guy ) )
			OnPlayerLoadoutChanged( player )
	}

	//turret availability
	cockpit.s.offhandHud[OFFHAND_EQUIPMENT] <- {}
	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].icon 	<- HudElement( "EquipmentIcon", panel )
	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].alert 	<- HudElement( "EquipmentAlert", panel )
	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].hint 	<- HudElement( "EquipmentHint", panel )
	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].hint.EnableKeyBindingIcons()
	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].bar 	<- HudElement( "EquipmentBar", panel )
	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].bar.SetBarProgress( 1.0 ) //Start off as full instead of empty so we don't play weapon ready sound by mistake
	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].count 	<- HudElement( "EquipmentCount", panel )
	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].bg 		<- HudElement( "EquipmentBG", panel )

	foreach( elem in cockpit.s.offhandHud[ OFFHAND_EQUIPMENT ] )
	{
		if ( elem != null && type( elem ) != "bool" )
			cockpit.s.weaponsGroup.AddElement( elem )
	}

	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].dots 	<- []
	for ( local i = 0; i < 3; i++ )
	{
		local elem = HudElement( "EquipmentDot" + i, panel )
		cockpit.s.offhandHud[OFFHAND_EQUIPMENT].dots.append( elem )
		cockpit.s.weaponsGroup.AddElement( elem )
	}

	UpdateEquipmentHud( cockpit, player )



	/*********************************************************\
		MINIMAP
	\*********************************************************/
	vgui.s.coopMinimapGroup <- {}
	vgui.s.coopMinimapGroup.hide <- []
	vgui.s.coopMinimapGroup.show <- []

	//hide the default minimap items we want
	vgui.s.coopMinimapGroup.hide.append( vgui.s.minimapGroup.GetElement( "Minimap" ) )
	vgui.s.coopMinimapGroup.hide.append( vgui.s.minimapGroup.GetElement( "MinimapBG" ) )
	vgui.s.coopMinimapGroup.hide.append( vgui.s.minimapGroup.GetElement( "MinimapCompass" ) )

	//create the larger tower defense minimap
	vgui.s.coopMinimapGroup.show.append( vgui.s.minimapGroup.CreateElement( "MinimapCoop", panel ) )
	vgui.s.coopMinimapGroup.show.append( vgui.s.minimapGroup.CreateElement( "MinimapCompassCoop", panel ) )
	vgui.s.coopMinimapGroup.show.append( vgui.s.minimapGroup.CreateElement( "MinimapBGCoop", panel ) )
	vgui.s.coopMinimapGroup.satLabel <- vgui.s.minimapGroup.CreateElement( "MinimapSatelliteLabel", panel )

	EnableCoopMinimap( cockpit, player )

	/*********************************************************\
		WAVE AND HEALTH INFO
	\*********************************************************/
	vgui.s.coopHealthGroup <- HudElementGroup( "coopHealthGroup" )
	vgui.s.coopInfo <- {}

	//generator shield and health
	vgui.s.coopInfo.GeneratorHealthBar 		<- vgui.s.coopHealthGroup.CreateElement( "GeneratorHealthBar", panel )
	vgui.s.coopInfo.GeneratorShieldBar 		<- vgui.s.coopHealthGroup.CreateElement( "GeneratorShieldBar", panel )
	vgui.s.coopInfo.GeneratorHealthDesc 	<- vgui.s.coopHealthGroup.CreateElement( "GeneratorHealthDesc", panel )
//	vgui.s.coopInfo.GeneratorHealthBarDamageGlow 	<- vgui.s.coopHealthGroup.CreateElement( "GeneratorHealthBarDamageGlow", panel )


	//wave description
	vgui.s.coopInfoGroup <- HudElementGroup( "coopInfoGroup" )
	vgui.s.coopInfo.waveDescription <- {}
	vgui.s.coopInfo.waveDescription.text		<- vgui.s.coopInfoGroup.CreateElement( "WaveDescription", panel )
	vgui.s.coopInfo.waveDescription.enemyCount 	<- vgui.s.coopInfoGroup.CreateElement( "WaveDescriptionCount", panel )
	vgui.s.coopInfo.waveDescription.bg 			<- vgui.s.coopInfoGroup.CreateElement( "WaveDescriptionBG", panel )


	//wave icons
	vgui.s.waveIconGroup <- HudElementGroup( "waveIconGroup" )
	vgui.s.waveIcons <- []
	for ( local i = 0; i < 8; i++ )
	{
		local elem = {}
		elem.icon <- vgui.s.waveIconGroup.CreateElement( "TD_wave_enemy_icon" + i, panel )
		elem.text <- vgui.s.waveIconGroup.CreateElement( "TD_wave_enemy_text" + i, panel )
		vgui.s.waveIcons.append( elem )
	}
	vgui.s.waveIconGroup.Hide()

	thread UpdateCoopHud( cockpit, player )
}

function CreateCoopScoresGroup( vgui, player )
{
	local panel = vgui.GetPanel()

	local scoreboardProgressBars = vgui.s.scoreboardProgressBars
	//hide the default mp scoreboard
	vgui.s.scoreboardProgressGroup.Hide()

	//show some basic bg elements
	scoreboardProgressBars.GameInfoBG.Show()
	scoreboardProgressBars.GameInfoBG.SetImage( "hud/coop/hud_hex_bg_left" )
	scoreboardProgressBars.GameInfoFG.Show()
	scoreboardProgressBars.GameInfoFG.SetImage( "hud/coop/hud_hex_left" )
	scoreboardProgressBars.ScoresBG.Show()
	scoreboardProgressBars.ScoresBG.SetImage( "hud/coop/hud_hex_line_bg_left" )
	scoreboardProgressBars.ScoresFG.Show()
	scoreboardProgressBars.ScoresFG.SetImage( "hud/coop/hud_hex_line_left" )

	scoreboardProgressBars.Player_Status_BG.Show()
	scoreboardProgressBars.Player_Status_BG.SetImage( "hud/coop/hud_hex_8v8_bg_left" )
	local offset = 5//offset from default hud
	local pos = scoreboardProgressBars.Player_Status_BG.GetPos()
	scoreboardProgressBars.Player_Status_BG.SetPos( pos[ 0 ] + offset, pos[ 1 ] )

	scoreboardProgressBars.ScoreBarCoop <- vgui.s.scoreboardProgressGroup.CreateElement( "ScoresCoop", panel )
	scoreboardProgressBars.ScoreBarCoop.Show()
	scoreboardProgressBars.StoredScoreBarCoop <- vgui.s.scoreboardProgressGroup.CreateElement( "ScoresCoopStored", panel )
	scoreboardProgressBars.StoredScoreBarCoop.Show()
	scoreboardProgressBars.ScoreCountCoop <- vgui.s.scoreboardProgressGroup.CreateElement( "ScoresCountCoop", panel )
	scoreboardProgressBars.ScoreCountCoop.Show()
	scoreboardProgressBars.ScoreBarText <- vgui.s.scoreboardProgressGroup.CreateElement( "ScoresLabelCoop", panel )
	scoreboardProgressBars.ScoreBarText.Show()

	//game description
	scoreboardProgressBars.GameModeLabel.Show()
	scoreboardProgressBars.EnemyTitanCount.Show()
	scoreboardProgressBars.EnemyBurnTitanCount.Show()

	//show the team and enemy titan counts
	local offset = -6//offset from default hud
	local pos = scoreboardProgressBars.EnemyTitanCount.GetPos()
	scoreboardProgressBars.EnemyTitanCount.SetPos( pos[ 0 ], pos[ 1 ] + offset )
	local pos = scoreboardProgressBars.EnemyBurnTitanCount.GetPos()
	scoreboardProgressBars.EnemyBurnTitanCount.SetPos( pos[ 0 ], pos[ 1 ] + offset )

	local scoreboardArrays = vgui.s.scoreboardArrays
	//the friendly ones are arrays - effect the 1st element
	local offset = -9//offset from default hud
	local pos = scoreboardArrays.FriendlyPlayerStatusCount[ 0 ].GetPos()
	scoreboardArrays.FriendlyPlayerStatusCount[ 0 ].SetPos( pos[ 0 ], pos[ 1 ] + offset )

	//create the player icon
	local index = GetPlayerIconIndex( player )
	local group = HudElementGroup( "CoopHeroCharGroup" + index )
	local frame = group.CreateElement( "CoopCharFrame", panel )
	local icon 	= group.CreateElement( "CoopCharIcon", panel )
	frame.SetImage( GetCharacterFrameImage( player ) )
	group.Show()

	//add it to the array that holds both the 3 world icons and the players bottom left icon
	local table = { group = group, icon = icon, frame = frame }
	local clientIndex = GetPlayerIconIndex( GetLocalClientPlayer() )
	level.indexedFaceIcons[ clientIndex ] = table
}

function UpdateEquipmentHud( cockpit, player )
{
	ReCalculatePetTurretNumbers()

	if ( !( "offhandHud" in cockpit.s ) )
		return

	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].bg.Show()
	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].icon.Show()
	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].hint.Show()
	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].count.Show()

	local ammoCount = level.sentryTurretInventory // this is always between 0 and 3

	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].count.SetText( "#HUDAUTOTEXT_ACTIVEWEAPONMAGAZINECOUNT", ammoCount )
	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].icon.SetImage( "hud/coop/mini_turret_counter" )

	foreach ( index, elem in cockpit.s.offhandHud[OFFHAND_EQUIPMENT].dots )
	{
		if ( index < level.petSentryTurrets )
			elem.Show()
		else
			elem.Hide()
	}

	if ( ammoCount <= 0 || level.petSentryTurrets >= COOP_SENTRY_TURRET_MAX_COUNT_PET || player.IsTitan() )
	{
		cockpit.s.offhandHud[OFFHAND_EQUIPMENT].icon.SetColor( 128, 128, 128, 255 )
	 	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].bar.SetAlpha( 64 )
 		cockpit.s.offhandHud[OFFHAND_EQUIPMENT].hint.SetAlpha( 64 )
	}
	else
	{
		cockpit.s.offhandHud[OFFHAND_EQUIPMENT].icon.ReturnToBaseColor()
	 	cockpit.s.offhandHud[OFFHAND_EQUIPMENT].bar.ReturnToBaseColor()
 		cockpit.s.offhandHud[OFFHAND_EQUIPMENT].hint.ReturnToBaseColor()
	}

	if ( player.IsTitan() )
		cockpit.s.offhandHud[OFFHAND_EQUIPMENT].hint.Hide()
	else
		cockpit.s.offhandHud[OFFHAND_EQUIPMENT].hint.Show()
}
Globalize( UpdateEquipmentHud )

function ReCalculatePetTurretNumbers()
{
	local clientPlayer = GetLocalClientPlayer()
	if ( !IsValid( clientPlayer ) )
		return

	local allTurrets = GetNPCArrayByClass( "npc_turret_sentry" )
	local petTurrets = 0

	foreach ( turret in allTurrets )
	{
		if ( turret.GetBossPlayer() == clientPlayer )
			petTurrets++
	}

	level.petSentryTurrets = petTurrets
}

function EnableCoopMinimap( cockpit, player )
{
	Assert( cockpit.GetMainVGUI() )
	local vgui = cockpit.GetMainVGUI()

	//hide the default minimap items we want
	foreach ( elem in vgui.s.coopMinimapGroup.hide )
		elem.Hide()

	//show the larger tower defense minimap
	foreach ( elem in vgui.s.coopMinimapGroup.show )
		elem.Show()

	//set the scale of the whole group - now rescale the last element ( directional ticker tape )
	vgui.s.minimapGroup.SetScale( COOPMINIMAPSCALE, COOPMINIMAPSCALE )
	vgui.s.coopMinimapGroup.satLabel.SetScale( 1, 1 )
	vgui.s.coopMinimapGroup.satLabel.Show()

	// Didn't place this earlier because the harvester healthbar will kinda break if i do that
	if ( Riff_MinimapState() == eMinimapState.Hidden )
	{
		vgui.s.minimapGroup.GetElement( "MinimapCoop" ).Hide()
		vgui.s.minimapGroup.GetElement( "MinimapBGCoop" ).Hide()
		vgui.s.minimapGroup.GetElement( "MinimapCompassCoop" ).Hide()
		vgui.s.minimapGroup.GetElement( "MinimapSatelliteLabel" ).Hide()
	}
}
Globalize( EnableCoopMinimap )


/*********************************************************\
	EOG Functions
\*********************************************************/

function ServerCallback_DisplayEOGStars( totalDuration )
{
	thread DisplayEOGStars( totalDuration )
}
Globalize( ServerCallback_DisplayEOGStars )

function DisplayEOGStars( totalDuration )
{
	ResetCurrentStarState()
	local starsDisplayed = 0
	local starsToDisplay = MAX_EOG_STARS
	for( local i = 0; i < starsToDisplay; i++ )
	{
		thread DisplayEOGStar( i, starsToDisplay )

		wait COOP_STAR_DISPLAY_INTERVAL
	}
	wait totalDuration - starsToDisplay * COOP_STAR_DISPLAY_INTERVAL
	HideEOGStars()
}

function DisplayEOGStar( i, totalStars )
{
	local star
	local isFullStar = false
	if ( i < file.currentStarEarned )
	{
		star = level.EOGStars[i]
		isFullStar = true
	}
	else
	{
		star = level.EOGEmptyStars[i]
	}
	star.SetPos( level.EOGStarXOffets[ totalStars ][i], star.GetBasePos()[1] )
	star.Show()
	local popInTime = 0.25

	star.SetAlpha( 50 )
	star.FadeOverTime( 255, popInTime )
	star.SetScale( 0.1, 0.1 )
	star.ScaleOverTime( 1.1, 1.1, popInTime )

	wait popInTime

	if ( isFullStar )
	{
		if ( i == 0 )
			EmitSoundOnEntity( GetLocalClientPlayer(), COOP_STAR_NOTIFICATION_SOUND_FIRST )
		else if ( i == 1 )
			EmitSoundOnEntity( GetLocalClientPlayer(), COOP_STAR_NOTIFICATION_SOUND_SECOND )
		else if ( i == 2 )
			EmitSoundOnEntity( GetLocalClientPlayer(), COOP_STAR_NOTIFICATION_SOUND_THIRD )
	}
	else
	{
			EmitSoundOnEntity( GetLocalClientPlayer(), COOP_STAR_NOTIFICATION_SOUND_FAILURE )
	}
	star.ScaleOverTime( 1.0, 1.0, 0.1 )
}

function HideEOGStars()
{

	level.EOGStars[0].FadeOverTime( 0, 0.2 )
	level.EOGStars[1].FadeOverTime( 0, 0.2 )
	level.EOGStars[2].FadeOverTime( 0, 0.2 )
}

function DebugEOGStars()
{
	HideEOGStars()
	thread DisplayEOGStars( COOP_VICTORY_ANNOUNCEMENT_LENGTH / 2 )
}
Globalize( DebugEOGStars )

function DebugSetStars( value )
{
	file.currentStarEarned = value
}
Globalize( DebugSetStars )

function IsCvHudValid( player )
{
	return ( ( "cv" in player ) && ( "clientHud" in player.cv ) && ( "mainVGUI" in player.cv.clientHud.s ) )
}

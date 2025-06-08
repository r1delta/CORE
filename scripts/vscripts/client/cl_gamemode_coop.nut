function main()
{
	if ( IsLobby() )
		return

	IncludeFile( "_gamemode_coop_shared" )

	file.turretHullTraceID <- -1
	file.turretLineTraceID <- -1

	level.sentryTurretInventory		<- 0
	level.sentryTurretProjection	<- false
	level.sentryTurretHidden		<- true

	level.enemyAnnounceInProgress 			<- false
	level.enemyAnnounce_queueProcessing 	<- false
	level.enemyAnnounce_pageWaiting 		<- false
	level.enemyAnnounce_lastFocusStartTime 	<- -1
	level.enemyAnnounce_cancelTime 			<- -1
	level.enemyAnnounceQueue 				<- []
	level.enemyAnnounceDisplayList 			<- []
	level.enemyAnnounceCardStopTime 		<- -1
	level.enemyAnnounceList_lastUpdateTime 	<- -1
	level.lastEnemyCardDisplayTime 			<- -1
	level.enemyAnnounceHeaderCard 			<- null
	level.enemyAnnounceFooterCard 			<- null

	level.lastRodeoWarningAlias <- ""

	level.lastGeneratorShieldHealth <- 0
	RegisterServerVarChangeCallback( "TDGeneratorShieldHealth", TDGeneratorShieldHealthChange )
	RegisterConCommandTriggeredCallback( "+scriptCommand1", ButtonCallback_InitTurretPlacement )

	RegisterServerVarChangeCallback( "gameState", CoopTD_Client_GameStateChangedCallback )

	AddCreateCallback( "player", COOP_PlayerCreateCallback )
	AddCreateCallback( "npc_turret_sentry", TurretOnCreateCallback )
	AddOnDeathOrDestroyCallback( "npc_turret_sentry", TurretOnDeathCallback )
	AddOnDeathOrDestroyCallback( "player", Coop_PlayerOnDeathOrDestroyCallback )

	AddCreatePilotCockpitCallback( Coop_CockpitCreatedCallback )
	AddCreateTitanCockpitCallback( Coop_CockpitCreatedCallback )

	Coop_CloakSettings()

	RegisterSignal( "DestroyTurretProjection" )
	RegisterSignal( "SentryTurretPlacementNag_Stop" )
	RegisterSignal( "NewEnemyAnnounce_StopFooterPositionUpdate" )

	Globalize( ServerCallback_GiveSentryTurret )
	Globalize( SentryTurretPlacementNag )

	TimerInit( "Nag_SpectreRodeo", 15.0 )

	level.forcedMusicOnly 		= true
	level.classMusicEnabled 	= false
	level.gameStateMusicEnabled = false
}

function CoopTD_Client_GameStateChangedCallback()
{
	local player  = GetLocalClientPlayer()
	local gameState = GetGameState()

	if ( gameState == eGameState.WinnerDetermined )
	{
		player.Signal( "SentryTurretPlacementNag_Stop" )
		if ( Coop_IsGameOver() )
		{
			//HACK - Need to update COOP to use GameStateEpilogue/Postmatch in a proper fashion.
			HideScoreboard()
			SetCrosshairPriorityState( crosshairPriorityLevel.MENU, CROSSHAIR_STATE_HIDE_ALL )
		}
	}
	else if ( gameState == eGameState.Prematch )
	{
		level.enemyAnnounceInProgress 		= false
		level.enemyAnnounce_queueProcessing = false
		level.enemyAnnounce_pageWaiting 	= false
		level.enemyAnnounceQueue 			= []
		level.enemyAnnounceDisplayList 		= []
	}
}

function Coop_CloakSettings()
{
	SetCloakPilotSettings( 0.012, 0.02, 0.95, 0.25 )	// 0.012, 0.02, 1.2, 0.25
	SetCloakTitanSettings( 0.003, 0.01, 1.0, 0.25 )		// 0.00015, 0.0, 1.0, 0.05
}

// script_client ServerCallback_TD_WaveAnnounce( 0, 0 )
function ServerCallback_TD_WaveAnnounce( waveIdx, waveNameID, isCheckpointRestart, restartsRemaining )
{
	Client_WaveAnnounceSplash( waveIdx, waveNameID, isCheckpointRestart, restartsRemaining )
}
Globalize( ServerCallback_TD_WaveAnnounce )


function Client_WaveAnnounceSplash( waveIdx, waveNameID, isCheckpointRestart, restartsRemaining )
{
	local isFinalWave = ( level.nv.TDCurrWave == level.nv.TDNumWaves )

	local titleStr = "#WAVE_INCOMING"
	if ( isFinalWave )
	{
		if ( isCheckpointRestart )
			titleStr = "#WAVE_RESTARTING_FINAL"
		else
			titleStr = "#WAVE_INCOMING_FINAL"
	}
	else if ( isCheckpointRestart )
	{
		titleStr = "#WAVE_RESTARTING"
	}

	local announcement = CAnnouncement( titleStr )
	announcement.SetOptionalTextArgsArray( [ waveIdx + 1 ] )
	announcement.SetSoundAlias( "UI_InGame_CoOp_WaveIncoming" )
	announcement.SetPurge( true )
	announcement.SetDuration( 4.5 )

	local waveNameStr = GetWaveNameStrByID( waveNameID )

	if ( waveNameStr != null )
	{
		announcement.SetSubText( "#WAVE_NAME" )
		announcement.SetOptionalSubTextArgsArray( [ waveNameStr ] )
	}

	if ( isCheckpointRestart )
	{
		local alias = "#WAVE_RETRIES_REMAINING"
		if ( restartsRemaining == 1 )
			alias = "#WAVE_RETRIES_REMAINING_ONE"
		else if ( restartsRemaining == 0 )
			alias = "#WAVE_RETRIES_REMAINING_NONE"

		announcement.SetSubText2( alias, restartsRemaining )
	}

	AnnouncementFromClass( GetLocalClientPlayer(), announcement )
}

function ServerCallback_TD_WaveFinished()
{
	local announcement = CAnnouncement( "#COOP_WAVE_CLEARED_SPLASH" )
	announcement.SetOptionalTextArgsArray( [ level.nv.TDCurrWave, level.nv.TDNumWaves ] )
	announcement.SetSubText( "#COOP_WAVE_CLEARED_SPLASH_HINT" )
	announcement.SetSoundAlias( "UI_InGame_CoOp_WaveSurvived" )
	announcement.SetPurge( true )
	announcement.SetDuration( 4.5 )

	AnnouncementFromClass( GetLocalClientPlayer(), announcement )
}
Globalize( ServerCallback_TD_WaveFinished )


function Coop_CockpitCreatedCallback( cockpit, player )
{
	if ( EnemyAnnounce_ShouldRedisplayOnCockpitCreated() )
		thread EnemyAnnounce_RedisplayList( cockpit, player, 2.0 )
}
Globalize( Coop_CockpitCreatedCallback )


function EnemyAnnounce_RedisplayList( cockpit, player, delay )
{
	player.EndSignal( "OnDestroy" )
	cockpit.EndSignal( "OnDestroy" )

	wait delay

	if ( !EnemyAnnounce_ShouldRedisplayOnCockpitCreated() )
		return

	printt( "Enemy announce was in progress, restarting")

	// Move old display list back into queue before we reprocess it
	local newQueue = []
	foreach ( aiTypeID in level.enemyAnnounceDisplayList )
		newQueue.append( aiTypeID )

	newQueue.extend( level.enemyAnnounceQueue )

	level.enemyAnnounceQueue = newQueue
	level.enemyAnnounceDisplayList = []

	thread EnemyAnnounce_ReprocessQueue()
}

function EnemyAnnounce_ShouldRedisplayOnCockpitCreated()
{
	if ( GetGameState() != eGameState.Playing )
		return false

	if ( level.nv.TDCurrWave == null )
		return false

	if ( !level.enemyAnnounceInProgress )
		return false

	// did they show long enough before the player/cockpit got destroyed?
	if ( level.enemyAnnounce_cancelTime - level.enemyAnnounce_lastFocusStartTime >= COOP_NEWENEMY_ANNOUNCE_CARD_FOCUS_TIME * 0.8 )
		return false

	return true
}


function ServerCallback_NewEnemyAnnounceCards( arg0, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null )
{
	local args = []
	args.append( arg0 )
	args.append( arg1 )
	args.append( arg2 )
	args.append( arg3 )
	args.append( arg4 )
	args.append( arg5 )
	args.append( arg6 )
	args.append( arg7 )
	args.append( arg8 )

	for ( local i = 0 ; i < args.len() - 1; i++ )
	{
		local aiTypeID = args[i]
		if ( aiTypeID != null )
		{
			NewEnemyAnnounce_AddToQueue( aiTypeID )
		}
	}

	thread EnemyAnnounce_ReprocessQueue()
}
Globalize( ServerCallback_NewEnemyAnnounceCards )


function NewEnemyAnnounce_AddToQueue( aiTypeID )
{
	Assert( typeof( aiTypeID ) == "integer" )

	ValidateCoopAITypeIdx( aiTypeID )
	Assert( aiTypeID in level.enemyAnnounceCardInfos, "Couldn't find announce card info for aiTypeID " + aiTypeID )

	level.enemyAnnounceQueue.append( aiTypeID )
}

function NewEnemyAnnounce_RemoveFromQueue( aiTypeID )
{
	ArrayRemove( level.enemyAnnounceQueue, aiTypeID )
}

function EnemyAnnounce_ReprocessQueue()
{
	local player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	local mainVGUI = cockpit.GetMainVGUI()
	if ( !mainVGUI )
		return

	if ( level.enemyAnnounce_queueProcessing == true )
		return

	level.enemyAnnounce_queueProcessing = true

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	cockpit.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : (  )
		{
			level.enemyAnnounce_queueProcessing = false
		}
	)

	local tickInterval = 0.1
	local nextTick = Time()

	while ( level.enemyAnnounceQueue.len() )
	{
		if ( nextTick > Time() )
			wait nextTick - Time()

		nextTick = Time() + tickInterval  // sets next tick time to default at first

		if ( level.enemyAnnounce_pageWaiting == true )
			continue

		local totalCardsOnscreen = level.enemyAnnounceDisplayList.len()

		// max cards onscreen
		if ( totalCardsOnscreen == COOP_NEWENEMY_ANNOUNCE_MAX_CARDS )
			continue

		local timeSinceLastCard = Time() - level.lastEnemyCardDisplayTime

		// only header displaying, wait for that
		if ( totalCardsOnscreen == 0 && timeSinceLastCard < COOP_NEWENEMY_ANNOUNCE_HEADER_DELAY )
			continue
		// other cards are on the list, do that wait instead
		else if ( timeSinceLastCard < COOP_NEWENEMY_ANNOUNCE_CARD_ADD_DELAY )
			continue

		if ( level.enemyAnnounceHeaderCard == null )
		{
			// if no cards onscreen first display header
			thread NewEnemyAnnounce_DisplayHeader( player )

			// since we just started showing a card, we will have to wait at least this long before showing another
			local nextTick = Time() + COOP_NEWENEMY_ANNOUNCE_HEADER_DELAY
		}
		else
		{
			// display the next card
			local idx = 0
			local aiTypeID = level.enemyAnnounceQueue[ idx ]
			local cardInfo = level.enemyAnnounceCardInfos[ aiTypeID ]

			thread NewEnemyAnnounce_DisplayCard( player, cardInfo )
			NewEnemyAnnounce_RemoveFromQueue( aiTypeID )

			if ( level.enemyAnnounceFooterCard == null )
				thread NewEnemyAnnounce_DisplayFooter( player )
			else
				thread NewEnemyAnnounce_UpdateFooterPosition( player )

			local nextTick = Time() + COOP_NEWENEMY_ANNOUNCE_CARD_ADD_DELAY
		}
	}
}

function NewEnemyAnnounce_DisplayHeader( player )
{
	Assert( level.enemyAnnounceHeaderCard == null )

	local player = GetLocalViewPlayer()

	local cardInfo = "HEADER"  // HACK
	thread NewEnemyAnnounce_DisplayCard( player, cardInfo )
}

function NewEnemyAnnounce_DisplayFooter( player )
{
	Assert( level.enemyAnnounceFooterCard == null )

	local player = GetLocalViewPlayer()

	local cardInfo = "FOOTER"  // HACK
	thread NewEnemyAnnounce_DisplayCard( player, cardInfo )
}

function NewEnemyAnnounce_UpdateFooterPosition( player )
{
	if ( !IsValid( player ) )
		return

	if ( level.enemyAnnounceFooterCard == null )  // might be called by the last card sliding away
		return

	level.ent.Signal( "NewEnemyAnnounce_StopFooterPositionUpdate" )
	level.ent.EndSignal( "NewEnemyAnnounce_StopFooterPositionUpdate" )

	local cockpit = player.GetCockpit()
	local vgui = level.enemyAnnounceFooterCard.vgui

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	cockpit.EndSignal( "OnDestroy" )
	vgui.EndSignal( "OnDestroy" )

	local cardInfo = "FOOTER"
	local cardDisplayInfo = NewEnemyAnnounce_GetCardDisplayInfo( player, cardInfo )
	local midOrigin 	= cardDisplayInfo.midOrigin
	local vguiWidth 	= cardDisplayInfo.vguiWidth
	local vguiHeight 	= cardDisplayInfo.vguiHeight

	// use this origin as a fallback, this gives us the offscreen start position for a card sliding in, not the current footer origin.
	//  - (Fallback because we want the footer update move to look like a vertical slide down, not a horizontal slide out.)
	local startOrigin 	= cardDisplayInfo.startOrigin

	// HACK As a Titan, the cockpit GetOrigin returns a location near the player's face. HOWEVER as a player the cockpit is rendered differently, so it returns a location that is offset from the worldspawn.
	//  Fix here is just to store it ourselves for future reference. -SRS
	if ( level.enemyAnnounceFooterCard.lastMidOrigin != null )
		startOrigin = level.enemyAnnounceFooterCard.lastMidOrigin

	//printt( "Footer start/midOrigin:", startOrigin, midOrigin )

	if ( midOrigin == startOrigin )
		return

	level.enemyAnnounceFooterCard.lastMidOrigin = midOrigin

	local startTime = Time()
	local moveTime = COOP_NEWENEMY_ANNOUNCE_CARD_MOVE_TIME
	local endTime = startTime + moveTime

	while( 1 )
	{
		if ( Time() >= endTime )
			break

		// the vgui can be deparented from the player before either of them are destroyed
		if ( !IsValid( vgui.GetParent() ) )
			break

		local result = Interpolate( startTime, moveTime, 0, moveTime )
		InterpolateBurnCard( vgui, result, startTime, moveTime, startOrigin, midOrigin, COOP_NEWENEMY_ANNOUNCE_CARD_SCALE_OUT, COOP_NEWENEMY_ANNOUNCE_CARD_SCALE_IN, vguiWidth, vguiHeight )

		wait 0
	}
}

function EnemyAnnounce_AddToDisplayList( aiTypeID )
{
	Assert( typeof( aiTypeID ) == "integer" )

	ValidateCoopAITypeIdx( aiTypeID )
	Assert( aiTypeID in level.enemyAnnounceCardInfos, "Couldn't find announce card info for aiTypeID " + aiTypeID )

	level.enemyAnnounceDisplayList.append( aiTypeID )

	level.enemyAnnounceList_lastUpdateTime = Time()
}

function EnemyAnnounce_RemoveFromDisplayList( aiTypeID )
{
	ArrayRemove( level.enemyAnnounceDisplayList, aiTypeID )

	level.enemyAnnounceList_lastUpdateTime = Time()
}


function NewEnemyAnnounce_DisplayCard( player, cardInfo )
{
	if ( player != GetLocalViewPlayer() )
		return

	local cockpit = player.GetCockpit()

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	cockpit.EndSignal( "OnDestroy" )

	level.lastEnemyCardDisplayTime = Time()  // the header should set this as well

	local listIdx = 0
	local pageEndingCard = false

	if ( cardInfo != "HEADER" && cardInfo != "FOOTER" )
	{
		listIdx = level.enemyAnnounceDisplayList.len()
		EnemyAnnounce_AddToDisplayList( cardInfo.aiTypeIdx )

		// page wait starts when the final list item is created and stops processing when the first list item is deleted
		if ( listIdx == 0 )
			pageEndingCard = true
		else if ( listIdx == COOP_NEWENEMY_ANNOUNCE_MAX_CARDS - 1 )
			level.enemyAnnounce_pageWaiting = true
	}

	if ( level.enemyAnnounceInProgress == false )
		level.enemyAnnounceInProgress = true

	local vguis = []

	OnThreadEnd(
		function () : ( vguis, player, cardInfo, pageEndingCard )
		{
			if ( cardInfo == "HEADER" )
			{
				if ( level.enemyAnnounceHeaderCard != null )
					level.enemyAnnounceHeaderCard = null
			}
			else if ( cardInfo == "FOOTER" )
			{
				if ( level.enemyAnnounceFooterCard != null )
					level.enemyAnnounceFooterCard = null
			}
			else
			{
				if ( IsValid( player ) )
					thread NewEnemyAnnounce_UpdateFooterPosition( player )

				if ( pageEndingCard == true && level.enemyAnnounce_pageWaiting == true )
					level.enemyAnnounce_pageWaiting = false

				if ( level.enemyAnnounceInProgress == true && level.enemyAnnounceDisplayList.len() + level.enemyAnnounceQueue.len() <= 0 )
					level.enemyAnnounceInProgress = false
			}

			if ( IsValid( player ) )
			{
				StopSoundOnEntity( player, "UI_InGame_CoOp_ThreatIncoming_SlideIn" )
				StopSoundOnEntity( player, "UI_InGame_CoOp_ThreatIncoming_Title" )
				//StopSoundOnEntity( player, "UI_InGame_CoOp_ThreatIncoming_SlideOut" )
			}

			foreach ( vgui in vguis )
			{
				vgui.Destroy()
			}
		}
	)

	// TODO better handling of delays etc
	waitthread WaitUntilDisplayBurnCard( player )

	local focusTime = COOP_NEWENEMY_ANNOUNCE_CARD_FOCUS_TIME
	local moveTime = COOP_NEWENEMY_ANNOUNCE_CARD_MOVE_TIME

	level.enemyAnnounceCardStopTime = Time() + moveTime + focusTime

	local cardDisplayInfo = NewEnemyAnnounce_GetCardDisplayInfo( player, cardInfo, listIdx )
	local startOrigin 	= cardDisplayInfo.startOrigin
	local midOrigin 	= cardDisplayInfo.midOrigin
	local cardAngles 	= cardDisplayInfo.cardAngles
	local vguiWidth 	= cardDisplayInfo.vguiWidth
	local vguiHeight 	= cardDisplayInfo.vguiHeight

	local vgui = CreateClientsideVGuiScreen( "vgui_enemy_announce", VGUI_SCREEN_PASS_HUD, startOrigin, cardAngles, vguiWidth, vguiHeight )
	vgui.SetParent( cockpit, "CAMERA_BASE" )
	vgui.SetAttachOffsetOrigin( startOrigin )
	vgui.SetAttachOffsetAngles( cardAngles )

	vguis.append( vgui )

	local announceCard = WaveAnnounce_CreateCard( vgui, cardInfo )
	WaveAnnounce_SetCard( announceCard, cardInfo )

	// CARD SLIDES INTO SCREEN

	if ( cardInfo != "HEADER" && cardInfo != "FOOTER" )
		EmitSoundOnEntity( player, "UI_InGame_CoOp_ThreatIncoming_SlideIn" )
	else if ( cardInfo == "HEADER" )
		EmitSoundOnEntity( player, "UI_InGame_CoOp_ThreatIncoming_Title" )

	local startTime = Time()
	local endTime = startTime + moveTime

	for ( ;; )
	{
		if ( Time() >= endTime )
			break

		local result = Interpolate( startTime, moveTime, 0, moveTime )
		InterpolateBurnCard( vgui, result, startTime, moveTime, startOrigin, midOrigin, COOP_NEWENEMY_ANNOUNCE_CARD_SCALE_OUT, COOP_NEWENEMY_ANNOUNCE_CARD_SCALE_IN, vguiWidth, vguiHeight )
		wait 0
	}

	vgui.SetAttachOffsetOrigin( midOrigin )
	vgui.SetSize( vguiWidth * COOP_NEWENEMY_ANNOUNCE_CARD_SCALE_IN, vguiHeight * COOP_NEWENEMY_ANNOUNCE_CARD_SCALE_IN )

	level.enemyAnnounce_lastFocusStartTime = Time()

	// CARD WAITS ONSCREEN

	local cardStopFocusTime = GetCardStopFocusTime( listIdx, cardInfo )
	local lastListUpdateCheck = Time()

	while ( 1 )
	{
		if ( Time() < cardStopFocusTime )
			wait cardStopFocusTime - Time()

		if ( lastListUpdateCheck < level.enemyAnnounceList_lastUpdateTime )
		{
			cardStopFocusTime = GetCardStopFocusTime( listIdx, cardInfo )
			lastListUpdateCheck = Time()
		}
		else
		{
			break
		}
	}

	if ( cardInfo != "HEADER" && cardInfo != "FOOTER" )
		EnemyAnnounce_RemoveFromDisplayList( cardInfo.aiTypeIdx )

	// CARD SLIDES BACK OFFSCREEN

	if ( cardInfo != "FOOTER" )
		EmitSoundOnEntity( player, "UI_InGame_CoOp_ThreatIncoming_SlideOut" )

	local startTime = Time()
	local endTime = startTime + moveTime

	for ( ;; )
	{
		if ( Time() >= endTime )
			break

		local result = Interpolate( startTime, moveTime, 0, moveTime )
		result = 1.0 - result
		// goes backwards
		InterpolateBurnCard( vgui, result, startTime, moveTime, startOrigin, midOrigin, COOP_NEWENEMY_ANNOUNCE_CARD_SCALE_OUT, COOP_NEWENEMY_ANNOUNCE_CARD_SCALE_IN, vguiWidth, vguiHeight )

		wait 0
	}
}

function GetCardStopFocusTime( listIdx, cardInfo )
{
	local removeDelay = COOP_NEWENEMY_ANNOUNCE_CARD_REMOVE_DELAY

	local distFromListBottom = level.enemyAnnounceDisplayList.len() - listIdx

	local cardStopFocusTime = level.enemyAnnounceCardStopTime + (removeDelay.tofloat() * distFromListBottom.tofloat()) + COOP_NEWENEMY_ANNOUNCE_CARD_MOVE_TIME

	if ( cardInfo == "HEADER" )
	{
		if ( level.enemyAnnounceQueue.len() > 0 )
			cardStopFocusTime += COOP_NEWENEMY_ANNOUNCE_CARD_ADD_DELAY  // if card(s) are in the queue, keep header up long enough for first queued card to start to display
		else
			cardStopFocusTime += removeDelay  // add another delay so header slides off after the final enemy card
	}

	return cardStopFocusTime
}

function NewEnemyAnnounce_GetCardDisplayInfo( player, cardInfo, listIdx = -1 )
{
	local cockpit = player.GetCockpit()

	// Has to match the vgui screen size setup in vgui_screens.txt and any "background" element sizes in the resfile
	local hudElemWidth = 472
	local hudElemHeight = 60

	local ratio = hudElemHeight.tofloat() / hudElemWidth.tofloat()
	local vguiWidth = 11.5  // worldspace VGUI width
	local vguiHeight = vguiWidth * ratio

	local whitespace = vguiHeight * 0.09  // whitespace between cards in the list, not between the header and the top of the list
	local scaledHeight = ( vguiHeight * COOP_NEWENEMY_ANNOUNCE_CARD_SCALE_IN ) + whitespace

	local rightOrgScalar_in 	= 13.5  // how far into the screen they go. Bigger # = closer to right side of screen
	local rightOrgScalar_out 	= 25

	local header_upOrgScalar 	= 4.0
	local cardstart_upOrgScalar = header_upOrgScalar - 1.6  // controls whitespace between header and start of list items

	// HACK the footer always tacks onto the bottom
	if ( cardInfo == "FOOTER" )
		listIdx = level.enemyAnnounceDisplayList.len()

	Assert( listIdx != -1 )

	local upOrgScalar = cardstart_upOrgScalar

	if ( cardInfo == "HEADER" )
	{
		upOrgScalar = header_upOrgScalar
	}
	else if ( listIdx != 0 )  // normal card or footer
	{
		upOrgScalar = cardstart_upOrgScalar - ( listIdx * scaledHeight )

		if ( cardInfo == "FOOTER" )
			upOrgScalar += ( vguiHeight * 0.275 )
	}

	local origin = Vector( 0, 0, 0 )
	local cardAngles = Vector( 0, 0, 0 )
	local forward = cardAngles.AnglesToForward()
	local right = cardAngles.AnglesToRight()
	local up = cardAngles.AnglesToUp()

	cardAngles = cardAngles.AnglesCompose( Vector( 0, -90, 90 ) )

	// card rotation
	local fwdScalar = 22  // default
	local cardRotationAngleVec = Vector( -8, 0, 0 )
	cardAngles = cardAngles.AnglesCompose( cardRotationAngleVec )

	origin += forward * fwdScalar
	origin += right * ( -vguiWidth / 2 )
	origin += up * ( -vguiHeight / 2 )

	local startOrigin = VectorCopy( origin )
	local midOrigin = VectorCopy( origin )
	startOrigin += up * upOrgScalar
	startOrigin += right * rightOrgScalar_out

	midOrigin += right * rightOrgScalar_in
	midOrigin += up * upOrgScalar

	local isTitanCockpit = IsTitanCockpitModelName( cockpit.GetModelName() )
	if ( !isTitanCockpit )
	{
		midOrigin += forward * -2
		startOrigin += right * 1.0
		startOrigin += up * 0.5
	}

	local cardDisplayInfo = {}
	cardDisplayInfo.startOrigin <- startOrigin
	cardDisplayInfo.midOrigin 	<- midOrigin
	cardDisplayInfo.cardAngles 	<- cardAngles
	cardDisplayInfo.vguiWidth 	<- vguiWidth
	cardDisplayInfo.vguiHeight 	<- vguiHeight

	return cardDisplayInfo
}

function WaveAnnounce_CreateCard( previewPanel, cardInfo )
{
	Assert( previewPanel instanceof C_VGuiScreen )

	local allCardElems = []
	allCardElems.append( "PreviewCard_HeaderTitle" )
	allCardElems.append( "PreviewCard_HeaderBackground" )
	allCardElems.append( "PreviewCard_background" )
	allCardElems.append( "PreviewCard_backgroundOutline" )
	allCardElems.append( "PreviewCard_title" )
	allCardElems.append( "PreviewCard_description" )
	allCardElems.append( "PreviewCard_icon1" )
	allCardElems.append( "PreviewCard_numEnemies" )
	allCardElems.append( "PreviewCard_FooterTitle" )

	local table = {}
	local panel = previewPanel.GetPanel()
	foreach ( name in allCardElems )
		table[ name ] <- HudElement( name, panel )

	table.vgui <- previewPanel

	return table
}

// this needs to be done AFTER the vgui has been initialized
function WaveAnnounceCard_HideInactiveElems( previewCardTable, cardInfo )
{
	local headerElems = [ 	"PreviewCard_background",
							"PreviewCard_HeaderTitle",
							"PreviewCard_HeaderBackground"
						]

	local normalElems = [ 	"PreviewCard_background",
							"PreviewCard_backgroundOutline",
							"PreviewCard_title",
							"PreviewCard_description",
							"PreviewCard_icon1",
							"PreviewCard_numEnemies",
						]

	local footerElems = [ 	"PreviewCard_FooterTitle" ]

	local activeElems, inactiveElems

	if ( cardInfo == "HEADER" )
	{
		activeElems = headerElems
		inactiveElems = normalElems
		inactiveElems.extend( footerElems )
	}
	else if ( cardInfo == "FOOTER" )
	{
		activeElems = footerElems
		inactiveElems = normalElems
		inactiveElems.extend( headerElems )
	}
	else
	{
		activeElems = normalElems
		inactiveElems = headerElems
		inactiveElems.extend( footerElems )
	}

	foreach ( name in inactiveElems )
		previewCardTable[ name ].Hide()

	foreach ( name in activeElems )
		previewCardTable[ name ].Show()
}

function WaveAnnounce_SetCard( previewCardTable, cardInfo )
{
	previewCardTable.vgui.Show()
	foreach ( element in previewCardTable )
	{
		element.Show()
		element.SetAlpha( 255 )
	}

	if ( cardInfo == "HEADER" )
		WaveAnnounce_SetHeaderCard( previewCardTable, cardInfo )
	else if ( cardInfo == "FOOTER" )
		WaveAnnounce_SetFooterCard( previewCardTable, cardInfo )
	else
		WaveAnnounce_SetEnemyCard( previewCardTable, cardInfo )

	WaveAnnounceCard_HideInactiveElems( previewCardTable, cardInfo )
}

function WaveAnnounce_SetHeaderCard( previewCardTable, cardInfo )
{
	Assert ( cardInfo == "HEADER" )

	level.enemyAnnounceHeaderCard = previewCardTable
	WaveAnnounce_UpdateHeaderText()
}

function WaveAnnounce_UpdateHeaderText()
{
	if ( !IsValid( level.enemyAnnounceHeaderCard ) )
		return

	local title = "#NEW_ENEMY_ANNOUNCE"
	if ( (level.enemyAnnounceDisplayList.len() + level.enemyAnnounceQueue.len() - 1 ) > 1 )  // minus-one hack = this card hasn't left the queue yet
		title = "#NEW_ENEMY_ANNOUNCE_MULTI"

	level.enemyAnnounceHeaderCard.PreviewCard_HeaderTitle.SetText( title )
}

function WaveAnnounce_SetFooterCard( previewCardTable, cardInfo )
{
	Assert ( cardInfo == "FOOTER" )

	level.enemyAnnounceFooterCard = previewCardTable

	level.enemyAnnounceFooterCard.lastMidOrigin <- null

	previewCardTable.PreviewCard_FooterTitle.EnableKeyBindingIcons()
}

function WaveAnnounce_SetEnemyCard( previewCardTable, cardInfo )
{
	local icon 			= cardInfo.icon
	local title 		= cardInfo.title
	local desc 			= cardInfo.description

	local numEnemies = GetCoopEnemyCount_ByAITypeIdx( cardInfo.aiTypeIdx )
	// TEMP for testing when waves are turned off, we won't need/want to do this in practice
	if ( numEnemies == -1 )
	{
		local ran = RandomInt( 1, 4 )
		if ( ran == 1 )
			numEnemies = RandomInt( 1, 99 )
		else if ( ran == 2 )
			numEnemies = RandomInt( 100, 199 )
		else
			numEnemies = RandomInt( 200, 301 )
	}

	previewCardTable.PreviewCard_numEnemies.SetText( numEnemies.tostring() )

	previewCardTable.PreviewCard_icon1.SetImage( icon )
	previewCardTable.PreviewCard_title.SetText( title )
	previewCardTable.PreviewCard_description.SetText( desc )

	local displayColor = { r = 157, g = 196, b = 219 }
	previewCardTable.PreviewCard_title.SetColor( displayColor.r, displayColor.g, displayColor.b )

	WaveAnnounce_UpdateHeaderText()
}

// ==================================================


function COOP_PlayerCreateCallback( player, isRecreate )
{
	if ( player == GetLocalViewPlayer() )
		return

	if ( PlayerMustRevive( player ) )
		thread COOP_ReviveNotify( player )
}

function Coop_PlayerOnDeathOrDestroyCallback( player )
{
	if ( level.enemyAnnounceInProgress )
		level.enemyAnnounce_cancelTime = Time()
}


function COOP_ReviveNotify( player )
{
	player.EndSignal( "OnDestroy" )
	local viewPlayer = GetLocalViewPlayer()
	viewPlayer.EndSignal( "OnDestroy" )

	for ( ;; )
	{
		if ( !IsAlive( player ) )
		{
			waitthread DrawRevivingPlayerMessage( viewPlayer, player )
		}

		WaitSignal( player, "OnDeath", "OnModelChanged", "HealthChanged" )
	}
}

function DrawRevivingPlayerMessage( viewPlayer, player )
{
	player.EndSignal( "OnModelChanged" )
	player.EndSignal( "HealthChanged" )

	local eventText = "Revived in %s1"
	OnThreadEnd(
		function() : ( viewPlayer, eventText )
		{
			if ( !IsValid( viewPlayer ) )
				return

			if ( viewPlayer.cv.hud.s.lastEventNotificationText == eventText )
				ClearEventNotification()
		}
	)

	wait REVIVE_DEATH_TIME

	for ( ;; )
	{
		wait 0
		if ( !IsAlive( viewPlayer ) )
			continue
		if ( Distance( player.GetOrigin(), viewPlayer.GetOrigin() ) > REVIVE_DIST_INNER )
			continue

		local doneReviveTime = Time() + REVIVE_TIME_TO_REVIVE + 1.2 // lag buffer time, account for the polling rate on server
		SetTimedEventNotificationHATT( 0.0, eventText, HATT_GAME_COUNTDOWN_SECONDS_MILLISECONDS, doneReviveTime )

		for ( ;; )
		{
			if ( !IsAlive( viewPlayer ) )
				break
			if ( Distance( player.GetOrigin(), viewPlayer.GetOrigin() ) > REVIVE_DIST_OUTER )
				break
			wait 0
		}
		ClearEventNotification()
	}
}

function TDGeneratorShieldHealthChange()
{
	local lastHealth = level.lastGeneratorShieldHealth
	local newHealth = level.nv.TDGeneratorShieldHealth
	local maxHealth = TD_GENERATOR_SHIELD_HEALTH
	local tower = GetMarkedEntity( MARKER_TOWERDEFENSEGENERATOR )

	if ( newHealth == null )
		return

	if ( !IsValid( tower ) )
		return

	if ( newHealth < lastHealth && lastHealth != null)
	{
		local damage = lastHealth - newHealth
		local shieldHealthFrac = newHealth / maxHealth
		local shieldFX

		if ( newHealth > 0 )
			shieldFX = GetParticleSystemIndex( FX_HARVESTER_SHIELD )
		else
			shieldFX = GetParticleSystemIndex( FX_HARVESTER_SHIELD_BREAK )

		local shieldFXHandle1 = StartParticleEffectOnEntity( tower, shieldFX, FX_PATTACH_ABSORIGIN, -1 )

		local colorVector = GetGeneratorShieldEffectCurrentColor( 1 - shieldHealthFrac )
		EffectSetControlPointVector( shieldFXHandle1, 1, colorVector )
	}

	level.lastGeneratorShieldHealth = newHealth
}

function GetGeneratorShieldEffectCurrentColor( shieldHealthFrac )
{
	local color1 = { r = 115, g = 247, b = 255 }	// blue
	local color2 = { r = 200, g = 128, b = 80 } // orange
	local color3 = { r = 200, g = 80, b = 80 } // red

	local crossover1 = 0.75  // from zero to this fraction, fade between color1 and color2
	local crossover2 = 0.95  // from crossover1 to this fraction, fade between color2 and color3

	local colorVec = Vector( 0, 0, 0 )
	// 0 = full charge, 1 = no charge remaining
	if ( shieldHealthFrac < crossover1 )
	{
		colorVec.x = Graph( shieldHealthFrac, 0, crossover1, color1.r, color2.r )
		colorVec.y = Graph( shieldHealthFrac, 0, crossover1, color1.g, color2.g )
		colorVec.z = Graph( shieldHealthFrac, 0, crossover1, color1.b, color2.b )
	}
	else if ( shieldHealthFrac < crossover2 )
	{
		colorVec.x = Graph( shieldHealthFrac, crossover1, crossover2, color2.r, color3.r )
		colorVec.y = Graph( shieldHealthFrac, crossover1, crossover2, color2.g, color3.g )
		colorVec.z = Graph( shieldHealthFrac, crossover1, crossover2, color2.b, color3.b )
	}
	else
	{
		// for the last bit of overload timer, keep it max danger color
		colorVec.x = color3.r
		colorVec.y = color3.g
		colorVec.z = color3.b
	}

	return colorVec
}

/************************************************************************************************\

######## ##     ## ########  ########  ######## ########  ######
   ##    ##     ## ##     ## ##     ## ##          ##    ##    ##
   ##    ##     ## ##     ## ##     ## ##          ##    ##
   ##    ##     ## ########  ########  ######      ##     ######
   ##    ##     ## ##   ##   ##   ##   ##          ##          ##
   ##    ##     ## ##    ##  ##    ##  ##          ##    ##    ##
   ##     #######  ##     ## ##     ## ########    ##     ######

\************************************************************************************************/
function ServerCallback_GiveSentryTurret()
{
	if ( level.sentryTurretInventory >= COOP_SENTRY_TURRET_MAX_COUNT_INV )
		return

	level.sentryTurretInventory = min( COOP_SENTRY_TURRET_MAX_COUNT_INV, level.sentryTurretInventory + 1 )

	local player = GetLocalClientPlayer()
	local cockpit = player.GetCockpit()
	if ( IsValid( cockpit ) )
		UpdateEquipmentHud( cockpit, player )

	SentryTurretUpdateVO()
}

function TurretOnCreateCallback( turret, isRecreate )
{
	if ( turret.GetBossPlayer() != GetLocalClientPlayer() )
		return

	thread DismantleTurretThink( turret )
}

function DismantleTurretThink( turret )
{
	turret.EndSignal( "OnDestroy" )

	while( 1 )
	{
		local results = turret.WaitSignal( "OnPlayerUse" )

		if ( !IsAlive( turret ) )
			return

		local player = results.activator

		if ( !IsValid( player ) )
			continue

		if ( !player.IsPlayer() )
			continue

		if ( player != turret.GetBossPlayer() )
			continue

		turret.s.suppressNextVo <- true
	}
}

function TurretOnDeathCallback( turret )
{
	local player = turret.GetBossPlayer()
	if ( !IsValid( player ) )
		return

	if ( player != GetLocalClientPlayer() )
		return

	if ( "suppressNextVo" in turret.s )
		return

	local justDied = true
	SentryTurretUpdateVO( justDied )
}

function SentryTurretUpdateVO( justDied = false )
{
	local freeRoom 			= level.petSentryTurrets < COOP_SENTRY_TURRET_MAX_COUNT_PET
	local isAvailable 		= level.sentryTurretInventory > 0
	local canInformPlayer 	= CanInformPlayerAboutTurretUpdate()

	//one just died, and you've got none in the inventory
	if ( justDied && !isAvailable && canInformPlayer )
		PlayConversationToLocalClient( "CoopTD_TurretDestroyed" )			//Hey your turrets been taken out, I'll get you another one as soon as I can

	//one just died, and you've got more in the inventory
	else if ( justDied && isAvailable && freeRoom )
	{
		if ( canInformPlayer )
		{
			PlayConversationToLocalClient( "CoopTD_TurretDeadAndReady" )		//Hey your turrets been destroyed, but you've got another one in reserve. Just deploy it somewhere.
			EventNotification( eEventNotifications.TurretAvailable, null )
		}
		thread SentryTurretPlacementNag()
	}

	//you just got a new turret and you have room to place it
	else if ( isAvailable && freeRoom )
	{
		if ( canInformPlayer )
		{
			PlayConversationToLocalClient( "CoopTD_TurretAvailable" )			//Pilot, you've got a turret available, put it some place where it can do some damage
			EventNotification( eEventNotifications.TurretAvailable, null )
		}
		thread SentryTurretPlacementNag()
	}
}

function CanInformPlayerAboutTurretUpdate()
{
	local player = GetLocalClientPlayer()

	if ( !IsAlive( player ) )
		return false

	if ( IsWatchingKillReplay() )
		return false

	if ( GetGameState() != eGameState.Playing )
		return false

	return true
}

function SentryTurretPlacementNag()
{
	local player = GetLocalClientPlayer()

	if ( GetGameState() != eGameState.Playing )
		return

	player.EndSignal( "OnDestroy" )
	player.Signal( "SentryTurretPlacementNag_Stop" )
	player.EndSignal( "SentryTurretPlacementNag_Stop" )
	player.EndSignal( "DestroyTurretProjection" )

	local curInventory = level.sentryTurretInventory

	if ( CanInformPlayerAboutTurretUpdate() )
	{
		local parentEnt = player.GetParent()
		if ( IsValid( parentEnt ) )
		{
			local delay = 0
			if ( parentEnt.IsTitan() )
				delay = 2.5
			if ( parentEnt.IsDropship() )
				delay = 15.0
			wait delay
		}
	}

	local nags = 0
	// as long as the inventory hasn't changed - keep nagging
	while ( curInventory == level.sentryTurretInventory )
	{
		//wait first - don't nag immediately
		local waitTime = GraphCapped( nags++, 0, 4, 1, 3 ).tointeger() * 45
		wait waitTime

		if ( !CanInformPlayerAboutTurretUpdate() )
			continue

		if ( level.sentryTurretProjection != false )
			continue

		if ( level.petSentryTurrets >= COOP_SENTRY_TURRET_MAX_COUNT_PET )
			continue

		local cockpit = player.GetCockpit()
		if ( !IsValid( cockpit ) )
			continue

		PlayConversationToLocalClient( "CoopTD_TurretAvailableNag" )
		//EventNotification( eEventNotifications.TurretAvailable, null )
	}
}

function ButtonCallback_InitTurretPlacement( player )
{
	Assert( player == GetLocalClientPlayer() )

	if ( IsWatchingKillReplay() )
		return

	if ( !IsAlive( player ) || player.IsTitan() )
		return

	if ( level.sentryTurretInventory <= 0 )
		return

	if ( player.ContextAction_IsActive() )
		return

	if ( level.petSentryTurrets >= COOP_SENTRY_TURRET_MAX_COUNT_PET )
	{
		EventNotification( eEventNotifications.MaxTurretsPlaced, player )
		return
	}

	if ( level.sentryTurretProjection == true )
		return

	if ( level.sentryTurretProjection == false && player.IsWeaponDisabled() )
		return

	if ( player.GetCinematicEventFlags() & CE_FLAG_WAVE_SPAWNING )
		return

	local parentEnt = player.GetParent()
	if ( parentEnt != null )
		return

	level.sentryTurretProjection = true

	RegisterButtonPressedCallback( MOUSE_LEFT, ButtonCallback_PlaceTurret )
	RegisterButtonPressedCallback( BUTTON_TRIGGER_RIGHT, ButtonCallback_PlaceTurret )
	RegisterConCommandTriggeredCallback( "+weaponCycle", ButtonCallback_AbortTurretPlacement )
	RegisterConCommandTriggeredCallback( "+weaponPickupAndCycle", ButtonCallback_AbortTurretPlacement )
	RegisterConCommandTriggeredCallback( "+scriptCommand1", ButtonCallback_AbortTurretPlacement )

	// this will holster the weapon of the player on the server.
	player.ClientCommand( "InitSentryTurretPlacement" )

	thread ProjectTurret( player )
	thread TurretPlacementCleanupThread( player )
}

function TurretPlacementCleanupThread( player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ()
		{
			level.sentryTurretProjection = false

			DeregisterButtonPressedCallback( MOUSE_LEFT, ButtonCallback_PlaceTurret )
			DeregisterButtonPressedCallback( BUTTON_TRIGGER_RIGHT, ButtonCallback_PlaceTurret )
			DeregisterConCommandTriggeredCallback( "+weaponCycle", ButtonCallback_AbortTurretPlacement )
			DeregisterConCommandTriggeredCallback( "+weaponPickupAndCycle", ButtonCallback_AbortTurretPlacement )
			DeregisterConCommandTriggeredCallback( "+scriptCommand1", ButtonCallback_AbortTurretPlacement )

			TurretPlacementHintVisiblity( false )
			TurretPlacementHintInvalid( false )
		}
	)

	player.WaitSignal( "DestroyTurretProjection" )
}

function ButtonCallback_PlaceTurret( player )
{
	if ( !IsValid( player ) )
		return

	local result = CalculateTurretLocation( player, false )

	if ( result.success == false || level.sentryTurretHidden == true )
	{
		// play bleep sound or some such.
		EmitSoundOnEntity( player, "CoOp_SentryGun_DeploymentDeniedBeep" )
		return false
	}

	local origin = result.origin
	local angles = result.angles

	local commandString = format( "PlaceSentryTurret %d %d %d %d %d %d", origin.x.tointeger(), origin.y.tointeger(), origin.z.tointeger(), angles.x.tointeger(), angles.y.tointeger(), angles.z.tointeger() )

	player.ClientCommand( commandString )

	level.sentryTurretInventory = max( 0, level.sentryTurretInventory - 1 )

	local cockpit = player.GetCockpit()
	if ( IsValid( cockpit ) )
		UpdateEquipmentHud( cockpit, player )

	player.Signal( "DestroyTurretProjection" )
}

function ButtonCallback_AbortTurretPlacement( player )
{
	AbortTurretPlacement( player )
}

function AbortTurretPlacement( player )
{
	if ( IsWatchingKillReplay() )
		return

	if ( !IsValid( player ) )
		return

	player.ClientCommand( "AbortSentryTurret" )

	player.Signal( "DestroyTurretProjection" )
}

function ProjectTurret( player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "DestroyTurretProjection" )

	if ( IsWatchingKillReplay() )
		return

	local player = GetLocalClientPlayer()
	local turret = CreateClientSidePropDynamic( player.GetOrigin(), Vector( 0, 0, 0 ), SENTRY_TURRET_MODEL )
	turret.Hide()
	turret.EnableRenderAlways()
	turret.SetSkin( 2 )	// Not sure how to know that it's index 2.

	local origin, vector, offset, angles

	OnThreadEnd(
		function() : ( turret )
		{
			if ( IsValid( turret ) )
				turret.Destroy()
		}
	)

	local result = CalculateTurretLocation( player )

	while( true )
	{
		wait 0.016 // HACK - this is a test to see if it's worth putting more effort into. If placeable turrets isn't super fun we will scrap it.

		local onWall = player.IsWallRunning() || player.IsWallHanging()
		local onGround = player.IsOnGround()

		if ( player.ContextAction_IsActive() )
		{
			// player started to leech or hack a turret so we have to abort the placement of the turret.
			AbortTurretPlacement( player )
			return
		}

		if ( onWall || !onGround )
		{
			TurretPlacementHintVisiblity( false )
			TurretPlacementHintInvalid( false )
			level.sentryTurretHidden = true
			turret.Hide()
			continue
		}

		result = CalculateTurretLocation( player )

		level.sentryTurretHidden = false
		turret.Show()

		if ( result.success == true )
		{
			TurretPlacementHintVisiblity( true )
			TurretPlacementHintInvalid( false )
			turret.SetSkin( 2 )
		}
		else
		{
			turret.SetSkin( 3 )
			TurretPlacementHintVisiblity( false )
			TurretPlacementHintInvalid( true )
		}

		turret.SetOrigin( result.origin )
		turret.SetAngles( result.angles )
	}
}

function TurretPlacementHintVisiblity( show )
{
	if ( show == true )
	{
		level.turretPlacementHints.keyboard.Show()
		level.turretPlacementHints.gamepad.Show()
	}
	else
	{
		level.turretPlacementHints.keyboard.Hide()
		level.turretPlacementHints.gamepad.Hide()
	}
}

function TurretPlacementHintInvalid( show )
{
	if ( show == true )
	{
		level.turretPlacementHints.invalid.Show()
	}
	else
	{
		level.turretPlacementHints.invalid.Hide()
	}
}

function CalculateTurretLocation( player, newTrace = true )
{
	local vector = player.GetViewVector()
	vector.z = 0 // flatten the vector
	vector.Norm()
	local traceHeight = 64
	local traceOffsetZ = 32
	local offset = vector * 48 + Vector( 0,0, traceOffsetZ )
	local origin = player.GetOrigin() + offset
	local angles = Vector( 0, vector.GetAngles().y, 0 )

	local prevHullTraceID = file.turretHullTraceID
	local prevLineTraceID = file.turretLineTraceID

	// for next frame
	if ( newTrace == true )
	{
		file.turretHullTraceID = DeferredTraceHull( origin, origin + Vector( 0, 0, -traceHeight ), Vector( -20, -20, 0 ), Vector( 20, 20, 32 ), player, TRACE_MASK_SOLID | TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
		file.turretLineTraceID = DeferredTraceLine( origin, origin + Vector( 0, 0, -traceHeight ), player, TRACE_MASK_SOLID | TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
	}

	// use prev frame trace results
	if ( !IsDeferredTraceValid( prevHullTraceID ) || !IsDeferredTraceValid( prevLineTraceID ) )
		return { success = false, origin = origin, angles = angles }

	local result = GetDeferredTraceResult( prevHullTraceID )
	local lineResult = GetDeferredTraceResult( prevLineTraceID )
	local frac = lineResult.fraction

	local diff = abs( ( frac * traceHeight ) - ( result.fraction * traceHeight ) )
	local slope = fabs( result.surfaceNormal.x ) + fabs( result.surfaceNormal.y )


	local onEntity = false
	if ( IsValid( result.hitEnt ) )
	{
		local ent = result.hitEnt
		if ( !ent.IsWorld() )
			onEntity = true
	}

	local success = result.fraction < 1 && result.fraction > 0 && diff < 8 && slope < 0.6 && !result.startSolid && onEntity == false

	if ( success == true )
	{
		angles = AnglesOnSurface( result.surfaceNormal, vector )
		origin = origin - Vector( 0, 0, traceHeight * frac )
	}
	else
	{
		// remove the traceOffsetZ
		origin.z -= traceOffsetZ
	}

	return { success = success, origin = origin, angles = angles }
}

function GetSlope( angles )
{
	Assert( abs( angles.x ) <= 360 )
	Assert( abs( angles.z ) <= 360 )

	local x = abs( angles.x ) > 180 ? abs( angles.x - 360 ) : abs( angles.x )
	local z = abs( angles.z ) > 180 ? abs( angles.z - 360 ) : abs( angles.z )

	return ( x + z )
}

function ServerCallback_CoopMusicPlay( musicID, doForcedLoop = false )
{
	if ( doForcedLoop == true )
		thread ForceLoopMusic( musicID )
	else
		thread ForcePlayMusic( musicID )
}
Globalize( ServerCallback_CoopMusicPlay )


function CoopTD_TrySpectreRodeoWarning()
{
	if ( !TimerCheck( "Nag_SpectreRodeo" ) )
		return

	local voAlias = "CoopTD_SpectreRodeoWarning"
	if ( voAlias == level.lastRodeoWarningAlias )
		voAlias = "CoopTD_SpectreRodeoWarning_Short"

	PlayConversationToLocalClient( voAlias )
	level.lastRodeoWarningAlias = voAlias

	TimerReset( "Nag_SpectreRodeo" )
}
Globalize( CoopTD_TrySpectreRodeoWarning )

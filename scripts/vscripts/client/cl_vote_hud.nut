
function main()
{
	if ( IsLobby() )
		return

	RegisterServerVarChangeCallback( "playersVotingYes", 		HudCallback_PlayerVotedYes )
	RegisterServerVarChangeCallback( "playersVotingNo", 		HudCallback_PlayerVotedNo )

	level.voteAnnounceInProgress 			<- false
	level.voteAnnounce_queueProcessing  	<- false
	level.voteAnnounce_pageWaiting 		    <- false
	level.voteAnnounce_lastFocusStartTime 	<- -1
	level.voteAnnounce_cancelTime 			<- -1
	level.voteAnnounceQueue 				<- []
	level.voteAnnounceDisplayList 			<- []
	level.voteAnnounceCardStopTime 		    <- -1
	level.voteAnnounceList_lastUpdateTime 	<- -1
	level.lastVoteCardDisplayTime 			<- -1
	level.voteAnnounceHeaderCard 			<- null

	level.voteTypeID						<- -1
	level.voteCaller						<- null
	level.voteTarget						<- null
	level.voteYesNumberElement 				<- null
	level.voteNoNumberElement 				<- null

	RegisterConCommandTriggeredCallback( "+voteYes", ButtonCallback_VoteYes )
	RegisterConCommandTriggeredCallback( "+voteNo", ButtonCallback_VoteNo )

	AddCreateMainHudCallback( VoteHUD_CockpitCreatedCallback )
	AddCreatePilotCockpitCallback( VoteHUD_CockpitCreatedCallback )
	AddCreateTitanCockpitCallback( VoteHUD_CockpitCreatedCallback )

	Globalize( ServerCallback_NewVoteAnnounceCards )
	Globalize( ServerCallback_VoteEnded )
	Globalize( ServerCallback_EndCurrentVote )
}

function VoteHUD_CockpitCreatedCallback( cockpit, player )
{
	if ( VoteAnnounce_ShouldRedisplayOnCockpitCreated() )
		thread VoteAnnounce_RedisplayList( cockpit, player, 2.0 )
}

function VoteAnnounce_RedisplayList( cockpit, player, delay )
{
	player.EndSignal( "OnDestroy" )
	cockpit.EndSignal( "OnDestroy" )

	wait delay

	if ( !VoteAnnounce_ShouldRedisplayOnCockpitCreated() )
		return

	//printt( "Vote announce was in progress, restarting")

	// Move old display list back into queue before we reprocess it
	local newQueue = []
	foreach ( voteTypeID in level.voteAnnounceDisplayList )
		newQueue.append( voteTypeID )

	newQueue.extend( level.voteAnnounceQueue )

	level.voteAnnounceQueue = newQueue
	level.voteAnnounceDisplayList = []

	thread VoteAnnounce_ReprocessQueue()
}

function VoteAnnounce_ShouldRedisplayOnCockpitCreated()
{
	if ( GetGameState() == eGameState.Postmatch )
		return false

	if ( !level.voteAnnounceInProgress )
		return false

	// did they show long enough before the player/cockpit got destroyed?
	if ( level.voteAnnounce_cancelTime - level.voteAnnounce_lastFocusStartTime >= GetVoteDuration() * 0.8 )
		return false

	return true
}

function ServerCallback_NewVoteAnnounceCards( voteTypeID, caller = null, target = null )
{
	level.voteTypeID = voteTypeID
	level.voteCaller = caller
	level.voteTarget = target

	NewVoteAnnounce_AddToQueue( voteTypeID )
	if ( VoteTypeNeedsTarget( voteTypeID ) )
		NewVoteAnnounce_AddToQueue( eVoteType.voteTargetInfo )

	NewVoteAnnounce_AddToQueue( eVoteType.voteYes )
	NewVoteAnnounce_AddToQueue( eVoteType.voteNo )

	thread VoteAnnounce_ReprocessQueue()
}
Globalize( ServerCallback_NewVoteAnnounceCards )

function NewVoteAnnounce_AddToQueue( voteTypeID )
{
	Assert( typeof( voteTypeID ) == "integer" )

	ValidateVoteTypeIdx( voteTypeID )
	Assert( voteTypeID in level.voteAnnounceCardInfos, "Couldn't find announce card info for voteTypeID " + voteTypeID )

	level.voteAnnounceQueue.append( voteTypeID )
}

function NewVoteAnnounce_RemoveFromQueue( voteTypeID )
{
	ArrayRemove( level.voteAnnounceQueue, voteTypeID )
}

function VoteAnnounce_ReprocessQueue()
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

	if ( level.voteAnnounce_queueProcessing == true )
		return

	level.voteAnnounce_queueProcessing = true

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	cockpit.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : (  )
		{
			level.voteAnnounce_queueProcessing = false
		}
	)

	local tickInterval = 0.1
	local nextTick = Time()

	while ( level.voteAnnounceQueue.len() )
	{
		if ( nextTick > Time() )
			wait nextTick - Time()

		nextTick = Time() + tickInterval  // sets next tick time to default at first

		if ( level.voteAnnounce_pageWaiting == true )
			continue

		local totalCardsOnscreen = level.voteAnnounceDisplayList.len()

		// max cards onscreen
		if ( totalCardsOnscreen == COOP_NEWENEMY_ANNOUNCE_MAX_CARDS )
			continue

		local timeSinceLastCard = Time() - level.lastVoteCardDisplayTime

		// only header displaying, wait for that
		if ( totalCardsOnscreen == 0 && timeSinceLastCard < COOP_NEWENEMY_ANNOUNCE_HEADER_DELAY )
			continue
		// other cards are on the list, do that wait instead
		else if ( timeSinceLastCard < COOP_NEWENEMY_ANNOUNCE_CARD_ADD_DELAY )
			continue

		if ( level.voteAnnounceHeaderCard == null )
		{
			// if no cards onscreen first display header
			thread NewVoteAnnounce_DisplayHeader( player )

			// since we just started showing a card, we will have to wait at least this long before showing another
			local nextTick = Time() + COOP_NEWENEMY_ANNOUNCE_HEADER_DELAY
		}
		else
		{
			// display the next card
			local idx = 0
			local voteTypeID = level.voteAnnounceQueue[ idx ]
			local cardInfo = level.voteAnnounceCardInfos[ voteTypeID ]

			thread NewVoteAnnounce_DisplayCard( player, cardInfo )
			NewVoteAnnounce_RemoveFromQueue( voteTypeID )

			local nextTick = Time() + COOP_NEWENEMY_ANNOUNCE_CARD_ADD_DELAY
		}
	}
}

function NewVoteAnnounce_DisplayHeader( player )
{
	Assert( level.voteAnnounceHeaderCard == null )

	local player = GetLocalViewPlayer()

	local cardInfo = "HEADER"  // HACK
	thread NewVoteAnnounce_DisplayCard( player, cardInfo )
}

function VoteAnnounce_AddToDisplayList( voteTypeID )
{
	Assert( typeof( voteTypeID ) == "integer" )

	ValidateVoteTypeIdx( voteTypeID )
	Assert( voteTypeID in level.voteAnnounceCardInfos, "Couldn't find announce card info for voteTypeID " + voteTypeID )

	level.voteAnnounceDisplayList.append( voteTypeID )

	level.voteAnnounceList_lastUpdateTime = Time()
}

function VoteAnnounce_RemoveFromDisplayList( voteTypeID )
{
	ArrayRemove( level.voteAnnounceDisplayList, voteTypeID )

	level.voteAnnounceList_lastUpdateTime = Time()
}

function NewVoteAnnounce_DisplayCard( player, cardInfo )
{
	if ( player != GetLocalViewPlayer() )
		return

	local cockpit = player.GetCockpit()

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	cockpit.EndSignal( "OnDestroy" )

	level.ent.EndSignal( "EndVote" )

	level.lastVoteCardDisplayTime = Time()  // the header should set this as well

	local listIdx = 0
	local pageEndingCard = false

	if ( cardInfo != "HEADER" && cardInfo != "FOOTER" )
	{
		listIdx = level.voteAnnounceDisplayList.len()
		VoteAnnounce_AddToDisplayList( cardInfo.voteTypeIdx )

		// page wait starts when the final list item is created and stops processing when the first list item is deleted
		if ( listIdx == 0 )
			pageEndingCard = true
		else if ( listIdx == COOP_NEWENEMY_ANNOUNCE_MAX_CARDS - 1 )
			level.voteAnnounce_pageWaiting = true
	}

	if ( level.voteAnnounceInProgress == false )
		level.voteAnnounceInProgress = true

	local vguis = []

	OnThreadEnd(
		function () : ( vguis, player, cardInfo, pageEndingCard )
		{
			if ( cardInfo == "HEADER" )
			{
				if ( level.voteAnnounceHeaderCard != null )
					level.voteAnnounceHeaderCard = null
			}
			else
			{
				if ( pageEndingCard == true && level.voteAnnounce_pageWaiting == true )
					level.voteAnnounce_pageWaiting = false

				if ( level.voteAnnounceInProgress == true && level.voteAnnounceDisplayList.len() + level.voteAnnounceQueue.len() <= 0 )
					level.voteAnnounceInProgress = false
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

	local focusTime = GetVoteDuration()
	local moveTime = COOP_NEWENEMY_ANNOUNCE_CARD_MOVE_TIME

	level.voteAnnounceCardStopTime = Time() + moveTime + focusTime

	local cardDisplayInfo = NewVoteAnnounce_GetCardDisplayInfo( player, cardInfo, listIdx )
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

	local announceCard = VoteAnnounce_CreateCard( vgui, cardInfo )
	VoteAnnounce_SetCard( announceCard, cardInfo )

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

	level.voteAnnounce_lastFocusStartTime = Time()

	// CARD WAITS ONSCREEN

	local cardStopFocusTime = GetCardStopFocusTime( listIdx, cardInfo )
	local lastListUpdateCheck = Time()

	while ( 1 )
	{
		if ( Time() < cardStopFocusTime )
			wait cardStopFocusTime - Time()

		if ( lastListUpdateCheck < level.voteAnnounceList_lastUpdateTime )
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
		VoteAnnounce_RemoveFromDisplayList( cardInfo.voteTypeIdx )

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

	local distFromListBottom = level.voteAnnounceDisplayList.len() - listIdx

	local cardStopFocusTime = level.voteAnnounceCardStopTime + (removeDelay.tofloat() * distFromListBottom.tofloat()) + COOP_NEWENEMY_ANNOUNCE_CARD_MOVE_TIME

	if ( cardInfo == "HEADER" )
	{
		if ( level.voteAnnounceQueue.len() > 0 )
			cardStopFocusTime += COOP_NEWENEMY_ANNOUNCE_CARD_ADD_DELAY  // if card(s) are in the queue, keep header up long enough for first queued card to start to display
		else
			cardStopFocusTime += removeDelay  // add another delay so header slides off after the final vote card
	}

	return cardStopFocusTime
}

function NewVoteAnnounce_GetCardDisplayInfo( player, cardInfo, listIdx = -1 )
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

	Assert( listIdx != -1 )

	local upOrgScalar = cardstart_upOrgScalar

	if ( cardInfo == "HEADER" )
	{
		upOrgScalar = header_upOrgScalar
	}
	else if ( listIdx != 0 )  // normal card or footer
	{
		upOrgScalar = cardstart_upOrgScalar - ( listIdx * scaledHeight )
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

function VoteAnnounce_CreateCard( previewPanel, cardInfo )
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

	local table = {}
	local panel = previewPanel.GetPanel()
	foreach ( name in allCardElems )
		table[ name ] <- HudElement( name, panel )

	table.vgui <- previewPanel

	return table
}

// this needs to be done AFTER the vgui has been initialized
function VoteAnnounceCard_HideInactiveElems( previewCardTable, cardInfo )
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

	local activeElems, inactiveElems

	if ( cardInfo == "HEADER" )
	{
		activeElems = headerElems
		inactiveElems = normalElems
	}
	else
	{
		activeElems = normalElems
		inactiveElems = headerElems
	}

	foreach ( name in inactiveElems )
		previewCardTable[ name ].Hide()

	foreach ( name in activeElems )
		previewCardTable[ name ].Show()
}

function VoteAnnounce_SetCard( previewCardTable, cardInfo )
{
	previewCardTable.vgui.Show()
	foreach ( element in previewCardTable )
	{
		element.Show()
		element.SetAlpha( 255 )
	}

	if ( cardInfo == "HEADER" )
		VoteAnnounce_SetHeaderCard( previewCardTable, cardInfo )
	else
		VoteAnnounce_SetVoteCard( previewCardTable, cardInfo )

	VoteAnnounceCard_HideInactiveElems( previewCardTable, cardInfo )
}

function VoteAnnounce_SetHeaderCard( previewCardTable, cardInfo )
{
	Assert ( cardInfo == "HEADER" )

	level.voteAnnounceHeaderCard = previewCardTable
	VoteAnnounce_UpdateHeaderText()
}

function VoteAnnounce_UpdateHeaderText()
{
	if ( !IsValid( level.voteAnnounceHeaderCard ) )
		return

	local name = Localize( "#SERVER" )
	local voteCaller = level.voteCaller
	if ( voteCaller )
		name = GetEntityFromEncodedEHandle( level.voteCaller ).GetPlayerName()

	local title = format( Localize( "#VOTE_HEADER" ), name )

	local titleElem = level.voteAnnounceHeaderCard.PreviewCard_HeaderTitle
	titleElem.SetText( title )
	titleElem.SetSize( 1024, titleElem.GetBaseHeight() )
}

function VoteAnnounce_SetVoteCard( previewCardTable, cardInfo )
{
	local icon 			= cardInfo.icon
	local title 		= cardInfo.title
	local desc 			= cardInfo.description

	//local numEnemies = 0
	//local numEnemies = ""

	local numEnemies = ""
	if ( cardInfo.voteTypeIdx == eVoteType.voteYes )
	{
		level.voteYesNumberElement = previewCardTable.PreviewCard_numEnemies
		numEnemies = level.nv.playersVotingYes.tostring()
	}
	else if ( cardInfo.voteTypeIdx == eVoteType.voteNo )
	{
		level.voteNoNumberElement = previewCardTable.PreviewCard_numEnemies
		numEnemies = level.nv.playersVotingNo.tostring()
	}

	previewCardTable.PreviewCard_numEnemies.SetText( numEnemies )

	previewCardTable.PreviewCard_icon1.SetImage( icon )
	previewCardTable.PreviewCard_title.SetText( title )
	previewCardTable.PreviewCard_description.SetText( desc )
	previewCardTable.PreviewCard_description.EnableKeyBindingIcons()

	if ( cardInfo.voteTypeIdx == eVoteType.voteTargetInfo )
	{
		desc = GetVoteTargetInfo( level.voteTypeID, level.voteTarget )
		printt( desc )
		previewCardTable.PreviewCard_description.SetText( desc )
	}

	local displayColor = { r = 157, g = 196, b = 219 }
	previewCardTable.PreviewCard_title.SetColor( displayColor.r, displayColor.g, displayColor.b )

	VoteAnnounce_UpdateHeaderText()
}

function ServerCallback_VoteEnded( choice, success )
{
	local player = GetLocalViewPlayer()
	local elem = level.voteAnnounceHeaderCard.PreviewCard_HeaderTitle

	if ( !success )
	{
		EmitSoundOnEntity( player, "Menu.Deny" )
		elem.SetText( "#VOTE_FAILED" )
		elem.SetColor( 255, 0, 0, 255 )
		return
	}

	EmitSoundOnEntity( player, "Vote_Success" )
	elem.SetText( "#VOTE_PASSED" )
	elem.SetColor( 0, 255, 0, 255 )

	switch ( choice )
	{
	}
}

function ServerCallback_EndCurrentVote()
{
	level.ent.Signal( "EndVote"  )
}

function HudCallback_PlayerVotedYes()
{
	if ( !IsVoteInProgress() )
		return

	local votes = level.nv.playersVotingYes
	if ( votes == 0 )
		return

	//if ( !IsValid( level.voteYesNumberElement ) )
	//	return

	level.voteYesNumberElement.SetText( votes.tostring() )
	EmitSoundOnEntity( GetLocalViewPlayer(), "Menu.Back" )
}

function HudCallback_PlayerVotedNo()
{
	if ( !IsVoteInProgress() )
		return

	local votes = level.nv.playersVotingNo
	if ( votes == 0 )
		return

	//if ( !IsValid( level.voteNoNumberElement ) )
	//	return

	level.voteNoNumberElement.SetText( votes.tostring() )
	EmitSoundOnEntity( GetLocalViewPlayer(), "Menu.Back" )
}

////////////////////////////////////////////////////////////////////////////////////

function ButtonCallback_VoteYes( player )
{
	ButtonCallback_PressedVote( player, 1 )
}

function ButtonCallback_VoteNo( player )
{
	ButtonCallback_PressedVote( player, 0 )
}

function ButtonCallback_PressedVote( player, index )
{
	if ( !PlayerCanVote( player ) )
		return

	EmitSoundOnEntity( player, "Menu.Accept" )
	player.ClientCommand( "VoteOption " + index )
}

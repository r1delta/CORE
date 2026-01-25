
const XP_BAR_FILL_DURATION	= 3.0
const XP_BAR_FILL_TIME_MIN = 0.3
const NUM_XP_BREAKDOWN_LINES = 9
const NUM_XP_SUBCAT_LINES = 14

menu <- null
buttonsRegistered <- false
buttonEventsRegistered <- false

startXP <- null
endXP <- null
newXP <- null
xpBarCurrentLevel <- null

menuAnimDone <- false

//#############################
// Hud elems
//#############################

pilotImage <- null

xpEarnedBreakdownButtons <- []
xpEarnedTotalDesc <- null
xpEarnedTotal <- null
xpEarnedTotalVal <- 0
level.matchXPByType <- {}
level.matchXPCountByType <- {}
matchXPByCategory <- {}
subCatNameLabels <- []
subCatValueLabels <- []

xpBarPanels <- []
activeXPBar <- 0
nextXPBar <- 1

//#############################

level.xpTypeDescriptions <- {}
level.xpTypeDescriptions[ XP_TYPE.PILOT_KILL ]					<- "#EOG_XPTYPE_PILOT_KILLS"
level.xpTypeDescriptions[ XP_TYPE.NPC_KILL ]					<- "#EOG_XPTYPE_NPC_KILLS"
level.xpTypeDescriptions[ XP_TYPE.AUTO_TITAN_KILL ]				<- "#EOG_XPTYPE_AUTO_TITAN_KILLS"
level.xpTypeDescriptions[ XP_TYPE.TITAN_KILL ]					<- "#EOG_XPTYPE_TITAN_KILLS"
level.xpTypeDescriptions[ XP_TYPE.PILOT_ASSIST ]				<- "#EOG_XPTYPE_PILOT_ASSISTS"
level.xpTypeDescriptions[ XP_TYPE.TITAN_ASSIST ]				<- "#EOG_XPTYPE_TITAN_ASSISTS"
level.xpTypeDescriptions[ XP_TYPE.SPECIAL ]						<- "#EOG_XPTYPE_SPECIAL"
level.xpTypeDescriptions[ XP_TYPE.ACCURACY ]					<- "#EOG_XPTYPE_ACCURACY"
level.xpTypeDescriptions[ XP_TYPE.BURNCARD_USED ]				<- "#EOG_XPTYPE_BURNCARD_USED"
level.xpTypeDescriptions[ XP_TYPE.BURNCARD_STOPPED ]			<- "#EOG_XPTYPE_BURNCARD_STOPPED"
level.xpTypeDescriptions[ XP_TYPE.BURNCARD_XP ]					<- "#EOG_XPTYPE_BURNCARD_XP"
level.xpTypeDescriptions[ XP_TYPE.BURNCARD_EARNED ]				<- "#EOG_XPTYPE_BURNCARD_EARNED"
level.xpTypeDescriptions[ XP_TYPE.MATCH_VICTORY ]				<- "#EOG_XPTYPE_MATCH_VICTORY"
level.xpTypeDescriptions[ XP_TYPE.MATCH_COMPLETED ]				<- "#EOG_XPTYPE_MATCH_COMPLETED"
level.xpTypeDescriptions[ XP_TYPE.ROUND_WIN ]					<- "#EOG_XPTYPE_ROUND_WIN"
level.xpTypeDescriptions[ XP_TYPE.ROUND_COMPLETE ]				<- "#EOG_XPTYPE_ROUND_COMPLETED"
level.xpTypeDescriptions[ XP_TYPE.NEW_PLAYER_BONUS ]			<- "#EOG_XPTYPE_NEW_PLAYER_BONUS"
level.xpTypeDescriptions[ XP_TYPE.CHALLENGE ]					<- "#EOG_XPTYPE_CHALLENGES"
level.xpTypeDescriptions[ XP_TYPE.HARDPOINT_CAPTURE ]			<- "#EOG_XPTYPE_HARDPOINT_CAPTURE"
level.xpTypeDescriptions[ XP_TYPE.HARDPOINT_ASSIST ]			<- "#EOG_XPTYPE_HARDPOINT_ASSIST"
level.xpTypeDescriptions[ XP_TYPE.HARDPOINT_NEUTRALIZE ]		<- "#EOG_XPTYPE_HARDPOINT_NEUTRALIZE"
level.xpTypeDescriptions[ XP_TYPE.HARDPOINT_KILL ]				<- "#EOG_XPTYPE_HARDPOINT_KILL"
level.xpTypeDescriptions[ XP_TYPE.HARDPOINT_DEFEND ]			<- "#EOG_XPTYPE_HARDPOINT_DEFEND"
level.xpTypeDescriptions[ XP_TYPE.HARDPOINT_DEFEND_KILL ]		<- "#EOG_XPTYPE_HARDPOINT_DEFEND_KILL"
level.xpTypeDescriptions[ XP_TYPE.HACKING ] 					<- "#EOG_XPTYPE_HACKING"
level.xpTypeDescriptions[ XP_TYPE.FIRST_STRIKE ] 				<- "#EOG_XPTYPE_FIRST_STRIKE"
level.xpTypeDescriptions[ XP_TYPE.KILL_STREAK ] 				<- "#EOG_XPTYPE_KILL_STREAK"
level.xpTypeDescriptions[ XP_TYPE.REVENGE ] 					<- "#EOG_XPTYPE_REVENGE"
level.xpTypeDescriptions[ XP_TYPE.SHOWSTOPPER ] 				<- "#EOG_XPTYPE_SHOWSTOPPER"
level.xpTypeDescriptions[ XP_TYPE.EJECT_KILL ] 					<- "#EOG_XPTYPE_EJECT_KILL"
level.xpTypeDescriptions[ XP_TYPE.VICTORY_KILL ] 				<- "#EOG_XPTYPE_VICTORY_KILL"
level.xpTypeDescriptions[ XP_TYPE.NEMESIS ] 					<- "#EOG_XPTYPE_NEMESIS"
level.xpTypeDescriptions[ XP_TYPE.COMEBACK_KILL ] 				<- "#EOG_XPTYPE_COMEBACK_KILL"
level.xpTypeDescriptions[ XP_TYPE.RODEO_RAKE ] 					<- "#EOG_XPTYPE_RODEO_RAKE"
level.xpTypeDescriptions[ XP_TYPE.DESTROYED_EXPLOSIVES ] 		<- "#EOG_XPTYPE_DESTROYED_EXPLOSIVES"
level.xpTypeDescriptions[ XP_TYPE.TITANFALL ] 					<- "#EOG_XPTYPE_TITANFALL"
level.xpTypeDescriptions[ XP_TYPE.RODEO_RIDE ] 					<- "#EOG_XPTYPE_RODEO_RIDE"
level.xpTypeDescriptions[ XP_TYPE.DROPSHIP_KILL ]				<- "#EOG_XPTYPE_DROPSHIP_KILL"
level.xpTypeDescriptions[ XP_TYPE.EPILOGUE_GET_TO_CHOPPER ]		<- "#EOG_XPTYPE_EPILOGUE_GET_TO_CHOPPER"
level.xpTypeDescriptions[ XP_TYPE.EPILOGUE_EVAC ]				<- "#EOG_XPTYPE_EPILOGUE_EVAC"
level.xpTypeDescriptions[ XP_TYPE.EPILOGUE_SOLE_SURVIVOR ]		<- "#EOG_XPTYPE_EPILOGUE_SOLE_SURVIVOR"
level.xpTypeDescriptions[ XP_TYPE.EPILOGUE_FULL_TEAM_EVAC ]		<- "#EOG_XPTYPE_EPILOGUE_FULL_TEAM_EVAC"
level.xpTypeDescriptions[ XP_TYPE.EPILOGUE_KILL ]				<- "#EOG_XPTYPE_EPILOGUE_KILL"
level.xpTypeDescriptions[ XP_TYPE.EPILOGUE_KILL_ALL ]			<- "#EOG_XPTYPE_EPILOGUE_KILL_ALL"
level.xpTypeDescriptions[ XP_TYPE.EPILOGUE_KILL_SHIP ]			<- "#EOG_XPTYPE_EPILOGUE_KILL_SHIP"
level.xpTypeDescriptions[ XP_TYPE.CTF_FLAG_CAPTURE ]			<- "#EOG_XPTYPE_CTF_FLAG_CAPTURE"
level.xpTypeDescriptions[ XP_TYPE.CTF_FLAG_RETURN ]				<- "#EOG_XPTYPE_CTF_FLAG_RETURN"
level.xpTypeDescriptions[ XP_TYPE.CTF_FLAG_CARRIER_KILL ]		<- "#EOG_XPTYPE_CTF_FLAG_CARRIER_KILL"

xpCategoryDescriptions <- {}
xpCategoryDescriptions[ XP_TYPE_CATEGORY.KILLS ]			<- "#EOG_XPTYPE_CATEGORY_KILLS"
xpCategoryDescriptions[ XP_TYPE_CATEGORY.ASSISTS ]			<- "#EOG_XPTYPE_CATEGORY_ASSISTS"
xpCategoryDescriptions[ XP_TYPE_CATEGORY.EPILOGUE ]			<- "#EOG_XPTYPE_CATEGORY_EPILOGUE"
xpCategoryDescriptions[ XP_TYPE_CATEGORY.GAMEMODE ]			<- "#EOG_XPTYPE_CATEGORY_GAMEMODE"
xpCategoryDescriptions[ XP_TYPE_CATEGORY.CHALLENGES ]		<- "#EOG_XPTYPE_CATEGORY_CHALLENGES"
xpCategoryDescriptions[ XP_TYPE_CATEGORY.BURNCARDS ]		<- "#EOG_XPTYPE_CATEGORY_BURNCARDS"
xpCategoryDescriptions[ XP_TYPE_CATEGORY.SPECIAL ]			<- "#EOG_XPTYPE_CATEGORY_SPECIAL"

level.xpCategory <- {}
level.xpCategory[ XP_TYPE.PILOT_KILL ]						<- XP_TYPE_CATEGORY.KILLS
level.xpCategory[ XP_TYPE.TITAN_KILL ]						<- XP_TYPE_CATEGORY.KILLS
level.xpCategory[ XP_TYPE.NPC_KILL ]						<- XP_TYPE_CATEGORY.KILLS
level.xpCategory[ XP_TYPE.AUTO_TITAN_KILL ]					<- XP_TYPE_CATEGORY.KILLS
level.xpCategory[ XP_TYPE.REVENGE ] 						<- XP_TYPE_CATEGORY.KILLS
level.xpCategory[ XP_TYPE.EJECT_KILL ] 						<- XP_TYPE_CATEGORY.KILLS
level.xpCategory[ XP_TYPE.VICTORY_KILL ] 					<- XP_TYPE_CATEGORY.KILLS
level.xpCategory[ XP_TYPE.NEMESIS ] 						<- XP_TYPE_CATEGORY.KILLS
level.xpCategory[ XP_TYPE.COMEBACK_KILL ] 					<- XP_TYPE_CATEGORY.KILLS
level.xpCategory[ XP_TYPE.DROPSHIP_KILL ] 					<- XP_TYPE_CATEGORY.KILLS
level.xpCategory[ XP_TYPE.PILOT_ASSIST ]					<- XP_TYPE_CATEGORY.ASSISTS
level.xpCategory[ XP_TYPE.TITAN_ASSIST ]					<- XP_TYPE_CATEGORY.ASSISTS
level.xpCategory[ XP_TYPE.SPECIAL ]							<- XP_TYPE_CATEGORY.SPECIAL
level.xpCategory[ XP_TYPE.ACCURACY ]						<- XP_TYPE_CATEGORY.SPECIAL
level.xpCategory[ XP_TYPE.HACKING ] 						<- XP_TYPE_CATEGORY.SPECIAL
level.xpCategory[ XP_TYPE.FIRST_STRIKE ] 					<- XP_TYPE_CATEGORY.SPECIAL
level.xpCategory[ XP_TYPE.KILL_STREAK ] 					<- XP_TYPE_CATEGORY.SPECIAL
level.xpCategory[ XP_TYPE.SHOWSTOPPER ] 					<- XP_TYPE_CATEGORY.SPECIAL
level.xpCategory[ XP_TYPE.RODEO_RAKE ] 						<- XP_TYPE_CATEGORY.SPECIAL
level.xpCategory[ XP_TYPE.RODEO_RIDE ] 						<- XP_TYPE_CATEGORY.SPECIAL
level.xpCategory[ XP_TYPE.DESTROYED_EXPLOSIVES ] 			<- XP_TYPE_CATEGORY.SPECIAL
level.xpCategory[ XP_TYPE.TITANFALL ] 						<- XP_TYPE_CATEGORY.SPECIAL
level.xpCategory[ XP_TYPE.BURNCARD_USED ]					<- XP_TYPE_CATEGORY.BURNCARDS
level.xpCategory[ XP_TYPE.BURNCARD_STOPPED ]				<- XP_TYPE_CATEGORY.BURNCARDS
level.xpCategory[ XP_TYPE.BURNCARD_XP ]						<- XP_TYPE_CATEGORY.BURNCARDS
level.xpCategory[ XP_TYPE.BURNCARD_EARNED ]					<- XP_TYPE_CATEGORY.BURNCARDS
level.xpCategory[ XP_TYPE.EPILOGUE_GET_TO_CHOPPER ]			<- XP_TYPE_CATEGORY.EPILOGUE
level.xpCategory[ XP_TYPE.EPILOGUE_EVAC ]					<- XP_TYPE_CATEGORY.EPILOGUE
level.xpCategory[ XP_TYPE.EPILOGUE_SOLE_SURVIVOR ]			<- XP_TYPE_CATEGORY.EPILOGUE
level.xpCategory[ XP_TYPE.EPILOGUE_FULL_TEAM_EVAC ]			<- XP_TYPE_CATEGORY.EPILOGUE
level.xpCategory[ XP_TYPE.EPILOGUE_KILL ]					<- XP_TYPE_CATEGORY.EPILOGUE
level.xpCategory[ XP_TYPE.EPILOGUE_KILL_ALL ]				<- XP_TYPE_CATEGORY.EPILOGUE
level.xpCategory[ XP_TYPE.EPILOGUE_KILL_SHIP ]				<- XP_TYPE_CATEGORY.EPILOGUE
level.xpCategory[ XP_TYPE.CHALLENGE ]						<- XP_TYPE_CATEGORY.CHALLENGES
level.xpCategory[ XP_TYPE.NEW_PLAYER_BONUS ]				<- XP_TYPE_CATEGORY.GAMEMODE
level.xpCategory[ XP_TYPE.MATCH_VICTORY ]					<- XP_TYPE_CATEGORY.GAMEMODE
level.xpCategory[ XP_TYPE.MATCH_COMPLETED ]					<- XP_TYPE_CATEGORY.GAMEMODE
level.xpCategory[ XP_TYPE.ROUND_WIN ]						<- XP_TYPE_CATEGORY.GAMEMODE
level.xpCategory[ XP_TYPE.ROUND_COMPLETE ]					<- XP_TYPE_CATEGORY.GAMEMODE
level.xpCategory[ XP_TYPE.HARDPOINT_CAPTURE ]				<- XP_TYPE_CATEGORY.GAMEMODE
level.xpCategory[ XP_TYPE.HARDPOINT_ASSIST ]				<- XP_TYPE_CATEGORY.GAMEMODE
level.xpCategory[ XP_TYPE.HARDPOINT_NEUTRALIZE ]			<- XP_TYPE_CATEGORY.GAMEMODE
level.xpCategory[ XP_TYPE.HARDPOINT_KILL ]					<- XP_TYPE_CATEGORY.GAMEMODE
level.xpCategory[ XP_TYPE.HARDPOINT_DEFEND ]				<- XP_TYPE_CATEGORY.GAMEMODE
level.xpCategory[ XP_TYPE.HARDPOINT_DEFEND_KILL ]			<- XP_TYPE_CATEGORY.GAMEMODE
level.xpCategory[ XP_TYPE.CTF_FLAG_CAPTURE ]				<- XP_TYPE_CATEGORY.GAMEMODE
level.xpCategory[ XP_TYPE.CTF_FLAG_RETURN ]					<- XP_TYPE_CATEGORY.GAMEMODE
level.xpCategory[ XP_TYPE.CTF_FLAG_CARRIER_KILL ]			<- XP_TYPE_CATEGORY.GAMEMODE

RegisterSignal( "ElemFlash" )
RegisterSignal( "LevelUpMessage" )
RegisterSignal( "XPBarChanging" )

function main()
{
	Globalize( OnOpenEOG_XP )
	Globalize( OnCloseEOG_XP )
}

function InitMenu()
{
	Assert( menu != null )

	// Buttons & Background
	SetupEOGMenuCommon( menu )

	// Pilot image
	pilotImage = GetElem( menu, "PilotImage" )
	if ( IsConnected() && GetTeam() == TEAM_IMC )
		pilotImage.SetImage( "../ui/menu/loadouts/pilot_character_male_battle_rifle_imc" )
	else
		pilotImage.SetImage( "../ui/menu/loadouts/pilot_character_male_battle_rifle_militia" )

	// XP earned elems
	for( local i = 0 ; i < NUM_XP_BREAKDOWN_LINES ; i++ )
	{
		local button = GetElem( menu, "BtnXPEarned" + i )
		xpEarnedBreakdownButtons.append( button )
		if ( !buttonEventsRegistered )
		{
			button.AddEventHandler( UIE_GET_FOCUS, Bind(BreakdownButton_Get_Focus) )
			button.AddEventHandler( UIE_LOSE_FOCUS, Bind(BreakdownButton_Lose_Focus) )
		}
	}
	buttonEventsRegistered = true

	xpEarnedTotalDesc 	= GetElem( menu, "XPEarned_TotalDesc" )
	xpEarnedTotal		= GetElem( menu, "XPEarned_TotalValue" )

	// XP Earned Category Breakdown elems
	for( local i = 0 ; i < NUM_XP_SUBCAT_LINES ; i++ )
	{
		local label = GetElem( menu, "SubCatDesc" + i )
		label.Hide()
		subCatNameLabels.append( label )

		label = GetElem( menu, "SubCatValue" + i )
		label.Hide()
		subCatValueLabels.append( label )
	}

	// XP bar panels
	for ( local i = 0 ; i < 2 ; i++ )
	{
		local panel = GetElem( menu, "XPBarPanel" + i )
		Assert( panel != null )

		panel.s.BarFillNew		<- panel.GetChild( "BarFillNew" )
		Assert( panel.s.BarFillNew != null )

		panel.s.BarFillNewColor	<- panel.GetChild( "BarFillNewColor" )
		Assert( panel.s.BarFillNewColor != null )

		panel.s.BarFillPrevious	<- panel.GetChild( "BarFillPrevious" )
		Assert( panel.s.BarFillPrevious != null )

		panel.s.BarFillShadow	<- panel.GetChild( "BarFillShadow" )
		Assert( panel.s.BarFillShadow != null )

		panel.s.BarFillFlash	<- panel.GetChild( "BarFillFlash" )
		Assert( panel.s.BarFillFlash != null )
		panel.s.BarFillFlash.SetAlpha( 0 )

		panel.s.BarFlare	<- panel.GetChild( "BarFlare" )
		Assert( panel.s.BarFlare != null )
		//panel.s.BarFlare.SetAlpha( 0 )

		panel.s.level			<- panel.GetChild( "LevelText" )
		Assert( panel.s.level != null )

		panel.s.xpCount			<- panel.GetChild( "XPText" )
		Assert( panel.s.xpCount != null )

		// Gen Icon
		local genIcon = panel.GetChild( "GenIcon" )
		Assert( genIcon != null )
		genIcon.SetImage( "../ui/menu/generation_icons/generation_" + GetGen() )
		genIcon.Show()

		xpBarPanels.append( panel )
	}

	xpBarPanels[0].SetPanelAlpha(255)
	xpBarPanels[1].SetPanelAlpha(0)
}

function OnOpenEOG_XP()
{
	menu = GetMenu( "EOG_XP" )
	level.currentEOGMenu = menu
	Signal( menu, "StopMenuAnimation" )
	EndSignal( menu, "StopMenuAnimation" )
	Signal( level, "CancelEOGThreadedNavigation" )

	//-----------------------------------------------------
	// Clear previous unlocks/progress
	//-----------------------------------------------------

	ClearEOGData()

	if ( !IsFullyConnected() && uiGlobal.activeMenu == menu )
	{
		thread CloseTopMenu()
		return
	}

	//-----------------------------------------------------
	// We also get unlock and challenge info now, so we
	// can disable those menus if there is nothing to show
	//-----------------------------------------------------

	//printt( "Calculating EOG XP" )
	GetXPEarned()
	//printt( "Calculating EOG Challenge Progress" )
	GetEOGChallenges()
	//printt( "Calculating EOG Unlocks" )
	GetEOGUnlockedItems()

	//-----------------------------------------------------

	InitMenu()
	ResetMenu()

	thread OpenMenuAnimated()

	EOGOpenGlobal()

	wait 0
	if ( !buttonsRegistered )
	{
		RegisterButtonPressedCallback( BUTTON_A, OpenMenuStatic )
		RegisterButtonPressedCallback( KEY_SPACE, OpenMenuStatic )
		buttonsRegistered = true
	}

	if ( !level.doEOGAnimsXP )
		OpenMenuStatic(false)
}

function OnCloseEOG_XP()
{
	thread EOGCloseGlobal()

	if ( buttonsRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_A, OpenMenuStatic )
		DeregisterButtonPressedCallback( KEY_SPACE, OpenMenuStatic )
		buttonsRegistered = false
	}

	level.doEOGAnimsXP = false
	menuAnimDone = false
	Signal( menu, "StopMenuAnimation" )
}

function OpenMenuAnimated()
{
	EndSignal( menu, "StopMenuAnimation" )

	if ( level.doEOGAnimsXP )
		EmitUISound( "Menu_GameSummary_ScreenSlideIn" )
	else
		EmitUISound( "EOGSummary.XPBreakdownPopup" )

	// Slide in XP Bar
	if ( EOGIsPrivateMatch() )
	{
		activeXPBar.Hide()
		nextXPBar.Hide()
	}
	else
	{
		activeXPBar.Show()
		nextXPBar.Show()
		thread FancyLabelFadeIn( menu, activeXPBar, 0, 300, false, 0.15, true )
	}

	// Slide in pilot image
	thread FancyLabelFadeIn( menu, pilotImage, 300, 0, false )

	// Show XP Earned breakdown and bar fill
	waitthread ShowXPEarned()

	if ( level.doEOGAnimsXP && uiGlobal.EOGAutoAdvance )
		thread EOGNavigateRight( null, true )
}

function OpenMenuStatic( userInitiated = true )
{
	if ( menuAnimDone && userInitiated )
		thread EOGNavigateRight( null )
	else
		Signal( menu, "StopMenuAnimation" )
}

function ResetMenu()
{
	// Reset XP Bar positions
	foreach( panel in xpBarPanels )
		panel.ReturnToBasePos()

	xpBarCurrentLevel = null
	activeXPBar = xpBarPanels[0]
	nextXPBar = xpBarPanels[1]

	SetXPBarXP( startXP )

	foreach( button in xpEarnedBreakdownButtons )
	{
		button.SetEnabled( false )
		button.Hide()
	}

	xpEarnedTotalDesc.Hide()
	xpEarnedTotal.Hide()
}

function GetXPEarned()
{
	// Update XP vars, they may have changed
	startXP = GetPersistentVar( "previousXP" )
	endXP = GetPersistentVar( "xp" )

	newXP = null
	if ( level.EOG_DEBUG )
		newXP = RandomInt( 5000, 15000 )

	// Get how much XP we earned for each type last round

	for( local i = 0 ; i < XP_TYPE_CATEGORY._NUM_CATEGORIES ; i++ )
		matchXPByCategory[i] <- 0

	xpEarnedTotalVal = 0
	for( local i = 0 ; i < XP_TYPE._NUM_TYPES ; i++ )
	{
		level.matchXPByType[ i ] <- GetPersistentVar( "xp_match[" + i + "]" )
		level.matchXPCountByType[ i ] <- GetPersistentVar( "xp_match_count[" + i + "]")
		if ( level.EOG_DEBUG )
		{
			level.matchXPByType[ i ] = RandomInt( 50, 1500 )
			level.matchXPCountByType[ i ] = RandomInt( 1, 20 )
		}
		xpEarnedTotalVal += level.matchXPByType[ i ]

		local category = level.xpCategory[ i ]
		matchXPByCategory[ category ] += level.matchXPByType[ i ]
	}

	if ( !level.EOG_DEBUG )
		newXP = xpEarnedTotalVal//max( xpEarnedTotalVal, endXP - startXP )
	Assert( newXP != null )

	// Any unaccounted for XP goes towards SPECIAL. This can happen during development when we are forcing levels
	if ( !level.EOG_DEBUG && xpEarnedTotalVal != newXP )
	{
		local unaccountedXP = newXP - xpEarnedTotalVal
		level.matchXPByType[ XP_TYPE.SPECIAL ] += unaccountedXP
		xpEarnedTotalVal += unaccountedXP

		local category = level.xpCategory[ XP_TYPE.SPECIAL ]
		matchXPByCategory[ category ] += unaccountedXP

		printt( "############################################################" )
		printt( "UNACCOUNTED XP:", unaccountedXP, "ADDING IT TO SPECIAL TYPE." )
		printt( "############################################################" )
	}
}

function ShowXPEarned()
{
	EndSignal( menu, "StopMenuAnimation" )

	SetXPBarXP( startXP )

	OnThreadEnd(
		function() : ()
		{
			if ( IsFullyConnected() && !EOGIsPrivateMatch() )
				SetXPBarXP( endXP )
			menuAnimDone = true
		}
	)

	if ( !IsFullyConnected() )
		return

	if ( newXP > 0 )
	{
		waitthread ShowXPEarnedBreakdown()
		if ( IsFullyConnected() && !EOGIsPrivateMatch() )
		{
			waitthread FlashElement( menu, activeXPBar.s.BarFillFlash, 4, 2.0, 120 )
			waitthread FillUpXPBars( startXP + newXP )
		}
	}
	wait 1.0
}

function ShowXPEarnedBreakdown()
{
	EndSignal( menu, "StopMenuAnimation" )

	//########################################################
	// DISPLAY BREAKDOWNS
	//########################################################

	local numLineItemsUsed = 0
	local breakdownDelay = 1.0

	foreach( xpCategory, xpSumVal in matchXPByCategory )
	{
		local button = xpEarnedBreakdownButtons[numLineItemsUsed]
		local categoryText = xpCategoryDescriptions[ xpCategory ]
		local valueTotal = floor( ( xpSumVal / GetXPModifierForGen() ) + 0.5 )
		UpdateXPEarnedBreakdownButton( button, xpCategory, categoryText, valueTotal, breakdownDelay )

		numLineItemsUsed++
		breakdownDelay += 0.25

		if ( numLineItemsUsed >= xpEarnedBreakdownButtons.len() )
			break
	}

	// Show Gen multiplier bonus
	if ( GetGen() > 0 )
	{
		local button = xpEarnedBreakdownButtons[numLineItemsUsed]
		local locString = EOGIsPrivateMatch() ? "#EOG_XP_GEN_BONUS_DESC_PRIVATEMATCH" : "#EOG_XP_GEN_BONUS_DESC"
		UpdateXPEarnedBreakdownButton( button, null, locString, GetXPModifierForGen(), breakdownDelay, true )
		breakdownDelay += 0.5
	}

	//########################################################
	// DISPLAY TOTAL VALUE
	//########################################################

	local xpValueLocString = EOGIsPrivateMatch() ? "#EOG_XP_VALUE_PRIVATE_MATCH" : "#EOG_XP_VALUE"

	thread SetTextCountUp( menu, xpEarnedTotal, xpEarnedTotalVal, "EOGSummary.XPTotalNumberTick", breakdownDelay + 0.2, null, 0.5, xpValueLocString )
	thread FancyLabelFadeIn( menu, xpEarnedTotalDesc, 300, 0, false, 0.15, false, breakdownDelay )
	thread FancyLabelFadeIn( menu, xpEarnedTotal, 300, 0, true, 0.15, false, breakdownDelay )
	thread FlashElement( menu, xpEarnedTotal, 4, 1.5, 255, breakdownDelay + 0.5 )

	wait breakdownDelay
	if ( level.doEOGAnimsXP )
		EmitUISound( "EOGSummary.XPTotalPopup" )

	wait 1.0
}

function UpdateXPEarnedBreakdownButton( button, xpCategory, categoryText, valueTotal, delay, isGenBonus = false )
{
	local descElems = []
	descElems.append( button.GetChild( "DescNormal" ) )
	descElems.append( button.GetChild( "DescFocused" ) )
	descElems.append( button.GetChild( "DescSelected" ) )
	descElems.append( button.GetChild( "DescDisabled" ) )

	local valueElems = []
	valueElems.append( button.GetChild( "ValueNormal" ) )
	valueElems.append( button.GetChild( "ValueFocused" ) )
	valueElems.append( button.GetChild( "ValueSelected" ) )
	valueElems.append( button.GetChild( "ValueDisabled" ) )

	//if ( level.doEOGAnimsXP )
	//	EmitUISound( "Menu_GameSummary_XPBonusesSlideIn" )

	foreach( elem in descElems )
	{
		Assert( elem != null )
		if ( isGenBonus )
			elem.SetText( categoryText, ( GetGen() + 1 ) )
		else
			elem.SetText( categoryText )
	}

	local xpValueLocString = EOGIsPrivateMatch() ? "#EOG_XP_VALUE_PRIVATE_MATCH" : "#EOG_XP_VALUE"

	foreach( elem in valueElems )
	{
		Assert( elem != null )
		if ( isGenBonus )
			elem.SetText( "#EOG_XP_GEN_BONUS_VAL", valueTotal )
		else
			thread SetTextCountUp( menu, elem, valueTotal, "Menu_GameSummary_XPBar", delay + 0.2, null, 0.5, xpValueLocString )
	}

	if ( isGenBonus )
	{
		descElems[ descElems.len() - 1 ].SetColor( 145, 84, 42, 255 )
		valueElems[ valueElems.len() - 1 ].SetColor( 145, 84, 42, 255 )
	}
	else
	{
		descElems[ descElems.len() - 1 ].SetColor( 100, 100, 100, 255 )
		valueElems[ valueElems.len() - 1 ].SetColor( 100, 100, 100, 255 )
	}

	if ( !( "xpCategory" in button.s ) )
		button.s.xpCategory <- null
	button.s.xpCategory = xpCategory

	if ( isGenBonus )
		button.SetEnabled( false )
	else
		button.SetEnabled( valueTotal > 0 )

	button.SetLocked( false )

	thread FancyLabelFadeIn( menu, button, 300, 0, true, 0.15, false, delay, "Menu_GameSummary_XPBonusesSlideIn" )
}

function FillUpXPBars( totalXPGoal )
{
	EndSignal( menu, "StopMenuAnimation" )

	OnThreadEnd(
		function() : ( menu )
		{
			StopUISound( "Menu_GameSummary_LevelBarLoop" )
			SetXPBarXP( endXP )
		}
	)

	// Clamp totalXPGoal to the max XP we allow, because some XP was rewarded for the match but it's not valid. We still reward the XP for breakdowns though
	totalXPGoal = clamp( totalXPGoal, 0, GetXPForLevel( MAX_LEVEL ) )
	local barXP = startXP
	local barXPToAdd = totalXPGoal - barXP

	//printt( "totalXPGoal:", totalXPGoal )
	//printt( "startXP:", startXP )
	//printt( "endXP:", endXP )
	//printt( "barXPToAdd:", barXPToAdd )

	while( barXPToAdd > 0 )
	{
		local barLevel = GetLevelForXP( barXP )
		local barXPStart = GetXPForLevel( barLevel )
		local barXPEnd = GetXPForLevel( barLevel + 1 )
		local barXPToAddThisLevel = clamp( barXPEnd - barXP, 0, barXPToAdd )
		local barStartFrac = GraphCapped( barXP, barXPStart, barXPEnd, 0.0, 1.0 )
		local barEndFrac = GraphCapped( barXP + barXPToAddThisLevel, barXPStart, barXPEnd, 0.0, 1.0 )
		local barFracDelta = clamp( barEndFrac - barStartFrac, 0.0, 1.0 )
		local barFillDuration = clamp( barFracDelta * XP_BAR_FILL_DURATION, XP_BAR_FILL_TIME_MIN, XP_BAR_FILL_DURATION )
		local fillStartTime = Time()
		local fillEndTime = Time() + barFillDuration

		// Fill the XP bar up for the current level
		thread ShowXPBarFlare( barFillDuration )
		EmitUISound( "Menu_GameSummary_LevelBarLoop" )
		while( Time() <= fillEndTime )
		{
			SetXPBarXP( GraphCapped( Time(), fillStartTime, fillEndTime, barXP, barXP + barXPToAddThisLevel ) )
			wait 0
		}
		SetXPBarXP( barXP + barXPToAddThisLevel, false )
		StopUISound( "Menu_GameSummary_LevelBarLoop" )

		// Did we level up?
		if ( barLevel < MAX_LEVEL && barXP + barXPToAddThisLevel == barXPEnd )
		{
			thread LevelUpMessage( barLevel + 1 )
			if ( barLevel + 1 < MAX_LEVEL )
				waitthread SwapXPBars()
		}

		barXP += barXPToAddThisLevel
		barXPToAdd -= barXPToAddThisLevel
	}
}

function SwapXPBars()
{
	Signal( menu, "XPBarChanging" )

	// Swap what the active bar is
	if ( activeXPBar == xpBarPanels[0] )
	{
		activeXPBar = xpBarPanels[1]
		nextXPBar = xpBarPanels[0]
	}
	else
	{
		activeXPBar = xpBarPanels[0]
		nextXPBar = xpBarPanels[1]
	}

	// Move the old bar down
	local duration = 0.3
	thread FancyLabelFadeOut( menu, nextXPBar, 0, 300, duration, true )
	thread FancyLabelFadeIn( menu, activeXPBar, activeXPBar.GetWidth(), 0, false, duration, true )
	wait duration
}

function SetXPBarXP( xp, fullBarLevelsUp = true )
{
	xp = xp.tointeger()
	xp = clamp( xp, 0, GetXPForLevel( MAX_LEVEL ) )

	local currentLevel = GetLevelForXP( xp )
	if ( !fullBarLevelsUp && GetXPForLevel( currentLevel ) == xp )
		currentLevel--

	if ( currentLevel >= MAX_LEVEL )
	{
		currentLevel = MAX_LEVEL
		fullBarLevelsUp = false
	}

	local nextLevel = currentLevel == MAX_LEVEL ? MAX_LEVEL : currentLevel + 1
	local nextNextlevel = nextLevel == MAX_LEVEL ? MAX_LEVEL : nextLevel + 1
	local levelStartXP = GetXPForLevel( currentLevel )
	local levelEndXP = GetXPForLevel( nextLevel )
	local XPIntoLevel = xp - levelStartXP
	local XPForLevel = levelEndXP - levelStartXP

	xpBarCurrentLevel = currentLevel

	activeXPBar.s.level.SetText( "#EOG_XP_BAR_LEVEL", currentLevel.tostring() )
	activeXPBar.s.xpCount.SetText( "#EOG_XP_BAR_XPCOUNT", XPForLevel - XPIntoLevel )

	nextXPBar.s.level.SetText( "#EOG_XP_BAR_LEVEL", nextLevel.tostring() )
	nextXPBar.s.xpCount.SetText( "#EOG_XP_BAR_XPCOUNT", GetXPForLevel( nextNextlevel ) )

	if ( currentLevel == MAX_LEVEL )
	{
		activeXPBar.s.xpCount.SetText( "#EOG_XP_BAR_XPCOUNT_MAXED" )
		nextXPBar.s.xpCount.SetText( "#EOG_XP_BAR_XPCOUNT_MAXED" )
	}

	// Next XP Bar should be empty
	nextXPBar.s.BarFillNew.SetScaleX( 0 )
	nextXPBar.s.BarFillNewColor.SetScaleX( 0 )
	nextXPBar.s.BarFillPrevious.SetScaleX( 0 )
	nextXPBar.s.BarFillShadow.SetScaleX( 0 )
	nextXPBar.s.BarFillFlash.SetScaleX( 0 )

	// Prevous XP
	local previousXPScale = 0
	local newXPScale = 0
	if ( startXP > levelStartXP )
	{
		previousXPScale = GraphCapped( startXP, levelStartXP, levelEndXP, 0.0, 1.0 )
		activeXPBar.s.BarFillPrevious.SetScaleX( previousXPScale )
		activeXPBar.s.BarFillPrevious.Show()
	}
	else
		activeXPBar.s.BarFillPrevious.Hide()

	// New XP
	newXPScale = GraphCapped( xp, levelStartXP, levelEndXP, 0.0, 1.0 )
	activeXPBar.s.BarFillNew.SetScaleX( newXPScale )
	activeXPBar.s.BarFillNew.SetAlpha( 255 )
	activeXPBar.s.BarFillNew.Show()
	activeXPBar.s.BarFillNewColor.SetScaleX( newXPScale )
	activeXPBar.s.BarFillNewColor.SetAlpha( 255 )
	activeXPBar.s.BarFillNewColor.Show()

	// Shadow
	local shadowScale = newXPScale > previousXPScale ? newXPScale : previousXPScale
	activeXPBar.s.BarFillShadow.SetScaleX( shadowScale )
	activeXPBar.s.BarFillShadow.Show()
	activeXPBar.s.BarFillFlash.SetScaleX( shadowScale )
	activeXPBar.s.BarFillFlash.Show()
}

function ShowXPBarFlare( duration )
{
	EndSignal( menu, "StopMenuAnimation" )
	EndSignal( menu, "XPBarChanging" )

	OnThreadEnd(
		function() : ()
		{
			activeXPBar.s.BarFlare.SetAlpha( 0 )
			activeXPBar.s.BarFlare.Hide()
			nextXPBar.s.BarFlare.SetAlpha( 0 )
			nextXPBar.s.BarFlare.Hide()
		}
	)

	local endTime = Time() + duration

	activeXPBar.s.BarFlare.SetAlpha( 0 )
	activeXPBar.s.BarFlare.Show()
	activeXPBar.s.BarFlare.FadeOverTime( 255, 0.15 )

	nextXPBar.s.BarFlare.SetAlpha( 0 )
	nextXPBar.s.BarFlare.Hide()

	wait duration

	activeXPBar.s.BarFlare.FadeOverTime( 0, 0.3 )
	wait 0.3
}

function LevelUpMessage( newLevel )
{
	EndSignal( menu, "StopMenuAnimation" )

	local text = GetElem( menu, "LevelUpText" )
	local scan = GetElem( menu, "LevelUpTextScan" )

	Signal( text, "LevelUpMessage" )
	EndSignal( text, "LevelUpMessage" )

	OnThreadEnd(
		function() : ( text, scan )
		{
			text.Hide()
			scan.Hide()
		}
	)

	text.SetText( "#EOG_XP_BAR_LEVEL", newLevel.tointeger() )
	local size = text.GetSize()

	thread LevelUpMessage_Text( text )

	// Animate the text scan
	scan.Show()
	scan.ReturnToBasePos()
	scan.ReturnToBaseSize()
	scan.SetBaseSize( size[0], size[1] )
	scan.SetSize( 0, 0 )
	scan.SetColor( 255, 255, 255, 0 )
	scan.FadeOverTime( 255, 0.5, INTERPOLATOR_ACCEL )
	scan.ScaleOverTime( 2.0, 3.0, 0.25, INTERPOLATOR_ACCEL )
	wait 0.25
	scan.ScaleOverTime( 0.5, 1.0, 0.25, INTERPOLATOR_DEACCEL )
	scan.ColorOverTime( 0, 0, 0, 0, 0.5, INTERPOLATOR_ACCEL )
	wait 0.5
	scan.ColorOverTime( 255, 255, 255, 255, 1.75, INTERPOLATOR_ACCEL )
	wait 1.75
	scan.FadeOverTime( 0, 1.5, INTERPOLATOR_ACCEL )
	scan.OffsetOverTime( -size[0], 0, 0.75, INTERPOLATOR_ACCEL )
	scan.ScaleOverTime( 0.0, 3.0, 0.75, INTERPOLATOR_ACCEL )
	wait 0.7
	scan.Hide()
	wait 0.1
}

function LevelUpMessage_Text( textLabel )
{
	// Animate the text label
	EndSignal( menu, "StopMenuAnimation" )
	EndSignal( textLabel, "LevelUpMessage" )

	OnThreadEnd(
		function() : ( textLabel )
		{
			textLabel.Hide()
		}
	)

	local color = [ 210, 170, 0 ]

	local basePos = textLabel.GetBasePos()
	local yOffset1 = 130
	local yOffset2 = 20
	local yOffset3 = -20
	local yOffset4 = -400

	textLabel.Show()
	textLabel.SetColor( color[0], color[1], color[2], 0 )
	textLabel.SetPos( basePos[0], basePos[1] + yOffset1 )
	textLabel.FadeOverTime( 255, 0.15, INTERPOLATOR_ACCEL )
	textLabel.MoveOverTime( basePos[0], basePos[1] + yOffset2, 0.2 )
	wait 0.2

	if ( level.doEOGAnimsXP )
		EmitUISound( "Menu_GameSummary_LevelUp" )

	textLabel.MoveOverTime( basePos[0], basePos[1] + yOffset3, 3.0 )
	textLabel.RunAnimationCommand( "FgColor", 0, 2.5, 0.5, INTERPOLATOR_FLICKER, 0.15 )
	wait 3.0
	textLabel.MoveOverTime( basePos[0], basePos[1] + yOffset4, 0.2 )
	wait 0.2
}

function BreakdownButton_Get_Focus( button )
{
	Assert( "xpCategory" in button.s )

	local menu = GetMenu( "EOG_XP" )

	local pilotImage = GetElem( menu, "PilotImage" )
	//pilotImage.SetAlpha( 100 )
	pilotImage.FadeOverTime( 100, 0.15 )

	// Find all xp types in this category
	local typesToDisplay = []
	for( local i = 0 ; i < XP_TYPE._NUM_TYPES ; i++ )
	{
		if ( level.xpCategory[ i ] == button.s.xpCategory )
			typesToDisplay.append( i )
	}

	// Put info on labels
	local xpValueLocString = EOGIsPrivateMatch() ? "#EOG_XP_VALUE_PRIVATE_MATCH" : "#EOG_XP_VALUE"

	local elemIndex = 0
	foreach( subCat in typesToDisplay )
	{
		local xpCountForType = level.matchXPCountByType[ subCat ]
		if ( xpCountForType <= 0 )
			continue
		local adjustedXPSumForSubCat = floor( ( level.matchXPByType[ subCat ] / GetXPModifierForGen() ) + 0.5 )

		local label = GetElem( menu, "SubCatDesc" + elemIndex )
		label.SetText( "#EOG_XOTYPE_NAME_AND_COUNT", level.xpTypeDescriptions[ subCat ], xpCountForType.tostring() )
		label.FadeOverTime( 255, 0.15 )
		label.Show()

		label = GetElem( menu, "SubCatValue" + elemIndex )
		label.SetText( xpValueLocString, adjustedXPSumForSubCat.tostring() )
		label.FadeOverTime( 255, 0.15 )
		label.Show()

		elemIndex++
	}

	for( local i = typesToDisplay.len() ; i < NUM_XP_SUBCAT_LINES ; i++ )
	{
		GetElem( menu, "SubCatDesc" + i ).Hide()
		GetElem( menu, "SubCatValue" + i ).Hide()
	}
}

function BreakdownButton_Lose_Focus( button )
{
	local menu = GetMenu( "EOG_XP" )

	local pilotImage = GetElem( menu, "PilotImage" )
	//pilotImage.SetAlpha( 255 )
	pilotImage.FadeOverTime( 255, 0.15 )

	for( local i = 0 ; i < NUM_XP_SUBCAT_LINES ; i++ )
	{
		local label = GetElem( menu, "SubCatDesc" + i )
		label.FadeOverTime( 0, 0.15 )

		label = GetElem( menu, "SubCatValue" + i )
		label.FadeOverTime( 0, 0.15 )
	}
}
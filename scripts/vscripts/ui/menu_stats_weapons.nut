
//ToDo: Kills Per Minute stat

const MAX_LIST_ITEMS = 26
const SCROLL_START_TOP = 2
const WEAPON_LIST_VISIBLE = 6
const MENU_MOVE_TIME = 0.15
const BUTTON_POPOUT_FRACTION = 0.19

pws <- {}
pws.weaponMenuInitComplete <- false

pws.allPilotWeapons <- []
pws.allTitanWeapons <- []

pws.buttonElems <- []
pws.buttonSpacing <- null
pws.buttonPopOutDist <- null
pws.selectedIndex <- 0
pws.numListButtonsUsed <- MAX_LIST_ITEMS

pws.bindings <- false

function main()
{
	Globalize( OnOpenViewStatsWeapons )
	Globalize( OnCloseViewStatsWeapons )
	Globalize( InitStats_Weapons )
}

function OnOpenViewStatsWeapons()
{
	local menu = GetMenu( "ViewStats_Weapons_Menu" )
	local titleLabel = menu.GetChild( "MenuTitle" )

	if ( uiGlobal.weaponStatListType == "pilot" )
	{
		UpdateButtons( pws.allPilotWeapons )
		titleLabel.SetText( "#STATS_PILOT_WEAPONS" )
	}
	else if ( uiGlobal.weaponStatListType == "titan" )
	{
		UpdateButtons( pws.allTitanWeapons )
		titleLabel.SetText( "#STATS_TITAN_WEAPONS" )
	}
	else
		Assert(0, "invalid " + uiGlobal.weaponStatListType )

	UpdateButtonsForSelection( 0, true )

	if ( !pws.bindings )
	{
		pws.bindings = true
		RegisterButtonPressedCallback( MOUSE_WHEEL_UP, WeaponSelectNextUp )
		RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, WeaponSelectNextDown )
		RegisterButtonPressedCallback( KEY_UP, WeaponSelectNextUp )
		RegisterButtonPressedCallback( KEY_DOWN, WeaponSelectNextDown )
	}
}

function OnCloseViewStatsWeapons()
{
	if ( pws.bindings )
	{
		DeregisterButtonPressedCallback( MOUSE_WHEEL_UP, WeaponSelectNextUp )
		DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN, WeaponSelectNextDown )
		DeregisterButtonPressedCallback( KEY_UP, WeaponSelectNextUp )
		DeregisterButtonPressedCallback( KEY_DOWN, WeaponSelectNextDown )
		pws.bindings = false
	}
}

function InitStats_Weapons()
{
	if ( pws.weaponMenuInitComplete )
		return

	local menu = GetMenu( "ViewStats_Weapons_Menu" )
	local buttonPanel = GetElem( menu, "WeaponButtonsNestedPanel" )
	for ( local i = 0 ; i < MAX_LIST_ITEMS ; i++ )
	{
		local button = buttonPanel.GetChild( "BtnWeapon" + i )
		Assert( button != null )

		button.s.dimOverlay <- button.GetChild( "DimOverlay" )
		button.s.weaponImageNormal <- button.GetChild( "WeaponImageNormal" )
		button.s.weaponImageFocused <- button.GetChild( "WeaponImageFocused" )
		button.s.weaponImageSelected <- button.GetChild( "WeaponImageSelected" )
		button.s.ref <- null

		button.AddEventHandler( UIE_CLICK, WeaponButtonClicked )
		button.AddEventHandler( UIE_GET_FOCUS, WeaponButtonFocused )

		pws.buttonElems.append( button )
	}

	GetElem( menu, "BtnScrollUpPC" ).AddEventHandler( UIE_CLICK, WeaponSelectNextUp )
	GetElem( menu, "BtnScrollDownPC" ).AddEventHandler( UIE_CLICK, WeaponSelectNextDown )

	pws.buttonSpacing = pws.buttonElems[1].GetBasePos()[1] - pws.buttonElems[0].GetBasePos()[1]
	pws.buttonPopOutDist = pws.buttonElems[0].GetBaseWidth() * BUTTON_POPOUT_FRACTION

	// Get Pilot weapon list
	pws.allPilotWeapons = GetAllItemsOfType( itemType.PILOT_PRIMARY )
	pws.allPilotWeapons.extend( GetAllItemsOfType( itemType.PILOT_SECONDARY ) )
	pws.allPilotWeapons.extend( GetAllItemsOfType( itemType.PILOT_SIDEARM ) )
	pws.allPilotWeapons.extend( GetAllItemsOfType( itemType.PILOT_ORDNANCE ) )
	//pws.allPilotWeapons.extend( GetAllItemsOfType( itemType.PILOT_SPECIAL ) )

	// Get Titan weapon list
	pws.allTitanWeapons = GetAllItemsOfType( itemType.TITAN_PRIMARY )
	pws.allTitanWeapons.extend( GetAllItemsOfType( itemType.TITAN_ORDNANCE ) )
	//pws.allTitanWeapons.extend( GetAllItemsOfType( itemType.TITAN_SPECIAL ) )

	pws.weaponMenuInitComplete = true
}

function WeaponButtonClicked( button )
{
	local id = button.GetScriptID().tointeger()
	if ( !IsControllerModeActive() )
		UpdateButtonsForSelection( id )
}

function WeaponButtonFocused( button )
{
	local id = button.GetScriptID().tointeger()
	if ( IsControllerModeActive() )
		UpdateButtonsForSelection( id )
}

function WeaponSelectNextUp( button )
{
	if ( pws.selectedIndex == 0 )
		return
	UpdateButtonsForSelection( pws.selectedIndex - 1 )
}

function WeaponSelectNextDown( button )
{
	if ( pws.selectedIndex + 1 >= pws.numListButtonsUsed )
		return
	UpdateButtonsForSelection( pws.selectedIndex + 1 )
}

function UpdateButtons( weaponList )
{
	Assert( weaponList.len() > 0 && weaponList.len() < MAX_LIST_ITEMS )
	pws.numListButtonsUsed = 0
	foreach( index, item in weaponList )
	{
		local button = pws.buttonElems[ index ]
		button.SetEnabled( true )
		button.Show()

		button.s.ref = item.ref
		local image = GetItemAltImage( item.ref )
		if ( image == null )
			image = GetItemImage( item.ref )
		Assert( image != null )
		button.s.weaponImageNormal.SetImage( image )
		button.s.weaponImageFocused.SetImage( image )
		button.s.weaponImageSelected.SetImage( image )

		if ( IsItemLocked( item.ref ) )
		{
			button.s.weaponImageNormal.SetAlpha( 200 )
			button.s.weaponImageFocused.SetAlpha( 200 )
			button.s.weaponImageSelected.SetAlpha( 200 )
		}
		else
		{
			button.s.weaponImageNormal.SetAlpha( 255 )
			button.s.weaponImageFocused.SetAlpha( 255 )
			button.s.weaponImageSelected.SetAlpha( 255 )
		}

		pws.numListButtonsUsed++
	}

	// Hide / Disable buttons we wont be using
	for ( local i = pws.numListButtonsUsed ; i < MAX_LIST_ITEMS ; i++ )
	{
		local button = pws.buttonElems[ i ]
		button.SetEnabled( false )
		button.Hide()
	}
}

function UpdateButtonsForSelection( index, instant = false )
{
	if ( !IsFullyConnected() )
		return

	Assert( pws.selectedIndex < pws.buttonElems.len() )
	EmitUISound( "EOGSummary.XPBreakdownPopup" )

	//pws.buttonElems[ pws.selectedIndex ].s.selectOverlay.Hide()
	//pws.buttonElems[ index ].s.selectOverlay.Show()
	pws.selectedIndex = index

	pws.buttonElems[ pws.selectedIndex ].SetScale( 1.5, 1.5 )

	foreach( index, button in pws.buttonElems )
	{
		local distFromSelection = abs( index - pws.selectedIndex )

		local isSelected = index == pws.selectedIndex ? true : false
		button.SetSelected( isSelected )

		// Button dim
		local dimAlpha = GraphCapped( distFromSelection, 0, 5, 0, 150 )
		button.s.dimOverlay.SetAlpha( dimAlpha )

		// Figure out button positioning
		local baseX = pws.buttonElems[0].GetBasePos()[0]
		local topY = pws.buttonElems[0].GetBasePos()[1]
		local shiftCount = max( 0, pws.selectedIndex - SCROLL_START_TOP )
		local maxShiftCount = pws.numListButtonsUsed - WEAPON_LIST_VISIBLE
		shiftCount = clamp( shiftCount, 0, maxShiftCount )
		local shiftDist = pws.buttonSpacing * shiftCount
		if ( index < pws.selectedIndex )
			shiftDist += pws.buttonSpacing * 0.25
		else if ( index > pws.selectedIndex )
			shiftDist -= pws.buttonSpacing * 0.25

		// Button popout
		local goalPosX = baseX
		if ( distFromSelection == 0 )
			goalPosX += pws.buttonPopOutDist
		else if ( distFromSelection == 1 )
			goalPosX += pws.buttonPopOutDist * 0.2

		// Button scroll pos
		local baseY = topY + ( pws.buttonSpacing * index )
		local goalPosY = baseY - shiftDist

		if ( instant )
			button.SetPos( goalPosX, goalPosY )
		else
			button.MoveOverTime( goalPosX, goalPosY, MENU_MOVE_TIME, INTERPOLATOR_DEACCEL )
	}

	// Update stats pane to match the button ref item
	UpdateStatsForWeapon( pws.buttonElems[ pws.selectedIndex ].s.ref )
}

function UpdateStatsForWeapon( weaponRef )
{
	local menu = GetMenu( "ViewStats_Weapons_Menu" )

	// Get required data needed for some calculations
	local hoursUsed = StatToFloat( "weapon_stats", "hoursUsed", weaponRef )
	local shotsFired = StatToInt( "weapon_stats", "shotsFired", weaponRef )
	local shotsHit = StatToInt( "weapon_stats", "shotsHit", weaponRef )
	local headshots = StatToInt( "weapon_stats", "headshots", weaponRef )
	local crits = StatToInt( "weapon_stats", "critHits", weaponRef )

	// Name
	menu.GetChild( "WeaponName" ).SetText( GetItemName( weaponRef ) )

	// Image
	local image = GetItemAltImage( weaponRef )
	if ( image == null )
		image = GetItemImage( weaponRef )
	local weaponImageElem = menu.GetChild( "WeaponImageLarge" )
	weaponImageElem.SetImage( image )
	weaponImageElem.SetAlpha( 255 )

	// Locked info
	local lockLabel = GetElementsByClassname( menu, "LblWeaponLocked" )[0]
	local levelReq = GetItemLevelReq( weaponRef )
	lockLabel.Hide()
	// if ( levelReq > GetLevel() )
	// {
	// 	weaponImageElem.SetAlpha( 200 )
	// 	lockLabel.SetText( "#LOUADOUT_UNLOCK_REQUIREMENT_LEVEL", levelReq )
	// 	lockLabel.Show()
	// }

	// Time Used
	SetStatsLabelValue( menu, "TimeUsed", 				StatToTimeString( "weapon_stats", "hoursEquipped", weaponRef ) )

	// Shots Fired / Accuracy
	SetStatsLabelValue( menu, "ShotsFired", 			shotsFired )
	SetStatsLabelValue( menu, "Accuracy", 				[ "#STATS_PERCENTAGE", GetPercent( shotsHit, shotsFired, 0 ) ] )

	// Headshots / Accuracy
	local headshotWeapon = GetWeaponInfoFileKeyField_Global( weaponRef, "allow_headshots" ) == 1
	if ( headshotWeapon )
	{
		SetStatsLabelValue( menu, "Headshots", 				headshots )
		SetStatsLabelValue( menu, "HeadshotAccuracy", 		[ "#STATS_PERCENTAGE", GetPercent( headshots, shotsFired, 0 ) ] )
	}
	else
	{
		SetStatsLabelValue( menu, "Headshots", 				"#STATS_NOT_APPLICABLE" )
		SetStatsLabelValue( menu, "HeadshotAccuracy", 		"#STATS_NOT_APPLICABLE" )
	}

	// Crits / Accuracy
	local critHitWeapon = GetWeaponInfoFileKeyField_Global( weaponRef, "critical_hit" ) == 1
	if ( critHitWeapon )
	{
		SetStatsLabelValue( menu, "CriticalHits", 			crits )
		SetStatsLabelValue( menu, "CriticalHitAccuracy", 	[ "#STATS_PERCENTAGE", GetPercent( crits, shotsFired, 0 ) ] )
	}
	else
	{
		SetStatsLabelValue( menu, "CriticalHits", 			"#STATS_NOT_APPLICABLE" )
		SetStatsLabelValue( menu, "CriticalHitAccuracy", 	"#STATS_NOT_APPLICABLE" )
	}

	// Total Kills Stats
	SetStatsLabelValue( menu, "Column0Value0", 				StatToInt( "weapon_kill_stats", "total", weaponRef ) )
	SetStatsLabelValue( menu, "Column0Value1", 				StatToInt( "weapon_kill_stats", "pilots", weaponRef ) )
	SetStatsLabelValue( menu, "Column0Value2", 				StatToInt( "weapon_kill_stats", "grunts", weaponRef ) )
	SetStatsLabelValue( menu, "Column0Value3", 				StatToInt( "weapon_kill_stats", "spectres", weaponRef ) )
	SetStatsLabelValue( menu, "Column0Value4", 				StatToInt( "weapon_kill_stats", "marvins", weaponRef ) )

	// Titan Kills Stats
	local kills_stryder = StatToInt( "weapon_kill_stats", "titans_stryder", weaponRef )
	local kills_atlas = StatToInt( "weapon_kill_stats", "titans_atlas", weaponRef )
	local kills_ogre = StatToInt( "weapon_kill_stats", "titans_ogre", weaponRef )
	local kills_titan_total = kills_stryder + kills_atlas + kills_ogre

	SetStatsLabelValue( menu, "Column1Value0", 				kills_titan_total )
	SetStatsLabelValue( menu, "Column1Value1", 				kills_stryder )
	SetStatsLabelValue( menu, "Column1Value2", 				kills_atlas )
	SetStatsLabelValue( menu, "Column1Value3", 				kills_ogre )

	// NPC Titan Kills Stats
	local kills_npc_stryder = StatToInt( "weapon_kill_stats", "npcTitans_stryder", weaponRef )
	local kills_npc_atlas = StatToInt( "weapon_kill_stats", "npcTitans_atlas", weaponRef )
	local kills_npc_ogre = StatToInt( "weapon_kill_stats", "npcTitans_ogre", weaponRef )
	local kills_npc_titan_total = kills_npc_stryder + kills_npc_atlas + kills_npc_ogre

	SetStatsLabelValue( menu, "Column2Value0", 				kills_npc_titan_total )
	SetStatsLabelValue( menu, "Column2Value1", 				kills_npc_stryder )
	SetStatsLabelValue( menu, "Column2Value2", 				kills_npc_atlas )
	SetStatsLabelValue( menu, "Column2Value3", 				kills_npc_ogre )
}


/*
//local killCount = StatToInt( "weapon_kill_stats", "total", weaponRef )
//local killsPerMinute = 0
//if ( hoursUsed > 0 )
//	killsPerMinute = format( "%.2f", killCount / ( hoursUsed * 60.0 ) )

UpdateScrollBarPosition( shiftCount, maxShiftCount, instant )
*/
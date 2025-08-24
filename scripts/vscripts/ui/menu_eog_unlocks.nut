
const DELAY_BETWEEN_ITEM_REVEALS = 1.0

menu <- null
buttonsRegistered <- false
nonItemUnlockInfo <- {}

//#############################
// Hud elems
//#############################

unlockItemPanels <- {}
unlockItemPanels[1] <- []
unlockItemPanels[2] <- []
unlockItemPanels[3] <- []
unlockItemPanels[8] <- []

eogUnlocksInitialized <- false

menuUnlockAnimDone <- false

//#############################

const PILOT_PRESET_IMAGE = "../ui/menu/loadouts/pilot_character_male_battle_rifle_imc"
const TITAN_PRESET_IMAGE = "../ui/menu/loadouts/titan_chassis_atlas_imc"
const PILOT_CUSTOM_IMAGE = "../ui/menu/loadouts/pilot_character_male_battle_rifle_imc"
const TITAN_CUSTOM_IMAGE = "../ui/menu/loadouts/titan_chassis_atlas_imc"

const BURNCARD_SLOT_1_IMAGE = "../ui/menu/items/non_items/burn_card_slot_2"
const BURNCARD_SLOT_2_IMAGE = "../ui/menu/items/non_items/burn_card_slot_2"
const BURNCARD_SLOT_3_IMAGE = "../ui/menu/items/non_items/burn_card_slot_3"
const BURNCARD_PACK_IMAGE 	= "../ui/menu/items/non_items/burn_card_pack"

const PERSONAL_STATS_IMAGE = "../ui/menu/items/non_items/personal_stats"
const CHALLENGES_IMAGE = "../ui/menu/items/non_items/challenges"

PrecacheHUDMaterial( BURNCARD_SLOT_2_IMAGE )
PrecacheHUDMaterial( BURNCARD_SLOT_3_IMAGE )
PrecacheHUDMaterial( BURNCARD_PACK_IMAGE )
PrecacheHUDMaterial( PERSONAL_STATS_IMAGE )
PrecacheHUDMaterial( CHALLENGES_IMAGE )

function main()
{
	Globalize( OnOpenEOG_Unlocks )
	Globalize( OnCloseEOG_Unlocks )
	Globalize( GetEOGUnlockedItems )

	InitNonItemDisplayData()
}

function InitMenu()
{
	Assert( menu != null )

	// Buttons & Background
	SetupEOGMenuCommon( menu )

	if ( eogUnlocksInitialized )
	{
		HideAllPanels()
		return
	}

	// Panels
	unlockItemPanels[1] = []
	unlockItemPanels[2] = []
	unlockItemPanels[3] = []
	unlockItemPanels[8] = []
	foreach( group, panels in unlockItemPanels )
	{
		if ( group == 1 )
		{
			local panel = GetElem( menu, "UnlockItem_One" )
			Assert( panel != null )
			panels.append( panel )
		}
		else if ( group == 2 )
		{
			for( local i = 0 ; i < group ; i++ )
			{
				local panel = GetElem( menu, "UnlockItem_Two_" + i )
				Assert( panel != null )
				panels.append( panel )
			}
		}
		else if ( group == 3 )
		{
			for( local i = 0 ; i < group ; i++ )
			{
				local panel = GetElem( menu, "UnlockItem_Three_" + i )
				Assert( panel != null )
				panels.append( panel )
			}
		}
		else if ( group == 8 )
		{
			for( local i = 0 ; i < group ; i++ )
			{
				local panel = GetElem( menu, "UnlockItem_Eight_" + i )
				Assert( panel != null )
				panels.append( panel )
			}
		}

		foreach( panel in panels )
		{
			panel.s.background <- panel.GetChild( "Background" )
			panel.s.popupTop <- panel.GetChild( "BackgroundPopupTop" )
			panel.s.popupBottom <- panel.GetChild( "BackgroundPopupBottom" )
			panel.s.itemImageWeapon <- panel.GetChild( "ItemImageWeapon" )
			panel.s.itemImageChassis <- panel.GetChild( "ItemImageChassis" )
			panel.s.itemImageLoadout <- panel.GetChild( "ItemImageLoadout" )
			panel.s.itemImageSquare <- panel.GetChild( "ItemImageSquare" )

			panel.s.title <- panel.GetChild( "Title" )
			panel.s.subTitle <- panel.GetChild( "SubTitle" )
			panel.s.desc <- panel.GetChild( "Desc" )

			panel.s.popupMoveDist <- panel.s.popupTop.GetHeight() * 0.5

			PopupsHide( panel, 0.0 )
			panel.Hide()
		}
	}

	eogUnlocksInitialized = true
}

function HideAllPanels()
{
	foreach( group, panels in unlockItemPanels )
	{
		foreach( panel in panels )
		{
			panel.Hide()
		}
	}
}

function OnOpenEOG_Unlocks()
{
	local numberUnlocks = uiGlobal.eog_unlocks.items.len() + uiGlobal.eog_unlocks.nonItems.len()
	Assert( numberUnlocks > 0, "EOG Unlocks menu was somehow opened when there were no unlocks. This shouldn't be possible" )

	menu = GetMenu( "EOG_Unlocks" )
	level.currentEOGMenu = menu
	Signal( menu, "StopMenuAnimation" )
	EndSignal( menu, "StopMenuAnimation" )
	Signal( level, "CancelEOGThreadedNavigation" )

	if ( !level.doEOGAnimsUnlocks )
		EmitUISound( "EOGSummary.XPBreakdownPopup" )

	InitMenu()
	thread OpenMenuAnimated()

	EOGOpenGlobal()

	wait 0
	if ( !buttonsRegistered )
	{
		RegisterButtonPressedCallback( BUTTON_A, OpenMenuStatic )
		RegisterButtonPressedCallback( KEY_SPACE, OpenMenuStatic )
		buttonsRegistered = true
	}

	if ( !level.doEOGAnimsUnlocks )
		OpenMenuStatic(false)
}

function OnCloseEOG_Unlocks()
{
	thread EOGCloseGlobal()

	HideAllPanels()

	if ( buttonsRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_A, OpenMenuStatic )
		DeregisterButtonPressedCallback( KEY_SPACE, OpenMenuStatic )
		buttonsRegistered = false
	}

	level.doEOGAnimsUnlocks = false
	menuUnlockAnimDone = false
	Signal( menu, "StopMenuAnimation" )
}

function OpenMenuAnimated()
{
	local numberUnlocks = uiGlobal.eog_unlocks.items.len() + uiGlobal.eog_unlocks.nonItems.len()
	local noUnlocksLabel = GetElem( menu, "NoUnlocksLabel" )

	noUnlocksLabel.SetText( "#EOG_NOTHING_UNLOCKED")
	noUnlocksLabel.Hide()

	OnThreadEnd(
		function() : (  )
		{
			menuUnlockAnimDone = true
			if ( level.doEOGAnimsUnlocks && uiGlobal.EOGAutoAdvance )
				thread EOGNavigateRight( null, true )
		}
	)

	if ( numberUnlocks == 0 )
	{
		// Display a different message if someone is max level
		if ( GetLevel() >= MAX_LEVEL )
			noUnlocksLabel.SetText( "#EOG_NOTHING_UNLOCKED_MAX_LEVEL")

		noUnlocksLabel.Show()
		wait 3.0
		return
	}

	local elemsToUse
	if ( numberUnlocks == 1 )
		elemsToUse = unlockItemPanels[1]
	else if ( numberUnlocks == 2 )
		elemsToUse = unlockItemPanels[2]
	else if ( numberUnlocks == 3 )
		elemsToUse = unlockItemPanels[3]
	else
		elemsToUse = unlockItemPanels[8]

	local panelIndex = 0

	// Show non-item unlocks first
	foreach( nonItem in uiGlobal.eog_unlocks.nonItems )
	{
		if ( panelIndex >= elemsToUse.len() )
			break

		if ( !( nonItem.ref in nonItemUnlockInfo ) )
			continue

		local delay = panelIndex * DELAY_BETWEEN_ITEM_REVEALS
		thread ShowUnlockOnPanel( elemsToUse[ panelIndex ], nonItem.ref, nonItem.childRef, delay )
		panelIndex++
	}

	// Now show item unlocks
	local delay = 0.0
	foreach( item in uiGlobal.eog_unlocks.items )
	{
		if ( panelIndex >= elemsToUse.len() )
			break

		delay = panelIndex * DELAY_BETWEEN_ITEM_REVEALS
		thread ShowUnlockOnPanel( elemsToUse[ panelIndex ], item.ref, item.childRef, delay )
		panelIndex++
	}
	wait delay
	wait 1.0
	menuUnlockAnimDone = true
	wait 3.0
}

function OpenMenuStatic( userInitiated = true )
{
	if ( menuUnlockAnimDone && userInitiated )
		thread EOGNavigateRight( null )
	else
		Signal( menu, "StopMenuAnimation" )
}

function ShowUnlockOnPanel( panel, ref, childRef, delay )
{
	local title = null
	local subTitle = null
	local desc = null

	local image
	local imageLabel

	panel.s.itemImageWeapon.Hide()
	panel.s.itemImageChassis.Hide()
	panel.s.itemImageLoadout.Hide()
	panel.s.itemImageSquare.Hide()

	if ( ref in nonItemUnlockInfo )
	{
		// Title
		if ( "title" in nonItemUnlockInfo[ ref ] )
			title = nonItemUnlockInfo[ ref ].title

		// SubTitle
		if ( "subTitle" in nonItemUnlockInfo[ ref ] )
			subTitle = nonItemUnlockInfo[ ref ].subTitle

		// Desc
		if ( "desc" in nonItemUnlockInfo[ ref ] )
			desc = nonItemUnlockInfo[ ref ].desc

		// Image & Image Label to use
		image = nonItemUnlockInfo[ ref ].image
		imageLabel = panel.s[ nonItemUnlockInfo[ ref ].imageLabelName ]
	}
	else
	{
		// Get item data
		local data
		if ( childRef != null )
			data = GetSubitemData( ref, childRef )
		else
			data = GetItemData( ref )

		// Image
		image = data.image

		switch( data.type )
		{
			case itemType.PILOT_SPECIAL:
			case itemType.PILOT_PASSIVE1:
			case itemType.PILOT_PASSIVE2:
			case itemType.TITAN_PASSIVE1:
			case itemType.TITAN_PASSIVE2:
			case itemType.TITAN_SPECIAL:
			case itemType.PILOT_ORDNANCE_MOD:
			case itemType.PILOT_PRIMARY_ATTACHMENT:
			case itemType.PILOT_PRIMARY_MOD:
			case itemType.PILOT_SECONDARY_MOD:
			case itemType.PILOT_SIDEARM_MOD:
			case itemType.TITAN_PRIMARY_MOD:
			case itemType.TITAN_DECAL:
				imageLabel = panel.s.itemImageSquare
				break
			default:
				imageLabel = panel.s.itemImageWeapon
				break
		}

		// Title
		title = data.name

		// SubTitle
		if ( childRef != null )
		{
			local parentData = GetItemData( ref )
			subTitle = parentData.name
		}
		else
		{
			subTitle = GetLocalizedNameFromItemType( data.type )
		}

		// Desc
		desc = data.desc
	}

	// Make null text be empty text
	if ( title == null )
		title = ""
	if ( subTitle == null )
		subTitle = ""
	if ( desc == null )
		desc = ""

	// Update title, subTitle, desc
	panel.s.title.SetText( title )
	panel.s.subTitle.SetText( subTitle )
	panel.s.desc.SetText( desc )

	// Update image
	imageLabel.SetImage( image )
	imageLabel.Show()

	thread PopupsShow( panel, delay )

	OnThreadEnd(
		function() : ( panel )
		{
			panel.Show()
			panel.SetPanelAlpha( 255 )
		}
	)
	EndSignal( menu, "StopMenuAnimation" )

	if ( delay > 0 )
		wait delay

	if ( level.doEOGAnimsUnlocks )
		EmitUISound( "Menu_GameSummary_Unlocks" )
}

function PopupsShow( panel, delay )
{
	PopupsHide( panel, 0.0 )

	OnThreadEnd(
		function() : ( panel )
		{
			panel.s.popupTop.ReturnToBasePos()
			panel.s.popupTop.Show()
			panel.s.popupBottom.ReturnToBasePos()
			panel.s.popupBottom.Show()

			panel.s.title.Show()
			panel.s.subTitle.Show()
			panel.s.desc.Show()
		}
	)
	EndSignal( menu, "StopMenuAnimation" )

	panel.ReturnToBasePos()
	panel.ReturnToBaseSize()

	if ( delay > 0 )
		wait delay

	local duration = 0.2

	local basePos = panel.s.popupTop.GetBasePos()
	panel.s.popupTop.MoveOverTime( basePos[0], basePos[1], duration, INTERPOLATOR_ACCEL )
	panel.s.popupTop.Show()

	basePos = panel.s.popupBottom.GetBasePos()
	panel.s.popupBottom.MoveOverTime( basePos[0], basePos[1], duration, INTERPOLATOR_ACCEL )
	panel.s.popupBottom.Show()

	panel.s.title.Show()
	panel.s.subTitle.Show()
	panel.s.desc.Show()

	if ( level.doEOGAnimsUnlocks )
		EmitUISound( "EOGSummary.XPTotalPopup" )

	wait duration
}

function PopupsHide( panel, duration = 0.1 )
{
	local basePos = panel.s.popupTop.GetBasePos()
	panel.s.popupTop.SetPos( basePos[0], basePos[1]  )
	panel.s.popupTop.MoveOverTime( basePos[0], basePos[1] + panel.s.popupMoveDist, duration, INTERPOLATOR_ACCEL )

	basePos = panel.s.popupBottom.GetBasePos()
	panel.s.popupBottom.MoveOverTime( basePos[0], basePos[1] - panel.s.popupMoveDist, duration, INTERPOLATOR_ACCEL )

	wait duration
	panel.s.popupTop.Hide()
	panel.s.popupBottom.Hide()
	panel.s.title.Hide()
	panel.s.subTitle.Hide()
	panel.s.desc.Hide()
}

function GetEOGUnlockedItems()
{
	if ( !( "eog_unlocks" in uiGlobal ) )
		uiGlobal.eog_unlocks <- null

	uiGlobal.eog_unlocks = {}
	uiGlobal.eog_unlocks[ "items" ] <- []
	uiGlobal.eog_unlocks[ "nonItems" ] <- []

	if ( level.EOG_DEBUG )
	{
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "titan_ogre", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "titan_stryder", childRef = null } )

		//uiGlobal.eog_unlocks.nonItems.append( { ref = "pilot_preset_loadout_1", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "pilot_preset_loadout_2", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "pilot_preset_loadout_3", childRef = null } )

		//uiGlobal.eog_unlocks.nonItems.append( { ref = "titan_preset_loadout_1", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "titan_preset_loadout_2", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "titan_preset_loadout_3", childRef = null } )

		//uiGlobal.eog_unlocks.nonItems.append( { ref = "pilot_custom_loadout_1", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "pilot_custom_loadout_2", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "pilot_custom_loadout_3", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "pilot_custom_loadout_4", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "pilot_custom_loadout_5", childRef = null } )

		//uiGlobal.eog_unlocks.nonItems.append( { ref = "titan_custom_loadout_1", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "titan_custom_loadout_2", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "titan_custom_loadout_3", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "titan_custom_loadout_4", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "titan_custom_loadout_5", childRef = null } )

		//uiGlobal.eog_unlocks.nonItems.append( { ref = "burn_card_slot_1", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "burn_card_slot_2", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "burn_card_slot_3", childRef = null } )

		//uiGlobal.eog_unlocks.nonItems.append( { ref = "challenges", childRef = null } )

		//uiGlobal.eog_unlocks.nonItems.append( { ref = "burn_card_pack_1", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "burn_card_pack_2", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "burn_card_pack_3", childRef = null } )
		//uiGlobal.eog_unlocks.nonItems.append( { ref = "burn_card_pack_4", childRef = null } )

		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_r97", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_grenade_emp", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_ability_heal", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_dmr", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_homing_rockets", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_sniper", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanability_smoke", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "pas_assault_reactor", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "pas_turbo_drop", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_satchel", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_g2", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_ability_sonar", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_arc_cannon", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_mgl", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_hemlok", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_dumbfire_rockets", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanability_bubble_shield", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_wingman", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_triple_threat", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_proximity_mine", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "pas_run_and_gun", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_shoulder_rockets", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_defender", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_car", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "pas_marathon_core", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "pas_dead_mans_trigger", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "pas_dash_recharge", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_lmg", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "pas_hyper_core", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "pas_fast_reload", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "pas_fast_hack", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_sniper", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "pas_defensive_core", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "pas_titan_punch", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "pas_stealth_movement", childRef = null } )
		//uiGlobal.eog_unlocks.items.append( { ref = "pas_enhanced_titan_ai", childRef = null } )

		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_car", childRef = "iron_sights" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_car", childRef = "hcog" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_dmr", childRef = "scope_6x" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_dmr", childRef = "aog" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_dmr", childRef = "scope_4x" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_g2", childRef = "iron_sights" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_g2", childRef = "hcog" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_g2", childRef = "holosight" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_g2", childRef = "aog" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_hemlok", childRef = "iron_sights" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_hemlok", childRef = "hcog" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_hemlok", childRef = "holosight" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_hemlok", childRef = "aog" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_lmg", childRef = "iron_sights" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_lmg", childRef = "hcog" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_lmg", childRef = "holosight" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_lmg", childRef = "aog" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_rspn101", childRef = "iron_sights" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_rspn101", childRef = "hcog" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_rspn101", childRef = "holosight" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_rspn101", childRef = "aog" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_r97", childRef = "iron_sights" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_r97", childRef = "hcog" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_sniper", childRef = "scope_6x" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_sniper", childRef = "aog" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_sniper", childRef = "scope_4x" } )

		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_car", childRef = "integrated_gyro" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_car", childRef = "extended_ammo" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_car", childRef = "silencer" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_dmr", childRef = "extended_ammo" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_dmr", childRef = "silencer" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_dmr", childRef = "stabilizer" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_g2", childRef = "extended_ammo" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_g2", childRef = "match_trigger" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_g2", childRef = "silencer" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_hemlok", childRef = "extended_ammo" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_hemlok", childRef = "silencer" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_hemlok", childRef = "starburst" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_lmg", childRef = "extended_ammo" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_lmg", childRef = "slammer" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_r97", childRef = "extended_ammo" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_r97", childRef = "scatterfire" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_r97", childRef = "silencer" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_rspn101", childRef = "extended_ammo" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_rspn101", childRef = "recoil_compensator" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_rspn101", childRef = "silencer" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_shotgun", childRef = "extended_ammo" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_shotgun", childRef = "spread_increase_sg" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_shotgun", childRef = "silencer" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_smart_pistol", childRef = "enhanced_targeting" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_smart_pistol", childRef = "extended_ammo" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_smart_pistol", childRef = "silencer" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_sniper", childRef = "extended_ammo" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_sniper", childRef = "silencer" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_weapon_sniper", childRef = "stabilizer" } )

		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_40mm", childRef = "burst" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_40mm", childRef = "extended_ammo" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_arc_cannon", childRef = "capacitor" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_rocket_launcher", childRef = "afterburners" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_rocket_launcher", childRef = "extended_ammo" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_rocket_launcher", childRef = "rapid_fire_missiles" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_sniper", childRef = "extended_ammo" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_sniper", childRef = "fast_reload" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_sniper", childRef = "instant_shot" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_sniper", childRef = "quick_shot" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_triple_threat", childRef = "extended_ammo" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_triple_threat", childRef = "mine_field" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_xo16", childRef = "accelerator" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_xo16", childRef = "burst" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_xo16", childRef = "extended_ammo" } )
		//uiGlobal.eog_unlocks.items.append( { ref = "mp_titanweapon_xo16", childRef = "fast_reload" } )

		uiGlobal.eog_unlocks.items.append( { ref = "titan_decal_skullwingsblk", childRef = null } )
		uiGlobal.eog_unlocks.items.append( { ref = "titan_decal_lastimosa", childRef = null } )

		return
	}

	//printt( "##############################" )
	//printt( "##############################" )
	//printt( "Checking for unlocked items..." )

	// Get unlocks that were completed this match and see if there are items to reward
	//printt( completedChallengeData.len(), "challenges completed" )
	foreach( data in uiGlobal.eog_challengesToShow["most_progress"] )
	{
		if ( data.tiersCompleted.len() == 0 )
			continue

		foreach( tier in data.tiersCompleted )
		{
			local reward = GetItemRewardForChallengeTier( data.ref, tier )
			if ( reward != null )
				uiGlobal.eog_unlocks.items.append( { ref = reward.parentRef, childRef = reward.childRef } )
		}
	}
	//printt( uiGlobal.eog_unlocks.items.len(), "items unlocked from challenge completion" )

	// Loop through all items and see if we earned the level requirement for any of them
	local startLevel = GetLevelForXP( GetPersistentVar( "previousXP" ) )
	local endLevel = GetLevelForXP( GetPersistentVar( "xp" ) )
	//printt( "    Leveled from", startLevel, "->", endLevel )
	if ( startLevel != endLevel )
	{
		// Loop through items
		local allItemRefs = GetAllItemRefs()
		foreach( data in allItemRefs )
		{
			local itemReq = GetItemLevelReq( data.ref, data.childRef )
			if ( itemReq > startLevel && itemReq <= endLevel )
			{
				//printt( "Now meet level requirement for:", data.ref, data.childRef )
				if ( GetGen() > 0 && ( data.ref == "titan_stryder" || data.ref == "titan_ogre" ) )
					continue
				uiGlobal.eog_unlocks.items.append( data )
			}
		}

		// Loop through special unlocks that were set to notify
		local refCount = PersistenceGetEnumCount( "unlockRefs" )
		for ( local i = 0 ; i < refCount ; i++ )
		{
			local itemRef = PersistenceGetEnumItemNameForIndex( "unlockRefs", i )
			local itemReq = GetItemLevelReq( itemRef )

			// If you have regen'd, don't show the burn card slot unlock because they are already unlocked
			if( GetGen() > 0 && itemRef.find( "burn_card_slot" ) == 0 )
				continue

			if ( itemReq > startLevel && itemReq <= endLevel )
			{
				if ( itemRef in nonItemUnlockInfo )
					uiGlobal.eog_unlocks.nonItems.append( { ref = itemRef, childRef = null } )
			}
		}
	}

	// Check if we played a game mode enough times to unlock a game mode loadout slot
	// use the last played game mode
	if ( GetPersistentVar( "savedScoreboardData.numPlayersIMC" ) > 0 || GetPersistentVar( "savedScoreboardData.numPlayersMCOR" ) > 0 )
	{
		local gameModeIndex = GetPersistentVar( "savedScoreboardData.gameMode" )
		if ( gameModeIndex >= 0 )
		{
			local modeName = PersistenceGetEnumItemNameForIndex( "gameModes", gameModeIndex )
			//printt( "modeName:", modeName )

			if ( PersistenceEnumValueIsValid( "gameModesWithLoadouts", modeName ) )
			{
				local gameModeWithLoadoutIndex = PersistenceGetEnumIndexForItemName( "gameModesWithLoadouts", modeName )
				local beforeCount = GetPersistentVar( "gameStats.previousModesPlayed[" + modeName + "]" )
				local afterCount = GetPersistentVar( "gameStats.modesPlayed[" + modeName + "]" )

				local unlockedSlot1 = false
				local unlockedSlot2 = false

				if ( beforeCount < UNLOCK_GAMEMODE_SLOT_1_VALUE && afterCount >= UNLOCK_GAMEMODE_SLOT_1_VALUE )
					unlockedSlot1 = true
				if ( beforeCount < UNLOCK_GAMEMODE_SLOT_2_VALUE && afterCount >= UNLOCK_GAMEMODE_SLOT_2_VALUE )
					unlockedSlot2 = true

				if ( unlockedSlot1 )
				{
					local index = NUM_CUSTOM_LOADOUTS + 1 + (gameModeWithLoadoutIndex*NUM_GAMEMODE_LOADOUTS)
					uiGlobal.eog_unlocks.nonItems.append( { ref = "pilot_custom_loadout_" + index, childRef = null } )
					uiGlobal.eog_unlocks.nonItems.append( { ref = "titan_custom_loadout_" + index, childRef = null } )
				}

				if ( unlockedSlot2 )
				{
					local index = NUM_CUSTOM_LOADOUTS + 2 + (gameModeWithLoadoutIndex*NUM_GAMEMODE_LOADOUTS)
					uiGlobal.eog_unlocks.nonItems.append( { ref = "pilot_custom_loadout_" + index, childRef = null } )
					uiGlobal.eog_unlocks.nonItems.append( { ref = "titan_custom_loadout_" + index, childRef = null } )
				}
			}
		}
	}

	// Check if we unlocked any titan decals
	if ( !IsItemLocked( "edit_titans" ) && !DevEverythingUnlocked() )
	{
		local decalItems = GetAllItemsOfType( itemType.TITAN_DECAL )
		foreach( item in decalItems )
		{
			if ( PersistenceEnumValueIsValid( "BlackMarketUnlocks", item.ref ) )
				continue

			local previouslyUnlocked = GetPersistentVar( "decalsUnlocked[" + item.ref + "]" )
			if ( previouslyUnlocked )
				continue

			if ( !IsItemLocked( item.ref ) )
				uiGlobal.eog_unlocks.items.append( { ref = item.ref, childRef = null } )
		}
	}

	//PrintTable( uiGlobal.eog_unlocks )

	//printt( "##############################" )
	//printt( "##############################" )
}

function InitNonItemDisplayData()
{
	// PILOT PRESET LOADOUTS
	nonItemUnlockInfo[ "pilot_preset_loadout_1" ] <- {}
	nonItemUnlockInfo[ "pilot_preset_loadout_1" ].title 			<- "#PILOT_PRESET_NAME_1"
	nonItemUnlockInfo[ "pilot_preset_loadout_1" ].subTitle 			<- "#EOG_UNLOCKHEADER_PILOT_PRESET"
	nonItemUnlockInfo[ "pilot_preset_loadout_1" ].desc 				<- "#UNLOCK_PRESET_DESC"
	nonItemUnlockInfo[ "pilot_preset_loadout_1" ].image 			<- PILOT_PRESET_IMAGE
	nonItemUnlockInfo[ "pilot_preset_loadout_1" ].imageLabelName 	<- "itemImageLoadout"

	nonItemUnlockInfo[ "pilot_preset_loadout_2" ] <- {}
	nonItemUnlockInfo[ "pilot_preset_loadout_2" ].title 			<- "#PILOT_PRESET_NAME_2"
	nonItemUnlockInfo[ "pilot_preset_loadout_2" ].subTitle 			<- "#EOG_UNLOCKHEADER_PILOT_PRESET"
	nonItemUnlockInfo[ "pilot_preset_loadout_2" ].desc 				<- "#UNLOCK_PRESET_DESC"
	nonItemUnlockInfo[ "pilot_preset_loadout_2" ].image 			<- PILOT_PRESET_IMAGE
	nonItemUnlockInfo[ "pilot_preset_loadout_2" ].imageLabelName 	<- "itemImageLoadout"

	nonItemUnlockInfo[ "pilot_preset_loadout_3" ] <- {}
	nonItemUnlockInfo[ "pilot_preset_loadout_3" ].title 			<- "#PILOT_PRESET_NAME_3"
	nonItemUnlockInfo[ "pilot_preset_loadout_3" ].subTitle 			<- "#EOG_UNLOCKHEADER_PILOT_PRESET"
	nonItemUnlockInfo[ "pilot_preset_loadout_3" ].desc 				<- "#UNLOCK_PRESET_DESC"
	nonItemUnlockInfo[ "pilot_preset_loadout_3" ].image 			<- PILOT_PRESET_IMAGE
	nonItemUnlockInfo[ "pilot_preset_loadout_3" ].imageLabelName 	<- "itemImageLoadout"

	// TITAN PRESET LOADOUTS
	nonItemUnlockInfo[ "titan_preset_loadout_1" ] <- {}
	nonItemUnlockInfo[ "titan_preset_loadout_1" ].title 			<- "#TITAN_PRESET_NAME_1"
	nonItemUnlockInfo[ "titan_preset_loadout_1" ].subTitle 			<- "#EOG_UNLOCKHEADER_TITAN_PRESET"
	nonItemUnlockInfo[ "titan_preset_loadout_1" ].desc 				<- "#UNLOCK_PRESET_DESC"
	nonItemUnlockInfo[ "titan_preset_loadout_1" ].image 			<- TITAN_PRESET_IMAGE
	nonItemUnlockInfo[ "titan_preset_loadout_1" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_preset_loadout_2" ] <- {}
	nonItemUnlockInfo[ "titan_preset_loadout_2" ].title 			<- "#TITAN_PRESET_NAME_2"
	nonItemUnlockInfo[ "titan_preset_loadout_2" ].subTitle 			<- "#EOG_UNLOCKHEADER_TITAN_PRESET"
	nonItemUnlockInfo[ "titan_preset_loadout_2" ].desc 				<- "#UNLOCK_PRESET_DESC"
	nonItemUnlockInfo[ "titan_preset_loadout_2" ].image 			<- TITAN_PRESET_IMAGE
	nonItemUnlockInfo[ "titan_preset_loadout_2" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_preset_loadout_3" ] <- {}
	nonItemUnlockInfo[ "titan_preset_loadout_3" ].title 			<- "#TITAN_PRESET_NAME_3"
	nonItemUnlockInfo[ "titan_preset_loadout_3" ].subTitle 			<- "#EOG_UNLOCKHEADER_TITAN_PRESET"
	nonItemUnlockInfo[ "titan_preset_loadout_3" ].desc 				<- "#UNLOCK_PRESET_DESC"
	nonItemUnlockInfo[ "titan_preset_loadout_3" ].image 			<- TITAN_PRESET_IMAGE
	nonItemUnlockInfo[ "titan_preset_loadout_3" ].imageLabelName 	<- "itemImageChassis"

	// PILOT CUSTOM LOADOUT SLOTS
	nonItemUnlockInfo[ "pilot_custom_loadout_1" ] <- {}
	nonItemUnlockInfo[ "pilot_custom_loadout_1" ].title 			<- "#UNLOCK_PILOT_CUSTOMIZATION_TITLE"
	nonItemUnlockInfo[ "pilot_custom_loadout_1" ].subTitle 			<- null
	nonItemUnlockInfo[ "pilot_custom_loadout_1" ].desc 				<- "#UNLOCK_PILOT_CUSTOMIZATION_DESC"
	nonItemUnlockInfo[ "pilot_custom_loadout_1" ].image 			<- PILOT_CUSTOM_IMAGE
	nonItemUnlockInfo[ "pilot_custom_loadout_1" ].imageLabelName 	<- "itemImageLoadout"

	nonItemUnlockInfo[ "pilot_custom_loadout_4" ] <- {}
	nonItemUnlockInfo[ "pilot_custom_loadout_4" ].title 			<- "#CUSTOM_PILOT_4"
	nonItemUnlockInfo[ "pilot_custom_loadout_4" ].subTitle 			<- "#EOG_UNLOCKHEADER_PILOT_CUSTOM"
	nonItemUnlockInfo[ "pilot_custom_loadout_4" ].desc 				<- null
	nonItemUnlockInfo[ "pilot_custom_loadout_4" ].image 			<- PILOT_CUSTOM_IMAGE
	nonItemUnlockInfo[ "pilot_custom_loadout_4" ].imageLabelName 	<- "itemImageLoadout"

	nonItemUnlockInfo[ "pilot_custom_loadout_5" ] <- {}
	nonItemUnlockInfo[ "pilot_custom_loadout_5" ].title 			<- "#CUSTOM_PILOT_5"
	nonItemUnlockInfo[ "pilot_custom_loadout_5" ].subTitle 			<- "#EOG_UNLOCKHEADER_PILOT_CUSTOM"
	nonItemUnlockInfo[ "pilot_custom_loadout_5" ].desc 				<- null
	nonItemUnlockInfo[ "pilot_custom_loadout_5" ].image 			<- PILOT_CUSTOM_IMAGE
	nonItemUnlockInfo[ "pilot_custom_loadout_5" ].imageLabelName 	<- "itemImageLoadout"

	nonItemUnlockInfo[ "pilot_custom_loadout_6" ] <- {}
	nonItemUnlockInfo[ "pilot_custom_loadout_6" ].title 			<- "#CUSTOM_TDM_PILOT_1"
	nonItemUnlockInfo[ "pilot_custom_loadout_6" ].subTitle 			<- "#EOG_UNLOCKHEADER_PILOT_CUSTOM"
	nonItemUnlockInfo[ "pilot_custom_loadout_6" ].desc 				<- null
	nonItemUnlockInfo[ "pilot_custom_loadout_6" ].image 			<- PILOT_CUSTOM_IMAGE
	nonItemUnlockInfo[ "pilot_custom_loadout_6" ].imageLabelName 	<- "itemImageLoadout"

	nonItemUnlockInfo[ "pilot_custom_loadout_7" ] <- {}
	nonItemUnlockInfo[ "pilot_custom_loadout_7" ].title 			<- "#CUSTOM_TDM_PILOT_2"
	nonItemUnlockInfo[ "pilot_custom_loadout_7" ].subTitle 			<- "#EOG_UNLOCKHEADER_PILOT_CUSTOM"
	nonItemUnlockInfo[ "pilot_custom_loadout_7" ].desc 				<- null
	nonItemUnlockInfo[ "pilot_custom_loadout_7" ].image 			<- PILOT_CUSTOM_IMAGE
	nonItemUnlockInfo[ "pilot_custom_loadout_7" ].imageLabelName 	<- "itemImageLoadout"

	nonItemUnlockInfo[ "pilot_custom_loadout_8" ] <- {}
	nonItemUnlockInfo[ "pilot_custom_loadout_8" ].title 			<- "#CUSTOM_CP_PILOT_1"
	nonItemUnlockInfo[ "pilot_custom_loadout_8" ].subTitle 			<- "#EOG_UNLOCKHEADER_PILOT_CUSTOM"
	nonItemUnlockInfo[ "pilot_custom_loadout_8" ].desc 				<- null
	nonItemUnlockInfo[ "pilot_custom_loadout_8" ].image 			<- PILOT_CUSTOM_IMAGE
	nonItemUnlockInfo[ "pilot_custom_loadout_8" ].imageLabelName 	<- "itemImageLoadout"

	nonItemUnlockInfo[ "pilot_custom_loadout_9" ] <- {}
	nonItemUnlockInfo[ "pilot_custom_loadout_9" ].title 			<- "#CUSTOM_CP_PILOT_2"
	nonItemUnlockInfo[ "pilot_custom_loadout_9" ].subTitle 			<- "#EOG_UNLOCKHEADER_PILOT_CUSTOM"
	nonItemUnlockInfo[ "pilot_custom_loadout_9" ].desc 				<- null
	nonItemUnlockInfo[ "pilot_custom_loadout_9" ].image 			<- PILOT_CUSTOM_IMAGE
	nonItemUnlockInfo[ "pilot_custom_loadout_9" ].imageLabelName 	<- "itemImageLoadout"

	nonItemUnlockInfo[ "pilot_custom_loadout_10" ] <- {}
	nonItemUnlockInfo[ "pilot_custom_loadout_10" ].title 			<- "#CUSTOM_AT_PILOT_1"
	nonItemUnlockInfo[ "pilot_custom_loadout_10" ].subTitle 		<- "#EOG_UNLOCKHEADER_PILOT_CUSTOM"
	nonItemUnlockInfo[ "pilot_custom_loadout_10" ].desc 			<- null
	nonItemUnlockInfo[ "pilot_custom_loadout_10" ].image 			<- PILOT_CUSTOM_IMAGE
	nonItemUnlockInfo[ "pilot_custom_loadout_10" ].imageLabelName 	<- "itemImageLoadout"

	nonItemUnlockInfo[ "pilot_custom_loadout_11" ] <- {}
	nonItemUnlockInfo[ "pilot_custom_loadout_11" ].title 			<- "#CUSTOM_AT_PILOT_2"
	nonItemUnlockInfo[ "pilot_custom_loadout_11" ].subTitle 		<- "#EOG_UNLOCKHEADER_PILOT_CUSTOM"
	nonItemUnlockInfo[ "pilot_custom_loadout_11" ].desc 			<- null
	nonItemUnlockInfo[ "pilot_custom_loadout_11" ].image 			<- PILOT_CUSTOM_IMAGE
	nonItemUnlockInfo[ "pilot_custom_loadout_11" ].imageLabelName 	<- "itemImageLoadout"

	nonItemUnlockInfo[ "pilot_custom_loadout_12" ] <- {}
	nonItemUnlockInfo[ "pilot_custom_loadout_12" ].title 			<- "#CUSTOM_CTF_PILOT_1"
	nonItemUnlockInfo[ "pilot_custom_loadout_12" ].subTitle 		<- "#EOG_UNLOCKHEADER_PILOT_CUSTOM"
	nonItemUnlockInfo[ "pilot_custom_loadout_12" ].desc 			<- null
	nonItemUnlockInfo[ "pilot_custom_loadout_12" ].image 			<- PILOT_CUSTOM_IMAGE
	nonItemUnlockInfo[ "pilot_custom_loadout_12" ].imageLabelName 	<- "itemImageLoadout"

	nonItemUnlockInfo[ "pilot_custom_loadout_13" ] <- {}
	nonItemUnlockInfo[ "pilot_custom_loadout_13" ].title 			<- "#CUSTOM_CTF_PILOT_2"
	nonItemUnlockInfo[ "pilot_custom_loadout_13" ].subTitle 		<- "#EOG_UNLOCKHEADER_PILOT_CUSTOM"
	nonItemUnlockInfo[ "pilot_custom_loadout_13" ].desc 			<- null
	nonItemUnlockInfo[ "pilot_custom_loadout_13" ].image 			<- PILOT_CUSTOM_IMAGE
	nonItemUnlockInfo[ "pilot_custom_loadout_13" ].imageLabelName 	<- "itemImageLoadout"

	nonItemUnlockInfo[ "pilot_custom_loadout_14" ] <- {}
	nonItemUnlockInfo[ "pilot_custom_loadout_14" ].title 			<- "#CUSTOM_LTS_PILOT_1"
	nonItemUnlockInfo[ "pilot_custom_loadout_14" ].subTitle 		<- "#EOG_UNLOCKHEADER_PILOT_CUSTOM"
	nonItemUnlockInfo[ "pilot_custom_loadout_14" ].desc 			<- null
	nonItemUnlockInfo[ "pilot_custom_loadout_14" ].image 			<- PILOT_CUSTOM_IMAGE
	nonItemUnlockInfo[ "pilot_custom_loadout_14" ].imageLabelName 	<- "itemImageLoadout"

	nonItemUnlockInfo[ "pilot_custom_loadout_15" ] <- {}
	nonItemUnlockInfo[ "pilot_custom_loadout_15" ].title 			<- "#CUSTOM_LTS_PILOT_2"
	nonItemUnlockInfo[ "pilot_custom_loadout_15" ].subTitle 		<- "#EOG_UNLOCKHEADER_PILOT_CUSTOM"
	nonItemUnlockInfo[ "pilot_custom_loadout_15" ].desc 			<- null
	nonItemUnlockInfo[ "pilot_custom_loadout_15" ].image 			<- PILOT_CUSTOM_IMAGE
	nonItemUnlockInfo[ "pilot_custom_loadout_15" ].imageLabelName 	<- "itemImageLoadout"

	nonItemUnlockInfo[ "pilot_custom_loadout_16" ] <- {}
	nonItemUnlockInfo[ "pilot_custom_loadout_16" ].title 			<- "#CUSTOM_MFD_PILOT_1"
	nonItemUnlockInfo[ "pilot_custom_loadout_16" ].subTitle 		<- "#EOG_UNLOCKHEADER_PILOT_CUSTOM"
	nonItemUnlockInfo[ "pilot_custom_loadout_16" ].desc 			<- null
	nonItemUnlockInfo[ "pilot_custom_loadout_16" ].image 			<- PILOT_CUSTOM_IMAGE
	nonItemUnlockInfo[ "pilot_custom_loadout_16" ].imageLabelName 	<- "itemImageLoadout"

	nonItemUnlockInfo[ "pilot_custom_loadout_17" ] <- {}
	nonItemUnlockInfo[ "pilot_custom_loadout_17" ].title 			<- "#CUSTOM_MFD_PILOT_2"
	nonItemUnlockInfo[ "pilot_custom_loadout_17" ].subTitle 		<- "#EOG_UNLOCKHEADER_PILOT_CUSTOM"
	nonItemUnlockInfo[ "pilot_custom_loadout_17" ].desc 			<- null
	nonItemUnlockInfo[ "pilot_custom_loadout_17" ].image 			<- PILOT_CUSTOM_IMAGE
	nonItemUnlockInfo[ "pilot_custom_loadout_17" ].imageLabelName 	<- "itemImageLoadout"

	// TITAN CUSTOM LOADOUT SLOTS
	nonItemUnlockInfo[ "titan_custom_loadout_1" ] <- {}
	nonItemUnlockInfo[ "titan_custom_loadout_1" ].title 			<- "#UNLOCK_TITAN_CUSTOMIZATION_TITLE"
	nonItemUnlockInfo[ "titan_custom_loadout_1" ].subTitle 			<- null
	nonItemUnlockInfo[ "titan_custom_loadout_1" ].desc 				<- "#UNLOCK_TITAN_CUSTOMIZATION_DESC"
	nonItemUnlockInfo[ "titan_custom_loadout_1" ].image 			<- TITAN_CUSTOM_IMAGE
	nonItemUnlockInfo[ "titan_custom_loadout_1" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_custom_loadout_4" ] <- {}
	nonItemUnlockInfo[ "titan_custom_loadout_4" ].title 			<- "#CUSTOM_TITAN_4"
	nonItemUnlockInfo[ "titan_custom_loadout_4" ].subTitle 			<- "#EOG_UNLOCKHEADER_TITAN_CUSTOM"
	nonItemUnlockInfo[ "titan_custom_loadout_4" ].desc 				<- null
	nonItemUnlockInfo[ "titan_custom_loadout_4" ].image 			<- TITAN_CUSTOM_IMAGE
	nonItemUnlockInfo[ "titan_custom_loadout_4" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_custom_loadout_5" ] <- {}
	nonItemUnlockInfo[ "titan_custom_loadout_5" ].title 			<- "#CUSTOM_TITAN_5"
	nonItemUnlockInfo[ "titan_custom_loadout_5" ].subTitle 			<- "#EOG_UNLOCKHEADER_TITAN_CUSTOM"
	nonItemUnlockInfo[ "titan_custom_loadout_5" ].desc 				<- null
	nonItemUnlockInfo[ "titan_custom_loadout_5" ].image 			<- TITAN_CUSTOM_IMAGE
	nonItemUnlockInfo[ "titan_custom_loadout_5" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_custom_loadout_6" ] <- {}
	nonItemUnlockInfo[ "titan_custom_loadout_6" ].title 			<- "#CUSTOM_TDM_TITAN_1"
	nonItemUnlockInfo[ "titan_custom_loadout_6" ].subTitle 			<- "#EOG_UNLOCKHEADER_TITAN_CUSTOM"
	nonItemUnlockInfo[ "titan_custom_loadout_6" ].desc 				<- null
	nonItemUnlockInfo[ "titan_custom_loadout_6" ].image 			<- TITAN_CUSTOM_IMAGE
	nonItemUnlockInfo[ "titan_custom_loadout_6" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_custom_loadout_7" ] <- {}
	nonItemUnlockInfo[ "titan_custom_loadout_7" ].title 			<- "#CUSTOM_TDM_TITAN_2"
	nonItemUnlockInfo[ "titan_custom_loadout_7" ].subTitle 			<- "#EOG_UNLOCKHEADER_TITAN_CUSTOM"
	nonItemUnlockInfo[ "titan_custom_loadout_7" ].desc 				<- null
	nonItemUnlockInfo[ "titan_custom_loadout_7" ].image 			<- TITAN_CUSTOM_IMAGE
	nonItemUnlockInfo[ "titan_custom_loadout_7" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_custom_loadout_8" ] <- {}
	nonItemUnlockInfo[ "titan_custom_loadout_8" ].title 			<- "#CUSTOM_CP_TITAN_1"
	nonItemUnlockInfo[ "titan_custom_loadout_8" ].subTitle 			<- "#EOG_UNLOCKHEADER_TITAN_CUSTOM"
	nonItemUnlockInfo[ "titan_custom_loadout_8" ].desc 				<- null
	nonItemUnlockInfo[ "titan_custom_loadout_8" ].image 			<- TITAN_CUSTOM_IMAGE
	nonItemUnlockInfo[ "titan_custom_loadout_8" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_custom_loadout_9" ] <- {}
	nonItemUnlockInfo[ "titan_custom_loadout_9" ].title 			<- "#CUSTOM_CP_TITAN_2"
	nonItemUnlockInfo[ "titan_custom_loadout_9" ].subTitle 			<- "#EOG_UNLOCKHEADER_TITAN_CUSTOM"
	nonItemUnlockInfo[ "titan_custom_loadout_9" ].desc 				<- null
	nonItemUnlockInfo[ "titan_custom_loadout_9" ].image 			<- TITAN_CUSTOM_IMAGE
	nonItemUnlockInfo[ "titan_custom_loadout_9" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_custom_loadout_10" ] <- {}
	nonItemUnlockInfo[ "titan_custom_loadout_10" ].title 			<- "#CUSTOM_AT_TITAN_1"
	nonItemUnlockInfo[ "titan_custom_loadout_10" ].subTitle 		<- "#EOG_UNLOCKHEADER_TITAN_CUSTOM"
	nonItemUnlockInfo[ "titan_custom_loadout_10" ].desc 			<- null
	nonItemUnlockInfo[ "titan_custom_loadout_10" ].image 			<- TITAN_CUSTOM_IMAGE
	nonItemUnlockInfo[ "titan_custom_loadout_10" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_custom_loadout_11" ] <- {}
	nonItemUnlockInfo[ "titan_custom_loadout_11" ].title 			<- "#CUSTOM_AT_TITAN_2"
	nonItemUnlockInfo[ "titan_custom_loadout_11" ].subTitle 		<- "#EOG_UNLOCKHEADER_TITAN_CUSTOM"
	nonItemUnlockInfo[ "titan_custom_loadout_11" ].desc 			<- null
	nonItemUnlockInfo[ "titan_custom_loadout_11" ].image 			<- TITAN_CUSTOM_IMAGE
	nonItemUnlockInfo[ "titan_custom_loadout_11" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_custom_loadout_12" ] <- {}
	nonItemUnlockInfo[ "titan_custom_loadout_12" ].title 			<- "#CUSTOM_CTF_TITAN_1"
	nonItemUnlockInfo[ "titan_custom_loadout_12" ].subTitle 		<- "#EOG_UNLOCKHEADER_TITAN_CUSTOM"
	nonItemUnlockInfo[ "titan_custom_loadout_12" ].desc 			<- null
	nonItemUnlockInfo[ "titan_custom_loadout_12" ].image 			<- TITAN_CUSTOM_IMAGE
	nonItemUnlockInfo[ "titan_custom_loadout_12" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_custom_loadout_13" ] <- {}
	nonItemUnlockInfo[ "titan_custom_loadout_13" ].title 			<- "#CUSTOM_CTF_TITAN_2"
	nonItemUnlockInfo[ "titan_custom_loadout_13" ].subTitle 		<- "#EOG_UNLOCKHEADER_TITAN_CUSTOM"
	nonItemUnlockInfo[ "titan_custom_loadout_13" ].desc 			<- null
	nonItemUnlockInfo[ "titan_custom_loadout_13" ].image 			<- TITAN_CUSTOM_IMAGE
	nonItemUnlockInfo[ "titan_custom_loadout_13" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_custom_loadout_14" ] <- {}
	nonItemUnlockInfo[ "titan_custom_loadout_14" ].title 			<- "#CUSTOM_LTS_TITAN_1"
	nonItemUnlockInfo[ "titan_custom_loadout_14" ].subTitle 		<- "#EOG_UNLOCKHEADER_TITAN_CUSTOM"
	nonItemUnlockInfo[ "titan_custom_loadout_14" ].desc 			<- null
	nonItemUnlockInfo[ "titan_custom_loadout_14" ].image 			<- TITAN_CUSTOM_IMAGE
	nonItemUnlockInfo[ "titan_custom_loadout_14" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_custom_loadout_15" ] <- {}
	nonItemUnlockInfo[ "titan_custom_loadout_15" ].title 			<- "#CUSTOM_LTS_TITAN_2"
	nonItemUnlockInfo[ "titan_custom_loadout_15" ].subTitle 		<- "#EOG_UNLOCKHEADER_TITAN_CUSTOM"
	nonItemUnlockInfo[ "titan_custom_loadout_15" ].desc 			<- null
	nonItemUnlockInfo[ "titan_custom_loadout_15" ].image 			<- TITAN_CUSTOM_IMAGE
	nonItemUnlockInfo[ "titan_custom_loadout_15" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_custom_loadout_16" ] <- {}
	nonItemUnlockInfo[ "titan_custom_loadout_16" ].title 			<- "#CUSTOM_MFD_TITAN_1"
	nonItemUnlockInfo[ "titan_custom_loadout_16" ].subTitle 		<- "#EOG_UNLOCKHEADER_TITAN_CUSTOM"
	nonItemUnlockInfo[ "titan_custom_loadout_16" ].desc 			<- null
	nonItemUnlockInfo[ "titan_custom_loadout_16" ].image 			<- TITAN_CUSTOM_IMAGE
	nonItemUnlockInfo[ "titan_custom_loadout_16" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_custom_loadout_17" ] <- {}
	nonItemUnlockInfo[ "titan_custom_loadout_17" ].title 			<- "#CUSTOM_MFD_TITAN_2"
	nonItemUnlockInfo[ "titan_custom_loadout_17" ].subTitle 		<- "#EOG_UNLOCKHEADER_TITAN_CUSTOM"
	nonItemUnlockInfo[ "titan_custom_loadout_17" ].desc 			<- null
	nonItemUnlockInfo[ "titan_custom_loadout_17" ].image 			<- TITAN_CUSTOM_IMAGE
	nonItemUnlockInfo[ "titan_custom_loadout_17" ].imageLabelName 	<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_stryder" ] <- {}
	nonItemUnlockInfo[ "titan_stryder" ].image 						<- "../ui/menu/loadouts/titan_chassis_stryder_imc"
	nonItemUnlockInfo[ "titan_stryder" ].title 						<- "#CHASSIS_STRYDER_NAME"
	nonItemUnlockInfo[ "titan_stryder" ].subTitle 					<- "#UNLOCK_TITAN_CHASSIS"
	nonItemUnlockInfo[ "titan_stryder" ].desc 						<- "#UNLOCK_CHASSIS_DESC"
	nonItemUnlockInfo[ "titan_stryder" ].imageLabelName 			<- "itemImageChassis"

	nonItemUnlockInfo[ "titan_ogre" ] <- {}
	nonItemUnlockInfo[ "titan_ogre" ].image 						<- "../ui/menu/loadouts/titan_chassis_ogre_imc"
	nonItemUnlockInfo[ "titan_ogre" ].title 						<- "#CHASSIS_OGRE_NAME"
	nonItemUnlockInfo[ "titan_ogre" ].subTitle 						<- "#UNLOCK_TITAN_CHASSIS"
	nonItemUnlockInfo[ "titan_ogre" ].desc 							<- "#UNLOCK_CHASSIS_DESC"
	nonItemUnlockInfo[ "titan_ogre" ].imageLabelName 				<- "itemImageChassis"

	nonItemUnlockInfo[ "burn_card_slot_1" ] <- {}
	nonItemUnlockInfo[ "burn_card_slot_1" ].title 					<- "#EOG_UNLOCKDESC_BURN_CARD_SLOT_1"
	nonItemUnlockInfo[ "burn_card_slot_1" ].subTitle 				<- "#EOG_UNLOCKHEADER_BURN_CARD_SLOT1"
	nonItemUnlockInfo[ "burn_card_slot_1" ].desc 					<- null
	nonItemUnlockInfo[ "burn_card_slot_1" ].image 					<- BURNCARD_SLOT_1_IMAGE
	nonItemUnlockInfo[ "burn_card_slot_1" ].imageLabelName 			<- "itemImageChassis"

	nonItemUnlockInfo[ "burn_card_slot_2" ] <- {}
	nonItemUnlockInfo[ "burn_card_slot_2" ].title 					<- "#EOG_UNLOCKDESC_BURN_CARD_SLOT_2"
	nonItemUnlockInfo[ "burn_card_slot_2" ].subTitle 				<- null
	nonItemUnlockInfo[ "burn_card_slot_2" ].desc 					<- "#UNLOCK_BURN_CARD_SLOT_DESC"
	nonItemUnlockInfo[ "burn_card_slot_2" ].image 					<- BURNCARD_SLOT_2_IMAGE
	nonItemUnlockInfo[ "burn_card_slot_2" ].imageLabelName 			<- "itemImageChassis"

	nonItemUnlockInfo[ "burn_card_slot_3" ] <- {}
	nonItemUnlockInfo[ "burn_card_slot_3" ].title 					<- "#EOG_UNLOCKDESC_BURN_CARD_SLOT_3"
	nonItemUnlockInfo[ "burn_card_slot_3" ].subTitle 				<- null
	nonItemUnlockInfo[ "burn_card_slot_3" ].desc 					<- "#UNLOCK_BURN_CARD_SLOT_DESC"
	nonItemUnlockInfo[ "burn_card_slot_3" ].image 					<- BURNCARD_SLOT_3_IMAGE
	nonItemUnlockInfo[ "burn_card_slot_3" ].imageLabelName 			<- "itemImageChassis"

	nonItemUnlockInfo[ "challenges" ] <- {}
	nonItemUnlockInfo[ "challenges" ].title 						<- "#MENU_CHALLENGES"
	nonItemUnlockInfo[ "challenges" ].subTitle 						<- null
	nonItemUnlockInfo[ "challenges" ].desc 							<- "#UNLOCK_CHALLENGES_DESC"
	nonItemUnlockInfo[ "challenges" ].image 						<- CHALLENGES_IMAGE
	nonItemUnlockInfo[ "challenges" ].imageLabelName 				<- "itemImageChassis"

	for ( local i = 1; i < MAX_BURN_CARD_PACKS_EVER; i++ )
	{
		local packName = "burn_card_pack_" + i
		if ( !GetUnlockLevelReq( packName ) )
			continue

		nonItemUnlockInfo[ packName ] <- {}
		nonItemUnlockInfo[ packName ].title 						<- "#BURN_CARD_PACK"
		nonItemUnlockInfo[ packName ].subTitle 						<- null
		nonItemUnlockInfo[ packName ].desc 							<- "#BURN_CARDS_ASSORTED"
		nonItemUnlockInfo[ packName ].image 						<- BURNCARD_PACK_IMAGE
		nonItemUnlockInfo[ packName ].imageLabelName 				<- "itemImageChassis"
	}
}
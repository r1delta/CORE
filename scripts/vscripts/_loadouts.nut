
function GetLoadoutName( loadout )
{
	if ( LoadoutNameIsToken( loadout.name ) )
		return TranslateTokenToUTF8( loadout.name )

	return loadout.name
}


function SetTextFromItemName( element, ref )
{
	local text = ""

	if ( ref )
		text = GetItemName( ref )

	element.SetText( text )
}

function SetTextFromItemDescription( element, ref )
{
	local text = ""

	if ( ref )
		text = GetItemDescription( ref )

	element.SetText( text )
}

function SetTextFromItemLongDescription( element, ref )
{
	local text = ""

	if ( ref )
		text = GetItemLongDescription( ref )

	if ( text == null )
		element.SetText( "ERROR: NO LONG DESC SPECIFIED" )
	else
		element.SetText( text )
}

function SetTextFromItemAdditionalDescription( element, ref )
{
	local text = ""

	if ( ref )
		text = GetItemAdditionalDescription( ref )

	element.SetText( text )
}

function SetTextFromItemAdditionalName( element, ref )
{
	local text = ""

	if ( ref )
		text = GetItemAdditionalName( ref )

	element.SetText( text )
}

function SetImageFromItemImage( element, ref )
{
	if ( ref )
	{
		element.SetImage( GetItemImage( ref ) )
		element.Show()
	}
	else
	{
		element.Hide()
	}
}

function SetImageFromItemIcon( element, ref )
{
	if ( ref )
	{
		element.SetImage( GetItemIcon( ref ) )
		element.Show()
	}
	else
	{
		element.Hide()
	}
}

function SetBarFromItemDamageStat( panel, ref, modRef = null )
{
	local statValue = GetItemDamageStat( ref )
	if ( statValue == null )
		statValue = 0

	local modStatValue = 0
	if ( modRef != null )
	{
		modStatValue = GetSubitemDamageStat( ref, modRef )
		if ( modStatValue == null )
			modStatValue = 0
	}

	SetBarFillValue( panel, statValue, modStatValue )
}

function SetBarFromItemAccuracyStat( panel, ref, modRef = null )
{
	local statValue = GetItemAccuracyStat( ref )
	if ( statValue == null )
		statValue = 0

	local modStatValue = 0
	if ( modRef != null )
	{
		modStatValue = GetSubitemAccuracyStat( ref, modRef )
		if ( modStatValue == null )
			modStatValue = 0
	}

	SetBarFillValue( panel, statValue, modStatValue )
}

function SetBarFromItemRangeStat( panel, ref, modRef = null )
{
	local statValue = GetItemRangeStat( ref )
	if ( statValue == null )
		statValue = 0

	local modStatValue = 0
	if ( modRef != null )
	{
		modStatValue = GetSubitemRangeStat( ref, modRef )
		if ( modStatValue == null )
			modStatValue = 0
	}

	SetBarFillValue( panel, statValue, modStatValue )
}

function SetBarFromItemFireRateStat( panel, ref, modRef = null )
{
	local statValue = GetItemFireRateStat( ref )
	if ( statValue == null )
		statValue = 0

	local modStatValue = 0
	if ( modRef != null )
	{
		modStatValue = GetSubitemFireRateStat( ref, modRef )
		if ( modStatValue == null )
			modStatValue = 0
	}

	SetBarFillValue( panel, statValue, modStatValue )
}

function SetTextFromItemClipSize( element, ref )
{
	local text = ""

	if ( ref )
		text = GetItemClipSize( ref ).tostring()

	element.SetText( text )
}

function SetTextFromSubItemClipSize( element, ref, modRef )
{
	element.SetText( "" )
	if ( ref && modRef )
	{
		local clipDiff = GetSubItemClipSizeStat( ref, modRef )
		if ( clipDiff == null || clipDiff == 0 )
			return

		if ( clipDiff > 0 )
		{
			element.SetColor( 141, 197, 84, 255 )
			element.SetText( "#MOD_CLIP_AMMO_INCREASE", clipDiff.tostring() )
		}
		else
		{
			element.SetColor( 211, 77, 61, 255 )
			element.SetText( "#MOD_CLIP_AMMO_DECREASE", abs(clipDiff).tostring() )
		}

	}
}

function SetTextFromItemDashCount( element, ref )
{
	local text = ""

	if ( ref )
		text = GetItemDashCountStat( ref ).tostring()

	element.SetText( text )
}

function SetBarFromItemSpeedStat( panel, ref )
{
	local statValue = GetItemSpeedStat( ref )
	if ( statValue == null )
		statValue = 0

	SetBarFillValue( panel, statValue )
}

function SetBarFromItemAccelStat( panel, ref )
{
	local statValue = GetItemAccelStat( ref )
	if ( statValue == null )
		statValue = 0

	SetBarFillValue( panel, statValue )
}

function SetBarFromItemHealthStat( panel, ref )
{
	local statValue = GetItemHealthStat( ref )
	if ( statValue == null )
		statValue = 0

	SetBarFillValue( panel, statValue )
}

function SetBarFillValue( panel, statValue, changeValue = 0 )
{
	local barBottom = panel.GetChild( "BarFillBottom" )
	local barTop = panel.GetChild( "BarFillTop" )
	local shadow = panel.GetChild( "BarFillShadow" )
	local frac

	if ( changeValue == 0 )
	{
		barBottom.Hide()
		barTop.SetImage( "../ui/menu/eog/xp_bar" )
		barTop.Show()

		frac = GraphCapped( statValue, 0, 100, 0.0, 1.0 )
		barTop.SetScaleX( frac )
		shadow.SetScaleX( frac )
	}
	else if ( changeValue > 0 )
	{
		barBottom.SetImage( "../ui/menu/eog/xp_bar_fill_green" )
		barBottom.Show()
		barTop.SetImage( "../ui/menu/eog/xp_bar" )
		barTop.Show()

		frac = GraphCapped( statValue, 0, 100, 0.0, 1.0 )
		barTop.SetScaleX( frac )

		frac = GraphCapped( statValue + changeValue, 0, 100, 0.0, 1.0 )
		barBottom.SetScaleX( frac )
		shadow.SetScaleX( frac )
	}
	else if ( changeValue < 0 )
	{
		barBottom.SetImage( "../ui/menu/eog/xp_bar_fill_red" )
		barBottom.Show()
		barTop.SetImage( "../ui/menu/eog/xp_bar" )
		barTop.Show()

		frac = GraphCapped( statValue, 0, 100, 0.0, 1.0 )
		barBottom.SetScaleX( frac )
		shadow.SetScaleX( frac )

		frac = GraphCapped( statValue + changeValue, 0, 100, 0.0, 1.0 )
		barTop.SetScaleX( frac )
	}
}

function SetTextFromSubitemName( element, parentRef, childRef, defaultText = "" )
{
	local text = defaultText

	if ( parentRef && childRef )
		text = GetSubitemName( parentRef, childRef )

	if (!text || text == "")
		text = defaultText

	element.SetText( text )
}

function SetTextFromSubitemDescription( element, parentRef, childRef, defaultText = "" )
{
	local text = defaultText

	if ( parentRef && childRef )
		text = GetSubitemDescription( parentRef, childRef )

	element.SetText( text )
}

function SetTextFromSubitemLongDescription( element, parentRef, childRef, defaultText = "" )
{
	local text = defaultText

	if ( parentRef && childRef )
		text = GetSubitemLongDescription( parentRef, childRef )

	if ( text == null )
		element.SetText( "ERROR: NO LONG DESC SPECIFIED" )
	else
		element.SetText( text )
}

function SetImageFromSubitemImage( element, parentRef, childRef )
{
	if ( parentRef && childRef )
	{
		element.SetImage( GetSubitemImage( parentRef, childRef ) )
		element.Show()
	}
	else
	{
		element.Hide()
	}
}

function SetImageFromSubitemIcon( element, parentRef, childRef, defaultIcon = null )
{
	local icon = null
	if ( parentRef && childRef )
	{
		icon = GetSubitemIcon( parentRef, childRef )
	}

	if ( parentRef && childRef && icon )
	{
		element.SetImage( icon )
		element.Show()
	}
	else
	{
		if ( defaultIcon )
		{
			element.SetImage( defaultIcon )
			element.Show()
		}
		else
			element.Hide()
	}
}

function SetImageFromItemTeamImages( element, ref, team )
{
	if ( ref )
	{
		local itemTeamImages = GetItemTeamImages( ref )
		if (itemTeamImages && team in itemTeamImages)
		{
			element.SetImage( GetItemTeamImages( ref )[team] )
			element.Show()
		}
		else
		{
			element.Hide()
		}
	}
	else
	{
		element.Hide()
	}
}

function SetImageFromItemCoreImage( element, ref )
{
	if ( ref )
	{
		element.SetImage( GetItemCoreImage( ref ) )
		element.Show()
	}
	else
	{
		element.Hide()
	}
}

function GetSetFileFromPrimaryWeaponAndPersistentData( ref, isFemale )
{
	local setFile

	local bodyType = GetWeaponInfoFileKeyField_Global( ref, "body_type" )

	Assert( bodyType )

	local pilotGenderString
	if ( isFemale )
		pilotGenderString = "female"
	else
		pilotGenderString = "male"

	local pilotSuffix

	switch ( bodyType )
	{
		case "close_quarters":
			pilotSuffix = "_cq"
			break

		case "designated_marksman":
			pilotSuffix = "_dm"
			break

		case "battle_rifle":
			pilotSuffix = "_br"
			break

		default:
			Assert( 0, "Error, unknown body type " + bodyType )
	}

	setFile = "pilot_" + pilotGenderString + pilotSuffix

	//printt( "ref: ", ref, " is bodyType: ", bodyType,  " using setFile: ", setFile )

	return setFile
}

function InitPresetLoadouts()
{
	local loadout = {}
	pilotLoadouts <- []
	titanLoadouts <- []

	loadout.name <- "#PILOT_PRESET_NAME_1"
	loadout.ref <- "pilot_preset_loadout_1"
	loadout.primary <- "mp_weapon_rspn101"
	loadout.primaryAttachment <- "hcog"
	loadout.primaryMod <- null
	loadout.secondary <- "mp_weapon_rocket_launcher"
	loadout.sidearm <- "mp_weapon_semipistol"
	loadout.sidearmMod <- null
	loadout.special <- "mp_ability_cloak"
	loadout.ordnance <- "mp_weapon_frag_grenade"
	loadout.race <- "race_human_male"

	loadout.passive1 <- "pas_ordnance_pack"
	loadout.passive2 <- "pas_longer_bubble"

	pilotLoadouts.append( clone loadout )

	loadout.clear()
	loadout.name <- "#PILOT_PRESET_NAME_2"
	loadout.ref <- "pilot_preset_loadout_2"
	loadout.primary <- "mp_weapon_smart_pistol"
	loadout.primaryAttachment <- null
	loadout.primaryMod <- "silencer"
	loadout.secondary <- "mp_weapon_smr"
	loadout.sidearm <- "mp_weapon_autopistol"
	loadout.sidearmMod <- null
	loadout.special <- "mp_ability_cloak"
	loadout.ordnance <- "mp_weapon_frag_grenade"
	loadout.race <- "race_human_female"

	loadout.passive1 <- "pas_power_cell"
	loadout.passive2 <- "pas_minimap_ai"
	pilotLoadouts.append( clone loadout )

	loadout.clear()
	loadout.name <- "#PILOT_PRESET_NAME_3"
	loadout.ref <- "pilot_preset_loadout_3"
	loadout.primary <- "mp_weapon_shotgun"
	loadout.primaryAttachment <- null
	loadout.primaryMod <- null
	loadout.secondary <- "mp_weapon_smr"
	loadout.sidearm <- "mp_weapon_semipistol"
	loadout.sidearmMod <- null
	loadout.special <- "mp_ability_cloak"
	loadout.ordnance <- "mp_weapon_frag_grenade"
	loadout.race <- "race_human_male"

	loadout.passive1 <- "pas_wall_runner"
	loadout.passive2 <- "pas_longer_bubble"
	pilotLoadouts.append( clone loadout )




	loadout.clear()
	loadout.name <- "#TITAN_PRESET_NAME_1"
	loadout.ref <- "titan_preset_loadout_1"
	loadout.setFile <- "titan_atlas"
	loadout.primary <- "mp_titanweapon_xo16"
	loadout.primaryAttachment <- null
	loadout.primaryMod <- null
	loadout.secondary <- null
	loadout.special <- "mp_titanweapon_vortex_shield"
	loadout.ordnance <- "mp_titanweapon_salvo_rockets"
	loadout.passive1 <- "pas_shield_regen"
	loadout.passive2 <- "pas_auto_eject"
	loadout.decal <- null
	loadout.voiceChoice <- "titanos_betty"
	titanLoadouts.append( clone loadout )

	loadout.clear()
	loadout.name <- "#TITAN_PRESET_NAME_2"
	loadout.ref <- "titan_preset_loadout_2"
	loadout.setFile <- "titan_ogre"
	loadout.primary <- "mp_titanweapon_40mm"
	loadout.primaryAttachment <- null
	loadout.primaryMod <- null
	loadout.secondary <- null
	loadout.special <- "mp_titanweapon_vortex_shield"
	loadout.ordnance <- "mp_titanweapon_salvo_rockets"
	loadout.passive1 <- "pas_build_up_nuclear_core"
	loadout.passive2 <- "pas_doomed_time"
	loadout.decal <- null
	loadout.voiceChoice <- "titanos_betty"
	titanLoadouts.append( clone loadout )

	loadout.clear()
	loadout.name <- "#TITAN_PRESET_NAME_3"
	loadout.ref <- "titan_preset_loadout_3"
	loadout.setFile <- "titan_stryder"
	loadout.primary <- "mp_titanweapon_rocket_launcher"
	loadout.primaryAttachment <- null
	loadout.primaryMod <- null
	loadout.secondary <- null
	loadout.special <- "mp_titanweapon_vortex_shield"
	loadout.ordnance <- "mp_titanweapon_salvo_rockets"
	loadout.passive1 <- "pas_shield_regen"
	loadout.passive2 <- "pas_doomed_time"
	loadout.decal <- null
	loadout.voiceChoice <- "titanos_betty"
	titanLoadouts.append( clone loadout )
}

function InitEmptyCustomLoadouts()
{
	customPilotLoadouts <- []
	customTitanLoadouts <- []
	for ( local i = 0 ; i < NUM_CUSTOM_LOADOUTS ; i++ )
	{
		customPilotLoadouts.append(null)
		customTitanLoadouts.append(null)
	}
}

function InitCustomLoadouts()
{
	EndSignal( uiGlobal.signalDummy, "LevelShutdown" )

	local loadout = {}
	customPilotLoadouts <- []
	customTitanLoadouts <- []

	while ( !GetPersistentVar( "previouslyInitialized" ).tointeger() )
		wait 0
	while ( GetPersistentVar( "initializedVersion" ).tointeger() < PERSISTENCE_INIT_VERSION )
		wait 0

	local numModes = PersistenceGetEnumCount( "gameModesWithLoadouts" )

	for ( local i = 0; i < NUM_CUSTOM_LOADOUTS + (NUM_GAMEMODE_LOADOUTS * numModes); i++ )
	{
		loadout.clear()
		loadout.name <- GetPersistentVar( "pilotLoadouts[" + i + "].name" )
		loadout.ref <- "pilot_custom_loadout_" + (i + 1)
		loadout.primary <- GetPersistentVar( "pilotLoadouts[" + i + "].primary" )
		loadout.secondary <- GetPersistentVar( "pilotLoadouts[" + i + "].secondary" )
		loadout.sidearm <- GetPersistentVar( "pilotLoadouts[" + i + "].sidearm" )
		loadout.special <- GetPersistentVar( "pilotLoadouts[" + i + "].special" )
		loadout.ordnance <- GetPersistentVar( "pilotLoadouts[" + i + "].ordnance" )
		loadout.primaryMod <- GetPersistentVar( "pilotLoadouts[" + i + "].primaryMod" )
		loadout.primaryAttachment <- GetPersistentVar( "pilotLoadouts[" + i + "].primaryAttachment" )
		loadout.sidearmMod <- GetPersistentVar( "pilotLoadouts[" + i + "].sidearmMod" )
		loadout.secondaryMod <- GetPersistentVar( "pilotLoadouts[" + i + "].secondaryMod" )
		loadout.passive1 <- GetPersistentVar( "pilotLoadouts[" + i + "].passive1" )
		loadout.passive2 <- GetPersistentVar( "pilotLoadouts[" + i + "].passive2" )
		loadout.race <- GetPersistentVar( "pilotLoadouts[" + i + "].race" )

		customPilotLoadouts.append( clone loadout )
	}

	for ( local i = 0; i < NUM_CUSTOM_LOADOUTS + (NUM_GAMEMODE_LOADOUTS * numModes); i++ )
	{
		loadout.clear()
		loadout.name <- GetPersistentVar( "titanLoadouts[" + i + "].name" )
		loadout.ref <- "titan_custom_loadout_" + (i + 1)
		loadout.setFile <- GetPersistentVar( "titanLoadouts[" + i + "].setFile" )
		loadout.primary <- GetPersistentVar( "titanLoadouts[" + i + "].primary" )
		loadout.special <- GetPersistentVar( "titanLoadouts[" + i + "].special" )
		loadout.ordnance <- GetPersistentVar( "titanLoadouts[" + i + "].ordnance" )
		loadout.primaryMod <- GetPersistentVar( "titanLoadouts[" + i + "].primaryMod" )
		loadout.primaryAttachment <- null
		loadout.secondary <- null
		loadout.passive1 <- GetPersistentVar( "titanLoadouts[" + i + "].passive1" )
		loadout.passive2 <- GetPersistentVar( "titanLoadouts[" + i + "].passive2" )
		loadout.decal <- GetPersistentVar( "titanLoadouts[" + i + "].decal" )
		loadout.voiceChoice <- GetPersistentVar( "titanLoadouts[" + i + "].voiceChoice" )

		customTitanLoadouts.append( clone loadout )
	}
}

function UI_GetPresetPilotLoadout( loadoutIndex )
{
	if ( loadoutIndex >= pilotLoadouts.len() )
		return null

	return pilotLoadouts[loadoutIndex]
}

function UI_GetCustomPilotLoadout( loadoutIndex )
{
	if ( loadoutIndex >= customPilotLoadouts.len() )
		return null

	return customPilotLoadouts[loadoutIndex]
}

function UI_GetPresetTitanLoadout( loadoutIndex )
{
	if ( loadoutIndex >= titanLoadouts.len() )
		return null

	return titanLoadouts[loadoutIndex]
}

function UI_GetCustomTitanLoadout( loadoutIndex )
{
	if ( loadoutIndex >= customTitanLoadouts.len() )
		return null

	return customTitanLoadouts[loadoutIndex]
}

function UI_GetPresetPilotLoadouts()
{
	return pilotLoadouts
}

function UI_GetCustomPilotLoadouts()
{
	return customPilotLoadouts
}

function UI_GetPresetTitanLoadouts()
{
	return titanLoadouts
}

function UI_GetCustomTitanLoadouts()
{
	return customTitanLoadouts
}

function GetUnlockLevelForCustomLoadout( loadoutClass, slot )
{
	if ( loadoutClass == "pilot" )
		return unlockLevels[ "pilot_custom_loadout_" + ( slot + 1 ) ]
	else if ( loadoutClass = "titan" )
		return unlockLevels[ "titan_custom_loadout_" + ( slot + 1 ) ]
	else
		Assert( 0, "Invalid loadout class" )
}

function LoadoutNameIsToken( name )
{
	if ( StringContains( name, "#CUSTOM_PILOT_" ) || StringContains( name, "#CUSTOM_TITAN_" ) )
		return true

	return false
}
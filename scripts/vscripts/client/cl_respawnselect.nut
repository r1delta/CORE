const IMAGE_SELECT_TITAN		= "../ui/menu/death_screen/ds_icon_titan"
const IMAGE_SELECT_PILOT		= "../ui/menu/death_screen/ds_icon_pilot"
const IMAGE_SELECT_FEMALE		= "../ui/menu/death_screen/ds_icon_pilot_female"

const IMAGE_SELECT_TITAN_HOVER	= "../ui/menu/death_screen/ds_icon_titan_hover"
const IMAGE_SELECT_PILOT_HOVER	= "../ui/menu/death_screen/ds_icon_pilot_hover"
const IMAGE_SELECT_FEMALE_HOVER	= "../ui/menu/death_screen/ds_icon_pilot_female_hover"

const RESPAWN_SELECTIONS = 2
const PRE_SHOW_WAIT = 1.5
const RESPAWN_BUILTINS = 2
const TITLE2_ENABLED = 0

const SELECT_NONE 			= 0
const SELECT_DEAD			= 1
const SELECT_TITAN_PILOT 	= 2
const SELECT_BURN_CARD 		= 3
const SELECT_PREMATCH		= 4
const SELECT_BURNCARDS_ONLY = 5

PrecacheHUDMaterial( IMAGE_SELECT_TITAN )
PrecacheHUDMaterial( IMAGE_SELECT_PILOT )
PrecacheHUDMaterial( IMAGE_SELECT_FEMALE )
PrecacheHUDMaterial( IMAGE_SELECT_TITAN_HOVER )
PrecacheHUDMaterial( IMAGE_SELECT_PILOT_HOVER )
PrecacheHUDMaterial( IMAGE_SELECT_FEMALE_HOVER )

function main()
{
	Globalize( RespawnSelect_AddClient )

	Globalize( ShowRespawnSelect )
	Globalize( HideRespawnSelect )
	Globalize( CreateRespawnSelectElement )
	Globalize( RegisterRespawnCommands )
	Globalize( DeregisterRespawnCommands )
	Globalize( UpdateBurnCardPrematchButtonText )
	Globalize( RespawnSelectionPending )
	Globalize( BurnCardSelectionMethod )
	Globalize( ShowBurnCardSelectors )

	FlagInit( "DisableBurnCardMenu" )

	RegisterSignal( "TitanReadyPulse" )
	RegisterSignal( "DisplayActiveBurnCard" )
	RegisterSignal( "RefreshDelayed" )

	file.selectingRespawnStep <- SELECT_NONE
	file.respawnSelectHud <- null
	file.respawnBackground <- null
	file.respawnSelect <- null
	file.burnCardSelectionMethod <- null

	file.respawnSelectVisible <- false

	level.selectedBurnCardID <- null
	file.lastKnownSpawnAsTitan <- null

	AddCreateCallback( "player", RespawnSelect_OnPlayerCreation )

	RegisterServerVarChangeCallback( "gameState", RespawnSelect_GameStateChanged )
	file.clickIgnoreTime <- 0
}

function SCB_RefreshBurnCardSelector()
{
	local player = GetLocalClientPlayer()
	//UpdateRespawnSelect( player )
	UpdateAndShowBurnCardSelectors( player )
}
Globalize( SCB_RefreshBurnCardSelector )

function SetRespawnSelectIgnoreTime( amt )
{
	file.clickIgnoreTime = Time() + amt
}
Globalize( SetRespawnSelectIgnoreTime )

function RespawnSelect_OnPlayerCreation( player, isRecreate )
{
	if ( player != GetLocalClientPlayer() )
		return

	if ( !IsWatchingKillReplay() )
		return

	if ( file.selectingRespawnStep != SELECT_BURN_CARD && ShouldShowSpawnAsTitanHint( player ) )
		SetRespawnSelectState( SELECT_TITAN_PILOT )
}


function ShowRespawnSelect( ... )
{
	local player = GetLocalClientPlayer()

	if ( PlayerMustRevive( player ) )
		return

	if ( GetGameState() == eGameState.Prematch && ShouldShowBurnCardSelection( player ) )
	{
		SetRespawnSelectState( SELECT_PREMATCH )
		return
	}

	if ( ShouldSetRespawnSelectStateNone( player ) )
	{
		SetRespawnSelectState( SELECT_NONE )
		return
	}

	file.lastKnownSpawnAsTitan = player.GetPersistentVar( "spawnAsTitan" )

	if ( !CanSpawnAsTitan() )
		file.lastKnownSpawnAsTitan = false

	level.selectedBurnCardID = null

	if ( file.selectingRespawnStep == SELECT_BURN_CARD )
	{
		SetRespawnSelectState( SELECT_BURN_CARD )
	}
	else if ( ShouldShowSpawnAsTitanHint( player ) )
	{
		SetRespawnSelectState( SELECT_TITAN_PILOT )
	}
	else
	{
		SetRespawnSelectState( SELECT_DEAD )
	}

}

function ShouldSetRespawnSelectStateNone( player )
{
	if ( IsAlive( player ) && !IsWatchingKillReplay() )
		return true

	if ( player.GetPlayerSettings() == "spectator" && !IsWatchingKillReplay() )
		return true

	if ( IsRoundBased() && IsMatchOver() )
		return true

	return false
}

function ShowBurnCardSelectors()
{
	SetRespawnSelectState( SELECT_BURNCARDS_ONLY )
}

function HideRespawnSelect()
{
	SetRespawnSelectState( SELECT_NONE )
}


function RespawnSelect_GameStateChanged()
{
	ShowRespawnSelect()
}

function SetRespawnSelectState( newState )
{
	local player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return

	file.selectingRespawnStep = newState
	UpdateRespawnSelect( player )
}

function RespawnSelectionPending()
{
	return file.selectingRespawnStep == SELECT_TITAN_PILOT
}

function UpdateRespawnSelect( player )
{
	file.respawnSelect.Show()
	file.respawnBackground.Hide()
	file.respawnSelectTitle.Hide()

	foreach ( table in file.respawnSelectHud )
	{
		table.hudElement.Hide()
	}

	file.respawnSelectVisible = false
	HideBurnCardOnDeckCard()
	HideBurnCardSelectorDisplay()
	HideBurnCardPrematchButton()

	switch ( file.selectingRespawnStep )
	{
		case SELECT_DEAD:
		case SELECT_BURNCARDS_ONLY:
			if ( ShouldShowBurnCardSelection( player ) )
			{
				UpdateAndShowBurnCardOnDeckOrActive( player )

				if ( ShouldEnableBurnCardSelectionPrompts( player ) )
				{
					RegisterRespawnCommands( "three" )
					UpdateAndShowBurnCardSelectors( player )
				}
			}

			TryShowSpectatorSelectButtons( player )

			break

		case SELECT_PREMATCH:
			if ( ShouldShowBurnCardSelection( player ) )
			{
				UpdateAndShowBurnCardOnDeckOrActive( player )

				if ( ShouldEnableBurnCardSelectionPrompts( player ) )
				{
					RegisterRespawnCommands( "menu" )
					UpdateBurnCardPrematchButtonText( player )
					ShowBurnCardPrematchButton()
					UpdateAndShowBurnCardSelectors( player )
				}
			}
			break

		case SELECT_TITAN_PILOT:
			ShowRespawnSelectPilotTitan( 255 )

			if ( ShouldShowBurnCardSelection( player ) )
			{
				RegisterRespawnCommands( "three" )
				UpdateAndShowBurnCardOnDeckOrActive( player )
				UpdateAndShowBurnCardSelectors( player )
			}
			break

		case SELECT_NONE:
			TryShowSpectatorSelectButtons( player )
			DeregisterRespawnCommands()
			return
	}

	if ( BurnCardSelectionMethod() == null )
		RegisterRespawnCommands( "pilot_or_titan" )
}

function ShouldEnableBurnCardSelectionPrompts( player )
{
	if ( GAMETYPE == COOPERATIVE )
	{
		local cardInfo = GetBurnCardOnDeckOrActive( player )

		if ( !cardInfo )
			return true

		if ( GetBurnCardLastsUntil( cardInfo.cardRef ) == BC_NEXTTITANDROP )
			return true  // HACK keeps normal Titan burn card reselect behavior, but the normal reselect behavior is a bug (can change between rounds, effectively not burning cards that were used)

		return false  // if a coop player has a PILOT burn card active, it's impossible for him to select select another one, so don't display
	}

	return true
}

function UpdateBurnCardPrematchButtonText( player )
{
	local table = GetBurnCardOnDeckOrActive( player )
	if ( table && !table.active )
		file.burnCardPrematchLabel.SetText( "#BURNCARD_PREMATCH_LABEL_CHANGE" )
	else if ( table && table.active )
		file.burnCardPrematchLabel.SetText( "#BURNCARD_PREMATCH_LABEL_REPLACE" )
	else
		file.burnCardPrematchLabel.SetText( "#BURNCARD_PREMATCH_LABEL_SELECT" )
}

function ShowBurnCardPrematchButton()
{
	file.burnCardPrematchLabel.Show()
	file.burnCardPrematchIcon.Show()
}

function HideBurnCardPrematchButton()
{
	file.burnCardPrematchLabel.Hide()
	file.burnCardPrematchIcon.Hide()
}

function ShowRespawnSelectPilotTitan( goalAlpha = 255 )
{
	if ( !file.respawnSelectVisible )
	{
		file.respawnSelectTitle.Show()

		file.respawnSelectTitle.SetColor( 255, 255, 255, 0 )
		file.respawnSelectTitle.FadeOverTime( 255, 0.5 )

		foreach ( table in file.respawnSelectHud )
		{
			table.hudElement.Show()
			table.image.Show()
			table.hudElement.SetPanelAlpha( 0 )
		}

		local timeElem = file.respawnSelectHud[0].time
		if ( !CanSpawnAsTitan() )
		{
			local player = GetLocalClientPlayer()
			local remainingTime = player.GetNextTitanRespawnAvailable() - Time()

			if ( PetTitanDeployed() )
			{
				timeElem.Hide()
			}
			else
			{
				timeElem.Show()
				timeElem.SetAutoText( "", HATT_COUNTDOWN_TIME, player.GetNextTitanRespawnAvailable() )

				thread RefreshRespawnSelectDelayed( remainingTime )
			}
		}
		else
		{
			timeElem.Hide()
		}
	}

	foreach ( table in file.respawnSelectHud )
	{
		table.hudElement.FadePanelOverTime( goalAlpha, 0.5 )
	}

	file.respawnSelectVisible = true

	RefreshRespawnSelectPilotTitan( true )
}

function RefreshRespawnSelectDelayed( delay )
{
	level.ent.Signal( "RefreshDelayed" )
	level.ent.EndSignal( "RefreshDelayed" )

	wait delay
	thread RefreshRespawnSelectPilotTitan( true )

	if ( file.lastKnownSpawnAsTitan )
	{
		local player = GetLocalClientPlayer()
		player.ClientCommand( "CC_SelectRespawn 1" )
	}
}

function CanSpawnAsTitan()
{
	local player = GetLocalClientPlayer()
	if ( !player )
		return false

	local nextTitanTime = player.GetNextTitanRespawnAvailable()

	if ( nextTitanTime <= 0 )
		return false

	return Time() > nextTitanTime
}


function RefreshRespawnSelectPilotTitan( titanReady = false )
{
	local player = GetLocalClientPlayer()

	// 0 = titan, 1 = pilot
	if ( file.lastKnownSpawnAsTitan )
	{
		// TITAN IS SELECTED
		if ( CanSpawnAsTitan() )
		{
			file.respawnSelectHud[ 0 ].notReady.SetColor( 224, 224, 224, 255 )
			file.respawnSelectHud[ 0 ].notReady.SetText( "#RESPAWNSELECT_READY" )
			if ( titanReady )
				thread TitanReadyPulse( player, true )

			file.respawnSelectHud[ 0 ].time.Hide()

			file.respawnSelectTitle.SetText( "#RESPAWNSELECT_TITAN" )

			file.respawnSelectHud[ 0 ].image.SetImage( IMAGE_SELECT_TITAN_HOVER )
			file.respawnSelectHud[ 0 ].image.SetColor( 255, 255, 255, 255 )
			file.respawnSelectHud[ 0 ].hover.Show()
			file.respawnSelectHud[ 0 ].hover.SetColor( 255, 255, 255, 255 )
		}
		else
		{
			file.respawnSelectHud[ 0 ].notReady.SetColor( 128, 128, 128, 255 )
			if ( PetTitanDeployed() )
			{
				file.respawnSelectHud[ 0 ].time.Hide()
				file.respawnSelectHud[ 0 ].notReady.SetText( "#RESPAWNSELECT_DEPLOYED" )
				thread TitanReadyPulse( player )
			}
			else
			{
				file.respawnSelectHud[ 0 ].time.Show()
				file.respawnSelectHud[ 0 ].notReady.SetText( "#RESPAWNSELECT_NOT_READY" )
				if ( Riff_SpawnAsTitan() == eSpawnAsTitan.Never )
				{
					file.respawnSelectHud[ 0 ].notReady.SetText( "#SETTING_DISABLED" )
					file.respawnSelectHud[ 0 ].time.Hide()
				}
				thread TitanReadyPulse( player )
			}

			if ( Riff_SpawnAsTitan() == eSpawnAsTitan.Never )
				file.respawnSelectTitle.SetText( "#SETTING_DISABLED" )
			else
				file.respawnSelectTitle.SetText( "#RESPAWNSELECT_TITAN_UNAVAILABLE" )

			file.respawnSelectHud[ 0 ].image.SetImage( IMAGE_SELECT_TITAN )
			file.respawnSelectHud[ 0 ].image.SetColor( 150, 150, 150, 255 )
			file.respawnSelectHud[ 0 ].hover.Show()
			file.respawnSelectHud[ 0 ].hover.SetColor( 224, 224, 224, 255 )
		}

		if ( PlayerIsFemale( player ) )
			file.respawnSelectHud[ 1 ].image.SetImage( IMAGE_SELECT_FEMALE )
		else
			file.respawnSelectHud[ 1 ].image.SetImage( IMAGE_SELECT_PILOT )

		file.respawnSelectHud[ 1 ].image.SetColor( 255, 255, 255, 255 )
		file.respawnSelectHud[ 1 ].hover.Hide()
	}
	else
	{
		// PILOT IS SELECTED
		if ( PlayerIsFemale( player ) )
			file.respawnSelectHud[ 1 ].image.SetImage( IMAGE_SELECT_FEMALE_HOVER )
		else
			file.respawnSelectHud[ 1 ].image.SetImage( IMAGE_SELECT_PILOT_HOVER )

		file.respawnSelectHud[ 1 ].image.SetColor( 255, 255, 255, 255 )
		file.respawnSelectHud[ 1 ].hover.Show()

		player.Signal( "TitanReadyPulse" )
		file.respawnSelectHud[ 0 ].notReady.SetColor( 128, 128, 128, 255 )
		file.respawnSelectHud[ 0 ].image.SetImage( IMAGE_SELECT_TITAN )
		file.respawnSelectHud[ 0 ].hover.Hide()
		if ( !CanSpawnAsTitan() )
			file.respawnSelectHud[ 0 ].image.SetColor( 150, 150, 150, 255 )
		else
			file.respawnSelectHud[ 0 ].image.SetColor( 255, 255, 255, 255 )

		if ( CanSpawnAsTitan() )
		{
			file.respawnSelectHud[ 0 ].notReady.SetText( "#RESPAWNSELECT_READY" )
			if ( titanReady )
				thread TitanReadyPulse( player )
			file.respawnSelectHud[0].time.Hide()	// hide the countdown element if the titan is available
		}
		else if ( PetTitanDeployed() )
		{
			file.respawnSelectHud[ 0 ].notReady.SetText( "#RESPAWNSELECT_DEPLOYED" )
			file.respawnSelectHud[0].time.Hide()	// hide the countdown element if the titan is deployed
		}
		else
		{
			if ( Riff_SpawnAsTitan() == eSpawnAsTitan.Never )
			{
				file.respawnSelectHud[ 0 ].notReady.SetText( "#SETTING_DISABLED" )
				file.respawnSelectHud[ 0 ].time.Hide()
			}
			else
			{
				file.respawnSelectHud[ 0 ].notReady.SetText( "#RESPAWNSELECT_NOT_READY" )
			}
		}

		file.respawnSelectTitle.SetText( "#RESPAWNSELECT_PILOT" )
	}
}

function TitanReadyPulse( player, reverse = false )
{
	player.Signal( "TitanReadyPulse" )
	player.EndSignal( "TitanReadyPulse" )

	file.respawnSelectHud[ 0 ].notReady.Show()

	local min = 128
	local max = 224
	if ( reverse )
	{
		min = 224
		max = 128
	}

	// pulse
	for ( local i = 0; i < 6 ; i++ )
	{
		local alpha = i % 2 ? min : max
		file.respawnSelectHud[ 0 ].notReady.ColorOverTime( alpha, alpha, alpha, 255, 0.35, INTERPOLATOR_SIMPLESPLINE )
		wait 0.35
	}
}

function PetTitanDeployed()
{
	local player = GetLocalClientPlayer()
	return player.GetNextTitanRespawnAvailable() >= 999999
}

function RegisterRespawnCommands( burnCardSelectionMethod )
{
	if ( file.burnCardSelectionMethod != null )
	{
		DeregisterRespawnCommands()
	}

	RegisterConCommandTriggeredCallback( "+moveright",		PlayerPressed_RespawnSelectRight )
	RegisterButtonPressedCallback( KEY_RIGHT,				PlayerPressed_RespawnSelectRight )
	RegisterButtonPressedCallback( BUTTON_DPAD_RIGHT,		PlayerPressed_RespawnSelectRight )
	RegisterButtonPressedCallback( STICK1_RIGHT,			PlayerPressed_RespawnSelectRight )

	RegisterConCommandTriggeredCallback( "+moveleft",		PlayerPressed_RespawnSelectLeft )
	RegisterButtonPressedCallback( KEY_LEFT,				PlayerPressed_RespawnSelectLeft )
	RegisterButtonPressedCallback( STICK1_LEFT,				PlayerPressed_RespawnSelectLeft )
	RegisterButtonPressedCallback( BUTTON_DPAD_LEFT,		PlayerPressed_RespawnSelectLeft )

	RegisterButtonPressedCallback( KEY_SPACE,				PlayerPressed_Respawn )
	RegisterButtonPressedCallback( BUTTON_A,				PlayerPressed_Respawn )

	file.burnCardSelectionMethod = burnCardSelectionMethod

	switch ( file.burnCardSelectionMethod )
	{
		case "menu":
			RegisterButtonPressedCallback( KEY_B,					PlayerPressed_BurnCardMenu )
			RegisterButtonPressedCallback( BUTTON_Y,				PlayerPressed_BurnCardMenu )
			break

		case "three":
			RegisterButtonPressedCallback( KEY_B,					PlayerPressed_SelectActiveBurnCard1 )
			RegisterButtonPressedCallback( KEY_N,					PlayerPressed_SelectActiveBurnCard2 )
			RegisterButtonPressedCallback( KEY_M,					PlayerPressed_SelectActiveBurnCard3 )
			RegisterButtonPressedCallback( BUTTON_SHOULDER_LEFT,	PlayerPressed_SelectActiveBurnCard1 )
			RegisterButtonPressedCallback( BUTTON_Y,				PlayerPressed_SelectActiveBurnCard2 )
			RegisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT,	PlayerPressed_SelectActiveBurnCard3 )
			break
	}
}

function DeregisterRespawnCommands()
{
	if ( file.burnCardSelectionMethod == null )
		return

	DeregisterConCommandTriggeredCallback( "+moveright",	PlayerPressed_RespawnSelectRight )
	DeregisterButtonPressedCallback( KEY_RIGHT,				PlayerPressed_RespawnSelectRight )
	DeregisterButtonPressedCallback( BUTTON_DPAD_RIGHT,		PlayerPressed_RespawnSelectRight )
	DeregisterButtonPressedCallback( STICK1_RIGHT,			PlayerPressed_RespawnSelectRight )

	DeregisterConCommandTriggeredCallback( "+moveleft",		PlayerPressed_RespawnSelectLeft )
	DeregisterButtonPressedCallback( KEY_LEFT,				PlayerPressed_RespawnSelectLeft )
	DeregisterButtonPressedCallback( STICK1_LEFT,			PlayerPressed_RespawnSelectLeft )
	DeregisterButtonPressedCallback( BUTTON_DPAD_LEFT,		PlayerPressed_RespawnSelectLeft )

	DeregisterButtonPressedCallback( KEY_SPACE,				PlayerPressed_Respawn )
	DeregisterButtonPressedCallback( BUTTON_A,				PlayerPressed_Respawn )

	switch ( file.burnCardSelectionMethod )
	{
		case "menu":
			DeregisterButtonPressedCallback( KEY_B,					PlayerPressed_BurnCardMenu )
			DeregisterButtonPressedCallback( BUTTON_Y,				PlayerPressed_BurnCardMenu )
			break

		case "three":
			DeregisterButtonPressedCallback( KEY_B,					PlayerPressed_SelectActiveBurnCard1 )
			DeregisterButtonPressedCallback( KEY_N,					PlayerPressed_SelectActiveBurnCard2 )
			DeregisterButtonPressedCallback( KEY_M,					PlayerPressed_SelectActiveBurnCard3 )
			DeregisterButtonPressedCallback( BUTTON_SHOULDER_LEFT,	PlayerPressed_SelectActiveBurnCard1 )
			DeregisterButtonPressedCallback( BUTTON_Y,				PlayerPressed_SelectActiveBurnCard2 )
			DeregisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT,	PlayerPressed_SelectActiveBurnCard3 )
			break
	}

	file.burnCardSelectionMethod = null
}


function RespawnSelectAnalogX( player, val )
{
	if ( val < -0.5 )
	{
		PlayerPressed_RespawnSelectLeft( player )
	}
	else if ( val > 0.5 )
	{
		PlayerPressed_RespawnSelectRight( player )
	}
}


function RespawnSelectAnalogY( player, val )
{
	if ( val < -0.5 )
	{
		PlayerPressed_RespawnSelectUp( player )
	}
}


function RespawnSelect_AddClient()
{
	local respawnSelect = HudElement( "RespawnSelect" )


	local elemNames = [ "RespawnSelectTitan", "RespawnSelectPilot" ]

	file.respawnSelectHud = []
	file.respawnSelectHud.resize( RESPAWN_SELECTIONS )

	SetupRespawnSelectHud( respawnSelect, elemNames, 0 ) //, "#RESPAWNSELECT_TITAN" )
	SetupRespawnSelectHud( respawnSelect, elemNames, 1 ) //, "#RESPAWNSELECT_PILOT" )

	file.respawnSelectHud[0].image.SetImage( IMAGE_SELECT_TITAN )
	file.respawnSelectHud[1].image.SetImage( IMAGE_SELECT_PILOT )

	file.respawnBackground <- HudElement( "RespawnSelect_Background", respawnSelect )
	file.respawnSelectTitle <- HudElement( "RespawnSelect_Title", respawnSelect )
	file.respawnSelectTitle.EnableKeyBindingIcons()

	file.burnCardPrematchLabel <- HudElement( "BurnCardPrematchLabel" )
	file.burnCardPrematchIcon <- HudElement( "BurnCardPrematchIcon" )
	file.burnCardPrematchIcon.EnableKeyBindingIcons()

	file.burnCardPrematchLabel.SetText( "#BURNCARD_PREMATCH_LABEL_SELECT" )

	file.burnCardPrematchIcon.SetText( "#BURNCARD_PREMATCH_ICON" )

	file.respawnSelect = respawnSelect
}

function SetupRespawnSelectHud( ownerHud, elemNames, i )
{
	file.respawnSelectHud[i] = CreateRespawnSelectElement( elemNames[i], ownerHud )
}

function CreateRespawnSelectElement( name, ownerHud )
{
	local table = {}
	table.hudElement <- HudElement( name, ownerHud )

	// image on respawn selection
	table.image <- HudElement( "RespawnSelect_image", table.hudElement )
	table.hover <- HudElement( "RespawnSelect_Hover", table.hudElement )
	table.time <- HudElement( "RespawnSelect_Time", table.hudElement )
	table.notReady <- HudElement( "RespawnSelect_NotReady", table.hudElement )
	table.time.Hide()
	table.notReady.Hide()

	return table
}

function PlayerAllowedToSelectActiveCard( player )
{
	if ( Time() < file.clickIgnoreTime )
		return false
	if ( IsInScoreboard( player ) )
		return false
	if ( Flag( "DisableBurnCardMenu" ) )
		return false

	return true
}
Globalize( PlayerAllowedToSelectActiveCard )

function PlayerPressed_BurnCardMenu( player )
{
	if ( Time() < file.clickIgnoreTime )
		return
	if ( IsInScoreboard( player ) )
		return
	if ( Flag( "DisableBurnCardMenu" ) )
		return
	DisplayActiveBurnCards( player )
}

function PlayerPressed_RespawnSelectLeft( player )
{
	switch ( file.selectingRespawnStep )
	{
		case SELECT_TITAN_PILOT:
			local oldSpawnAsTitan = file.lastKnownSpawnAsTitan
			if ( !CanSpawnAsTitan() )
				player.ClientCommand( "CC_SelectRespawn 2" )
			else
				player.ClientCommand( "CC_SelectRespawn 1" )

			file.lastKnownSpawnAsTitan = true

			if ( oldSpawnAsTitan != file.lastKnownSpawnAsTitan )
				RefreshRespawnSelectPilotTitan()
			return

		case SELECT_BURN_CARD:
				PlayerPressed_BurnCardLeft( player )
			return
	}
}

function PlayerPressed_RespawnSelectRight( player )
{
	switch ( file.selectingRespawnStep )
	{
		case SELECT_TITAN_PILOT:
			local oldSpawnAsTitan = file.lastKnownSpawnAsTitan
			player.ClientCommand( "CC_SelectRespawn 2" )
			file.lastKnownSpawnAsTitan = false

			if ( oldSpawnAsTitan != file.lastKnownSpawnAsTitan )
				RefreshRespawnSelectPilotTitan()
			return

		case SELECT_BURN_CARD:
			PlayerPressed_BurnCardRight( player )
			return
	}
}

function PlayerPressed_RespawnSelectUp( player )
{
	if ( file.selectingRespawnStep != SELECT_BURN_CARD )
		return

	PlayerPressed_BurnCardUp( player )
}

function PlayerPressed_Respawn( player )
{
	if ( Time() < file.clickIgnoreTime )
		return

	switch ( file.selectingRespawnStep )
	{
		case SELECT_TITAN_PILOT:
			if ( file.lastKnownSpawnAsTitan )
			{
				if ( CanSpawnAsTitan() )
				{
					SetRespawnSelectState( SELECT_DEAD )
					player.ClientCommand( "CC_RespawnPlayer Titan" )
				}
				else
				{
					EmitSoundOnEntity( player, "Menu.Deny" )
				}
			}
			else
			{
				SetRespawnSelectState( SELECT_DEAD )
				player.ClientCommand( "CC_RespawnPlayer Pilot" )
			}
			break

		case SELECT_BURN_CARD:
			if ( level.selectedBurnCardID != null )
				player.ClientCommand( "CC_RespawnPlayer " + level.selectedBurnCardID + "burncard" )

			if ( ShouldShowSpawnAsTitanHint( player ) )
				SetRespawnSelectState( SELECT_TITAN_PILOT )
			else
				SetRespawnSelectState( SELECT_DEAD )
			break

		case SELECT_DEAD:
		case SELECT_NONE:
			if ( file.lastKnownSpawnAsTitan )
			{
 				//Send a client command to skip the replay. Do this even if you can't actually spawn anymore
 				if ( CanSpawnAsTitan() )
					player.ClientCommand( "CC_RespawnPlayer Titan" )
				else
					player.ClientCommand( "CC_RespawnPlayer Pilot" )
			}
			else
			{
				player.ClientCommand( "CC_RespawnPlayer Pilot" )
			}

			break
	}
}

function BurnCardSelectionMethod()
{
	return file.burnCardSelectionMethod
}

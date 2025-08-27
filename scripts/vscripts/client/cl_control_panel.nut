
const HEAVY_TURRET_HEALTH_STR = "Health: %d%%"
const HEAVY_TURRET_REPAIR_STR = "Progress: %d%%"
const HEAVY_TURRET_REBOOT_STR = "Some indicator"

function main()
{
	level.TurretBackground <- array( 6, null )
	level.TurretBackground[ TURRET_INACTIVE ]	= "console_disabled"
	level.TurretBackground[ TURRET_DEPLOYING ]	= "console_%s_deploy"
	level.TurretBackground[ TURRET_SEARCHING ]	= "console_%s_search"
	level.TurretBackground[ TURRET_ACTIVE ]		= "console_%s_active"
	level.TurretBackground[ TURRET_DEAD ]		= "console_%s_repair"
	level.TurretBackground[ TURRET_RETIRING ]	= "console_disabled"	// missed one state

	PrecacheParticleSystem( "panel_light_blue" )
	PrecacheParticleSystem( "panel_light_red" )
	PrecacheParticleSystem( "runway_light_orange" )

	RegisterSignal( "KnifePopout" )

	Globalize( ServerCallback_ControlPanelRefresh )
	Globalize( CreateCallback_Panel )
	Globalize( DestroyCallback_PanelTarget )
	Globalize( RegisterWithPanel )
	Globalize( VGUIUpdateGeneric )
	Globalize( VGUISetupGeneric )
	Globalize( CreateFirstPersonDataKnife )
	Globalize( Create_Display )
	Globalize( AddPanelUpdateCallback )

	AddCreateCallback( "prop_control_panel", CreateCallback_Panel )
	AddDestroyCallback( "prop_control_panel", DestroyCallback_Panel )
}

function AddPanelUpdateCallback( panel, func )
{
	if ( !( "updateCallbacks" in panel.s ) )
		panel.s.updateCallbacks <- []
	panel.s.updateCallbacks.append( func )
}

function ServerCallback_ControlPanelRefresh( panelEHandle )
{
	local panel = GetEntityFromEncodedEHandle( panelEHandle )
	if ( !IsValid( panel ) )
		return

	ControlPanelRefresh( panel )
}

function CreateCallback_Panel( panel, isRecreate )
{
	if ( panel.GetModelName() != "models/communication/terminal_usable_imc_01.mdl" )
		return

	ControlPanelInit( panel )
	Create_Display( panel )

	ControlPanelRefresh( panel )
}

function DestroyCallback_Panel( panel )
{
	if ( panel.GetModelName() != "models/communication/terminal_usable_imc_01.mdl" )
		return

	if ( "HudVGUI" in panel.s && panel.s.HudVGUI )
	{
		panel.s.HudVGUI.Destroy()
		panel.s.HudVGUI = null
	}

    if ( "particleEffect" in panel.s && panel.s.particleEffect != null && EffectDoesExist( panel.s.particleEffect ) )
    	EffectStop( panel.s.particleEffect, true, false )
}

function ControlPanelInit( panel )
{
	panel.s.initiated <- true
	panel.s.HudVGUI <- null
	panel.s.VGUIFunc <- Bind( VGUIUpdateGeneric )
	panel.s.VGUISetupFunc <- Bind( VGUISetupGeneric )
	panel.s.targetArray <- []
	panel.s.resfile <- "control_panel_generic_screen"
	panel.s.particleEffect <- null
	panel.s.particleFlashingBlueToPlayer <- false

	if ( !( "updateCallbacks" in panel.s ) )
		panel.s.updateCallbacks <- []

	AddClientEventHandling( panel )

	AddAnimEvent( panel, "create_dataknife", CreateFirstPersonDataKnife )
	AddAnimEvent( panel, "knife_popout", KnifePopsOut )

	panel.useFunction = ControlPanel_CanUseFunction
}

function KnifePopsOut( panel )
{
	local player = GetLocalViewPlayer()
	local parentEnt = player.GetParent()

	// are we parented to this panel?
	if ( panel != parentEnt )
		return

	if ( "knife" in player.s )
		player.s.knife.Anim_Play( "data_knife_console_leech_start" )
}

function CreateFirstPersonDataKnife( panel )
{
	local player = GetLocalViewPlayer()
	local parentEnt = player.GetParent()

	// are we parented to this panel?
	if ( panel != parentEnt )
		return

	thread PlayerGetsKnifeUntilLosesParent( player, panel )
}

function PlayerGetsKnifeUntilLosesParent( player, panel )
{
	local viewModel = player.GetFirstPersonProxy()  //JFS: Defensive fix for player not having view models sometimes
	if ( !IsValid( viewModel ) )
		return
	if ( !EntHasModelSet( viewModel ) )
		return

	if ( !( "knife" in player.s ) )
		player.s.knife <- null

	local model = DATA_KNIFE_MODEL
	local knife = CreatePropDynamic( model, Vector(0,0,0), Vector(0,0,0) )
	knife.SetParent( viewModel, "propgun", false, 0.0 )

	OnThreadEnd(
		function () : ( player, knife )
		{
			if ( ( "knife" in player.s ) && player.s.knife == knife ) //JFS, Defensive check for knife. For some reason sometimes it disappears. See bug 60141
				delete player.s.knife
			// knife can be destroyed first by replay
			if ( IsValid( knife ) )
				knife.Destroy()
		}
	)

	player.s.knife = knife

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	knife.Anim_Play( "data_knife_console_leech_end" )

	for ( ;; )
	{
		if ( player.GetParent() != panel )
			break
		wait 0
	}
}

function RegisterWithPanel( entity )
{
	//printt( "RegisterWithPanel", entity.GetName() )
	entity.EndSignal( "OnDestroy" )
	local panel = entity.GetControlPanel()

	while ( !IsValid( panel ) || !( "initiated" in panel.s ) ) //Need to wait till panel has finished initializing
	{
		panel = turret.GetControlPanel() //Don't think is actually necessary, but better safe than sorry...
		wait 0
	}

	if ( !ArrayContains( panel.s.targetArray, entity ) )
		panel.s.targetArray.append( entity )

	Create_Display( panel )

	ControlPanelRefresh( panel )
}

function DestroyCallback_PanelTarget( entity )
{
	if ( entity.GetControlPanel() == null )
		return

	local panel = entity.GetControlPanel()
	if ( !IsValid( panel ) )
		return

	foreach ( index, ent in clone panel.s.targetArray )
	{
		if ( ent == entity )
		{
			panel.s.targetArray.remove( index )
			break
		}
	}
}

function ControlPanelRefresh( panel )
{
	if ( !IsValid( panel ) )
		return

	foreach ( func in panel.s.updateCallbacks )
	{
		func( panel )
	}

	if ( CanUpdateVGUI( panel ) )
	{
		panel.s.VGUIFunc( panel )	// Update the panel vgui screen to match the state of the target(s)
		UpdateParticleSystem( panel )
	}
}

function CanUpdateVGUI( panel )
{
	if ( panel.s.VGUIFunc == null )
		return false

	if ( panel.s.HudVGUI == null )
		return false

	if ( panel.s.targetArray.len() == 0 )
		return false

	return true
}

function Create_Display( panel )
{
	if ( panel.s.HudVGUI )
	{
		panel.s.HudVGUI.Destroy()
		panel.s.HudVGUI = null
	}

	local player = GetLocalViewPlayer()

	local bottomLeftID = panel.LookupAttachment( "PANEL_SCREEN_BL" )
	local topRightID = panel.LookupAttachment( "PANEL_SCREEN_TR" )

	local size = ComputeSizeForAttachments( panel, bottomLeftID, topRightID, false )

	local origin = panel.GetAttachmentOrigin( bottomLeftID )
	local angles = panel.GetAttachmentAngles( bottomLeftID )

	// push the origin "out" slightly, since the tags are coplanar with the geo
	origin += angles.AnglesToUp() * 0.05

	panel.s.HudVGUI = CreateClientsideVGuiScreen( panel.s.resfile, VGUI_SCREEN_PASS_WORLD, origin, angles, size[0], size[1] );
	panel.s.HudVGUI.s.panel <- panel.s.HudVGUI.GetPanel() // This is a different panel than the Control Panel
	panel.s.HudVGUI.SetParent( panel, "PANEL_SCREEN_BL" )

	panel.s.VGUISetupFunc( panel )
}

function VGUIUpdateSpectre( panel )
{
	local stateElement = panel.s.HudVGUI.s.state
	local controlledItem = panel.s.HudVGUI.s.controlledItem
	controlledItem.SetText( "Spectre Drop" )
	stateElement.SetText( "[READY]" )

	// alternate on and off
	local show = ( ( Time() * 4 ).tointeger() % 2 )
	if ( show )
		stateElement.Show()
	else
		stateElement.Hide()
}

function VGUISetupGeneric( panel )
{
	panel.s.HudVGUI.s.state <- HudElement( "State", panel.s.HudVGUI.s.panel )
	panel.s.HudVGUI.s.controlledItem <- HudElement( "ControlledItem", panel.s.HudVGUI.s.panel )
}

function VGUIUpdateGeneric( panel )
{
	local state = panel.s.HudVGUI.s.state

	// alternate on and off
	local show = ( Time().tointeger() % 2 )
	if ( show )
		state.Show()
	else
		state.Hide()

	local stateElement = panel.s.HudVGUI.s.state
	stateElement.SetText( "#CONTROL_PANEL_ENABLED" )
}

function UpdateParticleSystem( panel )
{
	local playerSameTeamAsPanel = ( GetLocalViewPlayer().GetTeam() == panel.GetTeam() )

	if ( panel.s.particleEffect != null )
	{
		// Return if don't need to update panel particle effect
		if ( playerSameTeamAsPanel && panel.s.particleFlashingBlueToPlayer )
			return

		if ( !playerSameTeamAsPanel && !panel.s.particleFlashingBlueToPlayer )
			return

		// We need to change the effect of the panel now, so stop existing one
		if ( EffectDoesExist( panel.s.particleEffect ) )
			EffectStop( panel.s.particleEffect, true, false )
	}

	local tagID = panel.LookupAttachment( "glow1" )

	local fxID
	if ( playerSameTeamAsPanel )
		fxID = GetParticleSystemIndex( "panel_light_blue" )
	else
		fxID = GetParticleSystemIndex( "panel_light_red" )

	panel.s.particleEffect = PlayFXOnTag( panel, fxID, tagID )

	panel.s.particleFlashingBlueToPlayer = playerSameTeamAsPanel
}
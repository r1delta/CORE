//=========================================================
// Control Panels
//
//=========================================================

//////////////////////////////////////////////////////////////////////
function main()
{
	return
	PrecacheModel( MODEL_BIGBROTHER_PANEL )
	PrecacheParticleSystem( "ar_titan_droppoint" )

	PrecacheMaterial( "vgui/hud/control_panel/console_disabled/console_disabled" )
	PrecacheMaterial( "vgui/hud/control_panel/console_f_deploy/console_f_deploy" )
	PrecacheMaterial( "vgui/hud/control_panel/console_f_search/console_f_search" )
	PrecacheMaterial( "vgui/hud/control_panel/console_f_active/console_f_active" )
	PrecacheMaterial( "vgui/hud/control_panel/console_f_repair/console_f_repair" )
	PrecacheMaterial( "vgui/hud/control_panel/console_e_deploy/console_e_deploy" )
	PrecacheMaterial( "vgui/hud/control_panel/console_e_search/console_e_search" )
	PrecacheMaterial( "vgui/hud/control_panel/console_e_active/console_e_active" )
	PrecacheMaterial( "vgui/hud/control_panel/console_e_repair/console_e_repair" )

	AddSpawnCallback( "prop_bigbrother_panel", 			OnBBPanelSpawn )

	//Globalize( InitBBPanelUseFuncTable )
	//Globalize( AddBBPanelUseFuncTable )
	//Globalize( SetBBPanelPrompts )
	Globalize( SetBBPanelUsableToEnemies )
	//Globalize( PanelFlipsToPlayerTeamAndUsableByEnemies )
	Globalize( GetAllBBPanels )
	//Globalize( CaptureAllAvailableControlPanels )
	//Globalize( GetPanelUseEnts )

	RegisterSignal( "BBPanelReprogrammed" )
	RegisterSignal( "PanelReprogram_Success" )
	RegisterSignal( "OnContinousUseStopped" )

	level.BBPanels <- []
}

//////////////////////////////////////////////////////////
function GameModeRemovePanel( ent )
{
	local keepUndefined
	local gameMode = GameRules.GetGameMode()

	switch ( gameMode )
	{
		// if we are in this game mode, then don't keep undefined panels
		case BIG_BROTHER:
		case HEIST:
			gameMode = BIG_BROTHER
			keepUndefined = true
			break

		case TITAN_RUSH:
			gameMode = TITAN_RUSH
			keepUndefined = true
			break

		default:
			keepUndefined = true
			gameMode = TEAM_DEATHMATCH
			break
	}

	local gamemodeKey = "gamemode_" + gameMode

	if ( ent.HasKey( gamemodeKey ) && ent.kv[gamemodeKey] == "1" )
	{
		// the key exists and it's true so keep it
		return
	}

	if ( !ent.HasKey( gamemodeKey ) && keepUndefined )
	{
		// the key doesn't exist but keepUndefined is true so still keep it
		return
	}

	ent.Destroy()
}


//////////////////////////////////////////////////////////////////////
function OnBBPanelSpawn( panel )
{
	Assert( panel.GetModelName() == MODEL_BIGBROTHER_PANEL )

	thread OnBBPanelSpawn_Internal( panel )
}

//////////////////////////////////////////////////////////////////////
function OnBBPanelSpawn_Internal( panel )
{
	panel.EndSignal( "OnDestroy" )
	GameModeRemovePanel( panel )

	panel.s.useStartFuncArray <- []
	panel.s.useSuccessFuncArray <- []
	panel.s.useFailFuncArray <- []

	Assert( IsValid( panel ), "Invalid panel " + panel )
	panel.EndSignal( "OnDestroy" )

	level.BBPanels.append( panel )
	//Default, set it usable by everyone
	panel.SetUsableByGroup( "pilot" )

	panel.useFunction = ControlPanel_CanUseFunction

	panel.s.leechTimeNormal <- 3.0
	panel.s.leechTimeFast <- 1.1

	// custom functions you can create for when the panel starts or stops hacking
	panel.s.panelHackStartFunc <- null
	panel.s.panelHackEndFunc <- null
	panel.s.panelHackScope <- null

	for ( ;; )
	{
		local results = panel.WaitSignal( "OnPlayerUse" )
		local player = results.activator

		Assert( IsPlayer( player ) )

		if ( !IsAlive( player ) || player.IsTitan()  )
			continue

		// already a user?
		if ( IsAlive( panel.GetBossPlayer() ) )
			continue

		if ( !panel.useFunction( player, panel ) )
		{
			//play buzzer sound
			EmitSoundOnEntity( panel, "Operator.Ability_offline" )
			wait 1
			continue
		}

		waitthread PlayerUsesBBPanel( player, panel )
	}
}

function PlayerUsesBBPanel( player, panel )
{
	thread PlayerProgramsBBPanel( panel, player )

	// panel use start
	RunBBPanelUseStartFunctions( panel, player )

	local result = panel.WaitSignal( "BBPanelReprogrammed" )

	if ( result.success )
	{
		panel.Signal( "PanelReprogram_Success" )

		local panelEHandle = IsValid( panel ) ? panel.GetEncodedEHandle() : null
		local players = GetPlayerArray()
		foreach( guy in players )
		{
			Remote.CallFunction_Replay( guy, "ServerCallback_BBPanelRefresh", panelEHandle )
		}

		RunBBPanelUseSuccessFunctions( panel, player )
	}
	else
	{
		RunBBPanelUseFailFunctions( panel, player )
		//play buzzer sound
		EmitSoundOnEntity( panel, "Operator.Ability_offline" )
		wait 0	// arbitrary delay so that you can't restart the leech instantly after failing
	}
}

function RunBBPanelUseSuccessFunctions( panel, player )
{
	if ( panel.s.useSuccessFuncArray.len() <= 0 )
		return

	foreach ( useFuncTable in clone panel.s.useSuccessFuncArray )
	{
		if ( useFuncTable.useSuccessEnt == null )
			useFuncTable.useSuccessFunc.acall( [useFuncTable.scope, panel, player] )
		else
			useFuncTable.useSuccessFunc.acall( [useFuncTable.scope, panel, player, useFuncTable.useSuccessEnt] )
	}
}

function SetBBPanelUseSuccessFunc( panel, func, scope, ent = null )
{
	local table = InitBBPanelUseSuccessFuncTable()
	table.useSuccessFunc = func
	table.useSuccessEnt = ent
	table.scope = scope
	AddBBPanelUseSuccessFuncTable( panel, table )
}
Globalize( SetBBPanelUseSuccessFunc )

function RunBBPanelUseFailFunctions( panel, player )
{
	if ( panel.s.useFailFuncArray.len() <= 0 )
		return

	foreach ( useFuncTable in clone panel.s.useFailFuncArray )
	{
		if ( useFuncTable.useFailEnt == null )
			useFuncTable.useFailFunc.acall( [useFuncTable.scope, panel, player] )
		else
			useFuncTable.useFailFunc.acall( [useFuncTable.scope, panel, player, useFuncTable.useFailEnt] )
	}
}

function SetBBPanelUseFailFunc( panel, func, scope, ent = null )
{
	local table = InitBBPanelUseFailFuncTable()
	table.useFailFunc = func
	table.useFailEnt = ent
	table.scope = scope
	AddBBPanelUseFailFuncTable( panel, table )
}
Globalize( SetBBPanelUseFailFunc )

function RunBBPanelUseStartFunctions( panel, player )
{
	if ( panel.s.useStartFuncArray.len() <= 0 )
		return

	foreach ( useFuncTable in clone panel.s.useStartFuncArray )
	{
		if ( useFuncTable.useStartEnt == null )
			useFuncTable.useStartFunc.acall( [useFuncTable.scope, panel, player] )
		else
			useFuncTable.useStartFunc.acall( [useFuncTable.scope, panel, player, useFuncTable.useStartEnt] )
	}
}

function SetBBPanelUseStartFunc( panel, func, scope, ent = null )
{
	local table = InitBBPanelUseStartFuncTable()
	table.useStartFunc = func
	table.useStartEnt = ent
	table.scope = scope
	AddBBPanelUseStartFuncTable( panel, table )
}
Globalize( SetBBPanelUseStartFunc )

//////////////////////////////////////////////////////////////////////
function PlayerProgramsBBPanel( panel, player )
{
	Assert( IsAlive( player ) )
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "ScriptAnimStop" )

	// need to wait here so that the panel script can start waiting for the PanelReprogrammed signal.
	wait 0

	local action =
	{
		playerAnimation1pStart = "ptpov_data_knife_console_leech_start"
		playerAnimation1pIdle = "ptpov_data_knife_console_leech_idle"
		playerAnimation1pEnd = "ptpov_data_knife_console_leech_end"

		playerAnimation3pStart = "pt_data_knife_console_leech_start"
		playerAnimation3pIdle = "pt_data_knife_console_leech_idle"
		playerAnimation3pEnd = "pt_data_knife_console_leech_end"

		panelAnimation3pStart = "tm_data_knife_console_leech_start"
		panelAnimation3pIdle = "tm_data_knife_console_leech_idle"
		panelAnimation3pEnd = "tm_data_knife_console_leech_end"

		direction = Vector( -1, 0, 0 )
		targetClass = "npc_marvin" // ???
	}

	local e = {}
	e.success <- false
	e.knives <- []

	e.ranPanelEndFunc <- false

	// make it so it's only usable by the player that started the leech
	e.panelUsableValue <- panel.GetUsableValue()

	e.startOrigin <- player.GetOrigin()
	panel.SetBossPlayer( player )
	panel.SetUsableByGroup( "owner pilot" )

	e.setIntruder <- false

	player.ForceStand()

	OnThreadEnd
	(
		function() : ( e, player, panel )
		{
			if ( e.setIntruder )
				level.nv.panelIntruder = null

			if ( IsValid( player ) )
			{
				player.ClearAnimNearZ()
				player.ClearParent()

				// stop any running first person sequences
				player.Anim_Stop()

				// stop dataknife animating and making sounds
				Remote.CallFunction_Replay( player, "ServerCallback_DataKnifeCancelLeech" )

				if ( IsAlive( player ) )
				 	UnStuck( player, e.startOrigin, panel )

				// done with first person anims
				player.ClearAnimViewEntity()
				player.DeployWeapon()
				player.UnforceStand()

				if ( player.ContextAction_IsLeeching() )
					player.Event_LeechEnd()
			}

			if ( IsValid( panel ) )
			{
				if ( !e.ranPanelEndFunc && panel.s.panelHackEndFunc )
					thread panel.s.panelHackEndFunc.acall( [panel.s.panelHackScope, panel, player] )

				// reset panel

				// stop any running first person sequences
				panel.Anim_Stop()
				panel.Anim_Play( "ref" ) // close the hatch

				// reset default usability
				panel.ClearBossPlayer()

				if ( !e.success )
				{
					panel.Signal( "BBPanelReprogrammed", { success = e.success } )
					/*
					local turret = GetMegaTurretLinkedToPanel( panel ) //CHIN: Control panels shouldn't need to know about turrets
					if ( IsValid( turret ) && turret.IsTurret() )
					{
						local usableValue = MegaTurretUsabilityFunc( turret, panel )
						panel.SetUsableByGroup( usableValue )
						SetUsePromptForPanel( panel, turret )
					}
					else
					{
						// Turret got destoyed while hacking.
						// Usability state has been set by ReleaseTurret( ... ) in ai_turret.nut
						// Changing it to the previous usable value would put us in a bad state.

						// training level a hackable panel that isn't hooked up to a turret.
						// In this case we need to reset the usable value to what it used to be
						// we should change how this works for R2
						if ( IsTrainingLevel() )
							panel.SetUsableValue( e.panelUsableValue )
					}
					*/

				}

			}

			foreach ( knife in e.knives )
			{
				if ( IsValid( knife ) )
					knife.Kill()
			}
		}
	)

	if ( !player.UseButtonPressed() )
		return	// it's possible to get here and no longer be holding the use button. If that is the case lets not continue.

	if ( player.ContextAction_IsActive() )
		return

	player.HolsterWeapon()
	player.SetAnimNearZ( 1 )

	player.Event_LeechStart()

	local leechTime = panel.s.leechTimeNormal

	if ( PlayerHasPassive( player, PAS_FAST_HACK ) )
		leechTime = panel.s.leechTimeFast

	local knifeIn = false
	local totalTime = leechTime + player.GetSequenceDuration( action.playerAnimation3pStart )

	thread TrackContinuousBBPanelUse( panel, player, totalTime )

	// The data knife needs to be turned off, or it could be drawing whatever
	// was last on it
	Remote.CallFunction_Replay( player, "ServerCallback_DataKnifeReset" )

	if ( panel.s.panelHackStartFunc )
	{
		thread panel.s.panelHackStartFunc.acall( [panel.s.panelHackScope, panel, player] )
	}

	waitthread BBPanelFlipAnimation( panel, player, action, e )

	if ( !player.UseButtonPressed() )
		return	// we might have returned from the flip anim because we released the use button.

	if( level.nv.BigBrotherPanelExplosion == true )
		return

	Remote.CallFunction_Replay( player, "ServerCallback_DataKnifeStartLeech", leechTime )

	waitthread WaitForEndLeechOrStoppedUse( player, leechTime, e, panel )

	if ( panel.s.panelHackEndFunc )
	{
		e.ranPanelEndFunc = true
		thread panel.s.panelHackEndFunc.acall( [panel.s.panelHackScope, panel, player] )
	}

	waitthread BBPanelFlipExitAnimation( player, panel, action, e )
}

function WaitForEndLeechOrStoppedUse( player, leechTime, e, panel )
{
	player.EndSignal( "OnContinousUseStopped" )
	//wait leechTime
	
	WaitSignalTimeout( panel, leechTime, "StopHacking" )

	if( level.nv.BigBrotherPanelExplosion == true )
	{
		e.success = false
	}
	else
	{
		e.success = true
	}

	panel.Signal( "BBPanelReprogrammed", { success = e.success } )
}


//////////////////////////////////////////////////////////////////////
function BBPanelFlipAnimation( panel, player, action, e )
{
//	OnThreadEnd
//	(
//		function() : ( panel )
//		{
//			if ( IsValid( panel ) )
//				DeleteAnimEvent( panel, "knife_popout", KnifePopOut )
//		}
//	)
	player.EndSignal( "OnContinousUseStopped" )

	local playerSequence = CreateFirstPersonSequence()
	playerSequence.blendTime = 0.25
	playerSequence.attachment = "ref"
	playerSequence.thirdPersonAnim = action.playerAnimation3pStart
	playerSequence.thirdPersonAnimIdle = action.playerAnimation3pIdle
	playerSequence.firstPersonAnim = action.playerAnimation1pStart
	playerSequence.firstPersonAnimIdle = action.playerAnimation1pIdle
	if ( IntroPreviewOn() )
		playerSequence.viewConeFunction = BBPanelFlipViewCone

	local panelSequence = CreateFirstPersonSequence()
	panelSequence.blendTime = 0.25
	panelSequence.thirdPersonAnim = action.panelAnimation3pStart
	panelSequence.thirdPersonAnimIdle = action.panelAnimation3pIdle


	local model = DATA_KNIFE_MODEL
	//AddAnimEvent( panel, "knife_popout", KnifePopOut, e )
	//local knife = CreatePropDynamic( model )
	//knife.SetName( "dataKnife" )
	//knife.SetParent( player.GetFirstPersonProxy(), "propgun", false, 0.0 )
	//e.knives.append( knife )

	local knife = CreatePropDynamic( model )
	knife.SetName( "dataKnife" )
	knife.SetParent( player, "propgun", false, 0.0 )
	e.knives.append( knife )

	thread PanelFirstPersonSequence( panelSequence, panel, player )
	waitthread FirstPersonSequence( playerSequence, player, panel )
}


function BBPanelFlipViewCone( player )
{
	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -80 )
	player.PlayerCone_SetMaxYaw( 80 )
	player.PlayerCone_SetMinPitch( -80 )
	player.PlayerCone_SetMaxPitch( 10 )
}


//////////////////////////////////////////////////////////////////////
function KnifePopOut( player, e )
{
	foreach ( knife in e.knives )
	{
		knife.Anim_Play( "data_knife_console_leech_start" )
	}
}


//////////////////////////////////////////////////////////////////////
function PanelFirstPersonSequence( panelSequence, panel, player )
{
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )
	panel.EndSignal( "OnDestroy" )

	waitthread FirstPersonSequence( panelSequence, panel )
}


//////////////////////////////////////////////////////////////////////
function BBPanelFlipExitAnimation( player, panel, action, e )
{
	local playerSequence = CreateFirstPersonSequence()
	playerSequence.blendTime = 0.0
	playerSequence.attachment = "ref"
	playerSequence.teleport = true

	local panelSequence = CreateFirstPersonSequence()
	panelSequence.blendTime = 0.0

	playerSequence.thirdPersonAnim = action.playerAnimation3pEnd
	playerSequence.firstPersonAnim = action.playerAnimation1pEnd
	panelSequence.thirdPersonAnim = action.panelAnimation3pEnd

	thread FirstPersonSequence( panelSequence, panel )
	waitthread FirstPersonSequence( playerSequence, player, panel )
}


//////////////////////////////////////////////////////////////////////
function TrackContinuousBBPanelUse( panel, player, leechTime )
{
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "ScriptAnimStop" )

	local result = {}
	result.success <- false

	OnThreadEnd
	(
		function() : ( player, result )
		{
			if ( !result.success )
			{
				player.Signal( "OnContinousUseStopped" )
			}
		}
	)

	ButtonUnpressedEndSignal( player, "use" )

	if ( !player.UseButtonPressed() )
		return

	//wait leechTime

	WaitSignalTimeout( panel, leechTime, "StopHacking" )

	if( level.nv.BigBrotherPanelExplosion == true )
	{
		result.success = false
	}
	else
	{
		result.success = true
	}
}

function InitBBPanelUseSuccessFuncTable()
{
	local table = {}
	table.useSuccessEnt <- null
	table.useSuccessFunc <- null
	table.scope <- null
	return table
}

function AddBBPanelUseSuccessFuncTable( panel, table )
{
	// a table that contains
	//1. a function to be called when the control panel is used
	//2. an entity that the function refers to, e.g. the turret to be created
	panel.s.useSuccessFuncArray.append( table )
}

function InitBBPanelUseFailFuncTable()
{
	local table = {}
	table.useFailEnt <- null
	table.useFailFunc <- null
	table.scope <- null
	return table
}

function AddBBPanelUseFailFuncTable( panel, table )
{
	// a table that contains
	//1. a function to be called when the control panel is used
	//2. an entity that the function refers to, e.g. the turret to be created
	panel.s.useFailFuncArray.append( table )
}

function InitBBPanelUseStartFuncTable()
{
	local table = {}
	table.useStartEnt <- null
	table.useStartFunc <- null
	table.scope <- null
	return table
}

function AddBBPanelUseStartFuncTable( panel, table )
{
	// a table that contains
	//1. a function to be called when the control panel is used
	//2. an entity that the function refers to, e.g. the turret to be created
	panel.s.useStartFuncArray.append( table )
}

function SetBBPanelPrompts( ent, func )
{
	ent.s.prompts <- func( ent )
}

function SetBBPanelUsableToEnemies( panel )
{
	if ( panel.GetTeam() == TEAM_IMC || panel.GetTeam() == TEAM_MILITIA  )
	{
		panel.SetUsableByGroup( "enemies pilot" )
		return
	}

	//Not on either player team, just set usable to everyone
	panel.SetUsableByGroup( "pilot" )
}

/*
function PanelFlipsToPlayerTeamAndUsableByEnemies( panel, player )
{
	panel.SetTeam( player.GetTeam() )
	SetBBPanelUsableToEnemies( panel )
}
*/

/*
function GetPanelUseEnts( panel )
{
	local useEntsArray = []
	foreach( useFuncTable in panel.s.useFuncArray )
	{
		if ( useFuncTable.useEnt )
			useEntsArray.append( useFuncTable.useEnt )
	}

	return useEntsArray

}
*/

function GetAllBBPanels()
{
	//Defensively remove control panels that are invalid.
	//This is because we can have control panels in levels for some game modes
	//but not in others, e.g. refuel mode vs tdm

	ArrayRemoveInvalid( level.BBPanels )
	return level.BBPanels
}

/*
function CaptureAllAvailableControlPanels( player )
{
	local panels = GetAllBBPanels()
	foreach ( panel in panels )
	{
		printt( "panel team " + panel.GetTeam() )
		RunPanelUseFunctions( panel, player )
	}
}
*/
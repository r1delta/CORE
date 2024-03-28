//=========================================================
// MP ai turret
//
//=========================================================
RegisterSignal( "Deactivate_Turret" )
DEAD_TURRET_FX <- "P_impact_exp_med_air"
DEAD_MEGA_TURRET_FX <- "xo_spark_med"

PrecacheParticleSystem( DEAD_TURRET_FX )
PrecacheParticleSystem( DEAD_MEGA_TURRET_FX )

const SATCHEL_MODEL = "models/weapons/satchel_charge/satchel_charge.mdl"
PrecacheModel( SATCHEL_MODEL )

enum eTurretType
{
	HeavyTurret,
	LightTurret,
	HeavyAATurret,
}

function main()
{
	AddSpawnCallback( "npc_turret_sentry", LightTurretSpawnFunction )
	AddSpawnCallback( "npc_turret_mega", MegaTurretSpawnFunction )
	AddDeathCallback( "npc_turret_sentry", LightTurretDeathFX )
	AddDeathCallback( "npc_turret_mega", MegaTurretDeathFX )
	AddDeathCallback( "npc_turret_mega", MageTurretRespawn )

	Globalize( LightTurretSpawnFunction )
	Globalize( SpawnReplacementTurret )
	Globalize( FlipTurret )
//	Globalize( SpawnYH803Turret )
//	Globalize( SpawnMegaTurret )
	Globalize( TurretChangeTeam )
	Globalize( HardpointTurretActivate )
	Globalize( HardpointTurretDeactivate )
    Globalize( ReleaseTurret )
	RegisterSignal( "HandleTargetDeath" )
	RegisterSignal( "OnPlayerDisconnectResetTurret" )
	PrecacheModel( SENTRY_TURRET_MODEL )
	Globalize( FindLinkedControlPanel )

	Globalize( SpawnTurret )
	Globalize( CaptureTurret )
	Globalize( MakeTurretInvulnerable )
}

//////////////////////////////////////////////////////////
function TurretChangeTeam( turret, team )
{
	local title = ""
	if ( team != TEAM_UNASSIGNED )
	{
		title = "Turret"
		if ( turret.s.spawnClassname == "npc_turret_mega" )
			title = "#NPC_TURRET_HEAVY"
		//If a turret is on some player's team it should never be invulnerable
		MakeTurretInvulnerable( turret, false )
	}

	turret.SetTeam( team )

	// refresh the turret client side particle effects
	UpdateTurretClientSideParticleEffects( turret )

	if ( !( "notitle" in turret.s ) )
	{
		turret.SetTitle( title )
		turret.SetShortTitle( title )
	}

	if ( "lasersight" in turret.s )
		turret.s.lasersight.SetTeam( team )
}


//////////////////////////////////////////////////////////
function MegaTurretSpawnFunction( turret )
{
	turret.SetMuzzleData( turret.LookupAttachment( "MUZZLE_LEFT_UPPER" ), 4 );

	turret.s.spawnOrigin <- turret.GetOrigin()
	turret.s.spawnAngles <- turret.GetAngles()
	turret.s.spawnName <- turret.GetName()
	turret.s.spawnClassname <- turret.GetClassname()
	turret.s.preventOwnerDamage <- true
	turret.s.linkedToControlPanel <- false

	// Hack to get different turret type in fracture for hardpoints. Need to do this in a cleaner way. Maybe different classname in leveled?
	if ( IsCapturePointTurret( turret ) )
	{
		turret.s.turretType <- eTurretType.HeavyAATurret
	}
	else
	{
		turret.s.turretType <- eTurretType.HeavyTurret
	}

	turret.DisableTurret()
	turret.SetTeam( TEAM_UNASSIGNED )
	//Turrets are invulnerable when you first spawn them!
	MakeTurretInvulnerable( turret, true )

	turret.SetMaxHealth( 8000 )
	turret.SetHealth( 8000 )

	turret.kv.maxEnemyDist = 6000


	//Set Control Panel stuff
	thread LinkToControlPanel( turret, FlipTurret )
	thread RefreshControlPanelOnStateChanges( turret )
}


function RefreshControlPanelOnStateChanges( turret )
{
	turret.EndSignal( "OnDestroy" )

	while ( turret.s.linkedToControlPanel != true )
		wait( 0.0 )

	local panel = FindLinkedControlPanel( turret )
	if ( panel == null )
		return

	panel.EndSignal( "OnDestroy" )

	while ( true )
	{
		WaitSignalOnDeadEnt( turret, "OnTurretStateChange" )

		local panelEHandle = panel.GetEncodedEHandle()
		local players = GetPlayerArray()
		foreach( player in players )
		{
			Remote.CallFunction_Replay( player, "ServerCallback_ControlPanelRefresh", panelEHandle )
		}
	}
}


/////////////////////////////////////////////////////////
function MakeGlow( turret, attachment )
{
	local env_sprite = CreateEntity( "env_sprite" )
	env_sprite.SetOrigin( turret.GetOrigin() )
	env_sprite.SetParent( turret, attachment )
	env_sprite.kv.rendermode = 5 //additive
	env_sprite.kv.rendercolor = "233 67 67 255"  //red
	env_sprite.kv.rendercolorFriendly = "67 87 233 255"	// blue
	env_sprite.kv.model = "sprites/glow_05.vmt"
	env_sprite.kv.scale = "0.25"
	env_sprite.kv.GlowProxySize = 16.0 //was 16 then 60
	env_sprite.kv.HDRColorScale = 15.0
	DispatchSpawn( env_sprite, false )

	//env_sprite.Fire( "HideSprite" )
	/*
	if( attachment in turret.s )
		turret.s.attachment = env_sprite
	else
		turret.s.attachment <- env_sprite

	turret.EndSignal( "OnDestroy" )
	turret.WaitSignal( "OnDeath" )
	env_sprite.Kill()
	*/
	return env_sprite
}


//////////////////////////////////////////////////////////
function LightTurretSpawnFunction( turret )
{
	if ( "skipTurretFX" in turret.s )
		return

	turret.s.spawnOrigin <- turret.GetOrigin()
	turret.s.spawnAngles <- turret.GetAngles()
	turret.s.spawnName <- turret.GetName()
	turret.s.spawnClassname <- turret.GetClassname()
	turret.SetModel( SENTRY_TURRET_MODEL )
	turret.s.turretType <- eTurretType.LightTurret
	turret.s.linkedToControlPanel <- false

	turret.DisableTurret()
	turret.SetTeam( TEAM_UNASSIGNED )
	//Turrets are invulnerable when you first spawn them!
	MakeTurretInvulnerable( turret, true )

	turret.SetMaxHealth( 1200 )
	turret.SetHealth( 1200 )

	//Set Control Panel stuff
	thread LinkToControlPanel( turret, FlipTurret )
}


//////////////////////////////////////////////////////////
function SpawnTurret( classname, model, weapon, title, team, origin, angles, name, solidType )
{
	local new_turret = CreateEntity( classname )
	new_turret.kv.solid = solidType
	new_turret.kv.spawnflags = 0
	new_turret.SetOrigin( origin )
	new_turret.SetAngles( angles )	// must set origin first or the entity may hit the map floor kill trigger on teleport from SetAngles
	new_turret.SetModel( model )
	new_turret.SetName( name )
	new_turret.kv.AccuracyMultiplier = 1.0
	new_turret.SetTeam( team )
	new_turret.SetTitle( title )
	new_turret.SetShortTitle( "" )	// "."

	if( classname == "npc_turret_mega" )
	{
		new_turret.kv.maxEnemyDist = 6000
	}

	new_turret.kv.additionalequipment = weapon

	DispatchSpawn( new_turret )

	return new_turret;
}

//////////////////////////////////////////////////////////
function CleanupTurret( turret )
{
	Assert( IsValid( turret ) )

	if ( "deathflame" in turret.s && IsValid( turret.s.deathflame ) )
			turret.s.deathflame.Kill()

	turret.Kill()
}

//////////////////////////////////////////////////////////
function SpawnReplacementTurret( turret )
{
	local newTurret

	switch( turret.s.turretType )
	{
		case eTurretType.LightTurret:
		{
			newTurret = SpawnYH803Turret( turret )
			break
		}

		case eTurretType.HeavyTurret:
		{
			newTurret = SpawnMegaTurret( turret )
			break
		}

		case eTurretType.HeavyAATurret:
		{
			newTurret = SpawnMegaAATurret( turret )
			break
		}

		default:
		{
			Assert( false, "Unsupported turret type for turret: " + turret  )
		}

	}

	return newTurret
}


//////////////////////////////////////////////////////////
function SpawnYH803Turret( turret )
{
	local weapon = turret.kv.additionalequipment

	/*
	if ( RandomInt( 0, 100 ) > 30 )
		weapon = "mp_weapon_yh803_bullet"
	else
		weapon = "mp_weapon_yh803"
	*/

	local newTurret = SpawnTurret( "npc_turret_sentry", SENTRY_TURRET_MODEL, weapon, "",
									turret.GetTeam(), turret.s.spawnOrigin, turret.s.spawnAngles,
									turret.s.spawnName, 6 /*vPhysics*/ )

	CleanupTurret( turret )
	return newTurret
}

function MageTurretRespawn( turret, damageInfo )
{
	thread MageTurretRespawnThread( turret )
}

function MageTurretRespawnThread( turret )
{
	while( IsValid( turret ) )
	{
		if ( turret.GetTurretState() == TURRET_INACTIVE )
		{
			if ( !( "doNotRespawn" in turret.s ) )
				ReplaceDeadTurret( turret )

			return
		}

		WaitSignalOnDeadEnt( turret, "OnTurretStateChange" )
	}
}

//////////////////////////////////////////////////////////
function SpawnMegaTurret( turret, weapon = "mp_weapon_mega_turret" )
{
	local newTurret = SpawnTurret( "npc_turret_mega", "models/turrets/turret_imc_lrg.mdl", weapon, "",
	                               turret.GetTeam(), turret.s.spawnOrigin, turret.s.spawnAngles,
	                               turret.s.spawnName, 6 /*vPhysics*/ )

	CleanupTurret( turret )
	return newTurret
}

//////////////////////////////////////////////////////////
function SpawnMegaAATurret( turret )
{
	local new_turret = SpawnMegaTurret( turret, "mp_weapon_mega_turret_aa" )
	new_turret.SetTitle( "" )
	new_turret.SetShortTitle( "" )
	new_turret.s.notitle <- true
	SetCrosshairTeamColoringDisabled( new_turret, true )
	return new_turret
}

//////////////////////////////////////////////////////////
function LinkToControlPanel( turret, func )
{
	FlagWait( "EntitiesDidLoad" )
	local controlPanel = FindLinkedControlPanel( turret )
	if ( IsValid( controlPanel ) )
	{
		//printt("Adding turret: " + turret + " to control panel " + controlPanel )
		local table = InitControlPanelUseFuncTable()
		table.scope <- this
		table.useFunc <- func
		table.useEnt <- turret
		AddControlPanelUseFuncTable( controlPanel, table )
		turret.SetControlPanel( controlPanel );
		//Not super happy with this: if control panel controls multiple things,
		//it will be associated with the last thing to add a use function to it.
		AssociateControlPanelWithTurret( controlPanel, turret )

		// when a turret is created if the panel isn't being used set it to be usable by pilots.
		local IsInUse = controlPanel.GetBossPlayer()
		if ( !IsInUse )
			controlPanel.SetUsableByGroup( "pilot" )
	}
	turret.s.linkedToControlPanel = true
}

//////////////////////////////////////////////////////////
function FindLinkedControlPanel( turret )
{
	local targets
	foreach( panel in GetAllControlPanels() )
	{
		targets = GetEntArrayByNameWildCard_Expensive( panel.Get( "target" ) )
		foreach( target in targets )
		{
			if ( target == turret )
				return panel
		}
	}
	return null
}

//////////////////////////////////////////////////////////
//In here: Set use prompt, set panel.nv.ePanelType
//Note that if the control panel controls multiple turrets,
//the last thing to add a use function to it will determine
//what use prompt it shows, what its nv.panelType variable is, etc
function AssociateControlPanelWithTurret( panel, turret )
{
	SetUsePromptForPanel( panel, turret )
}

//////////////////////////////////////////////////////////
function SetUsePromptForPanel( panel, turret )
{
	local usePromptString

	switch ( turret.s.turretType )
	{
		case eTurretType.HeavyTurret:
		{
			if ( panel.GetTeam() == TEAM_UNASSIGNED )
				usePromptString = "#TURRET_HEAVY_ACTIVATE"
			else
				usePromptString = "#TURRET_HEAVY_REPAIR_CAPTURE"
			break
		}
		case eTurretType.LightTurret:
		{
			local panelUseEntsLength = GetPanelUseEnts( panel ).len()
			if ( panel.GetTeam() == TEAM_UNASSIGNED )
			{
				if ( panelUseEntsLength > 1 )
					usePromptString = "#TURRETS_LIGHT_ACTIVATE"
				else
					usePromptString = "#TURRET_LIGHT_ACTIVATE"
			}
			else
			{
				if ( panelUseEntsLength > 1 )
					usePromptString = "#TURRETS_LIGHT_REPAIR_CAPTURE"
				else
					usePromptString = "#TURRET_LIGHT_REPAIR_CAPTURE"
			}
			break
		}

		default:
		{
			Assert( false, "Unsupported turret type for turret: " + turret  )
		}
	}

	panel.SetUsePrompts( usePromptString, usePromptString )
}
Globalize( SetUsePromptForPanel )

//////////////////////////////////////////////////////////////////////
function GetMegaTurretLinkedToPanel( panel ) //Assume only 1 mega turret linked with 1 panel!
{
	local megaTurrets = GetNPCArrayByClass( "npc_turret_mega" )
	foreach ( turret in megaTurrets )
	{
		if ( turret.GetControlPanel() == panel )
			return turret
	}

	return null
}

Globalize( GetMegaTurretLinkedToPanel )

function MegaTurretUsabilityFunc( turret, panel )
{
	if ( !IsAlive( turret ) )
	{
		return "pilot"
	}
	else if ( turret.GetTurretState() == TURRET_INACTIVE )
	{
		//printt( "Panel SetUsableByGroup Pilot, Turret Inactive, MegaTurretUsabilityFunc" )
		return "pilot"
	}
	else if ( panel.GetTeam() == TEAM_IMC || panel.GetTeam() == TEAM_MILITIA  )
	{
		//printt( "Panel SetUsableByGroup Enemies Pilot, panel on team, MegaTurretUsabilityFunc" )
		return "enemies pilot"
	}
	else
	{
		//Not on either player team, just set usable to everyone
		//printt( "Panel SetUsableByGroup Pilot, Panel not on either team, MegaTurretUsabilityFunc" )
		return "pilot"
	}
}
Globalize( MegaTurretUsabilityFunc )

//////////////////////////////////////////////////////////////////////
function CaptureTurret( turret, team, player )
{
	if ( !IsAlive( turret ) )
		return

	//ToDo: Get duration of disable animation associated with turret, wait that amount + a bit, then reneable
	if ( turret.GetTeam() == GetOtherTeam(player.GetTeam()))
	{
		turret.DisableTurret()
		//Don't let turret die while playing animation
		MakeTurretInvulnerable( turret, true )
		wait 2.5
		if ( !IsValid( turret ) ) //Defensive fix for turret getting deleted at end of match
			return
		turret.EnableTurret()
	}
	//Turret's invulnerability gets taken away here
    turret.SetHealth( turret.GetMaxHealth() )
	TurretChangeTeam( turret, team )

	if ( IsValid( player ) ) //Player may have disconnected during the animation of turret powering down
	{
		turret.SetShortTitle( "" )
		turret.SetBossPlayer( player )
	}
	else
	{
		turret.ClearBossPlayer()
	}

	local state = turret.GetTurretState()
	if ( state == TURRET_INACTIVE || state == TURRET_RETIRING )
		turret.EnableTurret()

	if ( IsValid( player ) )
		thread OnPlayerDisconnectReleaseTurret( player, turret )
}

function HardpointTurretActivate( turret, team, turretTarget = null )
{
	Assert( turret != null )
	Assert( team != null )
	wait 2.5
	turret.EnableTurret()
	TurretChangeTeam( turret, team )
	MakeTurretInvulnerable( turret, true )
	turret.ClearBossPlayer()

	if ( IsValid( turretTarget ) )
	{
		printt( "Turret targeting refuel ship" )
		turret.SetEnemy( turretTarget )
		turret.SetEnemyLKP( turretTarget, turretTarget.GetOrigin() )
	}
}

function MakeTurretInvulnerable( turret, invulnerable )
{
	Assert( IsValid( turret ) )
	if ( invulnerable )
	{
		turret.SetInvulnerable()
		turret.SetNoTarget(true)
		turret.SetNoTargetSmartAmmo(true)
	}
	else
	{
		turret.ClearInvulnerable()
		turret.SetNoTarget(false)
		turret.SetNoTargetSmartAmmo(false)
	}
}

function HardpointTurretDeactivate( turret )
{
	Assert( turret != null )
	ReleaseTurret( turret )
}

//////////////////////////////////////////////////////////////////////
function ReleaseTurret( turret, panel = null )
{
	TurretChangeTeam( turret, TEAM_UNASSIGNED )
	turret.ClearBossPlayer()

	if ( !turret.IsInvulnerable() )
		MakeTurretInvulnerable( turret, true )

	local state = turret.GetTurretState()
	if ( state != TURRET_INACTIVE && state != TURRET_RETIRING )
		turret.DisableTurret()

	//Allow panel to be usable to everyone to allow allies to repair this turret
	if ( IsValid( panel ) && turret.GetControlPanel() == panel )
	{
		panel.SetUsable()
		panel.SetUsableByGroup( "pilot" )
	}
}

//////////////////////////////////////////////////////////
function FlipTurret( panel, player, turret )
{
//	printt( "FLIP TURRET" )
//	printt( "turret Ent Index", turret.GetEntIndex() )
	//printt("FlipTurret, panel" + panel + ", player: " + player + ", turret :" + turret)
	//In here: Do stuff with the panel, the player, and the useEnt if needed
	if ( !IsAlive( turret ) )
	{
		local replacementTurret = ReplaceDeadTurret( turret )
		//Call FlipTurret again on the replacement Turret
		FlipTurret( panel, player, replacementTurret )
		return
	}

	thread CaptureTurret( turret, player.GetTeam(), player )
	thread OnTurretDeathReleaseTurret( turret, panel )
	PanelFlipsToPlayerTeamAndUsableByEnemies( panel, player )
	AddTurretCaptureScore( turret, player )
	SetUsePromptForPanel( panel, turret )
}

//////////////////////////////////////////////////////////
function OnTurretDeathReleaseTurret( turret, panel )
{
	turret.Signal( "HandleTargetDeath" )
	turret.EndSignal( "HandleTargetDeath" )
	turret.EndSignal( "OnDestroy" )
	turret.WaitSignal( "OnDeath" )

	ReleaseTurret( turret, panel )

	if ( !IsValid( panel ) )
		return

	local panelEHandle = panel.GetEncodedEHandle()
	local players = GetPlayerArray()
	foreach( player in players )
	{
		Remote.CallFunction_Replay( player, "ServerCallback_ControlPanelRefresh", panelEHandle )
	}
}

//////////////////////////////////////////////////////////
function ReplaceDeadTurret( turret )
{
//	printt( "REPLACE DEAD TURRET" )

	if ( IsAlive( turret ) )
		return turret

	local replacementTurret = SpawnReplacementTurret( turret )

	local panel = turret.GetControlPanel()
	if ( IsValid( panel ) )
	{
		//printt( "Replacement turret inheriting control panel from previous turret" )
		replacementTurret.SetControlPanel( panel );
		//Need to search through panel's usefuncarray and remove the element with the old turret
		//New turret gets added to the panel automatically through the spawncallback
		foreach( index, useFuncTable in panel.s.useFuncArray )
		{
			if ( useFuncTable.useEnt == turret )
			{
				panel.s.useFuncArray.remove( index )
				break
			}
		}

	}

	return replacementTurret
}

//////////////////////////////////////////////////////////////////////
function AddTurretCaptureScore( turret, player )
{
	switch( turret.s.turretType )
	{
		case eTurretType.HeavyTurret:
		{
			AddPlayerScore( player, "ControlPanelHeavyTurretActivate" )
			break
		}

		case eTurretType.LightTurret:
		{
			AddPlayerScore( player, "ControlPanelLightTurretActivate" )
			break
		}

		default:
		{
			Assert( false, "Unsupported turret type for turret: " + turret  )
		}
	}
}

function OnPlayerDisconnectReleaseTurret( player, turret )
{
	turret.Signal( "OnPlayerDisconnectResetTurret" )
	turret.EndSignal( "OnPlayerDisconnectResetTurret" )
	turret.EndSignal( "OnDeath" )
	player.WaitSignal( "Disconnected" )

	ReleaseTurret( turret, turret.GetControlPanel() )

}

//////////////////////////////////////////////////////////
function AttachSatchel( turret, angles, offset )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( "satchels" in turret.s )
		return

	local prop_dynamic = CreateEntity( "prop_dynamic" )
	prop_dynamic.kv.spawnflags = 0
	prop_dynamic.SetAngles( angles )
	prop_dynamic.SetOrigin( PositionOffsetFromEnt( turret, offset.x, offset.y, offset.z ) )
	prop_dynamic.kv.model = SATCHEL_MODEL
	prop_dynamic.SetName(  "_satchel" + UniqueString() + turret.GetName() )
	//prop_dynamic.kv.fadedist = -1
	//prop_dynamic.kv.rendermode = 9
	//prop_dynamic.kv.renderamt = 255
	//prop_dynamic.kv.rendercolor = "255 255 255"
	prop_dynamic.kv.solid = 6
	//prop_dynamic.kv.MinAnimTime = 5
	//prop_dynamic.kv.MaxAnimTime = 10
	//prop_dynamic.kv.TeamNumber = dropPod.GetTeam()
	//prop_dynamic.kv.VisibilityFlags = 4				// Visible to enemy team only
	DispatchSpawn( prop_dynamic )

	prop_dynamic.s.turret <- turret

	if ( !( "satchels" in turret.s ) )
		turret.s.satchels <- []
	turret.s.satchels.append( prop_dynamic )

	prop_dynamic.s.skip_view_model_anim <- true
	prop_dynamic.s.parent_model <- turret
	prop_dynamic.s.fuse_time <- 5


	turret.EndSignal( "OnDestroy" )
	turret.WaitSignal( "OnDeath" )
}


//////////////////////////////////////////////////////////
function Turret_Satchel_Explodes( satchel, player )
{
	if( !( IsValid( satchel ) ) )
		return
	satchel.EndSignal( "OnDestroy" )
	//printt( "turret_Satchel_Explodes" + satchel )
	local turret = satchel.s.turret
	//is turret alive?
	//do damage to turret in player's name
	if ( IsValid_ThisFrame( turret ) )
	{
		if( IsAlive( turret ) )
			turret.TakeDamage( turret.GetHealth(), player, player, { damageSourceId=eDamageSourceId.ai_turret } )
	}


	//make explosion
	local env_explosion = CreateEntity( "env_explosion" )
	env_explosion.kv.iMagnitude = 100    //was 55
	env_explosion.kv.iRadiusOverride = 120
	env_explosion.kv.fireballsprite = "sprites/zerogxplode.spr"
	env_explosion.kv.rendermode = 5   //additive
	env_explosion.kv.damageSourceId = eDamageSourceId.ai_turret_explosion
	//env_explosion.kv.spawnflags = 84 //nosound no fireball no decal
	//env_explosion.kv.spawnflags = 112 //no sound no sparks no decal
	//env_explosion.kv.spawnflags = 1648 //no sound no sparks no decal no particles no dlights
	//env_explosion.kv.spawnflags = 1652 //no sound no sparks no decal no particles no dlights no fireball
	//env_explosion.kv.spawnflags = 1620 //no sound no decal no particles no dlights no fireball
	//env_explosion.kv.scriptDamageType = damageTypes.FlamingGibs

	env_explosion.SetOrigin( satchel.GetOrigin() )
	env_explosion.SetTeam( satchel.GetTeam() )
	if( IsValid( player ) )
	{
		env_explosion.SetOwner( player )
	}
	DispatchSpawn( env_explosion, false )

	env_explosion.Fire( "Explode" )
	env_explosion.Kill( 3 )
}

function LightTurretDeathFX( turret, damageInfo )
{
	turret.SetBodygroup( 0, 1 )
	UpdateTurretClientSideParticleEffects( turret )

	PlayFX( DEAD_TURRET_FX, turret.GetOrigin() + Vector( 0,0,38 ) )	// played with a slight offset as requested by BigRig
}

function MegaTurretDeathFX( turret, damageInfo )
{
	UpdateTurretClientSideParticleEffects( turret )

	local impactSpark = CreateEntity( "info_particle_system" )
	impactSpark.kv.effect_name = DEAD_MEGA_TURRET_FX
	impactSpark.kv.start_active = 1
	impactSpark.kv.VisibilityFlags = 7

	DispatchSpawn( impactSpark, false )

	impactSpark.SetParent( turret, "glow1" )

	if ( "deathflame" in turret.s )
		turret.s.deathflame = impactSpark
	else
		turret.s.deathflame <- impactSpark
}

function UpdateTurretClientSideParticleEffects( turret )
{
	if ( !IsValid( turret ) )
		return

	local turretEHandle = turret.GetEncodedEHandle()
	local players = GetPlayerArray()
	foreach( player in players )
	{
		Remote.CallFunction_Replay( player, "ServerCallback_TurretRefresh", turretEHandle )
	}
}
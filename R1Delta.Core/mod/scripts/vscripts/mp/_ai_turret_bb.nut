//=========================================================
// MP ai bb turret
//
//=========================================================
DEAD_MEGA_TURRET_FX <- "xo_spark_med"

PrecacheParticleSystem( DEAD_MEGA_TURRET_FX )

function main()
{
	PrecacheModel( SENTRY_TURRET_MODEL )

	AddSpawnCallback( "npc_turret_mega_bb", BBTurretSpawnFunction )
	AddDeathCallback( "npc_turret_mega_bb", BBTurretDeathFX )
	AddDeathCallback( "npc_turret_mega_bb", BBTurretRespawn )

	Globalize( BBTurretChangeTeam )
    Globalize( ReleaseBBTurret )
    Globalize( ReplaceDeadBBTurret )
	RegisterSignal( "HandleTargetDeath" )
	RegisterSignal( "OnPlayerDisconnectResetTurret" )

	Globalize( CaptureBBTurret )
	Globalize( MakeBBTurretInvulnerable )
}

//////////////////////////////////////////////////////////
function BBTurretChangeTeam( turret, team )
{
	if( turret == null || !IsValid( turret ) )
		return

	if( team == turret.GetTeam() )
	{
		printt("[LJS] SameTeam???? ")
		printt("[LJS] turret Name: ", turret.GetName())
		return
	}

	printt("bbTurret Set Team: ", team)
	printt("[LJS] turret Name: ", turret.GetName())

	local title = ""
	if ( team != TEAM_UNASSIGNED )
	{
		title = "Turret"
		if ( turret.s.spawnClassname == "npc_turret_mega_bb" )
			title = "#NPC_TURRET_HEAVY"
		//If a turret is on some player's team it should never be invulnerable
		printt("Set Invulnerable false")
		
		if ( turret.IsInvulnerable() )
			MakeBBTurretInvulnerable( turret, false )
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
function BBTurretSpawnFunction( turret )
{
	printt("[LJS] call BBTurretSpawnFunction")
	turret.SetMuzzleData( turret.LookupAttachment( "MUZZLE_LEFT_UPPER" ), 4 );

	printt( "[LJS] spawn Turret Name: ",turret.GetName())

	turret.s.spawnOrigin <- turret.GetOrigin()
	turret.s.spawnAngles <- turret.GetAngles()
	turret.s.spawnName <- turret.GetName()
	turret.s.spawnClassname <- turret.GetClassname()
	turret.s.preventOwnerDamage <- true
	turret.s.linkedToControlPanel <- false

	turret.kv.maxEnemyDist = 6000

	//turret.DisableTurret()

	//Turrets are invulnerable when you first spawn them!
	//MakeBBTurretInvulnerable( turret, true )

	turret.SetMaxHealth( 12000 )
	turret.SetHealth( 12000 )


	//Set Control Panel stuff
	thread LinkToBBPanel( turret )
	thread CheckState( turret )
}

function CheckState( turret )
{
	while( IsValid( turret ) )
	{
		printt( turret.GetName(), " State: ", turret.GetTurretState() )

		WaitSignalOnDeadEnt( turret, "OnTurretStateChange" )
	}
}

//////////////////////////////////////////////////////////
function CleanupBBTurret( turret )
{
	Assert( IsValid( turret ) )

	if ( "deathflame" in turret.s && IsValid( turret.s.deathflame ) )
			turret.s.deathflame.Kill()

	turret.Kill()
}

//////////////////////////////////////////////////////////
function SpawnReplacementBBTurret( turret )
{
	local newTurret

	local newTurret = SpawnBBTurret( "npc_turret_mega_bb", "models/turrets/turret_imc_lrg.mdl", "mp_weapon_mega_turret", "",
	                               TEAM_UNASSIGNED, turret.s.spawnOrigin, turret.s.spawnAngles,
	                               turret.s.spawnName, 6 /*vPhysics*/ )

	if( !("spawnName" in newTurret.s))
		newTurret.s.spawnName <- turret.GetName()
	else
		newTurret.s.spawnName = turret.GetName()

	if( !("spawnClassname" in newTurret.s))
		newTurret.s.spawnClassname <- turret.GetClassname()
	else
		newTurret.s.spawnClassname = turret.GetClassname()

	if( !("preventOwnerDamage" in newTurret.s))
		newTurret.s.preventOwnerDamage <- true
	else
		newTurret.s.preventOwnerDamage = true

	if( !("linkedToControlPanel" in newTurret.s))
		newTurret.s.linkedToControlPanel <- false
	else
		newTurret.s.linkedToControlPanel = false

	newTurret.kv.maxEnemyDist = 6000

	newTurret.SetMaxHealth( 12000 )
	newTurret.SetHealth( 12000 )

	local panel = turret.GetControlPanel()

	if ( IsValid( panel ) )
	{
		//printt( "Replacement turret inheriting control panel from previous turret" )
		turret.SetControlPanel( panel );
		newTurret.s.linkedToControlPanel = true;
	}

	CleanupBBTurret( turret )

	thread CheckState( newTurret )

	return newTurret
}

//////////////////////////////////////////////////////////
function SpawnBBTurret( classname, model, weapon, title, team, origin, angles, name, solidType )
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

	new_turret.kv.maxEnemyDist = 7000

	new_turret.kv.additionalequipment = weapon

	DispatchSpawn( new_turret )

	return new_turret;
}

function BBTurretRespawn( turret, damageInfo )
{
	//ReplaceDeadBBTurret( turret )
	thread BBTurretRespawnThread( turret )
}

function BBTurretRespawnThread( turret )
{
	while( IsValid( turret ) )
	{
		if ( turret.GetTurretState() == TURRET_INACTIVE )
		{
			if ( !( "doNotRespawn" in turret.s ) )
				ReplaceDeadBBTurret( turret )

			return
		}

		WaitSignalOnDeadEnt( turret, "OnTurretStateChange" )
	}
}

//////////////////////////////////////////////////////////
function LinkToBBPanel( turret )
{
	FlagWait( "EntitiesDidLoad" )
	local BBPanel = FindLinkedBBPanel( turret )
	if ( IsValid( BBPanel ) )
	{
		turret.SetControlPanel( BBPanel );
		turret.s.linkedToControlPanel = true
	}
}

//////////////////////////////////////////////////////////
function FindLinkedBBPanel( turret )
{
	local targets
	foreach( panel in GetAllBBPanels() )
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

//////////////////////////////////////////////////////////////////////
function GetBBTurretLinkedToPanel( panel ) //Assume only 1 mega turret linked with 1 panel!
{
	local bbTurrets = GetNPCArrayByClass( "npc_turret_mega_bb" )
	foreach ( turret in bbTurrets )
	{
		if ( turret.GetControlPanel() == panel )
			return turret
	}

	return null
}

Globalize( GetBBTurretLinkedToPanel )

//////////////////////////////////////////////////////////////////////
function CaptureBBTurret( turret, team, player = null )
{
	printt("[LJS] CaptureBBTurret")
	if ( !IsAlive( turret ) )
		return

	//ToDo: Get duration of disable animation associated with turret, wait that amount + a bit, then reneable
	if ( turret.GetTeam() != team )
	{
		turret.DisableTurret()
		//Don't let turret die while playing animation
		if ( !turret.IsInvulnerable() )
			MakeBBTurretInvulnerable( turret, true )

		wait 2.5
		if ( !IsValid( turret ) ) //Defensive fix for turret getting deleted at end of match
			return

		turret.EnableTurret()

		if ( turret.IsInvulnerable() )
			MakeBBTurretInvulnerable( turret, false )
	}
	
	//Turret's invulnerability gets taken away here
    turret.SetHealth( turret.GetMaxHealth() )
	BBTurretChangeTeam( turret, team )

	if ( IsValid( player ) ) //Player may have disconnected during the animation of turret powering down
	{
		turret.SetShortTitle( "" )
		turret.SetBossPlayer( player )

		thread OnPlayerDisconnectReleaseBBTurret( player, turret )
	}
	else
	{
		turret.ClearBossPlayer()
	}

	local state = turret.GetTurretState()
	if ( state == TURRET_INACTIVE || state == TURRET_RETIRING )
		turret.EnableTurret()

	thread OnBBTurretDeathReleaseBBTurret( turret )
}

function MakeBBTurretInvulnerable( turret, invulnerable )
{
	printt( "[LJS] invulnerable: ", invulnerable)
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


//////////////////////////////////////////////////////////////////////
function ReleaseBBTurret( turret, panel = null )
{
	printt("[LJS] ReleaseBBTurret")

	if( turret == null || !IsValid(turret) )
		return

	BBTurretChangeTeam( turret, TEAM_UNASSIGNED )
	turret.ClearBossPlayer()

	if ( !turret.IsInvulnerable() )
		MakeBBTurretInvulnerable( turret, true )

	local state = turret.GetTurretState()
	if ( state != TURRET_INACTIVE && state != TURRET_RETIRING )
		turret.DisableTurret()
}


//////////////////////////////////////////////////////////
function OnBBTurretDeathReleaseBBTurret( turret, panel = null )
{
	turret.Signal( "HandleTargetDeath" )
	turret.EndSignal( "HandleTargetDeath" )
	turret.EndSignal( "OnDestroy" )
	turret.WaitSignal( "OnDeath" )

	ReleaseBBTurret( turret, panel )
}

//////////////////////////////////////////////////////////
function ReplaceDeadBBTurret( turret )
{
//	printt( "REPLACE DEAD TURRET" )

	if ( IsAlive( turret ) )
		return turret

	local replacementTurret = SpawnReplacementBBTurret( turret )

	local panel = turret.GetControlPanel()
	if ( IsValid( panel ) )
	{
		//printt( "Replacement turret inheriting control panel from previous turret" )
		replacementTurret.SetControlPanel( panel );
	}

	return replacementTurret
}

function OnPlayerDisconnectReleaseBBTurret( player, turret )
{
	turret.Signal( "OnPlayerDisconnectResetTurret" )
	turret.EndSignal( "OnPlayerDisconnectResetTurret" )
	turret.EndSignal( "OnDeath" )
	player.WaitSignal( "Disconnected" )

	ReleaseBBTurret( turret, turret.GetControlPanel() )

}

function BBTurretDeathFX( turret, damageInfo )
{
	turret.SetTeam( TEAM_UNASSIGNED )

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

	UpdateTurretClientSideParticleEffects( turret )
}

function UpdateTurretClientSideParticleEffects( turret )
{
	if ( !IsValid( turret ) )
		return

	local turretEHandle = turret.GetEncodedEHandle()
	local players = GetPlayerArray()
	foreach( player in players )
	{
		Remote.CallFunction_Replay( player, "ServerCallback_BBTurretRefresh", turretEHandle )
	}
}
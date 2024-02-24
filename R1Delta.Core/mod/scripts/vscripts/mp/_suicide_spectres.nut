//spectres
const SPECTRE_TRIGGER_EXPLODE_DIST = 200
const SPECTRE_EXPLOSION_RADIUSFALLOFFMAX = 300
const SPECTRE_EXPLOSION_RADIUSFULLDMG = 200
const SPECTRE_EXPLOSION_TITANDMG = 500
const SPECTRE_EXPLOSION_PILOTDMG = 100

enum eSuicideState
{
	SPECTRE_STATE_NULL // just to have 0
	SPECTRE_STATE_HANGING
	SPECTRE_STATE_DEACTIVATING
	SPECTRE_STATE_EXPLODING_ONPROXIMITY
	SPECTRE_STATE_EXPLODING_ONDAMAGE
	SPECTRE_STATE_SEARCHING
}

const SFX_SPECTRE_OVERLOAD 			= "corporate_spectre_overload_beep"
const SFX_SPECTRE_OVERLOAD_COOP		= "CoOp_Spectre_Overload_Beep"
const SFX_SPECTRE_EXPLODE 			= "corporate_spectre_death_explode"
const SFX_SPECTRE_NEUTRALIZED 		= "corporate_spectre_neutralized"
const SFX_SPECTRE_NEUTRALIZED_SPARKS = "marvin_weld"

const SUICIDE_FAST_MOVESPEED = 1.35

const CHAIN_EXPLOSION_INTERVALMIN 		= 0.1
const CHAIN_EXPLOSION_INTERVALMAX 		= 0.22
const CHAIN_EXPLOSION_MAXINTERVAL 		= 1.0
const CHAIN_EXPLOSION_MAXINDEX			= 10

function main()
{
	Globalize( SuicideSpectreEnemyChanged )
	Globalize( SetSuicideSpectreExplosionData )
	Globalize( ResetSuicideSpectreExplosionData )
	Globalize( DisableNeutralize )
	Globalize( EnableNeutralize )

	RegisterSignal( "Dying" )//for spectre
	RegisterSignal( "SuicideGotEnemy" )
	RegisterSignal( "SuicideLostEnemy" )

	level.spectreAnims <- {}
	level.spectreAnims[ "SpectreNeutralized" ] <- []
	level.spectreAnims[ "SpectreNeutralized" ].append( "sp_death_twitch_backfall" )
	level.spectreAnims[ "SpectreNeutralized" ].append( "sp_death_twitch" )
	level.spectreAnims[ "SpectreNeutralized" ].append( "sp_death_sidefall" )
	level.spectreAnims[ "SpectreNeutralized" ].append( "sp_death_overload" )
	level.spectreAnims[ "SpectreNeutralized" ].append( "sp_death_fallback_fire" )
	level.spectreAnims[ "spectreSearch" ] <- []
	level.spectreAnims[ "spectreSearch" ].append( "sp_suicide_spectre_search" )
	level.spectreAnims[ "spectreSearch" ].append( "sp_suicide_spectre_search_B" )
	level.spectreAnims[ "spectreSearch" ].append( "sp_suicide_spectre_search_C" )
	level.spectreAnims[ "spectreSearchDrone" ] <- []
	level.spectreAnims[ "spectreSearchDrone" ].append( "sp_suicide_spectre_search_drone" )
	level.spectreAnims[ "spectreSearchDrone" ].append( "sp_suicide_spectre_search_drone_B" )
	level.spectreAnims[ "spectreSearchDrone" ].append( "sp_suicide_spectre_search_drone_C" )

	level.spectreAnims[ "SpectreSuicideWalk" ] <- []
	level.spectreAnims[ "SpectreSuicideWalk" ].append( "sp_suicide_spectre_run" )
	level.spectreAnims[ "SpectreSuicideWalk" ].append( "sp_suicide_spectre_fastwalk" )
	level.spectreAnims[ "SpectreSuicideWalk" ].append( "sp_suicide_spectre_walk" )

	level.activeSuicideSpectres <- []
	level.chainExplosionTime <- 0
	level.chainExplosionIndex <- 0

	AddDamageCallback( "npc_spectre", SpectreSuicideOnDamaged )
}

function SpawnSuicideSpectre( team, squadName, origin, angles )
{
	local spectre = SpawnSpectre( team, squadName, origin, angles )
	MakeSuicideSpectre( spectre )
	return spectre
}
Globalize( SpawnSuicideSpectre )


/************************************************************************************************\

 ######  ######## ######## ##     ## ########
##    ## ##          ##    ##     ## ##     ##
##       ##          ##    ##     ## ##     ##
 ######  ######      ##    ##     ## ########
      ## ##          ##    ##     ## ##
##    ## ##          ##    ##     ## ##
 ######  ########    ##     #######  ##

\************************************************************************************************/
function MakeSuicideSpectre( spectre )
{
	spectre.SetSubclass( eSubClass.suicideSpectre )

	//--------------------------------------------------------------
	// Spectre properties to make them do unarmed chase/search
	//--------------------------------------------------------------
	Assert( !( "suicideBehavior" in spectre.s ), "Trying to run suicide behavior twice on a spectre" )

	spectre.s.suicideBehavior <- {}
	spectre.s.suicideBehavior.triggerExplodeDist 		<- null
	spectre.s.suicideBehavior.triggerExplodeDistSqr 	<- null
	spectre.s.suicideBehavior.explodeTitanDmg 			<- null
	spectre.s.suicideBehavior.explodePilotDmg 			<- null
	spectre.s.suicideBehavior.explodeRadiusFalloffMax 	<- null
	spectre.s.suicideBehavior.explodeRadiusFullDamage 	<- null
	ResetSuicideSpectreExplosionData( spectre )

	spectre.s.suicideBehavior.explosionFX <- FX_SPECTRE_EXPLOSION
	spectre.s.suicideBehavior.explosionSFX <- SFX_SPECTRE_EXPLODE

	spectre.s.suicideBehavior.allowNeutralize <- true
	spectre.s.state <- eSuicideState.SPECTRE_STATE_SEARCHING

	spectre.SetMaxHealth( 50 )
	spectre.SetHealth( 50 )
	spectre.SetAimAssistAllowed( false )
	spectre.SetAllowMelee( false )
	spectre.AllowSuicideAttack( true )
	DisableLeeching( spectre )

	spectre.s.moveAnim <- Random( level.spectreAnims[ "SpectreSuicideWalk" ] )
	spectre.SetMoveAnim( spectre.s.moveAnim )
	spectre.SetIdleAnim( Random( level.spectreAnims[ "spectreSearch" ] ) )
	spectre.kv.disableArrivalMoveTransitions = true
	spectre.kv.disableArrivals = true
	spectre.CrouchCombat( false )

	spectre.kv.allowShoot = 0
	spectre.TakeActiveWeapon()
	spectre.SetEnemyChangeCallback( "SuicideSpectreEnemyChanged" )
	spectre.IgnoreClusterDangerTime( true )
	spectre.FollowSafePaths( false )
	spectre.AllowIndoorActivityOverride( false )
	spectre.SetLookDist( SPECTRE_MAX_SIGHT_DIST )
	spectre.SetHearingSensitivity( 10 ) //1 is default

	spectre.SetModel( SUICIDE_SPECTRE_MODEL )
	spectre.Signal( "Stop_SimulateGrenadeThink" )
	spectre.SetTitle( "#NPC_SPECTRE_SUICIDE" )
	spectre.SetSkin( 2 )

	spectre.s.fakeHealth <- spectre.GetHealth()
	spectre.s.fakeMaxHealth <- spectre.GetMaxHealth()

	spectre.SetAISettings( "suicidespectre" )

	thread DoSpectreLogicDelayed( spectre )
}

function DoSpectreLogicDelayed( spectre )
{
	spectre.EndSignal( "OnDeath" )
	spectre.EndSignal( "OnDestroy" )

	wait 0.1 //just so any initial settings are caught

	//for damage hacking
	spectre.s.fakeHealth = spectre.GetHealth()
	spectre.SetMaxHealth( spectre.GetMaxHealth() + 10000 )
	spectre.SetHealth( spectre.GetHealth() + 10000 )

	thread FreeSpectreSlotOnDeath( spectre )
	thread SpectreWaitToExplode( spectre )
}


function SetFastSpectre( spectre )
{
	spectre.s.moveAnim = "sp_suicide_spectre_run"
	SuicideWalk( spectre )
}
Globalize( SetFastSpectre )

function SetSuicideSpectreExplosionData(  spectre, triggerDist = null, titanDmg = null, pilotDmg = null, radiusFalloffMax = null, radiusFullDamage = null )
{
	Assert( "suicideBehavior" in spectre.s )

	if ( triggerDist )//the distance to a player at which the spectre will explode
		spectre.s.suicideBehavior.triggerExplodeDist 		= triggerDist

	if ( titanDmg )//the max damage to a titan
		spectre.s.suicideBehavior.explodeTitanDmg 			= titanDmg

	if ( pilotDmg )//the max damage to a pilot
		spectre.s.suicideBehavior.explodePilotDmg 			= pilotDmg

	if ( radiusFalloffMax )//the max radius - at which point the damage is 0
		spectre.s.suicideBehavior.explodeRadiusFalloffMax 	= radiusFalloffMax

	if ( radiusFullDamage )//the rull damage radius - outside of this damage begins to falloff
		spectre.s.suicideBehavior.explodeRadiusFullDamage 	= radiusFullDamage

	__UpdateSuicideSpectreExplosionData( spectre )
}

function ResetSuicideSpectreExplosionData( spectre )
{
	Assert( "suicideBehavior" in spectre.s )

	spectre.s.suicideBehavior.triggerExplodeDist 		= SPECTRE_TRIGGER_EXPLODE_DIST
	spectre.s.suicideBehavior.explodeTitanDmg 			= SPECTRE_EXPLOSION_TITANDMG
	spectre.s.suicideBehavior.explodePilotDmg 			= SPECTRE_EXPLOSION_PILOTDMG
	spectre.s.suicideBehavior.explodeRadiusFalloffMax 	= SPECTRE_EXPLOSION_RADIUSFALLOFFMAX
	spectre.s.suicideBehavior.explodeRadiusFullDamage 	= SPECTRE_EXPLOSION_RADIUSFULLDMG

	__UpdateSuicideSpectreExplosionData( spectre )
}

function __UpdateSuicideSpectreExplosionData( spectre )
{
	Assert( "suicideBehavior" in spectre.s )

	spectre.s.suicideBehavior.triggerExplodeDistSqr = spectre.s.suicideBehavior.triggerExplodeDist * spectre.s.suicideBehavior.triggerExplodeDist
}

function AllowNeutralize( spectre )
{
	Assert( "suicideBehavior" in spectre.s )

	return spectre.s.suicideBehavior.allowNeutralize
}

function DisableNeutralize( spectre )
{
	Assert( "suicideBehavior" in spectre.s )

	spectre.s.suicideBehavior.allowNeutralize = false
}

function EnableNeutralize( spectre )
{
	Assert( "suicideBehavior" in spectre.s )

	spectre.s.suicideBehavior.allowNeutralize = true
}


function SuicideSpectreEnemyChanged( spectre )
{
	// Spectre "Speaks"
	if ( ( RandomFloat( 0, 1 ) ) < 0.02 )
		EmitSoundOnEntity( spectre, "diag_imc_spectre_gs_spotenemypilot_01_1" )

	local enemy = spectre.GetEnemy()
	if ( enemy && enemy.IsTitan() )
		SuicideSprint( spectre )
	else
		SuicideWalk( spectre )
}

function SuicideWalk( spectre )
{
	spectre.SetMoveSpeedScale( SUICIDE_FAST_MOVESPEED )
	spectre.PreferSprint( false )
	spectre.SetMoveAnim( spectre.s.moveAnim )
}

function SuicideSprint( spectre )
{
	spectre.SetMoveSpeedScale( 1.0 )
	spectre.PreferSprint( true )
	spectre.ClearMoveAnim()
}


/************************************************************************************************\

########  ########   #######  ##     ## #### ##     ## #### ######## ##    ##
##     ## ##     ## ##     ##  ##   ##   ##  ###   ###  ##     ##     ##  ##
##     ## ##     ## ##     ##   ## ##    ##  #### ####  ##     ##      ####
########  ########  ##     ##    ###     ##  ## ### ##  ##     ##       ##
##        ##   ##   ##     ##   ## ##    ##  ##     ##  ##     ##       ##
##        ##    ##  ##     ##  ##   ##   ##  ##     ##  ##     ##       ##
##        ##     ##  #######  ##     ## #### ##     ## ####    ##       ##

\************************************************************************************************/
function SpectreWaitToExplode( spectre )
{
	spectre.EndSignal( "OnDeath" )

	local canExplode = false
	local enemyTeam = GetTeamIndex(GetOtherTeams(1 << spectre.GetTeam()))

	spectre.s.state = eSuicideState.SPECTRE_STATE_SEARCHING

	while( true )
	{
		wait 0.1

		// Get out of this loop if it's not in default mode
		if ( spectre.s.state != eSuicideState.SPECTRE_STATE_SEARCHING )
			break

		//If spectre is not interrruptable, don't bother
		if ( ( IsNPC( spectre ) ) && ( !spectre.IsInterruptable() ) )
			continue

		//If spectre is parented, don't bother
		if ( IsValid( spectre.GetParent() ) )
			continue

		// See if any player is close eneough to trigger self-destruct
		local enemies = []
		local closestEnemy = spectre.GetClosestEnemy()
		if ( closestEnemy )
			enemies.append( closestEnemy )

		local currentEnemy = spectre.GetEnemy()
		if ( currentEnemy && currentEnemy != closestEnemy && !currentEnemy.IsCloaked( true ) )
			enemies.append( currentEnemy )

		canExplode = false
		foreach( enemy in enemies )
		{
			//distance check
			local distSq = DistanceSqr( spectre.GetOrigin(), enemy.GetOrigin() )
			local distCheckSqr = spectre.s.suicideBehavior.triggerExplodeDistSqr
			if ( distSq > distCheckSqr )
				continue

			canExplode = true
			break
		}

		if ( canExplode )
			break
	}

	if ( canExplode )
	{
		local results = {}
		results.activator <- spectre
		results.inflictor <- spectre
		results.damageSourceId <- eDamageSourceId.suicideSpectre
		thread SpectreSelfDestructOnProximity( spectre, results )
	}
}

/************************************************************************************************\

######## ##     ## ########  ##        #######  ########  ########
##        ##   ##  ##     ## ##       ##     ## ##     ## ##
##         ## ##   ##     ## ##       ##     ## ##     ## ##
######      ###    ########  ##       ##     ## ##     ## ######
##         ## ##   ##        ##       ##     ## ##     ## ##
##        ##   ##  ##        ##       ##     ## ##     ## ##
######## ##     ## ##        ########  #######  ########  ########

\************************************************************************************************/
function SpectreSelfDestructOnDamage( spectre, results )
{
	if ( AllowNeutralize( spectre ) )
		SpectreNeutralize( spectre, results  )
	else
		__SpectreSelfDestructInternal( spectre, results, eSuicideState.SPECTRE_STATE_EXPLODING_ONDAMAGE )
}

function SpectreSelfDestructOnProximity( spectre, results )
{
	__SpectreSelfDestructInternal( spectre, results, eSuicideState.SPECTRE_STATE_EXPLODING_ONPROXIMITY )
}

function __SpectreSelfDestructInternal( spectre, results, state )
{
	if ( !IsAlive( spectre ) )
		return

	//if we're already exploding - ignore it
	if ( spectre.s.state == eSuicideState.SPECTRE_STATE_EXPLODING_ONDAMAGE )
		return
	spectre.s.state = state

	spectre.EndSignal( "OnDeath" )
	spectre.EndSignal( "OnDestroy" )
	spectre.Signal( "Dying" )

	thread SpectrePreExplodeTell( spectre )

	// Spectre plays self destruct anim
	if ( state == eSuicideState.SPECTRE_STATE_EXPLODING_ONPROXIMITY )
	{
		local anim = "sp_suicide_spectre_explode_stand"
		if ( spectre.IsInterruptable() && !IsValid( spectre.GetParent() ) )
			thread PlayAnimGravity( spectre, anim )
		local time = spectre.GetSequenceDuration( anim )
		wait time
	}
	else
	{
		local waitTime = 0

		if ( IsValid( results.inflictor ) && IsPlayer( results.inflictor ) )
			waitTime = 0.3//if the player shot this guy, then give this much time for a tell before exploding
		else
		{
			//we are the result of a chain reaction
			local curTime = Time()
			local newChainExplosion = false

			if ( curTime - level.chainExplosionTime > CHAIN_EXPLOSION_MAXINTERVAL )
				newChainExplosion = true
			else if ( level.chainExplosionIndex > CHAIN_EXPLOSION_MAXINDEX )
				newChainExplosion = true

			if ( newChainExplosion )
			{
				level.chainExplosionIndex = 1 //not zero - always want some wait time
				level.chainExplosionTime = curTime
			}

			waitTime = level.chainExplosionIndex * RandomFloat( CHAIN_EXPLOSION_INTERVALMIN, CHAIN_EXPLOSION_INTERVALMAX )
			level.chainExplosionIndex++
		}

		Assert( waitTime )
		wait waitTime
	}

	// Blow up if we've gotten this far
	SpectreExplode( spectre, results )
}

function SpectrePreExplodeTell( spectre )
{
	local pos = spectre.GetOrigin()
	local ang = spectre.GetAngles()

	// Spectre "Speaks"
	EmitSoundOnEntity( spectre, "diag_imc_spectre_gs_selfDestruct_01_1" )

	// Overload FX
	local spectreFx = []
	spectreFx.append( PlayFXOnEntity( FX_SPECTRE_GOING_CRITICAL_1, spectre, "CHESTFOCUS" ) )

	// Overload Sound
	local overloadSound
	if ( GAMETYPE == COOPERATIVE )
		overloadSound = SFX_SPECTRE_OVERLOAD_COOP
	else
		overloadSound = SFX_SPECTRE_OVERLOAD
	EmitSoundOnEntity( spectre, overloadSound )

	// Cleanup on thread end
	OnThreadEnd
	(
		function() : ( spectre, spectreFx  )
		{
			if ( IsValid( spectre ) )
			{
				if ( GAMETYPE == COOPERATIVE )
					StopSoundOnEntity( spectre, SFX_SPECTRE_OVERLOAD_COOP )
				else
					StopSoundOnEntity( spectre, SFX_SPECTRE_OVERLOAD )

			}
			foreach( fx in spectreFx )
			{
				if ( !IsValid( fx ) )
					continue
				fx.ClearParent()
				fx.Fire( "Stop" )
				fx.Fire( "DestroyImmediately" )
			}
		}
	)

	spectre.WaitSignal( "OnDeath" )
}

function SpectreExplode( spectre, results )
{
	local pos = spectre.GetOrigin()
	local tagID = spectre.LookupAttachment( "CHESTFOCUS" )
	local fxOrg = spectre.GetAttachmentOrigin( tagID )
	local expSFX = spectre.s.suicideBehavior.explosionSFX
	local expFX = spectre.s.suicideBehavior.explosionFX

	SpectreExplosionDamage( spectre, results )
	EmitSoundAtPosition( pos, expSFX )
	CreateShake( pos, 10, 105, 1.25, 768 )
	PlayFX( expFX, fxOrg, Vector( 0, 0, 0 ) )

	//----------------------------
	// spectre real AI
	//----------------------------

	local attacker = level.worldspawn
	local damageSource
	if ( results )
	{
		if ( results.activator )
			attacker = results.activator

		if ( results.damageSourceId == eDamageSourceId.suicideSpectreAoE )
			damageSource = eDamageSourceId.suicideSpectreAoE
	}

	if ( damageSource == null )
		damageSource = eDamageSourceId.suicideSpectre

	if ( IsNPC( spectre ) )
		spectre.Die( attacker, attacker, { force = Vector( 0.4, 0.2, 0.3 ), scriptType = DF_SPECTRE_GIB, damageSourceId = damageSource } )
	else
		spectre.Kill() // spectre is fake prop_dynamic
}

function SpectreExplosionDamage( spectre, results = null )
{
	local pos = spectre.GetOrigin()

	local TitanDmg 	 		= spectre.s.suicideBehavior.explodeTitanDmg
	local PilotDmg 	 		= spectre.s.suicideBehavior.explodePilotDmg
	local RadiusFalloffMax 	= spectre.s.suicideBehavior.explodeRadiusFalloffMax
	local RadiusFullDamage 	= spectre.s.suicideBehavior.explodeRadiusFullDamage

	local attacker = spectre
	if ( results && results.activator )
		attacker = results.activator

	spectre.SetTeam( TEAM_EXPLODING )
	local damageSourceId 	= eDamageSourceId.suicideSpectreAoE
	local selfDamage 		= true
	local team 				= TEAM_EXPLODING //so can damage everyone
	local scriptFlags 		= DF_EXPLOSION

	RadiusDamage( pos,					// origin
		TitanDmg,						// titan damage
		PilotDmg,						// pilot damage
		RadiusFalloffMax,				// radiusFalloffMax
		RadiusFullDamage,				// radiusFullDamage
		attacker, 						// owner
		damageSourceId,  				// damage source id
		true,							// alive only
		selfDamage,
		team,
		scriptFlags )
}

/************************************************************************************************\

##    ## ######## ##     ## ######## ########     ###    ##       #### ######## ########
###   ## ##       ##     ##    ##    ##     ##   ## ##   ##        ##       ##  ##
####  ## ##       ##     ##    ##    ##     ##  ##   ##  ##        ##      ##   ##
## ## ## ######   ##     ##    ##    ########  ##     ## ##        ##     ##    ######
##  #### ##       ##     ##    ##    ##   ##   ######### ##        ##    ##     ##
##   ### ##       ##     ##    ##    ##    ##  ##     ## ##        ##   ##      ##
##    ## ########  #######     ##    ##     ## ##     ## ######## #### ######## ########

\************************************************************************************************/
function SpectreNeutralize( spectre, results )
{
	//Early out if being called twice (neutralized by a bullet while trying to be neutralized by a hardpoint cap
	if ( "neutralizing" in spectre.s )
		return

	spectre.s.neutralizing <- true
	spectre.s.state = eSuicideState.SPECTRE_STATE_DEACTIVATING

	if ( IsNPC( spectre ) )
	{
		Assert( IsAlive( spectre ), "Trying to neutralize a spectre that is already dead at: " + spectre.GetOrigin() )
		spectre.EndSignal( "OnDeath" )
	}

	thread SpectreNeutralizeFx( spectre )

	//----------------------------------
	// Kill if normal NPC
	//----------------------------------
	if ( spectre.IsNPC() )
	{
		ClearDeathFuncName( spectre )
		SetDeathFuncName( spectre, "SpectreNeutralizeDeath" )

		local attacker = level.worldspawn
		local inflictor =  level.worldspawn

		if ( results && results.activator )
			attacker = results.activator
		if ( results && results.inflictor )
			inflictor =  results.inflictor

		spectre.Die( attacker, inflictor, { force = Vector( 0.4, 0.2, 0.3 ) } )
	}

	else
	{
		local anim = "sp_death_overload_prop_dynamic"	//need specific anim without ragdoll notetracks, otherwise prop would get deleted
		waitthread PlayAnim( spectre, anim )
	}
}

function SpectreNeutralizeFx( spectre )
{
	local pos = spectre.GetOrigin()
	EmitSoundAtPosition( pos, SFX_SPECTRE_NEUTRALIZED )
	PlayFXOnEntity( FX_SPECTRE_DEACTIVATING, spectre, "CHESTFOCUS" )

	wait 1.5

	EmitSoundAtPosition( pos, SFX_SPECTRE_NEUTRALIZED_SPARKS )
	PlayFX( FX_SPECTRE_DEACTIVATED_SPARKS, pos, Vector( 0, 0, 0 ) )
}

function SpectreNeutralizeDeath( spectre )
{
	local anim = Random( level.spectreAnims[ "SpectreNeutralized" ] )
	spectre.Anim_Play( anim )
	WaitSignalOnDeadEnt( spectre, "OnAnimationDone" )
	spectre.BecomeRagdoll( Vector( 0, 0, 0 ) )
}

/************************************************************************************************\

########     ###    ##     ##    ###     ######   ########
##     ##   ## ##   ###   ###   ## ##   ##    ##  ##
##     ##  ##   ##  #### ####  ##   ##  ##        ##
##     ## ##     ## ## ### ## ##     ## ##   #### ######
##     ## ######### ##     ## ######### ##    ##  ##
##     ## ##     ## ##     ## ##     ## ##    ##  ##
########  ##     ## ##     ## ##     ##  ######   ########

\************************************************************************************************/
function SpectreSuicideOnDamaged( spectre, damageInfo )
{
	if ( !IsSuicideSpectre( spectre ) )
		return

	if ( !IsAlive( spectre ) )
		return

	if ( spectre.s.state == eSuicideState.SPECTRE_STATE_DEACTIVATING )
		return
	if ( spectre.s.state == eSuicideState.SPECTRE_STATE_HANGING )
		return

	local damage 				= damageInfo.GetDamage()
	local attacker 				= damageInfo.GetAttacker()
	local damageSourceId 		= damageInfo.GetDamageSourceIdentifier()
	local inflictor 			= damageInfo.GetInflictor()
	local weapon 				= damageInfo.GetWeapon()

	damageInfo.SetDamage( 0 )//safer to set the real damage to 0... also fixes smart pistol bug where they didn't blow up

	local results = {}
	results.activator <- attacker
	results.inflictor <- inflictor
	results.damageSourceId <- damageSourceId

	// calculate build time credit
	if ( ShouldGiveTimerCredit( attacker, spectre ) && attacker.IsPlayer() )
	{
		local timerCredit = CalculateBuildTimeCredit( attacker, spectre, damage, spectre.s.fakeHealth, spectre.s.fakeMaxHealth, "spectre_kill_credit", 9 )
		if ( timerCredit )
			DecrementBuildCondition( attacker, timerCredit )
	}

	if ( damage )
		spectre.s.fakeHealth -= damage

	if ( spectre.s.fakeHealth > 0 )
		return

	switch( damageSourceId )
	{
		//electrical things neutralize
		case eDamageSourceId.mp_weapon_grenade_emp:
		case eDamageSourceId.mp_titanweapon_arc_cannon:
		case eDamageSourceId.mp_titanability_smoke:
		case eDamageSourceId.mp_ability_emp:
		case eDamageSourceId.mp_titanability_emp:
		case eDamageSourceId.super_electric_smoke_screen:
		case eDamageSourceId.titan_melee:
		case eDamageSourceId.human_melee:
		case eDamageSourceId.titan_fall:
		case eDamageSourceId.bubble_shield:
		case eDamageSourceId.switchback_trap:
		case eDamageSourceId.titanEmpField:
			thread SpectreNeutralize( spectre, results )
			return

		default:
			//continue on
			break
	}

	thread SpectreSelfDestructOnDamage( spectre, results )
}

/************************************************************************************************\
	TOOLS
\************************************************************************************************/
function IsTouchingGround( npc )
{
	local start = npc.GetOrigin()
	local end = start + Vector( 0, 0, -1000 )
	local traceDist = ( start - end ).Length()

	local result = TraceLineSimple( start, end, npc )
	local distFromGround = traceDist * result

	//printt( "distFromGround: ", distFromGround )

	if ( distFromGround > 5.5 )
		return false
	else
		return true
}

function FreeSpectreSlotOnDeath( spectre )
{
	spectre.EndSignal( "OnDestroy" )

	level.activeSuicideSpectres.append( spectre )

	OnThreadEnd
	(
		function () : ( spectre )
		{
			ArrayRemove( level.activeSuicideSpectres, spectre )
		}
	)

	spectre.WaitSignal( "OnDestroy" )
}

function main()
{
	RegisterSignal( "TitanHotDropComplete" )
	RegisterSignal( "OnLostTarget" )
	RegisterSignal( "DisableRocketPods" )
	RegisterSignal( "BubbleShieldStatusUpdate" )

	level.stationaryTitanPositions <- []
}

//script SpawnCoopTitan( Vector( 0,0,0 ), Vector( 0,0,0 ), TEAM_MILITIA, "titan_atlas", null, null, "mp_titanweapon_salvo_rockets" )
//script SpawnCoopTitan( Vector( 0,0,0 ), Vector( 0,0,0 ), TEAM_MILITIA, "titan_atlas", null, null, "mp_titanweapon_dumbfire_rockets" )
//script SpawnCoopTitan( Vector( 0,0,0 ), Vector( 0,0,0 ), TEAM_MILITIA, "titan_atlas", null, null, "mp_titanweapon_shoulder_rockets" )
//script SpawnCoopTitan( Vector( 0,0,0 ), Vector( 0,0,0 ), TEAM_MILITIA, "titan_atlas", null, null, "mp_titanweapon_homing_rockets" )
function SpawnCoopTitan( origin, angles, team, settings = null, weapon = null, weaponMod = null, shoulderWeapon = null )
{
	local table 	= CreateDefaultNPCTitanTemplate( team )
	table.origin 	= origin
	table.angles 	= angles

/*	if ( settings == null )
	{
		local rInt = RandomInt( Native_GetTitanCount() )
		settings = Native_GetTitanName( rInt )
	}*/

	if ( settings == null )
		settings = Random( [ "titan_atlas", "titan_ogre", "titan_stryder" ] )


	UseSettingsOnTitanTemplate( table, settings )

	if ( weapon )
	{
		table.weapon = weapon
		if ( weaponMod )
			table.weaponMod = weaponMod
	}
	else
	{
		local randomMod = RandomInt( 0, 100 ) <= 40 //40 % chance
		SetRandomWeaponOnTitanTemplate( table, randomMod )
	}

	local titan = SpawnNPCTitan( table )

	GiveTitanRandomTacticalAbility( titan )

	if ( shoulderWeapon )
		GiveTitanShoulderWeapon( titan, shoulderWeapon )
	else
		GiveTitanRandomShoulderWeapon( titan )

	return titan
}
Globalize( SpawnCoopTitan )

function SpawnAmpedCoopTitan( origin, angles, team, settings = null, weapon = null, weaponMod = null, shoulderWeapon = null )
{
	local table 	= CreateDefaultNPCTitanTemplate( team )
	table.origin 	= origin
	table.angles 	= angles

	/*(if ( settings == null )
	{
		local rInt = RandomInt( Native_GetTitanCount() )
		settings = Native_GetTitanName( rInt )
	}*/
	
	if ( settings == null )
		settings = Random( [ "titan_atlas", "titan_ogre", "titan_stryder"] )

	UseSettingsOnTitanTemplate( table, settings )

	if ( weapon )
	{
		table.weapon = weapon
		if ( weaponMod )
			table.weaponMod = weaponMod
	}
	else
	{
		local randomMod = true // RandomInt( 0, 100 ) <= 40 //40 % chance
		SetRandomWeaponOnTitanTemplate( table, randomMod, true )
	}

	local titan = SpawnNPCTitan( table )

	if ( shoulderWeapon )
		GiveTitanShoulderWeapon( titan, shoulderWeapon )
	else
		GiveTitanRandomShoulderWeapon( titan )

	return titan
}
Globalize( SpawnAmpedCoopTitan )


function UseSettingsOnTitanTemplate( table, settings )
{
	local model, title = null

	local titanName = settings
	if ( Native_GetTitanTypeByName( titanName ) != null )
	{
		table.model = GetPlayerSettingsFieldForClassName(titanName, "titanmodel")
		table.title = GetPlayerSettingsFieldForClassName(titanName, "nametext")
	}
/*
	switch( settings )
	{
		case "titan_atlas":
			table.model = ATLAS_MODEL
			table.title = "#CHASSIS_ATLAS_NAME"
			break

		case "titan_ogre":
			table.model = OGRE_MODEL
			table.title = "#CHASSIS_OGRE_NAME"
			break

		case "titan_stryder":
			table.model = STRYDER_MODEL
			table.title = "#CHASSIS_STRYDER_NAME"
			break
	}
*/
	table.settings  = settings
}
Globalize( UseSettingsOnTitanTemplate )


function SetRandomWeaponOnTitanTemplate( table, randomMod = false, useAmpedWeapons = false )
{	
	// useAmpedWeapons = false //disable burn_mode by iskyfish.2016.10.13

	local weapon, weaponMod = null

	local weapons = [
		"mp_titanweapon_rocket_launcher",
		"mp_titanweapon_40mm",
		"mp_titanweapon_xo16",
		"mp_titanweapon_triple_threat"
		]

	local mods
	if ( useAmpedWeapons )
	{
		mods = [
		[ "burn_mod_titan_rocket_launcher" ],
		[ "burn_mod_titan_40mm" ],
		[ "burn_mod_titan_xo16" ],
		[ "burn_mod_titan_triple_threat" ],
		]
	}
	else
	{
		mods = [
		[ "rapid_fire_missiles" ],
		[ "burst" ],
		[ "extended_ammo" ],
		[ "mine_field" ],
		]
	}

	local weapIndex = RandomInt( 0, weapons.len() )
	weapon = weapons[ weapIndex ]

	if ( randomMod )
		weaponMod = [ Random( mods[ weapIndex ] ) ]

	table.weapon	= weapon
	table.weaponMod = weaponMod
}
Globalize( SetRandomWeaponOnTitanTemplate )


function GiveTitanRandomTacticalAbility( titan )
{
	switch( RandomInt( 5 ) )
	{
		case 0:
			GiveTitanTacticalAbility( titan, TAC_ABILITY_WALL )
			break

		case 1:
		case 2:
			GiveTitanTacticalAbility( titan, TAC_ABILITY_SMOKE )
			break

		default:
			GiveTitanTacticalAbility( titan, TAC_ABILITY_VORTEX )
			break
	}
}
Globalize( GiveTitanRandomTacticalAbility )


function GiveTitanTacticalAbility( titan, tacAbility )
{
	local tac = titan.GetOffhandWeapon( tacAbility )

	switch ( tacAbility )
	{
		case TAC_ABILITY_WALL:
			if ( !IsValid( tac ) )
				titan.GiveOffhandWeapon( "mp_titanability_bubble_shield", TAC_ABILITY_WALL )
			titan.SetTacticalAbility( titan.GetOffhandWeapon( TAC_ABILITY_WALL ), TTA_WALL )
			break

		case TAC_ABILITY_SMOKE:
			if ( !IsValid( tac ) )
				titan.GiveOffhandWeapon( "mp_titanability_smoke", TAC_ABILITY_SMOKE )
			titan.SetTacticalAbility( titan.GetOffhandWeapon( TAC_ABILITY_SMOKE ), TTA_SMOKE )
			break

		case TAC_ABILITY_VORTEX:
			titan.SetTacticalAbility( titan.GetOffhandWeapon( TAC_ABILITY_VORTEX ), TTA_VORTEX )
			break
		default:
			Assert( 0, "tac ability index" + tacAbility + " not valid" )
			break
	}
}
Globalize( GiveTitanTacticalAbility )


function CoopTitanNPCDropsIn( titan )
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )

	Assert( !( "hotdropFinished" in titan.s ) )
	titan.s.hotdropFinished <- false
	titan.s.bubbleShieldStatus <- 0

	local anim = "at_hotdrop_drop_2knee_turbo"
	local impactTime = GetHotDropImpactTime( titan, anim )
	local origin = titan.GetOrigin()
	local angles = titan.GetAngles()

	TitanDisableRocketPods( titan )

	TryAnnounceTitanfallWarningToTeam( origin, level.nv.attackingTeam )

	thread CreateGenericBubbleShield_Delayed( impactTime, titan, origin, angles )
	waitthread SuperHotDropReplacementTitan( titan, origin, angles, null, anim )
	waitthread PlayAnimGravity( titan, "at_hotdrop_quickstand" )

	titan.s.hotdropFinished = true
	titan.Signal( "TitanHotDropComplete" )

	while( titan.s.bubbleShieldStatus == 1 )
		titan.WaitSignal( "BubbleShieldStatusUpdate" )

	if ( TitanHasRocketPods( titan ) )
		TitanEnableRocketPods( titan )
}
Globalize( CoopTitanNPCDropsIn )


function WaitTillHotDropComplete( titan )
{
	// waits for him to drop in from the sky AND stand up
	if ( !( "hotdropFinished" in titan.s ) || !titan.s.hotdropFinished )
		WaitSignal( titan, "TitanHotDropComplete" )
}
Globalize( WaitTillHotDropComplete )


function CreateGenericBubbleShield_Delayed( delay, titan, origin, angles )
{
	titan.EndSignal( "OnDestroy" )

	if ( delay > 0 )
		wait delay

	titan.s.bubbleShieldStatus = 1
	CreateGenericBubbleShield( titan, origin, angles )
	titan.s.bubbleShieldStatus = 0
	titan.Signal( "BubbleShieldStatusUpdate" )
}

function AddStationaryTitanPosition( origin )
{
	level.stationaryTitanPositions.append( { origin = origin, inUse = false } )
}
Globalize( AddStationaryTitanPosition )

function GetRandomStationaryTitanPosition( origin, maxDist )
{
	Assert( level.stationaryTitanPositions.len(), "No stationary titan positions exist. Add them using AddStationaryTitanPosition( origin )." )

	local resultArray = []
	local maxDistSqr = maxDist * maxDist

	local backupPosition = null
	local closestDist = null

	foreach( position in level.stationaryTitanPositions )
	{
		if ( position.inUse )
			continue

		local dist = DistanceSqr( origin, position.origin )
		if ( dist <= maxDistSqr )
		{
			resultArray.append( position )
		}
		else if ( backupPosition == null || dist < closestDist )
		{
			closestDist = dist
			backupPosition = position
		}
	}

	if ( resultArray.len() == 0 )
	{
		Assert( backupPosition != null, "Couldn't find a mortar position within " + maxDist + " units around" + origin.tostring() + " that wasn't in use. Add more AddStationaryTitanPosition to the map." )
		resultArray.append( backupPosition )
	}

	return Random( resultArray )
}
Globalize( GetRandomStationaryTitanPosition )

function ClaimStationaryTitanPosition( stationaryTitanPositions )
{
	Assert( stationaryTitanPositions.inUse == false )
	stationaryTitanPositions.inUse = true
}
Globalize( ClaimStationaryTitanPosition )

function ReleaseStationaryTitanPosition( stationaryTitanPositions )
{
	Assert( stationaryTitanPositions.inUse == true )
	stationaryTitanPositions.inUse = false
}
Globalize( ReleaseStationaryTitanPosition )


/************************************************************************************************\

########   #######   ######  ##    ## ######## ########       ########   #######  ########   ######
##     ## ##     ## ##    ## ##   ##  ##          ##          ##     ## ##     ## ##     ## ##    ##
##     ## ##     ## ##       ##  ##   ##          ##          ##     ## ##     ## ##     ## ##
########  ##     ## ##       #####    ######      ##          ########  ##     ## ##     ##  ######
##   ##   ##     ## ##       ##  ##   ##          ##          ##        ##     ## ##     ##       ##
##    ##  ##     ## ##    ## ##   ##  ##          ##          ##        ##     ## ##     ## ##    ##
##     ##  #######   ######  ##    ## ########    ##          ##         #######  ########   ######

\************************************************************************************************/
function GiveTitanRandomShoulderWeapon( titan )
{
	local weapons = [
		"mp_titanweapon_salvo_rockets",
		"mp_titanweapon_dumbfire_rockets",
		"mp_titanweapon_shoulder_rockets",
		"mp_titanweapon_homing_rockets",
		]

	GiveTitanShoulderWeapon( titan, Random( weapons ) )
}

function GiveTitanShoulderWeapon( titan, shoulderWeapon )
{
	titan.GiveOffhandWeapon( shoulderWeapon, 0 )
	thread CreateTitanRocketPods( titan.GetTitanSoul(), titan )
	thread TitanShoulderWeaponThink( titan )
}

function TitanDisableRocketPods( titan )
{
	if ( "lockedRocketPods" in titan.s && titan.s.lockedRocketPods )
		return

	titan.Signal( "DisableRocketPods" )
}
Globalize( TitanDisableRocketPods )


function TitanHasRocketPods( titan )
{
	return IsValid( titan.GetOffhandWeapon( 0 ) )
}
Globalize( TitanHasRocketPods )


function TitanEnableRocketPods( titan )
{
	if ( "lockedRocketPods" in titan.s && titan.s.lockedRocketPods )
		return

	Assert( IsValid( titan.GetOffhandWeapon( 0 ) ) )
	thread TitanShoulderWeaponThink( titan )
}
Globalize( TitanEnableRocketPods )

function TitanLockRocketPods( titan )
{
	if ( !( "lockedRocketPods" in titan.s ) )
		titan.s.lockedRocketPods <- false

	titan.s.lockedRocketPods = true
}
Globalize( TitanLockRocketPods )

function TitanUnlockRocketPods( titan )
{
	if ( !( "lockedRocketPods" in titan.s ) )
		titan.s.lockedRocketPods <- false

	titan.s.lockedRocketPods = false
}
Globalize( TitanUnlockRocketPods )

function TitanShoulderWeaponThink( titan )
{
	local weapon = titan.GetOffhandWeapon( 0 )

	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "Doomed" )
	titan.EndSignal( "DisableRocketPods" )
	weapon.EndSignal( "OnDestroy" )

	local fireFunc

	switch ( weapon.GetClassname() )
	{
		case "mp_titanweapon_salvo_rockets":
			fireFunc = RocketPodsFire_SalvoRockets
			break

		case "mp_titanweapon_dumbfire_rockets":
			fireFunc = RocketPodsFire_DumbfireRockets
			break

		case "mp_titanweapon_shoulder_rockets":
			fireFunc = RocketPodsFire_ShoulderRockets
			break

		case "mp_titanweapon_homing_rockets":
			fireFunc = RocketPodsFire_HomingRockets
			break

		default:
			Assert( 0 , "shoulder weapon " + shoulderWeapon + " not setup for NPC titan use.")
			break
	}

	local max_range 			= weapon.GetWeaponInfoFileKeyField( "npc_max_range" )
	local max_range_sqr 		= pow( max_range, 2 )

	while( 1 )
	{
		wait 0.5

		if ( !titan.GetEnemy() )
			titan.WaitSignal( "OnFoundEnemy" )

		local enemy = titan.GetEnemy()

		if ( !IsValid( enemy ) || !enemy.IsTitan() )
			continue

		if ( DistanceSqr( enemy.GetOrigin(), titan.GetOrigin() ) > max_range_sqr )
			continue

		if ( !titan.CanSee( enemy ) )
			continue

		if ( !IsFacingEnemy( titan, enemy ) )
			continue

		local results = {}
		results.numRocketsFired <- 0
		results.maxRockets 		<- 12
		results.targetLockon 	<- false
		results.cooldown 		<- 0

		local soul = enemy.GetTitanSoul()
		Assert( soul != null )

		waitthread fireFunc( titan, weapon, soul, results )

		if ( !results.numRocketsFired )
			continue

		wait results.cooldown
	}
}


/**************************************************************************\
	salvo rockets
\**************************************************************************/
function RocketPodsFire_SalvoRockets( titan, weapon, soul, results )
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "Doomed" )
	titan.EndSignal( "DisableRocketPods" )
	titan.EndSignal( "OnLostEnemy" )
	soul.EndSignal( "OnTitanDeath" )
  	soul.EndSignal( "OnDestroy" )

	local numRockets 			= weapon.GetWeaponModSetting( "burst_fire_count" )
	local fireRate 				= 0//weapon.GetWeaponModSetting( "fire_rate" ) * 0.01

	results.maxRockets 		= numRockets
	results.cooldown 		= weapon.GetWeaponModSetting( "burst_fire_delay" )
	results.numRocketsFired = numRockets

	local attackParams = GetFakedAttackParams( weapon, soul )

	for ( local i = 0; i < numRockets; i++ )
	{
		attackParams.burstIndex = i
		weapon.SetWeaponBurstFireCount( numRockets )
		weapon.GetScriptScope().OnWeaponPrimaryAttack( attackParams )
		wait fireRate
	}
}

/**************************************************************************\
	dumb fire rockets
\**************************************************************************/
function RocketPodsFire_DumbfireRockets( titan, weapon, soul, results )
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "Doomed" )
	titan.EndSignal( "DisableRocketPods" )
	titan.EndSignal( "OnLostEnemy" )
	soul.EndSignal( "OnTitanDeath" )
  	soul.EndSignal( "OnDestroy" )

	results.maxRockets 		= 1
	results.cooldown 		= 1.0 / weapon.GetWeaponModSetting( "fire_rate" )
	results.numRocketsFired = 1

	local attackParams = GetFakedAttackParams( weapon, soul )

	weapon.GetScriptScope().OnWeaponPrimaryAttack( attackParams )
}

/**************************************************************************\
	shoulder rockets -> multi target ( 12x misslies )
\**************************************************************************/
function RocketPodsFire_ShoulderRockets( titan, weapon, soul, results )
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "Doomed" )
	titan.EndSignal( "DisableRocketPods" )
	titan.EndSignal( "OnLostEnemy" )
	soul.EndSignal( "OnTitanDeath" )
  	soul.EndSignal( "OnDestroy" )

	local maxRockets 			= weapon.GetWeaponModSetting( "smart_ammo_target_max_locks_titan" )
	local minRockets 			= ( maxRockets / 3 ).tointeger()
	local numRockets 			= RandomInt( minRockets, maxRockets + 1 )
	local targeting_time_max 	= weapon.GetWeaponModSetting( "smart_ammo_targeting_time_max" )
	local targetTime 			= numRockets * targeting_time_max

	results.maxRockets 	= maxRockets

	waitthread LockOntoEnemy( titan, weapon, soul, targetTime, results )
	if ( !results.targetLockon )
		return

	local attackParams = GetFakedAttackParams( weapon, soul )

	weapon.SmartAmmo_Enable()
	weapon.SetWeaponBurstFireCount( numRockets )
	weapon.SmartAmmo_SetTarget( soul, numRockets )  // hack: fraction is the number of rockets; same as player weapon

	for ( local i = 0; i < numRockets; i++ )
	{
		attackParams.burstIndex = i
		weapon.GetScriptScope().OnWeaponPrimaryAttack( attackParams )
	}

	local cooldown_time 	= weapon.GetWeaponModSetting( "charge_cooldown_time" )
	local cooldown_delay 	= weapon.GetWeaponModSetting( "charge_cooldown_delay" )
	local rocketFrac 		= numRockets / maxRockets
	cooldown_time *= rocketFrac

	results.cooldown 		= cooldown_time
	results.numRocketsFired = numRockets

	weapon.SmartAmmo_Clear( true )
	if ( IsValid( soul.GetBossPlayer() ) )
		SmartAmmo_ClearCustomFractionSource( weapon, soul.GetBossPlayer() )
}

/**************************************************************************\
	homing rockets -> slaved warheads ( 4x 3-missiles )
\**************************************************************************/
function RocketPodsFire_HomingRockets( titan, weapon, soul, results )
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "Doomed" )
	titan.EndSignal( "DisableRocketPods" )
	titan.EndSignal( "OnLostEnemy" )
	soul.EndSignal( "OnTitanDeath" )
  	soul.EndSignal( "OnDestroy" )

	local fireRate 				= 1.0 / weapon.GetWeaponModSetting( "fire_rate" )
	local numRockets 			= 12
	local numBursts 			= weapon.GetWeaponModSetting( "smart_ammo_max_targeted_burst" )
	local rocketsPerBurst 		= ( numRockets / numBursts ).tointeger()
	local targetTime 			= weapon.GetWeaponModSetting( "smart_ammo_targeting_time_max" )

	results.maxRockets 	= numRockets
	results.cooldown 	= weapon.GetWeaponModSetting( "burst_fire_delay" )

	waitthread LockOntoEnemy( titan, weapon, soul, targetTime, results )
	if ( !results.targetLockon )
		return

	weapon.SmartAmmo_SetTarget( soul, rocketsPerBurst )
	results.numRocketsFired = numRockets

	for ( local i = 0; i < numBursts; i++ )
	{
		local attackParams = GetFakedAttackParams( weapon, soul )

		attackParams.burstIndex = i
		weapon.SmartAmmo_Enable()
		weapon.SetWeaponBurstFireCount( rocketsPerBurst )
		weapon.GetScriptScope().OnWeaponPrimaryAttack( attackParams )

		wait fireRate

		if ( !( soul.GetTitan().IsPlayer() ) && IsValid( soul.GetBossPlayer() ) )
			SmartAmmo_ClearCustomFractionSource( weapon, soul.GetBossPlayer() )
	}

	weapon.SmartAmmo_Clear( true )
	if ( IsValid( soul.GetBossPlayer() ) )
		SmartAmmo_ClearCustomFractionSource( weapon, soul.GetBossPlayer() )
}

/**************************************************************************\
	HACKED LOCK ON FOR NPCS
\**************************************************************************/
function LockOntoEnemy( titan, weapon, soul, targetTime, results )
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "Doomed" )
	titan.EndSignal( "DisableRocketPods" )
	titan.EndSignal( "OnLostEnemy" )
	soul.EndSignal( "OnTitanDeath" )
  	soul.EndSignal( "OnDestroy" )
	titan.EndSignal( "OnLostTarget" )

	local currTargetTime 	= 0.0
	local humanFakedDelay 	= 1.5
	local giveUpTime 		= 4.0
	local giveUpTargetTime 	= Time() + targetTime + giveUpTime + humanFakedDelay

	thread SetSignalDelayed( titan, "OnLostTarget", giveUpTargetTime )

	local customFractionSource = []
	OnThreadEnd(
		function() : ( titan, weapon, soul, giveUpTargetTime, customFractionSource )
		{
			if ( !IsValid( weapon ) )
				return

			if ( !customFractionSource.len() )
				return

			Assert( customFractionSource.len() == 1 )

			if ( !IsValid( customFractionSource[ 0 ] ) )
				return

			SmartAmmo_ClearCustomFractionSource( weapon, customFractionSource[ 0 ] )
		}
	)

	local interval 			= 0.2
	while( 1 )
	{
		local newLock = true
		local lockWasPlayer = false
		local lockIsPlayer = false

		while( titan.CanSee( soul.GetTitan() ) && IsFacingEnemy( titan, soul.GetTitan() ) )
		{
			if ( soul.GetTitan().IsPlayer() )
				lockIsPlayer = true

			if ( lockWasPlayer != lockIsPlayer )
				newLock = true

			if ( newLock )
			{
				if ( soul.GetTitan().IsPlayer() )
				{
					customFractionSource.append( soul.GetBossPlayer() )
					SmartAmmo_SetCustomFractionSource( weapon, customFractionSource[ 0 ], targetTime )
				}
				else if ( customFractionSource.len() )
				{
					SmartAmmo_ClearCustomFractionSource( weapon, customFractionSource[ 0 ] )
					Assert( customFractionSource.len() == 1 )
					customFractionSource.remove( 0 )
				}

				lockWasPlayer = true
				lockIsPlayer = true
				newLock = false
			}

			if ( currTargetTime >= targetTime + humanFakedDelay )
			{
				results.targetLockon = true
				return
			}

			wait interval
			currTargetTime += interval
		}

		while( !titan.CanSee( soul.GetTitan() ) || !IsFacingEnemy( titan, soul.GetTitan() ) )
		{
			if ( customFractionSource.len() )
			{
				SmartAmmo_ClearCustomFractionSource( weapon, customFractionSource[ 0 ] )
				Assert( customFractionSource.len() == 1 )
				customFractionSource.remove( 0 )
			}

			wait interval
			currTargetTime -= interval * 1.5
			if ( currTargetTime < 0 )
				currTargetTime = 0.0
		}
	}
}

function GetFakedAttackParams( weapon, enemySoul )
{
	local titan 	= weapon.GetWeaponOwner()
	local soul = titan.GetTitanSoul()
	Assert( IsValid( soul ) && IsValid( soul.rocketPod ) )

	local model		= soul.rocketPod.model
	local attachID 	= model.LookupAttachment( "muzzle_flash" )
	local origin 	= model.GetAttachmentOrigin( attachID )
	local vec 		= null

	local enemy 	= enemySoul.GetTitan()

	if ( enemy )
	{
		vec = enemy.EyePosition() - titan.EyePosition()
		vec.Normalize()
	}
	else
	{
		vec = titan.GetViewVector()
	}

	local attackParams = {}
	attackParams.burstIndex <- 0
	attackParams.pos <- origin
	attackParams.dir <- vec

	return attackParams
}

function SetSignalDelayed( ent, signal, delay )
{
	wait delay
	if ( IsValid( ent ) )
		Signal( ent, signal )
}

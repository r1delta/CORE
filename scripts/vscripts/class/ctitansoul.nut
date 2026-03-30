// all soul-specific vars should be created here
CTitanSoul.rocketPod <- null
CTitanSoul.lastOwner <- null
CTitanSoul.lastAttackInfo <- null
CTitanSoul.cabers <- null
CTitanSoul.bubbleShield <- null
CTitanSoul.rodeoPanel <- null
CTitanSoul.hijackProgress <- null
CTitanSoul.lastHijackTime <- null
CTitanSoul.rodeoHitBoxNumber <- null
CTitanSoul.shoulderTurret <- null
CTitanSoul.capturable <- null
CTitanSoul.followOnly <- null
CTitanSoul.passives <- null
CTitanSoul.createTime <- null
CTitanSoul.rodeoRiderTracker <- null
CTitanSoul.doomedTime <- null
CTitanSoul.chargeCannon <- null
// the functions below should not change

function CTitanSoul::constructor()
{
	::CBaseEntity.constructor()

	cabers = []
	lastAttackInfo = { time = 0 }
	rocketPod = { model = null, anims = null }
	shoulderTurret = { model = null, anims = null }
	chargeCannon = { model = null, anims = null }
	passives = 0
	createTime = Time()
	doomedTime = null
	rodeoRiderTracker = {} // all players that rode this titan, so they cant get multiple score events

	capturable = false
	followOnly = false
}

// function InitSoul()
function CTitanSoul::InitSoul( titan )
{
	local playerSettings = titan.GetPlayerSettingsNum()
	this.SetPlayerSettingsNum( playerSettings )

	this.hijackProgress = 0
	this.lastHijackTime = 0

	SetStanceStand( this ) // this seems bad, what if we spawn a crouched titan?
	this.SetSoulOwner( titan )
	this.s.recentDamageHistory <- []

	local titanShieldHealth = TITAN_SHIELD_HEALTH

	if ( GetCurrentPlaylistVarInt( "titan_shield_health", 0 ) != 0 )
	{
		titanShieldHealth = GetCurrentPlaylistVarInt( "titan_shield_health", 0 )
		if ( titanShieldHealth < 0 ) // less than 0 equals disabled
			titanShieldHealth = 0
	}

	this.SetShieldHealth( titanShieldHealth )
	this.SetShieldHealthMax( titanShieldHealth )

	this.lastAttackInfo = {
		attacker = titan,
		inflictor = titan,
		weapon = null,
		damageSourceId = getconsttable().eDamageSourceId.suicide,
		scriptType = 0
	}

	foreach ( name, func in level.soulInitFuncs )
	{
		func( this, titan )
	}

	if ( BURN_CARD_MAP_LOOT_DROP )
		AddBurnCardToEntity( this, "titan", titan.GetTeam() )

	local coreBuildTime = GetCurrentPlaylistVarInt( "titan_core_build_time", TITAN_CORE_BUILD_TIME )

	this.SetNextCoreChargeAvailable( Time() + coreBuildTime )
}


// function SoulDeath()
function CTitanSoul::SoulDestroy()
{
	// transfer the soul away from the last owner
	local titan = this.GetTitan()
	foreach ( name, func in level.soulTransferFuncs )
	{
		func( this, null, titan )
	}

	foreach ( name, func in level.soulDestroyFuncs )
	{
		func( this )
	}
}

function CTitanSoul::GetSoulOwner()
{
	return this.GetTitan()
}

// function SetSoulOwner()
function CTitanSoul::SetSoulOwner( titan )
{
	Assert( this.GetTitan() != titan, "Already set soul owner as " + titan )
	local oldTitan = this.GetTitan()

	Assert( IsAlive( titan ), titan + " is dead" )
	foreach ( name, func in level.soulTransferFuncs )
	{
		func( this, titan, oldTitan )
	}

	// must be done manually after setting soul owner
	// this is so an entity can share the soul during the part of the transition that has passage of time
//	if ( ::IsValid( oldTitan ) )
//	{
//		oldTitan.SetTitanSoul( null )
//	}

	local pastTitan = GetPlayerTitanFromSouls( titan )
	if ( IsAlive( pastTitan ) && pastTitan != oldTitan )
	{
		// the past titan blows up
		local extraDeathInfo = {}
		extraDeathInfo.scriptType <- DF_TITAN_GIB
		extraDeathInfo.damageSourceId <- getconsttable().eDamageSourceId.suicide

		pastTitan.Die( titan, titan, extraDeathInfo )
	}

	titan.SetTitanSoul( this )
	this.SetTitan( titan )

	this.Signal( "OnSoulTransfer" )

	if ( titan.IsNPC() )
	{
		thread SoulDeathDetection( this )
	}
	else
	{
		Assert( titan.IsPlayer(), "Is not a player" )
	}
}

CTitanSoul.__SetRiderEnt <- CTitanSoul.SetRiderEnt
function CTitanSoul::SetRiderEnt( ent )
{
	this.Signal( "RodeoRiderChanged" )
	this.__SetRiderEnt( ent )
}

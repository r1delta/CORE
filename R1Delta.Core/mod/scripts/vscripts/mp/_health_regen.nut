
const HEALTH_REGEN_START_DELAY = 3.8
const HEALTH_REGEN_RATE = 3.0

function main()
{
	Globalize( SetHealUseTime )
	Globalize( HealthRegenThink )
	Globalize( TrackLastFullHealthTime )
	Globalize( IsHealActive )

	AddDamageCallback( "player", HealthRegen_OnDamage )
}

function HealthRegenThink( player )
{
	player.EndSignal( "Disconnected" )
	local playerClass

	while( IsValid( player ) )
	{
		wait( HEALTH_REGEN_TICK_TIME )

		if ( !IsAlive( player ) )
			continue

		playerClass = player.GetPlayerClass()
		switch( playerClass )
		{
			case level.pilotClass:
				HealthRegen_Runner( player )
				break
		}
	}
}


function HealthRegen_OnDamage( player, damageInfo )
{
	if ( !IsHealActive( player ) )
		return

	player.s.lastHealResetTime = Time()

	// non-explosive damage interrupts stim
	if ( !(damageInfo.GetCustomDamageType() & DF_EXPLOSION) )
	{
		player.s.lastHealResetTime = Time()
		return
	}

	// direct damage (even explosive) interrupts stim
	if ( damageInfo.GetCustomDamageType() & DF_IMPACT )
	{
		player.s.lastHealResetTime = Time()
		return
	}

	damageInfo.SetDamage( damageInfo.GetDamage() * 0.75 )
}


function SetHealUseTime( player, duration )
{
	if ( duration == USE_TIME_INFINITE )
		player.s.lastHealUseEndTime = USE_TIME_INFINITE
	else
		player.s.lastHealUseEndTime = Time() + duration
}


function IsHealActive( player )
{
	if ( player.s.lastHealUseEndTime == USE_TIME_INFINITE )
		return true
	return Time() < player.s.lastHealUseEndTime
}

function HealthRegen_Runner( player )
{
	local healthRegenStartDelay = HEALTH_REGEN_START_DELAY	// seconds after we take damager to start regen
	local healthRegenRate = HEALTH_REGEN_RATE 	// health regen per tick

	if ( player.GetHealth() == player.GetMaxHealth() )
		return

	if ( IsHealActive( player ) )
	{
		if ( Time() - player.s.lastHealResetTime > ABILITY_STIM_REGEN_DELAY )
			healthRegenRate = HEALTH_REGEN_RATE * ABILITY_STIM_REGEN_MOD
	}
	else if ( Time() - player.s.lastDamageTime < healthRegenStartDelay )
	{
		return
	}

	player.SetHealth( min( player.GetMaxHealth(), player.GetHealth() + healthRegenRate ) )
}

function TrackLastFullHealthTime( player )
{
	// Tracks the last known full health time for a player. Works for both Pilots and Titans
	while( IsValid( player ) )
	{
		// Store time when health was last full
		if ( IsValid( player ) && IsAlive( player ) )
		{
			if ( player.GetHealth() == player.GetMaxHealth() && !player.GetDoomedState()  )
				player.s.lastFullHealthTime = Time()
		}
		wait 0.3
	}
}
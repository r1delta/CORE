
const RED_GLOW = "runway_light_red_2"
const BLUE_GLOW = "runway_light_blue_2"

function main()
{
	PrecacheParticleSystem( RED_GLOW )
	PrecacheParticleSystem( BLUE_GLOW )

	Globalize( ServerCallback_BBTurretRefresh )

	AddCreateCallback( "npc_turret_mega_bb", CreateCallback_BBTurret )

}

function CreateCallback_BBTurret( turret, isRecreate )
{
	turret.s.heavy <- true
	turret.s.turretFriendly <- null
	turret.s.particleEffects <- []
	UpdateParticleSystem( turret )
}

function ServerCallback_BBTurretRefresh( turretEHandle )
{
	local turret = GetEntityFromEncodedEHandle( turretEHandle )
	if ( !IsValid( turret ) )
		return

	UpdateParticleSystem( turret )
}

//////////////////////////////////////////////////////////////////////
function UpdateParticleSystem( turret )
{
	printt("[LJS] call UpdateParticleSystem")
	local turretFriendly = false
	local player = GetLocalViewPlayer()

	if ( turret.GetTeam() == TEAM_UNASSIGNED || !IsAlive( turret ) )
	{
		printt("[LJS] effect Stop")
		StopTurretParticleEffects( turret )
		return
	}

	if ( turret.GetTeam() == player.GetTeam() )
		turretFriendly = true

	if ( turretFriendly == turret.s.turretFriendly )
		return

	turret.s.turretFriendly = turretFriendly
	StopTurretParticleEffects( turret )

	printt("[LJS] Set Effect")
	local fxID
	if ( turretFriendly )
		fxID = GetParticleSystemIndex( BLUE_GLOW )
	else
		fxID = GetParticleSystemIndex( RED_GLOW )

	if ( turret.s.heavy )
	{
		local tag1ID = turret.LookupAttachment( "glow1" )
		local tag2ID = turret.LookupAttachment( "glow2" )

		if ( tag1ID )
			turret.s.particleEffects.append( PlayFXOnTag( turret, fxID, tag1ID ) )

		if ( tag2ID )
			turret.s.particleEffects.append( PlayFXOnTag( turret, fxID, tag2ID ) )
	}
	else
	{
		local tag1ID = turret.LookupAttachment( "camera_glow" )

		if ( tag1ID )
			turret.s.particleEffects.append( PlayFXOnTag( turret, fxID, tag1ID ) )
	}
}

function StopTurretParticleEffects( turret )
{
	foreach( particle in turret.s.particleEffects )
	{
		if ( EffectDoesExist( particle ) )
			EffectStop( particle, true, false )
	}
	turret.s.particleEffects.clear()

	turret.s.turretFriendly = null
}
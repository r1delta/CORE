
function main()
{
	Globalize( CreateBubbleShield )
	Globalize( IsTitanWithinBubbleShield )
	Globalize( LetTitanPlayerShootThroughBubbleShield )
	Globalize( CreateGenericBubbleShield )

	RegisterSignal( "ShotOutOfBubbleShield" )

	level.bubbleShieldEnabled <- true
}

const SHIELD_FADE_ARBITRARY_DELAY = 3.0
const SHIELD_FADE_ENDCAP_DELAY = 1.0

function CreateBubbleShield( titan, origin, angles )
{
	if ( !IsAlive( titan ) )
		return

	titan.Signal( "ClearDisableTitanfall" )

	local soul = titan.GetTitanSoul()
	local player = soul.GetBossPlayer()
	if ( !IsValid( player ) )
		return

	if ( !level.bubbleShieldEnabled )
		return

	player.EndSignal( "Disconnected" )

	local bubbleShield = CreateEntity( "prop_dynamic" )
	bubbleShield.kv.model = "models/fx/xo_shield.mdl"
	bubbleShield.kv.solid = 6 //Solid flag: use VPhysics
    bubbleShield.kv.rendercolor = "81 130 151"
	bubbleShield.SetOrigin( origin )
	bubbleShield.SetAngles( angles )
	bubbleShield.SetBossPlayer( player ) // so code knows AI should try to shoot at titan inside shield
     //CollisionGroup 21 is listed as "COLLISION_GROUP_BLOCK_WEAPONS ". Blocks bullets, projectiles but not players and not AI
	bubbleShield.kv.CollisionGroup = 21
	DispatchSpawn( bubbleShield )

	soul.bubbleShield = bubbleShield

	bubbleShield.Hide()
	local particleSystem = CreateEntity( "info_particle_system" )
	particleSystem.kv.start_active = 1
	particleSystem.kv.VisibilityFlags = 7
	particleSystem.kv.effect_name = "P_shield_hld_01"
	particleSystem.SetName( UniqueString() )
	particleSystem.SetOrigin( bubbleShield.GetOrigin() + Vector( 0, 0, 25 ) )
	DispatchSpawn( particleSystem, false )

    DisableTitanfallForLifetimeOfEntityNearOrigin( bubbleShield, origin, TITANHOTDROP_DISABLE_ENEMY_TITANFALL_RADIUS )

	EmitSoundOnEntity( bubbleShield, "BubbleShield_Sustain_Loop" )

	OnThreadEnd(
		function () : ( bubbleShield, particleSystem, soul, player )
		{
			if ( IsValid( player ) )
				player.SetTitanBubbleShieldTime( 0 ) //This sets the time to display "Titan Shielded" on the HUD

			if ( IsValid_ThisFrame( bubbleShield ) )
			{
				StopSoundOnEntity( bubbleShield, "BubbleShield_Sustain_Loop" )
				EmitSoundOnEntity( bubbleShield, "BubbleShield_End" )
				bubbleShield.Kill()
			}

			if ( IsValid_ThisFrame( particleSystem ) )
			{
				particleSystem.Fire( "StopPlayEndCap" )
				particleSystem.Kill( 1.0 )
			}
			if ( IsValid( soul ) )
				soul.bubbleShield = null
		}
	)

	if ( !IsAlive( titan ) ) // defensive?
		return

	local bubTime = GetBubbleShieldDuration( player ) + SHIELD_FADE_ARBITRARY_DELAY + SHIELD_FADE_ENDCAP_DELAY
	player.SetTitanBubbleShieldTime( Time() + bubTime  ) //This sets the time to display "Titan Shielded" on the HUD

	titan.SetNPCPriorityOverride( 1 )

	local e = {}
	EndSignal( e, "OnDeath" )

	local playerTeam = player.GetTeam()

	thread BubbleShieldDamageEnemies( bubbleShield, player )
	waitthread WaitUntilShieldFades( player, titan, bubbleShield, bubTime + 4 )
}


function CreateGenericBubbleShield( titan, origin, angles, duration = 9999 )
{
	if ( !IsAlive( titan ) )
		return

	local soul = titan.GetTitanSoul()

	local bubbleShield = CreateEntity( "prop_dynamic" )
	bubbleShield.kv.model = "models/fx/xo_shield.mdl"
	bubbleShield.kv.solid = 6 //Solid flag: use VPhysics
    bubbleShield.kv.rendercolor = "81 130 151"
	bubbleShield.SetOrigin( origin )
	bubbleShield.SetAngles( angles )
     //CollisionGroup 21 is listed as "COLLISION_GROUP_BLOCK_WEAPONS ". Blocks bullets, projectiles but not players and not AI
	bubbleShield.kv.CollisionGroup = 21
	DispatchSpawn( bubbleShield )

	soul.bubbleShield = bubbleShield

	bubbleShield.Hide()
	local particleSystem = CreateEntity( "info_particle_system" )
	particleSystem.kv.start_active = 1
	particleSystem.kv.VisibilityFlags = 7
	particleSystem.kv.effect_name = "P_shield_hld_01"
	particleSystem.SetName( UniqueString() )
	particleSystem.SetOrigin( bubbleShield.GetOrigin() + Vector( 0, 0, 25 ) )
	DispatchSpawn( particleSystem, false )

	local nodeTable = {}
	GetTitanfallNodesInRadius( nodeTable, origin, 192 )
	thread DisableTitanfallForNodes( nodeTable, bubbleShield, origin, 192 )

	EmitSoundOnEntity( bubbleShield, "BubbleShield_Sustain_Loop" )

	OnThreadEnd(
		function () : ( bubbleShield, particleSystem, soul )
		{
			if ( IsValid_ThisFrame( bubbleShield ) )
			{
				StopSoundOnEntity( bubbleShield, "BubbleShield_Sustain_Loop" )
				EmitSoundOnEntity( bubbleShield, "BubbleShield_End" )
				bubbleShield.Kill()
			}

			if ( IsValid_ThisFrame( particleSystem ) )
			{
				particleSystem.Fire( "StopPlayEndCap" )
				particleSystem.Kill( 1.0 )
			}
			if ( IsValid( soul ) )
				soul.bubbleShield = null
		}
	)

	if ( !IsAlive( titan ) ) // defensive?
		return

	titan.SetNPCPriorityOverride( 10 )

	local e = {}
	EndSignal( e, "OnDeath" )

	bubbleShield.SetTeam( titan.GetTeam() )

	thread BubbleShieldDamageEnemies( bubbleShield, null )
	waitthread WaitUntilGenericShieldFades( titan, bubbleShield, duration )
}


function WaitUntilGenericShieldFades( titan, bubbleShield, failTime )
{
	bubbleShield.EndSignal( "OnDestroy" )
	local soul = titan.GetTitanSoul()
	soul.EndSignal( "OnDestroy" )

	waitthread WaitUntilTitanStandsOrDies( titan, bubbleShield, failTime )

	if ( IsAlive( titan ) )
		titan.ClearNPCPriorityOverride()

	wait SHIELD_FADE_ARBITRARY_DELAY
}


function WaitUntilShieldFades( player, titan, bubbleShield, failTime )
{
	player.EndSignal( "ShotOutOfBubbleShield" )
	bubbleShield.EndSignal( "OnDestroy" )
	local soul = titan.GetTitanSoul()
	soul.EndSignal( "OnDestroy" )

	waitthread WaitUntilTitanStandsOrDies( titan, bubbleShield, failTime )

	if ( IsAlive( titan ) )
		titan.ClearNPCPriorityOverride()

	if ( !IsAlive( player ) )
		return

	if ( "embarkingTitan" in player.s && player.Anim_IsActive() )
		player.WaittillAnimDone()

	wait SHIELD_FADE_ARBITRARY_DELAY
}

function WaitUntilTitanStandsOrDies( titan, bubbleShield, failTime )
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "ChangedTitanMode" )
	local endTime = Time() + failTime

	for ( ;; )
	{
		if ( titan.GetTitanSoul().GetStance() == STANCE_STAND )
		{
			return
		}

		if ( Time() > endTime )
			break
		wait 0.2
	}
}

function BubbleShieldDamageEnemies( bubbleShield, bubbleShieldPlayer )
{
	bubbleShield.EndSignal( "OnDestroy" )
	if ( IsValid( bubbleShieldPlayer ) )
		bubbleShieldPlayer.EndSignal( "Disconnected" )

	local refreshLowerBound = 0.5
	local refreshUpperBound = 0.8

	local soulTable = {}
	local npcTable = {}
	local pilotTable = {}


	while ( true )
	{
		DamageTitansWithinBubbleShield( bubbleShield, bubbleShieldPlayer, soulTable )

		DamagePilotsWithinBubbleShield( bubbleShield, bubbleShieldPlayer, pilotTable )

		if ( GAMETYPE == COOPERATIVE && IsValid( bubbleShieldPlayer ) )
			DamageMinionsWithinBubbleShield( bubbleShield, bubbleShieldPlayer, npcTable )

		wait RandomFloat( refreshLowerBound, refreshUpperBound )
	}

}

function LetTitanPlayerShootThroughBubbleShield( titanPlayer )
{
	Assert( titanPlayer.IsTitan() )

	local soul = titanPlayer.GetTitanSoul()

	local bubbleShield = soul.bubbleShield

	if ( !IsValid( bubbleShield ) )
		return

	bubbleShield.SetOwner( titanPlayer ) //After this, player is able to fire out from shield. WATCH OUT FOR POTENTIAL COLLISION BUGS!

	thread MonitorLastFireTime( titanPlayer )
	thread StopPlayerShootThroughBubbleShield( titanPlayer, bubbleShield )

}

function StopPlayerShootThroughBubbleShield( player, bubbleShield )
{
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )
	player.WaitSignal( "OnChangedPlayerClass" ) //Kill this thread once player gets out of the Titan

	if ( !IsValid( bubbleShield ) )
		return

	bubbleShield.SetOwner( null )
}

function MonitorLastFireTime( player )
{
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnChangedPlayerClass" ) //Kill this thread once player gets out of the Titan


	player.WaitSignal( "OnPrimaryAttack" ) //Sent when player fires his weapon
	//printt( "Player fired weapon! in MonitorLastFireTime" )

	player.Signal( "ShotOutOfBubbleShield" ) //WaitUntilShieldFades will end when this signal is sent
}

function DamageTitansWithinBubbleShield( bubbleShield, bubbleShieldPlayer, soulTable )
{
	local titans = GetAllTitans()
	local ownerTeam = IsValid( bubbleShieldPlayer ) ?  bubbleShieldPlayer.GetTeam() : bubbleShield.GetTeam()

	foreach ( titan in titans )
	{
		local soul = titan.GetTitanSoul()
		if ( !( soul in soulTable ) )
			soulTable[ soul ] <- 0

		if ( BubbleShieldShouldDamage( bubbleShield, ownerTeam, titan ) )
			BubbleShieldDamageTitan( bubbleShield, bubbleShieldPlayer, titan, soulTable )
	}
}

function DamagePilotsWithinBubbleShield( bubbleShield, bubbleShieldPlayer, pilotTable )
{
	local ownerTeam = IsValid( bubbleShieldPlayer ) ?  bubbleShieldPlayer.GetTeam() : bubbleShield.GetTeam()
	local enemyTeam = GetTeamIndex(GetOtherTeams(1 << ownerTeam))
	local enemyPilots = GetAllPilots( enemyTeam )

	foreach ( pilot in enemyPilots )
	{
		if ( !( pilot in pilotTable ) )
			pilotTable[ pilot ] <- 0

		if ( BubbleShieldShouldDamage( bubbleShield, ownerTeam, pilot ) )
			BubbleShieldDamagePilot( bubbleShield, bubbleShieldPlayer, pilot, pilotTable )
	}
}

function DamageMinionsWithinBubbleShield( bubbleShield, bubbleShieldPlayer, npcTable )
{
	local ownerTeam = IsValid( bubbleShieldPlayer ) ?  bubbleShieldPlayer.GetTeam() : bubbleShield.GetTeam()
	local enemyTeam = GetTeamIndex(GetOtherTeams(1 << ownerTeam))
	local enemyMinions = GetNPCArrayEx( "any", enemyTeam, Vector(0,0,0), -1 )

	foreach ( npc in enemyMinions )
	{
		local isMinion = npc.IsSpectre() || npc.IsSoldier()
		if ( !isMinion )
			continue

		if ( !( npc in npcTable ) )
			npcTable[ npc ] <- 0

		if ( BubbleShieldShouldDamage( bubbleShield, ownerTeam, npc ) )
			BubbleShieldDamageMinion( bubbleShield, bubbleShieldPlayer, npc, npcTable )
	}
}




function BubbleShieldShouldDamage( bubbleShield, ownerTeam, ent )
{
	if ( !IsAlive( ent ) )
		return false

	if ( ownerTeam == ent.GetTeam() )
		return false

	if ( ent.IsTitan() && IsTitanWithinBubbleShield( ent ) )
		return false

	local distanceSqr = ( ent.GetOrigin() - bubbleShield.GetOrigin() ).LengthSqr()

	return  distanceSqr <= TITAN_BUBBLE_SHIELD_DAMAGE_RANGE * TITAN_BUBBLE_SHIELD_DAMAGE_RANGE

}


function BubbleShieldDamageTitan( bubbleShield, bubbleShieldPlayer, titan, soulTable )
{
	local soul = titan.GetTitanSoul()
	soulTable[ soul ]++
	local damageAmount = 250 + EvaluatePolynomial( soulTable[ soul ], 12, 5, 2 ) //Damage grows quadratically. Can tweak numbers to change damage done, with the first number (currently 12 ) having the largest effect, followed by the next number, followed by the next, etc

	//printt( "Bubble shield hits titan for: " + damageAmount )

	titan.TakeDamage( damageAmount, bubbleShieldPlayer, bubbleShield, { origin = bubbleShield.GetOrigin(), damageSourceId=eDamageSourceId.bubble_shield } )

	if ( titan.IsPlayer()  )
	{
		EmitSoundOnEntity( bubbleShield, "titan_energyshield_damage" )
		BubbleShieldDamageFX( titan )
	}

}

function BubbleShieldDamagePilot( bubbleShield, bubbleShieldPlayer, pilot, pilotTable )
{
	pilotTable[ pilot ]++
	local damageAmount = 30 + EvaluatePolynomial( pilotTable[ pilot ], 2, 1, 1 ) //Damage grows quadratically. Can tweak numbers to change damage done, with the first number (currently 2 ) having the largest effect, followed by the next number, followed by the next, etc

	damageAmount = min( 60, damageAmount ) //Cap the damage amount. This is actually primarily for the case where you die due to bubble shield, respawn as a pilot, and walk into the same bubble shield. You start taking increased damage immediately from that case. This is a good enough solution for that

	//printt( "Bubble shield hits pilot for: " + damageAmount )

	pilot.TakeDamage( damageAmount, bubbleShieldPlayer, bubbleShield, { origin = bubbleShield.GetOrigin(), damageSourceId=eDamageSourceId.bubble_shield } )

	EmitSoundOnEntity( bubbleShield, "titan_energyshield_damage" )
	BubbleShieldDamageFX( pilot )

}

function BubbleShieldDamageMinion( bubbleShield, bubbleShieldPlayer, npc, npcTable )
{
	npcTable[ npc ]++
	local damageAmount = 30 + EvaluatePolynomial( npcTable[ npc ], 2, 1, 1 ) //Damage grows quadratically. Can tweak numbers to change damage done, with the first number (currently 2 ) having the largest effect, followed by the next number, followed by the next, etc

	damageAmount = min( 60, damageAmount ) //Cap the damage amount. This is actually primarily for the case where you die due to bubble shield, respawn as a npc, and walk into the same bubble shield. You start taking increased damage immediately from that case. This is a good enough solution for that

	//printt( "Bubble shield hits npc for: " + damageAmount )

	npc.TakeDamage( damageAmount, bubbleShieldPlayer, bubbleShield, { origin = bubbleShield.GetOrigin(), damageSourceId=eDamageSourceId.bubble_shield } )

	EmitSoundOnEntity( bubbleShield, "titan_energyshield_damage" )
}

function BubbleShieldDamageFX( player )
{
	local colorCorrection = GetColorCorrectionByFileName( player, ELECTRIC_SMOKESCREEN_DAMAGE_COLORCORRECTION )

	if ( !colorCorrection )
		return null

	local fadeInDuration = 0.2
	local fadeOutDuration = 0.2
	local colorTime = 0.4
	local isMaster = 1

	colorCorrection.kv.fadeInDuration = fadeInDuration
	colorCorrection.kv.fadeOutDuration = fadeOutDuration
	colorCorrection.kv.spawnflags = isMaster

	colorCorrection.Fire( "Enable" )
	colorCorrection.Fire( "Disable", "", colorTime + fadeInDuration )
}

function IsTitanWithinBubbleShield( titan )
{
	if ( !IsAlive( titan ) )
		return false

	local soul = titan.GetTitanSoul()


	if ( !IsValid( soul.bubbleShield ) )
		return false

	return DistanceSqr( soul.bubbleShield.GetOrigin(), titan.GetOrigin() ) < TITAN_BUBBLE_SHIELD_INVULNERABILITY_RANGE * TITAN_BUBBLE_SHIELD_INVULNERABILITY_RANGE
}

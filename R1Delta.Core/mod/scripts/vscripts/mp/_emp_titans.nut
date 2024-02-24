// Player Effects -> copied and modified from arc_cannon.nut
const ARC_TITAN_TITAN_SCREEN_SFX 		= "Titan_Offhand_ElectricSmoke_Titan_Damage_1P"
const ARC_TITAN_PILOT_SCREEN_SFX 		= "Titan_Offhand_ElectricSmoke_Human_Damage_1P"

const ARC_TITAN_EMP_DURATION			= 0.35
const ARC_TITAN_EMP_FADEOUT_DURATION	= 0.35
const ARC_TITAN_SCREEN_EFFECTS 			= 0.085
const DAMAGE_AGAINST_TITANS 			= 300
const DAMAGE_AGAINST_PILOTS 			= 40
const ARC_TITAN_SLOW_SCALE 				= 0.6

const EMP_DAMAGE_TICK_RATE = 0.3

function main()
{
	AddDamageCallbackSourceID( eDamageSourceId.titanEmpField, EmpField_DamagedEntity )
}

//script SpawnEMPTitan( Vector(0,0,0), Vector(0,0,0), TEAM_IMC )
function SpawnEMPTitan( origin, angles, team )
{
	local table 	= CreateDefaultNPCTitanTemplate( team )
	table.title 	= "#NPC_TITAN_EMP"
	table.origin 	= origin
	table.angles 	= angles
	table.model 	= STRYDER_MODEL
	table.settings  = "titan_stryder_tier0"

	table.weapon	= "mp_titanweapon_arc_cannon"
	//disable burn_mode by iskyfish.2016.10.17
	//table.weaponMod = [ "burn_mod_titan_arc_cannon" ]

	local titan = SpawnNPCTitan( table )
	titan.Minimap_SetEnemyMaterial( "vgui/hud/coop/minimap_coop_emp_titan" )
	titan.Minimap_SetAlignUpright( true )
	titan.Minimap_SetZOrder( 10 )

	//titan.PreferSprint( true )
	//titan.NoForceWalk( true )
	titan.kv.faceEnemyWhileMovingDistSq = 1024 * 1024
	titan.SetMoveSpeedScale( 0.9 )

	titan.s.electrocutedPlayers <- []
	//Assuming players are always 0-COOP_MAX_PLAYER_COUNT in player array.
	for ( local i = 0; i < COOP_MAX_PLAYER_COUNT; i++ )
		titan.s.electrocutedPlayers.append( false )

	titan.SetSubclass( eSubClass.empTitan )

	GiveTitanTacticalAbility( titan, TAC_ABILITY_SMOKE )

	thread EMPTitanThinkConstant( titan )
	return titan
}
Globalize( SpawnEMPTitan )

function EMPTitanThinkConstant( titan )
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "Doomed" )

	thread EMPTitanFX( titan )

	local attachID = titan.LookupAttachment( "hijack" )

	local empFieldDamage = CreateEntity( "env_explosion" )
	empFieldDamage.kv.spawnflags 			= (SF_ENVEXPLOSION_NOSOUND|SF_ENVEXPLOSION_NO_DAMAGEOWNER|SF_ENVEXPLOSION_NODECAL|SF_ENVEXPLOSION_REPEATABLE|SF_ENVEXPLOSION_NOFIREBALL|SF_ENVEXPLOSION_NOSMOKE|SF_ENVEXPLOSION_NOSPARKS|SF_ENVEXPLOSION_NOPARTICLES|SF_ENVEXPLOSION_NOFIREBALLSMOKE|SF_ENVEXPLOSION_NODLIGHTS|SF_ENVEXPLOSION_MASK_BRUSHONLY)
	empFieldDamage.kv.damageSourceId 		= eDamageSourceId.titanEmpField
	empFieldDamage.kv.iMagnitude 			= DAMAGE_AGAINST_PILOTS
	empFieldDamage.kv.iMagnitudeHeavyArmor 	= DAMAGE_AGAINST_TITANS
	empFieldDamage.kv.iInnerRadius 			= ARC_TITAN_EMP_FIELD_INNER_RADIUS
	empFieldDamage.kv.iRadiusOverride 		= ARC_TITAN_EMP_FIELD_RADIUS
	empFieldDamage.kv.scriptDamageType 		= DF_ELECTRICAL | DF_STOPS_TITAN_REGEN

	empFieldDamage.SetOwner( titan )
	empFieldDamage.SetTeam( titan.GetTeam() )

	DispatchSpawn( empFieldDamage, false )

	OnThreadEnd(
		function () : ( empFieldDamage )
		{
			if ( IsValid_ThisFrame( empFieldDamage ) )
				empFieldDamage.Destroy()
		}
	)

	wait RandomFloat( 0, EMP_DAMAGE_TICK_RATE )

	while ( 1 )
	{
		local origin = titan.GetAttachmentOrigin( attachID )
		empFieldDamage.SetOrigin( origin )
		empFieldDamage.Fire( "Explode" )

		wait EMP_DAMAGE_TICK_RATE
	}
}

function EMPTitanFX( titan )
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "Doomed" )

	EmitSoundOnEntity( titan, "EMP_Titan_Electrical_Field" )

	//emp field fx
	local particleSystem = CreateEntity( "info_particle_system" )
	particleSystem.kv.start_active = 1
	particleSystem.kv.VisibilityFlags = 7
	particleSystem.kv.effect_name = FX_EMP_FIELD

	local attachID = titan.LookupAttachment( "hijack" )
	local origin = titan.GetAttachmentOrigin( attachID )
	particleSystem.SetOrigin( origin )
	DispatchSpawn( particleSystem, false )
	particleSystem.SetParent( titan, "hijack" )

	OnThreadEnd(
		function () : ( titan, particleSystem )
		{
			if ( IsValid( titan ) )
				StopSoundOnEntity( titan, "EMP_Titan_Electrical_Field" )

			if ( IsValid_ThisFrame( particleSystem ) )
			{
				particleSystem.ClearParent()
				particleSystem.Fire( "StopPlayEndCap" )
				particleSystem.Kill( 1.0 )
			}
		}
	)

	//thread DebugDrawSphereOnTag( titan, "hijack", ARC_TITAN_EMP_FIELD_RADIUS, 255, 200, 0, 900 )
	WaitForever()
}

function EmpField_DamagedEntity( target, damageInfo )
{
	if ( !IsAlive( target ) )
		return

	local titan = damageInfo.GetAttacker()

	if ( !IsValid( titan ) )
		 return

	local className = target.GetClassname()
	if ( className == "rpg_missile" || className == "npc_turret_sentry" )
	{
		damageInfo.SetDamage( 0 )
		return
	}

	if ( damageInfo.GetDamage() <= 0 )
		return

	if ( damageInfo.GetCustomDamageType() & DF_DOOMED_HEALTH_LOSS )
		return

	if ( target.IsPlayer() )
	{
		local targetIndex = target.GetEntIndex()
		titan.s.electrocutedPlayers[ targetIndex - 1 ] = true

		local attachID 	= titan.LookupAttachment( "hijack" )
		local origin 	= titan.GetAttachmentOrigin( attachID )
		local distSqr 	= DistanceSqr( origin, target.GetOrigin() )

		local minDist 	= ARC_TITAN_EMP_FIELD_INNER_RADIUS_SQR
		local maxDist 	= ARC_TITAN_EMP_FIELD_RADIUS_SQR
		local empFxHigh = ARC_TITAN_SCREEN_EFFECTS
		local empFxLow 	= ( ARC_TITAN_SCREEN_EFFECTS * 0.6 )
		local screenEffectAmplitude = GraphCapped( distSqr, minDist, maxDist, empFxHigh, empFxLow )

		if ( target.IsTitan() )
		{
			Remote.CallFunction_Replay( target, "ServerCallback_TitanEMP", screenEffectAmplitude, ARC_TITAN_EMP_DURATION, ARC_TITAN_EMP_FADEOUT_DURATION, false, false )
			EmitSoundOnEntityOnlyToPlayer( target, target, ARC_TITAN_TITAN_SCREEN_SFX )
			//thread EMP_SlowPlayer( target, ARC_TITAN_SLOW_SCALE, ARC_TITAN_EMP_DURATION )
		}
		else
		{
			Remote.CallFunction_Replay( target, "ServerCallback_PilotEMP", screenEffectAmplitude, ARC_TITAN_EMP_DURATION, ARC_TITAN_EMP_FADEOUT_DURATION, false, false )
			EmitSoundOnEntityOnlyToPlayer( target, target, ARC_TITAN_PILOT_SCREEN_SFX )
		}
	}
/*	optimized away
	// Do 3rd person effect on the body
	local effect = null
	local tag = null

	if ( target.IsTitan() )
	{
		effect = "impact_arc_cannon_titan"
		tag = "exp_torso_front"
	}
	else
	{
		effect = "P_emp_body_human"
		tag = "CHESTFOCUS"
	}

	if ( effect != null && tag != null )
	{
		if ( target.LookupAttachment( tag ) != 0 )
			ClientStylePlayFXOnEntity( effect, target, tag, ARC_TITAN_EMP_DURATION )
	}
*/
}
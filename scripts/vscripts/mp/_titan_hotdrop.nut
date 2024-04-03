const HOTDROP_FP_WARP = "P_warpjump_FP"
const PREVIEW_DEBUG = 1
const HOTDROP_TRAIL_FX = "hotdrop_hld_warp"

function main()
{
	Globalize( TitanHotDrop )
	Globalize( SuperHotDrop )
	Globalize( ScriptedHotDrop )
	Globalize( SuperHotDropGenericTitan )
	Globalize( SuperHotDropReplacementTitan )
	Globalize( OnReplacementTitanImpact )
	Globalize( OnHotdropImpact )
	Globalize( TitanHulldropSpawnpoint )
	Globalize( TitanTestDropPoint )

	Globalize( CreateTitanEscort )
	Globalize( RunTitanEscort )
	Globalize( TitanFindDropNodes )

	Globalize( GetHotDropImpactTime )

	RegisterSignal( "titan_impact" )

	PrecacheEffect( HOTDROP_TRAIL_FX )
	PrecacheEffect( HOTDROP_FP_WARP )

	AddDamageCallbackSourceID( eDamageSourceId.titan_fall, TitanFall_DamagedPlayerOrNPC )

	PrecacheImpactEffectTable( HOTDROP_IMPACT_FX_TABLE )

	PrecacheModel( "models/fx/xo_shield.mdl" )
	PrecacheModel( "models/fx/xo_shield_wall.mdl" )
	PrecacheParticleSystem( "P_shield_hld_01" )

	IncludeFile( "mp/_bubble_shield" )
}

function TitanHotDrop( titan, animation, origin, angles, player, delayedCreation = false )
{
	Assert( titan.IsTitan(), titan + " is not a titan" )

	titan.EndSignal( "OnDeath" )

	HideName( titan )

	local cleanup = [] // ents that will be deleted upon completion

	OnThreadEnd(
		function() : ( cleanup, titan )
		{
			if ( IsValid( titan ) )
			{
				delete titan.s.hotDropPlayer
			}

			foreach ( ent in cleanup )
			{
				if ( IsValid_ThisFrame( ent ) )
				{
					// Delay enough seconds to allow titan hot drop smokeTrail FX to play fully
					ent.Kill()
				}
			}
		}
	)

	titan.s.hotDropPlayer <- player

	origin += Vector(0,0,8 ) // work around for currently busted animation

	local ref = CreateScriptRef()
	ref.SetOrigin( origin )
	ref.SetAngles( angles )
	ref.Show()
	cleanup.append( ref )

	// wait for intro delay
	if ( titan.HasKey( "introstyle_delay" ) )
	{
		local weapon = titan.GetActiveWeapon()
		weapon.Hide()
		titan.Hide()
		thread PlayAnimTeleport( titan, "at_hotdrop_loop", ref )
		wait titan.kv.introstyle_delay.tofloat()
		titan.Show()
		weapon.Show()
	}

	// add smoke fx

	TitanHotDrop_Smoke( cleanup, titan, titan.GetBossPlayer() )

//	"Titan_1P_Warpfall_Hotdrop" 		- for first person drops while inside the titan dropping into the level
//	"Titan_1P_Warpfall_Start" 			- for first person warp calls, starting right on the button press
//	"Titan_1P_Warpfall_WarpToLanding" 	- for first person from the visual of the titan appearing and falling
//	"Titan_3P_Warpfall_Start"  			- for any 3P other player or NPC when they call in a warp, starting right on their button press
//	"Titan_3P_Warpfall_WarpToLanding" 	- for any 3P other player or NPC  from the visual of the titan appearing and falling

	EmitSoundAtPositionOnlyToPlayer( origin, player, "Titan_1P_Warpfall_Hotdrop" )
	EmitSoundAtPositionOnlyToPlayer( origin, player, "Titan_1P_Warpfall_Start" )
	EmitSoundAtPositionExceptToPlayer( origin, player, "Titan_3P_Warpfall_Start" )
	EmitSoundAtPositionExceptToPlayer( origin, player, "Titan_3P_Warpfall_WarpToLanding" )

	local duration = titan.GetSequenceDuration( animation )
	//local animation = "at_hotdrop_01"
	thread PlayAnimTeleport( titan, animation, ref )
	titan.EndSignal( "OnAnimationDone" )

	if ( delayedCreation )
	{
		if ( duration > 1.0 )
		{
			wait 0.1
			GiveHotDropTitanWeaponsForPlayer( player, titan )
		}
		else
		{
			GiveTitanWeaponsForPlayer( player, titan )
		}
	}

	if ( player )
	{
		player.PlayerCone_SetMinYaw( -70 )
		player.PlayerCone_SetMaxYaw( 70 )
		player.PlayerCone_SetMinPitch( -90 )
		player.PlayerCone_SetMaxPitch( 90 )
	}

	titan.WaitSignal( "titan_impact" )
//	wait duration - 1.25

	local impactExplode = TitanHotDrop_ImpactExplode( titan, origin )
	impactExplode.Kill( 3.0 )
	local sourcePosition = origin;
	sourcePosition.z = sourcePosition.z + 5.0
	impactExplode.SetExplosionSourcePosition( sourcePosition )
	impactExplode.Fire( "Explode" )


	ShowName( titan )
}

function TitanHotDrop_ImpactExplode( titan, origin )
{
	local impactExplode = CreateEntity( "env_explosion" )
	impactExplode.SetOrigin( origin )
	impactExplode.kv.iRadiusOverride = 250
	impactExplode.kv.iInnerRadius = 80
	impactExplode.kv.iMagnitude = 150
	impactExplode.kv.damageSourceId = eDamageSourceId.titan_hotdrop
	impactExplode.SetOwner( titan )
	impactExplode.SetTeam( titan.GetTeam() )
	// No Fireball
	// No Smoke
	// No Sparks
	// No Sound
	// No Fireball Smoke
	// No particles
	// No Decal
	// No DLights
	// Do NOT damage owner entity
	impactExplode.kv.spawnflags = 132988
	impactExplode.kv.impact_effect_table = HOTDROP_IMPACT_FX_TABLE
	DispatchSpawn( impactExplode, false )
	printt( "Bot Titan Dropped" )
	return impactExplode
}

function TitanHotDrop_Smoke( cleanup, titan, player )
{
	local smokeTrail = CreateEntity( "info_particle_system" )
	if ( IsValid( player ) )
	{
		smokeTrail.SetOwner( player )
		smokeTrail.kv.VisibilityFlags = 1
	}

	smokeTrail.kv.effect_name = HOTDROP_TRAIL_FX // HOTDROP_FP_WARP
	smokeTrail.kv.start_active = 1
	DispatchSpawn( smokeTrail )
	smokeTrail.SetParent( titan, "HATCH_HEAD" )
	cleanup.append( smokeTrail )


	local smokeTrail = CreateEntity( "info_particle_system" )
	if ( IsValid( player ) )
	{
		smokeTrail.SetOwner( player )
		smokeTrail.kv.VisibilityFlags = 6 //owner cant see
	}

	smokeTrail.kv.effect_name = HOTDROP_TRAIL_FX // HOTDROP_FP_WARP
	smokeTrail.kv.start_active = 1
	DispatchSpawn( smokeTrail )
	smokeTrail.SetParent( titan, "HATCH_HEAD" )
	cleanup.append( smokeTrail )

	return smokeTrail
}


function GetHotDropImpactTime( titan, animation )
{
	local impactTime = titan.GetScriptedAnimEventCycleFrac( animation, "titan_impact" )
	Assert( impactTime > -1, "No event titan_impact in " + animation )

	local duration = titan.GetSequenceDuration( animation )

	impactTime *= duration

	return impactTime
}


function SuperHotDropReplacementTitan( titan, origin, angles, player, animation )
{
	titan.EndSignal( "OnDeath" )
	titan.s.disableAutoTitanConversation <- true

	OnThreadEnd(
		function() : ( titan, player )
		{
			if ( !IsValid( titan ) )
				return

			titan.DisableRenderAlways()

			delete titan.s.hotDropPlayer
			DeleteAnimEvent( titan, "titan_impact", OnReplacementTitanImpact )
			DeleteAnimEvent( titan, "second_stage", OnReplacementTitanSecondStage )
			DeleteAnimEvent( titan, "set_usable", SetTitanUsableByOwner )
		}
	)

	HideName( titan )
	titan.s.hotDropPlayer <- player
	titan.UnsetUsable() //Stop titan embark before it lands
	AddAnimEvent( titan, "titan_impact", OnReplacementTitanImpact )
	AddAnimEvent( titan, "second_stage", OnReplacementTitanSecondStage, origin )
	AddAnimEvent( titan, "set_usable", SetTitanUsableByOwner )
	HideTitanEyePartial( titan )

	local sfxFirstPerson
	local sfxThirdPerson

	switch ( animation )
	{
		case "at_hotdrop_drop_2knee_turbo_upgraded":
			sfxFirstPerson = "Titan_1P_Warpfall_WarpToLanding"
			sfxThirdPerson = "Titan_3P_Warpfall_WarpToLanding"
			break

		case "at_hotdrop_drop_2knee_turbo":
			sfxFirstPerson = "titan_hot_drop_turbo_begin"
			sfxThirdPerson = "titan_hot_drop_turbo_begin_3P"
			break

		default:
			Assert( 0, "Unknown anim " + animation )
	}

	local impactTime = GetHotDropImpactTime( titan, animation )
	local result = titan.Anim_GetAttachmentAtTime( animation, "OFFSET", impactTime )
	local maxs = titan.GetBoundingMaxs()
	local mins = titan.GetBoundingMins()
	local mask = titan.GetPhysicsSolidMask()
	ModifyOriginForDrop( origin, mins, maxs, result.position, mask )

	titan.SetInvulnerable() //Make Titan invulnerable until bubble shield is up. Cleared in OnReplacementTitanImpact
	DisableTitanfallForLifetimeOfEntityNearOrigin( titan, origin, TITANHOTDROP_DISABLE_ENEMY_TITANFALL_RADIUS )

	delaythread( impactTime ) CreateBubbleShield( titan, origin, angles )

	//DrawArrow( origin, angles, 10, 150 )
	titan.EnableRenderAlways()
	EmitDifferentSoundsAtPositionForPlayerAndWorld( sfxFirstPerson, sfxThirdPerson, origin, player )

	SetStanceKneel( titan.GetTitanSoul() )

	waitthread PlayAnimTeleport( titan, animation, origin, angles )

	TitanCanStand( titan )
	if ( !titan.GetCanStand() )
	{
		titan.SetOrigin( origin )
		titan.SetAngles( angles )
	}

	titan.ClearInvulnerable() //Make Titan vulnerable again once he's landed

	if ( !Flag( "DisableTitanKneelingEmbark" ) )
	{
		if ( IsValid( GetEmbarkPlayer( titan ) ) )
		{
			//A player is trying to get in before the hotdrop animation has finished
			//Wait until the embark animation has finished
			titan.WaittillAnimDone()
			return
		}

		titan.s.standQueued = false // SetStanceKneel should set this
		SetStanceKneel( titan.GetTitanSoul() )
		thread PlayAnim( titan, "at_MP_embark_idle_blended" )
	}
}

function ModifyOriginForDrop( origin, mins, maxs, resultPos, mask )
{
	local trace = TraceHull( resultPos + Vector(0,0,20), resultPos + Vector(0,0,-20), mins, maxs, null, mask, TRACE_COLLISION_GROUP_NONE )
	local zDif = trace.endPos.z - resultPos.z
	origin.z += zDif
	origin.z += 3.0
}
Globalize( ModifyOriginForDrop )


function OnReplacementTitanSecondStage( titan, origin )
{
	local sfxFirstPerson = "titan_drop_pod_turbo_landing"
	local sfxThirdPerson = "titan_drop_pod_turbo_landing_3P"
	local player = titan.GetBossPlayer()
	EmitDifferentSoundsAtPositionForPlayerAndWorld( sfxFirstPerson, sfxThirdPerson, origin, player )
}


function SuperHotDrop( titan, animation, origin, angles )
{
	OnThreadEnd(
		function() : ( titan )
		{
			if ( IsValid( titan ) )
			{
				DeleteAnimEvent( titan, "titan_impact", OnHotdropImpact )
				DeleteAnimEvent( titan, "second_stage", OnReplacementTitanSecondStage )
				titan.DisableRenderAlways()
				delete titan.s.disableAutoTitanConversation
			}
		}
	)
	titan.EndSignal( "OnDeath" )

	titan.s.disableAutoTitanConversation <- true
	AddAnimEvent( titan, "titan_impact", OnHotdropImpact  )
	AddAnimEvent( titan, "second_stage", OnReplacementTitanSecondStage, origin )

	titan.EnableRenderAlways()
	local sfxFirstPerson = "titan_drop_pod"
	local sfxThirdPerson = "titan_drop_pod"
	if ( animation != "at_hotdrop_drop_2knee" )
	{
		//This is one of the shortened titanfall animations, play only the beginning of the sound
		sfxFirstPerson = "titan_hot_drop_turbo_begin"
		sfxThirdPerson = "titan_hot_drop_turbo_begin_3P"
	}

	local player = titan.GetBossPlayer()
	EmitDifferentSoundsAtPositionForPlayerAndWorld( sfxFirstPerson, sfxThirdPerson, origin, player )
	waitthread PlayAnimTeleport( titan, animation, origin, angles )

	PlayAnimGravity( titan, "at_hotdrop_quickstand" )
}

function ScriptedHotDrop( titan, origin = null, angles = null, animation = "at_hotdrop_drop_2knee", noImpactCall = false )
{
	if ( !origin )
		origin = titan.GetOrigin()
	if ( !angles )
		angles = titan.GetAngles()

	OnThreadEnd(
		function() : ( titan, noImpactCall )
		{
			if ( IsValid( titan ) )
			{
				if ( !noImpactCall )
					DeleteAnimEvent( titan, "titan_impact", OnScripteddropImpact )
				DeleteAnimEvent( titan, "second_stage", OnReplacementTitanSecondStage )
				titan.DisableRenderAlways()
			}
		}
	)
	titan.EndSignal( "OnDeath" )

	if ( !noImpactCall )
		AddAnimEvent( titan, "titan_impact", OnScripteddropImpact  )
	AddAnimEvent( titan, "second_stage", OnReplacementTitanSecondStage, origin )

	titan.EnableRenderAlways()
	local sfxThirdPerson = "titan_drop_pod"
	//This is one of the shortened titanfall animations, play only the beginning of the sound
	if ( animation != "at_hotdrop_drop_2knee" )
		sfxThirdPerson = "titan_hot_drop_turbo_begin_3P"

	EmitSoundAtPosition( origin, sfxThirdPerson )
	waitthread PlayAnimTeleport( titan, animation, origin, angles )
}


function SuperHotDropGenericTitanAndStand( titan, origin, angles )
{
	SuperHotDropGenericTitan_DropIn( titan, origin, angles )
}
Globalize( SuperHotDropGenericTitanAndStand )


function SuperHotDropGenericTitan( titan, origin, angles )
{
	SuperHotDropGenericTitan_DropIn( titan, origin, angles )
	HotdroppingTitanKneels( titan )
}

function SuperHotDropGenericTitan_DropIn( titan, origin, angles )
{
	titan.EndSignal( "OnDeath" )

//	printt( "TitanHotDrop" )
//origin = Vector(-2257.346924, -2599.757080, -275.556885)
//angles = Vector(0.000000, -177.883041, 0.000000)

//	printt( "origin: " + origin )
//	printt( "angles: " + angles )
	titan.s.disableAutoTitanConversation <- true

	OnThreadEnd(
		function() : ( titan )
		{
			if ( !IsValid( titan ) )
				return

			//delete titan.s.disableAutoTitanConversation //Don't delete here, otherwise Auto Titan will start talking about engaging enemy soldiers while kneeling down.
			titan.DisableRenderAlways()

			DeleteAnimEvent( titan, "titan_impact", OnReplacementTitanImpact )
			DeleteAnimEvent( titan, "second_stage", OnReplacementTitanSecondStage )
			DeleteAnimEvent( titan, "set_usable", SetTitanUsable )
		}
	)

	HideName( titan )
	titan.UnsetUsable() //Stop titan embark before it lands
	AddAnimEvent( titan, "titan_impact", OnReplacementTitanImpact )
	AddAnimEvent( titan, "second_stage", OnReplacementTitanSecondStage, origin )
	AddAnimEvent( titan, "set_usable", SetTitanUsable )
	HideTitanEyePartial( titan )

	local animation
	local sfxFirstPerson = "titan_hot_drop_turbo_begin"
	local sfxThirdPerson = "titan_hot_drop_turbo_begin_3P"

	animation = "at_hotdrop_drop_2knee_turbo"

	local impactTime = GetHotDropImpactTime( titan, animation )
	local result = titan.Anim_GetAttachmentAtTime( animation, "OFFSET", impactTime )
	local maxs = titan.GetBoundingMaxs()
	local mins = titan.GetBoundingMins()
	local mask = titan.GetPhysicsSolidMask()
	ModifyOriginForDrop( origin, mins, maxs, result.position, mask )


	titan.SetInvulnerable() //Make Titan invulnerable until bubble shield is up

	//DrawArrow( origin, angles, 10, 150 )
	titan.EnableRenderAlways()

	EmitSoundAtPosition( origin, sfxThirdPerson )

	SetStanceKneel( titan.GetTitanSoul() )

	waitthread PlayAnimTeleport( titan, animation, origin, angles )

	titan.ClearInvulnerable() //Make Titan vulnerable again once he's landed
}

function HotdroppingTitanKneels( titan )
{
	if ( !Flag( "DisableTitanKneelingEmbark" ) )
	{
		if ( IsValid( GetEmbarkPlayer( titan ) ) )
		{
			//A player is trying to get in before the hotdrop animation has finished
			//Wait until the embark animation has finished
			titan.WaittillAnimDone()
			return
		}

		titan.s.standQueued = false // SetStanceKneel should set this
		SetStanceKneel( titan.GetTitanSoul() )
		thread PlayAnim( titan, "at_MP_embark_idle_blended" )
	}
}

function OnScripteddropImpact( titan )
{
	OnHotdropImpact( titan )
	PlayFX( HOTDROP_IMPACT_FX_TABLE, titan.GetOrigin(), titan.GetAngles() )
}

function OnReplacementTitanImpact( titan )
{
	ShowName( titan )
	OnHotdropImpact( titan )
}

function SetTitanUsable( titan )
{
	titan.SetUsableByGroup( "friendlies pilot" )
}

function SetTitanUsableByOwner( titan )
{
	titan.SetUsableByGroup( "owner pilot" )
}

function OnHotdropImpact( titan )
{
	local pilotDamage = 0
	local titanDamage = 0
	if ( IsAlive( titan ) && titan.IsTitan() )
	{
		pilotDamage = 400
		titanDamage = 23000
	}
	titan.ClearInvulnerable()
	CreateExplosion(
		titan.GetOrigin(),  // origin
		pilotDamage,  // mag
		titanDamage,  // mag vs titans
		TITANFALL_INNER_RADIUS,  // inner rad
		TITANFALL_OUTER_RADIUS,  // outer rad
		titan,  // owner
		0,  // delay
		null,  // sound
		eDamageSourceId.titan_fall,  // damage source
		false,  // self damage
		HOTDROP_IMPACT_FX_TABLE, // fx
		true // skips doomed state
		)

	CreateShake( titan.GetOrigin(), 16, 150, 2, 1500 )
	// No Damage - Only Force
	// Push players
	// Push radially - not as a sphere
	// Test LOS before pushing
	local flags = 15
	local impactOrigin = titan.GetOrigin() + Vector( 0,0,10 )
	local impactRadius = 512
	CreatePhysExplosion( impactOrigin, impactRadius, "large", flags )
}

function NearTitanfallBlocker( baseOrigin )
{
	foreach ( hardpoint in level.testHardPoints )
	{
		local hpOrigin = hardpoint.GetOrigin()
		hpOrigin.z -= 100 // why are hardpoints not really at the origin?
		if ( Distance( hpOrigin, baseOrigin ) < SAFE_TITANFALL_DISTANCE )
			return true
	}

	foreach ( flagSpawnPoint in level.testFlagSpawnPoints )
	{
		local fspOrigin = flagSpawnPoint.GetOrigin()
		if ( Distance( fspOrigin, baseOrigin ) < SAFE_TITANFALL_DISTANCE_CTF )
			return true
	}

	foreach ( blocker in level.titanfallBlockers )
	{
		if ( Distance2D( baseOrigin, blocker.origin  ) > blocker.radius )
			continue

		if ( baseOrigin.z < blocker.origin.z )
			continue

		if ( baseOrigin.z > blocker.maxHeight )
			continue

		return true
	}

	return false
}
Globalize( NearTitanfallBlocker )

function DevCheckInTitanfallBlocker()
{
	if ( "toggleBlocker" in level.ent.s )
	{
		level.ent.s.toggleBlocker.Kill()
		delete level.ent.s.toggleBlocker
		return
	}

	level.ent.s.toggleBlocker <- CreateScriptRef()
	level.ent.s.toggleBlocker.EndSignal( "OnDestroy" )

	local player = GetPlayerArray()[0]
	for ( ;; )
	{
		printt( "Inside Titanfall blocker: " + NearTitanfallBlocker( player.GetOrigin() ) )
		DrawTitanfallBlockers()
		wait 0.5
	}
}
Globalize( DevCheckInTitanfallBlocker )

function DrawTitanfallBlockers()
{
	foreach ( hardpoint in level.testHardPoints )
	{
		local hpOrigin = hardpoint.GetOrigin()
		DebugDrawCircle( hpOrigin, Vector(0,0,0), SAFE_TITANFALL_DISTANCE, 255, 255, 0, 1 )
	}

	foreach ( flagSpawnPoint in level.testFlagSpawnPoints )
	{
		local fspOrigin = flagSpawnPoint.GetOrigin()
		DebugDrawCircle( fspOrigin, Vector(0,0,0), SAFE_TITANFALL_DISTANCE_CTF, 255, 255, 0, 1 )
	}

	foreach ( blocker in level.titanfallBlockers )
	{
		DebugDrawCircle( blocker.origin, Vector(0,0,0), blocker.radius, 255, 255, 0, 1 )
		local org = Vector( blocker.origin.x, blocker.origin.y, blocker.maxHeight )
		DebugDrawCircle( org, Vector(0,0,0), blocker.radius, 255, 255, 0, 1 )
	}
}
Globalize( DrawTitanfallBlockers )


function TitanFindDropNodes( analysis, baseOrigin, yaw )
{
//	return TitanFindDropNodesReloadable( analysis, baseOrigin, yaw )
//}
//function TitanFindDropNodesReloadable( analysis, baseOrigin, yaw )
//{
	if ( NearTitanfallBlocker( baseOrigin ) )
		return false

	local model = analysis.model
	local animation = analysis.anim
	//local analysis = GetAnalysisForModel( model, animation )

	local origin = VectorCopy( baseOrigin )
	local angles = Vector(0,yaw,0)
	//local titan = CreatePropDynamic( model, origin, Vector(0,0,0) )
	//local titan = CreateNPCTitanFromSettings( "titan_atlas", TEAM_IMC, origin, angles )

	local titan = level.ainTestTitan

	titan.SetModel( model )
	titan.SetAngles( angles )
	titan.SetOrigin( origin )

	local impactTime = GetHotDropImpactTime( titan, animation )
	local result = titan.Anim_GetAttachmentAtTime( animation, "OFFSET", impactTime )
	local maxs = titan.GetBoundingMaxs()
	local mins = titan.GetBoundingMins()
	local mask = titan.GetPhysicsSolidMask()
	ModifyOriginForDrop( origin, mins, maxs, result.position, mask )
	titan.SetOrigin( origin )

	if ( !TitanTestDropPoint( origin, analysis ) )
		return false

	if ( !TitanCanStand( titan ) )
		return false

	if ( TitanHulldropSpawnpoint( analysis, origin ) == null )
		return false

	if ( !EdgeTraceDropPoint( origin ) )
		return false

	return true
}


function DropPodFindDropNodes( analysis, origin, yaw )
{
	if ( NearTitanfallBlocker( origin ) )
		return false

	//level.drawAnalysisPreview = true
	if ( !TitanTestDropPoint( origin, analysis ) )
		return false

	return EdgeTraceDropPoint( origin )
}
Globalize( DropPodFindDropNodes )

function TitanTestDropPoint( start, analysis )
{
	local draw = level.drawAnalysisPreview
	local end = start + Vector(0,0,8000)

	local result = TraceHull( start, end, analysis.mins, analysis.maxs, null, analysis.traceMask, TRACE_COLLISION_GROUP_NONE )
	if ( result.startSolid )
	{
		if ( draw )
		{
			DrawArrow( start, Vector(0,0,0), 5, 80 )
			DebugDrawLine( start, result.endPos, 0, 255, 0, true, 5.0 )
			DebugDrawLine( result.endPos, end, 255, 0, 0, true, 5.0 )
			//local newstart = start + Vector(0,0,150)
			//local reresult = TraceHull( newstart, start, analysis.mins, analysis.maxs, null, analysis.traceMask, TRACE_COLLISION_GROUP_NONE )
			//printt( "surface " + reresult.surfaceName )
			//DebugDrawLine( newstart, reresult.endPos, 155, 0, 0, true, ANALYSIS_PREVIEW_TIME )
			//DrawArrow( reresult.endPos, Vector(0,0,0), ANALYSIS_PREVIEW_TIME, 15 )
            //
//			//DrawArrow( start, Vector(0,0,0), ANALYSIS_PREVIEW_TIME, 15 )
			//DebugDrawLine( start, result.endPos, 255, 0, 0, true, ANALYSIS_PREVIEW_TIME )
			//printt( "length " + ( start - result.endPos ).Length() )
		}
		return false
	}

	if ( result.fraction < 1 )
	{
		if ( result.hitSky )
		{
			if ( draw )
			{
				DebugDrawLine( start, end, 0, 0, 255, true, ANALYSIS_PREVIEW_TIME )
				//DrawArrow( start, Vector(0,0,0), 1.0, 100 )
			}
			return true
		}

//		if ( draw )
//			DebugDrawLine( orgs[i-1] + Vector(10,10,10), orgs[i]+ Vector(10,10,10), 255, 255, 0, true, ANALYSIS_PREVIEW_TIME )

		// some fudge factor
		if ( Distance( result.endPos, end ) > 16 )
		{
			if ( draw )
			{
				local offset = Vector(-0.1, -0.1, 0 )
				DebugDrawLine( start + offset, result.endPos + offset, 0, 255, 0, true, ANALYSIS_PREVIEW_TIME )
				DebugDrawLine( result.endPos + offset, end + offset, 255, 0, 0, true, ANALYSIS_PREVIEW_TIME )
				//DebugDrawLine( start, end, 255, 0, 0, true, ANALYSIS_PREVIEW_TIME )
			}
			return false
		}
	}

//		DebugDrawLine( orgs[i-1], orgs[i], 0, 255, 0, true, ANALYSIS_PREVIEW_TIME )

	if ( draw )
		DebugDrawLine( start, end, 0, 255, 0, true, 0.2 )
	return true
}



function TitanHulldropSpawnpoint( analysis, origin, _ = null )
{
	return HullTraceDropPoint( analysis, origin, 20 )
}

function CreateTitanEscort()
{
	local table = CreateCallinTable()
	table.titanTemplate <- null
	table.spawnFunc <- null
	return table
}


function RunTitanEscort( table )
{
	Assert( IsNewThread(), "Must be threaded off" )

	local origin =   	table.origin
	local yaw =   		table.yaw
	local team =   		table.team
	local owner =		table.owner
	local squadname = 	table.squadname
	local squadFunc =	table.squadFunc
	local squadParm =	table.squadParm
	local style =		table.style
	local titanTemplate = table.titanTemplate
	table.success <- false

	if ( team == null )
	{
		if ( owner )
			team = owner.GetTeam()
		else
			team = 0
	}

	local animation = "at_hotdrop_drop_2knee"
	local analysis = GetAnalysisForModel( "models/titans/atlas/atlas_titan.mdl", animation )
	local wasPlayerOwned = owner && IsValidPlayer( owner )

	local spawnPoint = GetSpawnPointForStyle( analysis, table )

	if ( !spawnPoint )
	{
		printt( "Couldn't find good spawn location for titan" )
		return
	}

	table.success = true

	titanTemplate.origin = spawnPoint.origin
	titanTemplate.angles = spawnPoint.angles

	local titan = SpawnNPCTitan( titanTemplate )
	if ( !IsAlive( titan ) )
		return
	titan.EndSignal( "OnDeath" )

	if ( table.spawnFunc )
	{
		table.spawnFunc( titan )
	}

	if ( IsValidPlayer( owner ) )
	{
		titan.SetBossPlayer( owner )
		titan.EndSignal( "OnDeath" )
		thread DieIfBossDisconnects( titan, owner )

		HideNameToAllExceptOwner( titan )
	}

	waitthread SuperHotDrop( titan, animation, spawnPoint.origin, spawnPoint.angles )
	UpdateEnemyMemoryFromTeammates( titan )
}


function TitanFall_DamagedPlayerOrNPC( entity, damageInfo )
{
	if ( !entity.IsPlayer() )
		return

	if ( !entity.IsTitan() )
		return

	local damageOrigin = damageInfo.GetDamagePosition()
	local entityOrigin = entity.GetOrigin()
	local distance = Distance( entityOrigin, damageOrigin )

	// on top of them, let the titans fall where they may
	if ( distance < TITANFALL_INNER_RADIUS )
		return

	if ( IsTitanWithinBubbleShield( entity ) )
	{
		damageInfo.SetDamage( 0 )
		return
	}

	local pushVector = (entityOrigin - damageOrigin)
	pushVector.Normalize()

	local traceEndOrigin = damageOrigin + (pushVector * TITANFALL_OUTER_RADIUS)
	local traceResult = TraceHull( damageOrigin, traceEndOrigin, entity.GetBoundingMins(), entity.GetBoundingMins(), entity, TRACE_MASK_NPCSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )

	// no room to push them
	if ( traceResult.fraction < 0.85 )
		return

	damageInfo.SetDamage( damageInfo.GetDamage() * 0.15 )

	entity.SetVelocity( pushVector * 400 )
	entity.SetStaggering()
}

function PlayDeathFromTitanFallSounds( player )
{
	if ( player.IsTitan() )
	{
		//printt( "Playing titanfall_on_titan at: "+ player.GetOrigin() )
		EmitSoundAtPosition( player.GetOrigin(), "titanfall_on_titan" )
	}
	else
	{
		//printt( "Playing titanfall_on_human at " + player.GetOrigin() )
		EmitSoundAtPosition( player.GetOrigin(), "titanfall_on_human" )
	}
}

Globalize( PlayDeathFromTitanFallSounds )
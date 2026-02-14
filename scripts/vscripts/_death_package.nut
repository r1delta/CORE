::DF_GIB				<- 0x0001
::DF_DISSOLVE			<- 0x0002
::DF_FIRE				<- 0x0004
::DF_INSTANT			<- 0x0008
::DF_LONG				<- 0x0010
::DF_TITAN_GIB			<- 0x0020
::DF_SKIPS_DOOMED_STATE	<- 0x0040
::DF_IMPACT				<- 0x0080
::DF_AT_ROCKET			<- 0x0100
::DF_RAGDOLL			<- 0x0200
::DF_TITAN_STEP 		<- 0x0400
::DF_NO_TITAN_DMG 		<- 0x0800	// no damage to titans
::DF_ELECTRICAL 		<- 0x1000
::DF_BULLET 			<- 0x2000
::DF_EXPLOSION			<- 0x4000
::DF_MELEE				<- 0x8000
::DF_NO_INDICATOR		<- 0x10000
::DF_DOOMED_HEALTH_LOSS	<- 0x20000
::DF_KNOCK_BACK			<- 0x40000
::DF_STOPS_TITAN_REGEN	<- 0x80000
::DF_NO_FLINCH			<- 0x100000
::DF_MAX_RANGE			<- 0x200000
::DF_SHIELD_DAMAGE		<- 0x400000
::DF_CRITICAL			<- 0x800000
::DF_SPECTRE_GIB		<- 0x1000000
::DF_HEADSHOT			<- 0x2000000
::DF_VORTEX_REFIRE		<- 0x4000000
::DF_RODEO				<- 0x8000000
::DF_BURN_CARD_WEAPON	<- 0x10000000
::DF_KILLSHOT			<- 0x20000000
::DF_SHOTGUN			<- 0x40000000
::DF_NO_HITBEEP			<- 0x80000000
// No more allowed... there are only 32 bits.

::damageTypes <- {}

damageTypes.Gibs 				<- (DF_GIB)
damageTypes.FlamingGibs 		<- (DF_GIB | DF_FIRE)
damageTypes.LargeCaliberExp		<- (DF_BULLET | DF_GIB | DF_EXPLOSION)
damageTypes.GibBullet			<- (DF_BULLET | DF_GIB)
damageTypes.Instant				<- (DF_INSTANT)
damageTypes.Dissolve			<- (DF_DISSOLVE)
damageTypes.ATRocket			<- (DF_GIB | DF_FIRE | DF_AT_ROCKET | DF_EXPLOSION)
damageTypes.PinkMist 			<- (DF_GIB) //If updated from DF_GIB, change the DF_GIB in Arc Cannon to match.
damageTypes.Ragdoll				<- (DF_RAGDOLL)
damageTypes.TitanStepCrush		<- (DF_TITAN_STEP | DF_NO_TITAN_DMG)
damageTypes.NoDamageToTitans	<- (DF_NO_TITAN_DMG)
damageTypes.ArcCannon			<- (DF_DISSOLVE | DF_GIB | DF_ELECTRICAL | DF_SPECTRE_GIB )
damageTypes.Electric			<- (DF_ELECTRICAL) //Only increases Vortex Shield decay for bullet weapons atm.
damageTypes.Explosive			<- (DF_RAGDOLL | DF_FIRE | DF_EXPLOSION )
damageTypes.Bullet				<- (DF_BULLET)
damageTypes.LargeCaliber		<- (DF_BULLET | DF_KNOCK_BACK)
damageTypes.Shotgun				<- (DF_BULLET | DF_GIB | DF_SHOTGUN )
damageTypes.SmallArms			<- (DF_NO_TITAN_DMG | DF_BULLET)
damageTypes.TitanMelee			<- (DF_MELEE | DF_RAGDOLL)
damageTypes.TitanMeleePinkMist	<- (DF_MELEE | DF_GIB )
damageTypes.HumanMelee          <- (DF_MELEE | DF_KNOCK_BACK)
damageTypes.TitanEjectExplosion	<- (DF_GIB | DF_EXPLOSION | DF_TITAN_GIB)

bodyGroupSkeletons <- {}

disallowDissolveList <- {}
disallowDissolveList[ "npc_spectre" ]		<- true
disallowDissolveList[ "npc_turret_mega" ]	<- true
disallowDissolveList[ "npc_turret_sentry" ] <- true
disallowDissolveList[ "npc_dropship" ] 		<- true

function main()
{
	if ( IsServer() )
	{
		const NPC_GRUNT_DEATH = "npc_grunt_death"
		const TITAN_GRUNT_SQUISH = "titan_grunt_squish"
		const TITAN_SPECTRE_SQUISH = "titan_spectre_squish"
		const HUMAN_DISSOLVE_DEATH = "soldier_dissolving_scream"
		const MARVIN_DISSOLVE_DEATH = "marvin_dissolving_scream"
		const TITAN_EXPLOSION_EFFECT = "xo_exp_death"

		PrecacheEffect( TITAN_EXPLOSION_EFFECT )
		PrecacheEffect( "P_wpn_dumbfire_burst_trail" )
		PrecacheEffect( "P_exp_spectre_death" )

		PrecacheModel( "models/gibs/human_gibs.mdl" )

		PrecacheModel( "models/weapons/bullets/damage_arrow.mdl" )
		PrecacheModel( "models/weapons/bullets/mgl_grenade.mdl" )
		PrecacheModel( "models/weapons/grenades/m20_f_grenade.mdl" )

		PrecacheModel( "models/weapons/bullets/grenade_indicator_arrow.mdl" )
		PrecacheModel( "models/weapons/bullets/grenade_indicator.mdl" )
		PrecacheModel( "models/weapons/bullets/grenade_indicator_tt.mdl" )

		//GENERIC GIBS
		PrecacheModel( "models/gibs/metal_gib1.mdl" )
		PrecacheModel( "models/gibs/metal_gib2.mdl" )
		PrecacheModel( "models/gibs/metal_gib3.mdl" )
		PrecacheModel( "models/gibs/metal_gib4.mdl" )
		PrecacheModel( "models/gibs/metal_gib5.mdl" )

		//SPECTRE GIBS
		PrecacheModel( "models/robots/spectre/spectre_assault_d_gib_leg_l.mdl" )
		PrecacheModel( "models/robots/spectre/spectre_assault_d_gib_leg_r.mdl" )
    	PrecacheModel( "models/robots/spectre/spectre_assault_d_gib_foot_l.mdl" )
		PrecacheModel( "models/robots/spectre/spectre_assault_d_gib_foot_r.mdl" )
        PrecacheModel( "models/robots/spectre/spectre_assault_d_gib_arm_l.mdl" )
        PrecacheModel( "models/robots/spectre/spectre_assault_d_gib_arm_r.mdl" )
        PrecacheModel( "models/robots/spectre/spectre_assault_d_gib_chest.mdl" )
        PrecacheModel( "models/robots/spectre/spectre_assault_d_gib_head.mdl" )
        PrecacheModel( "models/robots/spectre/spectre_corporate_d_gib_head.mdl" )

		//ATLAS GIBS
		PrecacheModel( "models/gibs/titan_gibs/at_gib1.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib2.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib3.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib4.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib5.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib6.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib_hatch_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib7_r_shin.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib8_l_thigh1.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib8_l_thigh2.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib9_l_bicep1.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib9_l_bicep2.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib9_l_bicep3.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib_l_arm1_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib_l_arm2_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib_l_leg1_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib_l_leg2_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib_r_arm1_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib_r_arm2_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib_r_leg1_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/at_gib_r_leg2_d.mdl" )

		//STRYDER GIBS
		PrecacheModel( "models/gibs/titan_gibs/stry_gib1.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib2.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib3.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib4.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib5.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib6.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib_hatch_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib7_r_shin.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib8_l_thigh1.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib8_l_thigh2.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib9_l_bicep1.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib9_l_bicep2.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib9_l_bicep3.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib_l_arm1_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib_l_arm2_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib_l_leg1_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib_l_leg2_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib_r_arm1_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib_r_arm2_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib_r_leg1_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/stry_gib_r_leg2_d.mdl" )

		//OGRE GIBS
		PrecacheModel( "models/gibs/titan_gibs/og_gib_hatch_d.mdl" )
		PrecacheModel( "models/gibs/titan_gibs/og_gib_r_forarm_d.mdl" )


		Globalize( ExplodeTitanBits )
		Globalize( GetGibModel )

		Globalize( InitDamageStates )
		Globalize( HandleDeathPackage )
		Globalize( TransferDamageStates )
		Globalize( UpdateDamageState )

		Globalize( GetBodyGroupForHitbox )
		Globalize( GetTagsForBodyGroup )
		Globalize( IsBodyGroupBroken )

		file.hitDataCache <- {}
	}
}


function InitDamageStates( ent )
{
	local modelName = ent.GetModelName()
	if ( !(modelName in file.hitDataCache) )
	{
		local hitData = {}
		file.hitDataCache[modelName] <- hitData

		local entKVs = ent.CreateTableFromModelKeyValues()

		hitData.hasHitData <- ("hit_data" in entKVs)
		hitData.entKVs <- entKVs
		hitData.damageStateInfo <- {}
		hitData.critBoxes <- {}
		hitData.hitBoxToBodyGroup <- {}
		hitData.skeletonData <- {}

		if ( !hitData.hasHitData )
			return

		local kvhitData = entKVs["hit_data"]
		foreach ( bodyGroupName, bodyGroupData in kvhitData )
		{
			foreach ( k, v in bodyGroupData )
			{
				if ( k.find( "hitbox" ) == null )
					continue

				hitData.hitBoxToBodyGroup[v.tointeger()] <- bodyGroupName
			}
		}

		hitData.critBoxes <- {}
		if ( "crit_data" in entKVs )
		{
			foreach ( keyName, v in entKVs["crit_data"] )
			{
				if ( keyName.find( "hitbox" ) != null )
					hitData.critBoxes[v.tointeger()] <- true
			}
		}

		if ( !(ent.GetModelName() in bodyGroupSkeletons) )
		{
			// build a graph of bodygroup connections to calculate radial damage states
			local skeletonData = {}

			foreach ( bodyGroupName, bodyGroupData in entKVs.hit_data )
			{
				skeletonData[bodyGroupName] <- { siblings = [] }
			}

			foreach ( bodyGroupName, bodyGroupData in entKVs.hit_data )
			{
				if ( !("parent" in bodyGroupData ) )
					continue

				local parentName = bodyGroupData["parent"]

				skeletonData[bodyGroupName].siblings.append( parentName )
				skeletonData[parentName].siblings.append( bodyGroupName )
			}

			bodyGroupSkeletons[ ent.GetModelName() ] <- skeletonData
		}

		hitData.damageStateInfo <- {}
		foreach ( bodyGroupName, bodyGroupData in entKVs.hit_data )
		{
			hitData.damageStateInfo[bodyGroupName] <- 0
		}

		hitData.skeletonData <- bodyGroupSkeletons[ ent.GetModelName() ]
	}

	ent.s.hasHitData <- file.hitDataCache[modelName].hasHitData
	ent.s.entKVs <- clone file.hitDataCache[modelName].entKVs
	ent.s.damageStateInfo <- clone file.hitDataCache[modelName].damageStateInfo
	ent.s.critBoxes <- clone file.hitDataCache[modelName].critBoxes
	ent.s.hitBoxToBodyGroup <- clone file.hitDataCache[modelName].hitBoxToBodyGroup
	ent.s.skeletonData <- clone file.hitDataCache[modelName].skeletonData
}


function TransferDamageStates( source, dest )
{
	// when you get in a titan from the other team, it wants to make your model match your team. grr.
	if ( source.GetModelName() != dest.GetModelName() )
		return

	//Assert( source.GetModelName() == dest.GetModelName(), "Model name mismatch: " + source.GetModelName() + " " + dest.GetModelName() )

	dest.SetFullBodygroup( source.GetFullBodygroup() )

	if ( !HasDamageStates( dest ) )
	{
		dest.s.damageStateInfo <- null
		dest.s.critBoxes <- null
		dest.s.hitBoxToBodyGroup <- null
		dest.s.hasHitData <- null
		dest.s.skeletonData <- null
	}

	dest.s.hasHitData = source.s.hasHitData
	dest.s.damageStateInfo = source.s.damageStateInfo
	dest.s.critBoxes = source.s.critBoxes
	dest.s.hitBoxToBodyGroup = source.s.hitBoxToBodyGroup
	dest.s.skeletonData = source.s.skeletonData
}


function HandleDeathPackage( entity, damageInfo )
{
	// Code will disallow ragdoll in some cases, such on a player that is inside a dying titan.
	if ( !damageInfo.IsRagdollAllowed() )
		return

	if ( damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.round_end )
		return

	local dpFlags = damageInfo.GetCustomDamageType()

	//PrintDamageFlags( dpFlags )

	if ( entity.HasKey( "deathScriptFuncName" ) && entity.kv.deathScriptFuncName != "" )
	{
		local exceptions = ( dpFlags & DF_DISSOLVE ) && !( entity.GetClassname() in disallowDissolveList )
		exceptions = exceptions || ( dpFlags & DF_GIB && GetGibModel( entity ) )

		if ( !exceptions )
			return
	}

	local forceRagdoll = false
	if ( "forceRagdollDeath" in entity.s )
		forceRagdoll = entity.s.forceRagdollDeath

	if ( damageInfo.GetDamageType() == DMG_CLUB )
	{
		local attacker = damageInfo.GetAttacker()
		if ( entity.IsHuman() && attacker && attacker.IsTitan() )
			forceRagdoll = true
		else
			damageInfo.SetDeathPackage( "knockback" )
	}

	if ( dpFlags <= 0 && !forceRagdoll )
	{
		if ( entity.IsTitan() )
		{
			// titan explodes!
			PlayFXOnEntity( TITAN_EXPLOSION_EFFECT, entity, "exp_torso_main" )

			if ( !( "silentDeath" in entity.s ) )
				EmitSoundOnEntity( entity, "titan_death_explode" )

			GibTitan( entity, damageInfo )
		}

		return
	}

	if ( !( "silentDeath" in entity.s ) )
	{
		//pain sounds in _base_gametype.nut, death sounds in _death_package.nut
		if ( dpFlags & DF_TITAN_STEP )
			PlayCrushingDeathSound( entity )
		else if ( dpFlags & DF_DISSOLVE )
			PlayDissolvingDeathSound( entity, damageInfo )
		else
			PlayDeathSound( entity, damageInfo )
	}

	if ( (dpFlags & DF_SPECTRE_GIB) && entity.IsSpectre() )
	{
		local gibModel = GetGibModel( entity )
		if ( gibModel )
		{
			local forceVec = damageInfo.GetDamageForce()
			local velocityMag = forceVec.Length()
			forceVec.Normalize()

			local kg = 225 // assume specters weigh 500 pounds
			velocityMag /= kg
			velocityMag /= 5.0 // assume gibs are 1/5th body sized or so

			entity.Gib( gibModel, forceVec * velocityMag, false )
		}
	}

	if ( dpFlags & ( DF_RAGDOLL ) || forceRagdoll )
	{
		local forceVec = damageInfo.GetDamageForce()
		local forceMag = forceVec.Normalize()
		const MAX_FORCE = 19999
		if ( forceMag > MAX_FORCE )
			forceMag = MAX_FORCE

		entity.BecomeRagdoll( forceVec * forceMag )
		return
	}

	if ( dpFlags & DF_INSTANT )
		damageInfo.SetDeathPackage( "instant" )
	else if ( dpFlags & DF_LONG )
		damageInfo.SetDeathPackage( "long" )
	else if ( dpFlags & ( DF_KNOCK_BACK | DF_TITAN_STEP ) )
		damageInfo.SetDeathPackage( "knockback" )

	local onFire = (dpFlags & DF_FIRE) ? true : false
	local playedPinkMistSound = false

	if ( entity.IsTitan() )
	{
		// no explode on current melees
		if ( dpFlags & DF_MELEE )
			return

		// titan explodes!
		PlayFXOnEntity( TITAN_EXPLOSION_EFFECT, entity, "exp_torso_main" )

		if ( !( "silentDeath" in entity.s ) )
				EmitSoundOnEntity( entity, "titan_death_explode" )

		//if ( dpFlags & DF_TITAN_GIB )
		//{

			GibTitan( entity, damageInfo )
			return
		//}
	}
	else
	{
		if ( dpFlags & DF_DISSOLVE && ( !(entity.GetClassname() in disallowDissolveList ) ) )
		{
			local gibModel = GetGibModel( entity )
			if ( dpFlags & DF_GIB && gibModel )
			{
				entity.Dissolve( ENTITY_DISSOLVE_PINKMIST, Vector( 0, 0, 0 ), 500 )
			}
			else
			{
				entity.Dissolve( ENTITY_DISSOLVE_CORE, Vector( 0, 0, 0 ), 500 )
			}
			playedPinkMistSound = true
		}
	}

	if ( dpFlags & DF_GIB )
	{
		local gibModel = GetGibModel( entity )
		if ( gibModel )
		{
			local forceVec = damageInfo.GetDamageForce()
			local velocityMag = forceVec.Length()
			forceVec.Normalize()

			local kg = 90 // assume specters weigh 200 pounds
			velocityMag /= kg
			velocityMag /= 5.0 // assume gibs are 1/5th body sized or so

			if ( !playedPinkMistSound )
				EmitSoundOnEntity( entity, "death.pinkmist" )

			entity.Gib( gibModel, forceVec * velocityMag, onFire )
		}
	}
}

function GibTitan( titan, damageInfo )
{
	if ( !HasHitData( titan ) )
		return

	HideTitanEye( titan )

	damageInfo.SetDeathPackage( "instant" )

	local entKVs = titan.CreateTableFromModelKeyValues()
	local hitData = entKVs["hit_data"]

	foreach ( bodyGroupName, bodyGroupData in hitData )
	{
		if ( !("blank" in bodyGroupData) )
			continue

		local bodyGroupIndex = titan.FindBodyGroup( bodyGroupName )
		local stateCount = titan.GetBodyGroupModelCount( bodyGroupIndex )
		titan.SetBodygroup( bodyGroupIndex, stateCount - 1 )
	}

//	EmitSoundOnEntity( titan, "titan_death_explode" ) // moved to client side on bodygroup chang
}
Globalize( GibTitan )

function DoomTitan( titan )
{
	if ( !HasHitData( titan ) )
		return

	HideTitanEye( titan )

	local entKVs = titan.CreateTableFromModelKeyValues()
	local hitData = entKVs["hit_data"]

	foreach ( bodyGroupName, bodyGroupData in hitData )
	{
		local hasBlank = ("blank" in bodyGroupData)

		local bodyGroupIndex = titan.FindBodyGroup( bodyGroupName )
		local stateCount = titan.GetBodyGroupModelCount( bodyGroupIndex )

		if ( hasBlank )
			stateCount -= 1

		thread DelayedBodyGroupBreak( titan, bodyGroupIndex, stateCount - 1 )
		//titan.SetBodygroup( bodyGroupIndex, stateCount - 1 )
	}
}
Globalize( DoomTitan )

function DelayedBodyGroupBreak( titan, bodyGroupIndex, stateIndex )
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )

	wait RandomFloat( 0, 4 )

	titan.SetBodygroup( bodyGroupIndex, stateIndex )
}


function ExplodeTitanBits( titan )
{
	if ( !HasHitData( titan ) )
		return

	local entKVs = titan.CreateTableFromModelKeyValues()
	local hitData = entKVs["hit_data"]

	HideTitanEye( titan )

	foreach ( bodyGroupName, bodyGroupData in hitData )
	{
		local hasBlank = ("blank" in bodyGroupData)

		local bodyGroupIndex = titan.FindBodyGroup( bodyGroupName )
		local stateCount = titan.GetBodyGroupModelCount( bodyGroupIndex )

		if ( hasBlank )
			stateCount -= 1

		titan.SetBodygroup( bodyGroupIndex, stateCount - 1 )
	}
}


function UpdateDamageState( ent, damageInfo )
{
	if ( !HasHitData( ent ) )
		return

	local hitBox = damageInfo.GetHitBox()
	local bodyGroup = GetBodyGroupForHitbox( ent, hitBox )

	if ( !bodyGroup )
		return

	local damage = damageInfo.GetDamage()

	if ( IsBodyGroupBroken( ent, bodyGroup ) )
	{
		local originalBodyGroup = bodyGroup
		foreach ( siblingName in ent.s.skeletonData[bodyGroup].siblings )
		{
			if ( IsBodyGroupBroken( ent, siblingName ) )
				continue

			bodyGroup = siblingName
			break
		}

		if ( bodyGroup == originalBodyGroup )
			return

		// randomize the sibling array so that next time the damage has a chance to go to a different sibling
		ArrayRandomize( ent.s.skeletonData[originalBodyGroup].siblings )
	}

	if ( ent.IsTitan() )
	{
		if ( !damageInfo.GetAttacker().IsTitan() && !IsHitEffective( damageInfo.GetCustomDamageType() ) )
			return

		local breakFrac = GetNumBrokenLimbs( ent ) / 4.0 // max limbs
		local checkFrac = GraphCapped( breakFrac, 1.0, 0.0, 0.15, TITAN_DAMAGE_STAGE_1 )

		if ( checkFrac < GetHealthFrac( ent ) )
			return

		ent.s.damageStateInfo[bodyGroup] = 1
	}
	else
	{
		ent.s.damageStateInfo[bodyGroup] += damageInfo.GetDamage()

		if ( !IsBodyGroupBroken( ent, bodyGroup ) )
			return
	}

	local bodyGroupIndex = ent.FindBodyGroup( bodyGroup )

	// JFS
	if ( bodyGroupIndex == -1 )
	{
		// TODO: added error report
		//Assert( bodyGroupIndex != -1, bodyGroup + " " + hitBox + " " + ent.GetModelName() )
		return
	}

	local stateCount = GetStateCountForBodyGroup( ent, bodyGroup )
	local bodyGroupState = ent.GetBodyGroupState( bodyGroupIndex )

	if ( bodyGroupState >= (stateCount - 1) )
		return

	if ( !ent.IsTitan() )
		ent.s.damageStateInfo[bodyGroup] = 0

	ent.SetBodygroup( bodyGroupIndex, bodyGroupState + 1 )
}


function GetNumBrokenLimbs( titan )
{
	local brokenLimbs = 0

	if ( titan.s.damageStateInfo["right_leg"] )
		brokenLimbs++
	if ( titan.s.damageStateInfo["left_leg"] )
		brokenLimbs++
	if ( titan.s.damageStateInfo["right_arm"] )
		brokenLimbs++
	if ( titan.s.damageStateInfo["left_arm"] )
		brokenLimbs++

	return brokenLimbs
}

function IsBodyGroupBroken( ent, bodyGroupName )
{
	if ( ent.IsTitan() )
		return ( ent.s.damageStateInfo[bodyGroupName] )
	else
		return ( ent.s.damageStateInfo[bodyGroupName] > ( ent.GetMaxHealth() * TITAN_DAMAGE_STATE_ARMOR_HEALTH ) )
}


function GetStateCountForBodyGroup( ent, bodyGroupName )
{
	local bodyGroupIndex = ent.FindBodyGroup( bodyGroupName )
	local entKVs = ent.CreateTableFromModelKeyValues()
	local hitData = entKVs["hit_data"]

	local stateCount = ent.GetBodyGroupModelCount( bodyGroupIndex )

	if ( "blank" in hitData[bodyGroupName] )
		stateCount--

	return stateCount
}


function GetBodyGroupForHitbox( ent, hitBox )
{
	if ( !(hitBox in ent.s.hitBoxToBodyGroup) )
		return null

	return ent.s.hitBoxToBodyGroup[hitBox]
}


function GetTagsForBodyGroup( ent, bodyGroupName )
{
	local entKVs = ent.CreateTableFromModelKeyValues()

	local hitData = entKVs["hit_data"]

	local bodyGroupData = hitData[bodyGroupName]

	local tags = []

	foreach ( k, v in bodyGroupData )
	{
		if ( k.find( "tag" ) == null )
			continue

		tags.append( v )
	}

	return tags
}


function GetGibModel( entity )
{
	if ( entity.IsHuman() )
		return "models/gibs/human_gibs.mdl"

	if ( entity.IsSpectre() )
		return "models/gibs/human_gibs.mdl"

	return null
}


function PlayCrushingDeathSound( entity )
{
	if ( entity.IsSpectre() || entity.IsMarvin() )
	{
		EmitSoundOnEntity( entity, TITAN_SPECTRE_SQUISH )
		return
	}

	//Not a spectre, is either a pilot or soldier
	EmitSoundOnEntity( entity, TITAN_GRUNT_SQUISH ) //Sounds like flesh being crushed

	if ( entity.IsSoldier() )
	{
		if ( entity.GetTeam() == TEAM_IMC )
			EmitSoundOnEntity( entity, "diag_imc_titansquish_01" )
		else if ( entity.GetTeam() == TEAM_MILITIA )
			EmitSoundOnEntity( entity, "diag_mcor_titansquish_01" )
		else Assert( false, "Grunt : " + entity + " is neither IMC nor Militia" )
	}

	if ( entity.IsPlayer() )
	{
		if ( IsPlayerMalePilot( entity ) ) {
			EmitSoundOnEntity( entity, "diag_mcor_titansquish_01" ) //Use MCOR grunt ones for males
        }
        else if ( IsPlayerFemalePilot( entity ) )
			EmitSoundOnEntity( entity, "diag_female_titansquish" )
	}


}


function PlayDissolvingDeathSound( entity, damageInfo )
{
	local entClassname = entity.GetClassname()
	if ( entClassname == "npc_marvin" || entClassname == "npc_spectre" )
		EmitSoundOnEntity( entity, MARVIN_DISSOLVE_DEATH )
	else if ( !entity.IsTitan() )
		EmitSoundOnEntity( entity, HUMAN_DISSOLVE_DEATH )
	else
		PlayDeathSound( entity, damageInfo )
}


function PlayDeathSound( entity, damageInfo )
{
	local customDamageType = damageInfo.GetCustomDamageType()

	if ( !entity.IsSoldier() )
	{
		if ( entity.IsSpectre() )
		{
			if ( IsValidHeadShot( damageInfo, entity ) )
			{
				local attacker = damageInfo.GetAttacker()
				local isTitan = IsValid( attacker ) && attacker.IsTitan()

				if ( isTitan )
				{
					EmitSoundOnEntityExceptToPlayer( entity, attacker, "Android.Heavy.BulletImpact_Headshot_3P_vs_3P" )
				}
				else
				{
					if ( customDamageType & DF_SHOTGUN )
						EmitSoundOnEntityExceptToPlayer( entity, attacker, "Android.Shotgun.BulletImpact_HeadShot_3P_vs_3P" )
					else
						EmitSoundOnEntityExceptToPlayer( entity, attacker, "Android.Light.BulletImpact_Headshot_3P_vs_3P" )
				}
			}
		}
		return
	}

	if ( entity.IsSoldier() )
	{
		if ( IsValidHeadShot( damageInfo, entity ) )
		{
			local attacker = damageInfo.GetAttacker()
			local isTitan = IsValid( attacker ) && attacker.IsTitan()
			if ( isTitan )
			{
				EmitSoundOnEntityExceptToPlayer( entity, attacker, "Flesh.Heavy.BulletImpact_Headshot_3P_vs_3P" )
			}
			else
			{
				if ( customDamageType & DF_SHOTGUN )
					EmitSoundOnEntityExceptToPlayer( entity, attacker, "Flesh.Shotgun.BulletImpact_Headshot_3P_vs_3P" )
				else
					EmitSoundOnEntityExceptToPlayer( entity, attacker, "Flesh.Light.BulletImpact_Headshot_3P_vs_3P" )
			}

			return
		}

		local randomGruntNumber = RandomInt( 1, 5 )
		local team = entity.GetTeam()
		local teamString
		if ( team == TEAM_IMC )
		{
			teamString = "imc"
		}
		else if ( team == TEAM_MILITIA )
		{
			teamString = "mcor"
		}
		else
		{
			printt( "Warning, entity has unknown team: ", entity.GetTeam(), entity.GetClassname(), entity.GetModelName() )
			return
		}

		local deathSound = "diag_" + teamString + "_grunt" + randomGruntNumber + "_gs_death_01" //Example of full string is diag_imc_grunt1_gs_death_01

		EmitSoundOnEntity( entity, deathSound )
	}
}

function PrintDamageFlags( flags )
{
	local table =
	{
		[DF_GIB					] = "::DF_GIB",
		[DF_DISSOLVE			] = "::DF_DISSOLVE",
		[DF_FIRE				] = "::DF_FIRE",
		[DF_INSTANT				] = "::DF_INSTANT",
		[DF_LONG				] = "::DF_LONG",
		[DF_TITAN_GIB			] = "::DF_TITAN_GIB",
		[DF_SKIPS_DOOMED_STATE	] = "::DF_SKIPS_DOOMED_STATE",
		[DF_IMPACT				] = "::DF_IMPACT",
		[DF_AT_ROCKET			] = "::DF_AT_ROCKET",
		[DF_RAGDOLL				] = "::DF_RAGDOLL",
		[DF_TITAN_STEP 			] = "::DF_TITAN_STEP",
		[DF_NO_TITAN_DMG 		] = "::DF_NO_TITAN_DMG",
		[DF_ELECTRICAL 			] = "::DF_ELECTRICAL",
		[DF_BULLET 				] = "::DF_BULLET",
		[DF_EXPLOSION			] = "::DF_EXPLOSION",
		[DF_MELEE				] = "::DF_MELEE",
		[DF_NO_INDICATOR		] = "::DF_NO_INDICATOR",
		[DF_DOOMED_HEALTH_LOSS	] = "::DF_DOOMED_HEALTH_LOSS",
		[DF_KNOCK_BACK			] = "::DF_KNOCK_BACK",
		[DF_STOPS_TITAN_REGEN	] = "::DF_STOPS_TITAN_REGEN",
		[DF_NO_FLINCH			] = "::DF_NO_FLINCH",
		[DF_MAX_RANGE			] = "::DF_MAX_RANGE",
		[DF_SHIELD_DAMAGE		] = "::DF_SHIELD_DAMAGE",
		[DF_CRITICAL			] = "::DF_CRITICAL",
		[DF_SPECTRE_GIB			] = "::DF_SPECTRE_GIB",
		[DF_HEADSHOT			] = "::DF_HEADSHOT",
		[DF_VORTEX_REFIRE		] = "::DF_VORTEX_REFIRE",
		[DF_RODEO				] = "::DF_RODEO",
		[DF_BURN_CARD_WEAPON	] = "::DF_BURN_CARD_WEAPON",
		[DF_KILLSHOT			] = "::DF_KILLSHOT",
		[DF_SHOTGUN				] = "::DF_SHOTGUN",
		[DF_NO_HITBEEP			] = "::DF_NO_HITBEEP"
	}

	foreach( key, value in table )
	{
		if ( flags & key )
		{
			printt( "Damage Flag: " + value + " was set" )
		}
	}

}
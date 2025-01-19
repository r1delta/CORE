
const VERBOSE_DAMAGE_PRINTOUTS = false

// TODO: Get an equivalent callback happening on the client, so we can stop using ServerCallback_PlayerTookDamage which is always out of date to some degree.
function CodeCallback_DamagePlayerOrNPC( ent, damageInfo )
{
	if ( VERBOSE_DAMAGE_PRINTOUTS )
	{
		printt( "CodeCallback_DamagePlayerOrNPC ent:", ent )
		printt( "    Original damage:", damageInfo.GetDamage() )
	}

	local entIsPlayer = ent.IsPlayer()
	local entIsTitan = ent.IsTitan()

	if ( !ScriptCallback_ShouldEntTakeDamage( ent, damageInfo ) )
	{
		// EMP triggers on damage, but in some cases players are invlunerable (embark, disembark, etc...)
		if ( entIsPlayer && damageInfo.GetDamageSourceIdentifier() in level._empForcedCallbacks )
		{
			local attacker = damageInfo.GetAttacker()
			if ( ShouldPlayEMPEffectEvenWhenDamageIsZero( ent, attacker ) )
				EMPGrenade_DamagedPlayerOrNPC( ent, damageInfo )
		}

		damageInfo.SetDamage( 0 )
		return
	}

	local attacker = damageInfo.GetAttacker()
	local inflictor = damageInfo.GetInflictor()

	if ( damageInfo.GetDamageSourceIdentifier() == eDamageSourceId.titan_step )
		HandleFootstepDamage( ent, damageInfo )

	// HACK helps trap/grenade weapons do damage to the correct entities (player who deployed it as well as the team opposite his)
	if ( IsValid( inflictor ) && "originalOwner" in inflictor.s )
	{
		local ogOwner = inflictor.s.originalOwner
		if ( IsValid( ogOwner ) )
		{
			// if the victim is the guy who damaged the trap, and he is not the ogOwner...
			if ( ent == attacker && ent != ogOwner )
			{
				// HACK to do this legit we need damageInfo.SetAttacker()
				// victim should take damage from the original owner instead of the satchel attacker so he gets a kill credit
				ent.TakeDamage( damageInfo.GetDamage(), ogOwner, inflictor, { weapon = damageInfo.GetWeapon(), origin = damageInfo.GetDamagePosition(), force = damageInfo.GetDamageForce(), scriptType = damageInfo.GetCustomDamageType(), damageSourceId = damageInfo.GetDamageSourceIdentifier() } )

				// now zero out the normal damage and return
				damageInfo.SetDamage( 0 )
				return
			}
		}
	}

	if ( IsValid( inflictor ) && inflictor.IsProjectile() && entIsPlayer )
	{
		// Don't take damage from projectiles created before you where spawned.
		if ( inflictor.GetProjectileCreationTime() < ent.s.respawnTime && ( Time() - ent.s.respawnTime ) < 2.0 )
		{
			damageInfo.SetDamage( 0 )
			return
		}
	}

	// Round damage to nearest full value
	damageInfo.SetDamage( floor( damageInfo.GetDamage() + 0.5 ) )
	if ( damageInfo.GetDamage() == 0 )
		return

	if ( VERBOSE_DAMAGE_PRINTOUTS )
		printt( "    rounded damage amount:", damageInfo.GetDamage() )

	HandleLocationBasedDamage( ent, damageInfo )

	if ( VERBOSE_DAMAGE_PRINTOUTS )
		printt( "    after location based damage:", damageInfo.GetDamage() )

	// Set damage source correctly when npc grunts or titans try to melee us
	if ( attacker.IsNPC() && damageInfo.GetDamageType() == DMG_CLUB )
	{
		if ( IsValid( attacker ) )
		{
			if ( attacker.IsTitan() )
				damageInfo.SetDamageSourceIdentifier( eDamageSourceId.titan_melee )
			else if ( attacker.IsSpectre() )
				damageInfo.SetDamageSourceIdentifier( eDamageSourceId.spectre_melee )
			else
				damageInfo.SetDamageSourceIdentifier( eDamageSourceId.grunt_melee )
		}
	}

	// use AddDamageCallback( "classname", function ) to registed functions
	local className = ent.GetClassname()
	if ( className in level.damageCallbacks )
	{
		foreach ( callbackInfo in level.damageCallbacks[className] )
		{
			callbackInfo.func.acall( [callbackInfo.scope, ent, damageInfo] )
			if ( damageInfo.GetDamage() == 0 )
				return
		}
	}

	// use AddDamageByCallback( "classname", function ) to registed functions
	if ( IsValid( attacker ) )
	{
		if ( attacker.IsTitan() )
		{
			local soul = attacker.GetTitanSoul()
			if ( soul in level.titanDamageScaler )
				damageInfo.SetDamage( damageInfo.GetDamage() * level.titanDamageScaler[ soul ] )
		}

		local attackerClassName = attacker.GetClassname()
		if ( attackerClassName in level.damageByCallbacks )
		{
			foreach ( callbackInfo in level.damageByCallbacks[attackerClassName] )
			{
				callbackInfo.func.acall( [callbackInfo.scope, ent, damageInfo] )
				if ( damageInfo.GetDamage() == 0 )
					return
			}
		}
	}

	if ( VERBOSE_DAMAGE_PRINTOUTS )
		printt( "    after damage callbacks:", damageInfo.GetDamage() )

	// use AddDamageCallbackSourceID( "classname", function ) to registed functions
	local damageSourceId = damageInfo.GetDamageSourceIdentifier()
	if ( damageSourceId in level.damageCallbacksSourceID )
	{
		foreach ( callbackInfo in level.damageCallbacksSourceID[damageSourceId] )
		{
			callbackInfo.func.acall( [callbackInfo.scope, ent, damageInfo] )

			if ( damageInfo.GetDamage() == 0 )
				break
		}
	}

	if ( damageInfo.GetDamage() == 0 )
		return

	if ( VERBOSE_DAMAGE_PRINTOUTS )
		printt( "    after damageSourceID callbacks:", damageInfo.GetDamage() )

	if ( damageInfo.GetCustomDamageType() & DF_DOOMED_HEALTH_LOSS )
		damageInfo.AddDamageFlags( DAMAGEFLAG_NOPAIN )

	local savedDamage = damageInfo.GetDamage()
	local shieldDamage = 0

	if ( entIsPlayer )
	{
		shieldDamage = PlayerTookDamage( ent, damageInfo, attacker, inflictor, damageSourceId )
		if ( damageInfo.GetDamage() == 0 )
			return

		PlayerDamageFeedback( ent, damageInfo )
		savedDamage = damageInfo.GetDamage()

		if ( !entIsTitan )
			ent.SetCloakFlicker( 0.5, 0.65 )
	}
	else
	{
		if ( entIsTitan )
		{
			shieldDamage = Titan_NPCTookDamage( ent, damageInfo )
			savedDamage = damageInfo.GetDamage()
		}

		PlayerDamageFeedback( ent, damageInfo )
	}

	if ( VERBOSE_DAMAGE_PRINTOUTS )
		printt( "    After player damage mod:", damageInfo.GetDamage() )

	UpdateLastDamageTime( ent )

	ReportDevStat_TimeTillEngagement( attacker, ent, damageInfo )

	//pain sounds _base_gametype.nut, death sounds in _death_package.nut
	UpdateDamageState( ent, damageInfo )
	HandlePainSounds( ent, damageInfo )

	UpdateAttackerInfo( ent, attacker, savedDamage )

	if ( attacker.IsPlayer() && !(damageInfo.GetCustomDamageType() & DF_DOOMED_HEALTH_LOSS) )
	{
		if ( entIsTitan )
		{
			local entSoul = ent.GetTitanSoul()
			if ( attacker.currentTargetPlayerOrSoul_Ent != entSoul )
			{
				attacker.currentTargetPlayerOrSoul_Ent = ent.GetTitanSoul()

				local enemyTeam = GetOtherTeam( ent.GetTeam() )
				TitanVO_TellPlayersThatAreAlsoFightingThisTarget( attacker, entSoul, enemyTeam )
			}
			attacker.currentTargetPlayerOrSoul_LastHitTime = Time()
		}
		else if ( entIsPlayer )
		{
			attacker.currentTargetPlayerOrSoul_Ent = ent
			attacker.currentTargetPlayerOrSoul_LastHitTime = Time()
		}

		local titanSpawnDelay = GetTitanBuildTime( attacker )
		local timerCredit = 0

		if ( ShouldGiveTimerCredit( attacker, ent ) )
		{
			if ( titanSpawnDelay && IsAlive( ent ) )
			{
				if ( entIsTitan )
				{
					timerCredit = GetCurrentPlaylistVarFloat( "titan_kill_credit", 0.5 )
					if ( PlayerHasServerFlag( attacker, SFLAG_HUNTER_TITAN ) )
						timerCredit *= 2.0
				}
				else
				{
					if ( entIsPlayer )
					{
						timerCredit = GetCurrentPlaylistVarFloat( "player_kill_credit", 0.5 )
						if ( PlayerHasServerFlag( attacker, SFLAG_HUNTER_PILOT ) )
							timerCredit *= 2.5
					}
					else
					{
						if ( ent.IsSoldier() )
						{
							timerCredit = GetCurrentPlaylistVarFloat( "ai_kill_credit", 0.5 )
							if ( PlayerHasServerFlag( attacker, SFLAG_HUNTER_GRUNT ) )
								timerCredit *= 2.5
						}
						else
						if ( ent.IsSpectre() )
						{
							timerCredit = GetCurrentPlaylistVarFloat( "spectre_kill_credit", 0.5 )
							if ( PlayerHasServerFlag( attacker, SFLAG_HUNTER_SPECTRE ) )
								timerCredit *= 2.5
						}
						else
						if ( ent.IsTurret() )
						{

							timerCredit = GetCurrentPlaylistVarFloat( "megaturret_kill_credit", 0.5 )
							//No 2x burn card for shooting mega turret
						}
						else
						if ( IsEvacDropship( ent ) )
						{
							timerCredit = GetCurrentPlaylistVarFloat( "evac_dropship_kill_credit", 0.5 )
						}
					}
				}

				if ( attacker.IsTitan() && PlayerHasPassive( attacker, PAS_HYPER_CORE ) )
					timerCredit *= 2.0

				local dealtDamage = min( ent.GetHealth(), savedDamage + shieldDamage )
				timerCredit = timerCredit * (dealtDamage / ent.GetMaxHealth().tofloat())
			}

			if ( timerCredit )
				DecrementBuildTimer( attacker, timerCredit )
		}
	}

	if ( entIsTitan )
	{
		TitanDamageFlinch( ent, attacker, damageInfo )
	}

	if ( VERBOSE_DAMAGE_PRINTOUTS )
		printt( "    final damage done:", damageInfo.GetDamage() )
}

function ShouldGiveTimerCredit( attacker, victim )
{
	if ( attacker == victim )
		return

	if ( attacker.IsTitan() && attacker.GetDoomedState() )
		return false

	return true
}

function TitanDamageFlinch( ent, attacker, damageInfo )
{
	if ( damageInfo.GetCustomDamageType() & DF_DOOMED_HEALTH_LOSS )
		return

	if ( damageInfo.GetCustomDamageType() & DF_NO_FLINCH )
		return

	if ( TitanStagger( ent, damageInfo ) )
		return

	if ( damageInfo.GetDamage() >= TITAN_ADDITIVE_FLINCH_DAMAGE_THRESHOLD )
	{
		AddFlinch( ent, damageInfo )
	}
}

function GetDamageOrigin( damageInfo, victim = null )
{
	local damageSourceId = damageInfo.GetDamageSourceIdentifier()

	local inflictor = damageInfo.GetInflictor()

	if ( inflictor == level.worldspawn )
		return damageInfo.GetDamagePosition()

	local damageOrigin = IsValid( inflictor ) ? inflictor.GetOrigin() : damageInfo.GetDamagePosition()

	switch ( damageSourceId )
	{
		case eDamageSourceId.mp_weapon_laser_mine:
		case eDamageSourceId.mp_weapon_satchel:
		case eDamageSourceId.mp_weapon_proximity_mine:
			break
		case eDamageSourceId.nuclear_core:
		case eDamageSourceId.mp_titanability_smoke:
			//if ( IsValid( victim ) && victim.IsPlayer() && IsValid( victim.GetTitanSoulBeingRodeoed() ) )
			{
				damageOrigin += (RandomVecInDome( Vector( 0, 0, -1 ) ) * SMOKESCREEN_DAMAGE_OUTER_RADIUS)
				damageOrigin += Vector( 0, 0, 128 )
			}
			break
		case eDamageSourceId.switchback_trap:
			if ( IsValid( victim ) && victim.IsPlayer() )
				damageOrigin = victim.EyePosition() + (RandomVecInDome( Vector( 0, 0, -1 ) ) * SMOKESCREEN_DAMAGE_OUTER_RADIUS)
			break
		default:
			if ( damageInfo.GetAttacker() )
			{
				inflictor = damageInfo.GetAttacker()
				damageOrigin = inflictor.GetWorldSpaceCenter()
			}
			break
	}

	return damageOrigin
}


function TrackDPS( ent )
{
	ent.s.dpsTracking <- {}
	ent.s.dpsTracking.damage <- 0

	local startTime = Time()

	ent.WaitSignal( "Doomed" )

	local duration = Time() - startTime

	printt( "DPS:", ent.s.dpsTracking.damage / duration, duration )

	delete ent.s.dpsTracking
}

function UpdateDPS( ent, damageInfo )
{
	if ( ent.GetDoomedState() )
		return

	if ( !( "dpsTracking" in ent.s ) )
		thread TrackDPS( ent )

	ent.s.dpsTracking.damage += damageInfo.GetDamage()
}


function PlayerTookDamage( player, damageInfo, attacker, inflictor, damageSourceId )
{
	local hitBox = damageInfo.GetHitBox()

	local critHit = false

	if ( CritWeaponInDamageInfo( damageInfo ) )
		critHit = IsCriticalHit( attacker, player, hitBox, damageInfo.GetDamage(), damageInfo.GetDamageType() )

	local damageType = damageInfo.GetCustomDamageType()
	if ( critHit )
	{
		damageType = damageType | DF_CRITICAL
		damageInfo.SetCustomDamageType( damageType )
	}

	local weaponMods = GetWeaponModsFromDamageInfo( damageInfo )

	local eModSourceID = null
	foreach ( mod in weaponMods )
	{
		local modSourceID = GetModSourceID( mod )
		if( modSourceID != null && modSourceID in modNameStrings )
			eModSourceID = modSourceID

		if ( mod in level.burnCardWeaponModList )
		{
			damageType = damageType | DF_BURN_CARD_WEAPON
			damageInfo.SetCustomDamageType( damageType )
			break
		}
	}

	local isTitan = player.IsTitan()
	local shieldDamage = 0
	local becameDoomed = false

	if ( isTitan )
	{
		local doomedState = player.GetDoomedState()
		shieldDamage = Titan_PlayerTookDamage( player, damageInfo, attacker, critHit )
		becameDoomed = (!doomedState && player.GetDoomedState())
	}
	else
	{
		Wallrun_PlayerTookDamage( player, damageInfo, attacker )
	}

	if ( damageInfo.GetDamage() == 0  )
	{
		if ( becameDoomed ) //becameDoomed check is to make kill card come up for you even if you have auto-eject. In Titan_PlayerTookDamage we set damage to 0 if you have Auto-Eject and are doomed
			TellClientPlayerTookDamage( player, damageInfo, attacker, eModSourceID, damageType, damageSourceId, becameDoomed )

		return shieldDamage
	}

	local attackerOrigin = Vector( 0, 0, 0 )
	if ( IsValid( attacker ) )
		attackerOrigin = attacker.GetOrigin()

	local weapon = damageInfo.GetWeapon()
	if ( IsValid( weapon ) && "damagePush" in weapon.s )
	{
			local direction = player.GetOrigin() - ( weapon.GetOrigin() )
			direction.Normalize()

			PushEntWithDamageInfo( player, damageInfo, weapon.s.damagePush, direction )
	}

	// Get damage type again, because it may have been updated in one of the function calls above
	damageType = damageInfo.GetCustomDamageType()

	if ( IsAlive( player ) )
	{
		local storeEnt
		if ( isTitan )
			storeEnt = player.GetTitanSoul()
		else
			storeEnt = player

		StoreDamageHistoryAndUpdate( storeEnt, MAX_DAMAGE_HISTORY_TIME, damageInfo.GetDamage(), attackerOrigin, damageType, damageSourceId, attacker, weaponMods )
	}

	if ( !(damageInfo.GetCustomDamageType() & DF_DOOMED_HEALTH_LOSS) )
		TellClientPlayerTookDamage( player, damageInfo, attacker, eModSourceID, damageType, damageSourceId, becameDoomed )

	return shieldDamage
}

function TellClientPlayerTookDamage( player, damageInfo, attacker, eModSourceID, damageType, damageSourceId, becameDoomed )
{
	if ( !player.hasConnected )
		return

	local attackerEHandle = IsValid( attacker ) ? attacker.GetEncodedEHandle() : null
	local weaponEHandle = IsValid( damageInfo.GetWeapon() ) ? damageInfo.GetWeapon().GetEncodedEHandle() : null
	local damageOrigin = GetDamageOrigin( damageInfo, player )

	if ( player.IsTitan() )
		Remote.CallFunction_Replay( player, "ServerCallback_TitanTookDamage", damageInfo.GetDamage(), damageOrigin.x, damageOrigin.y, damageOrigin.z, damageType, damageSourceId, attackerEHandle, eModSourceID, becameDoomed )
	else
		Remote.CallFunction_Replay( player, "ServerCallback_PilotTookDamage", damageInfo.GetDamage(), damageOrigin.x, damageOrigin.y, damageOrigin.z, damageType, damageSourceId, attackerEHandle, eModSourceID )
}

// This only handles damage events. Whizbys can still cause snipercam to trigger without passing through this check.
function CodeCallBack_ShouldTriggerSniperCam( damageInfo )
{
	switch ( damageInfo.GetDamageSourceIdentifier() )
	{
		case eDamageSourceId.titan_step:
		case eDamageSourceId.titan_melee:
		case eDamageSourceId.super_electric_smoke_screen:
			return false
	}

	return true
}

function CodeCallback_ForceAIMissPlayer( npc, player )
{
	if ( GetGameState() >= eGameState.Postmatch ) //Force AI to miss when controls are frozen
		return true

	if ( player.IsTitan() )
		return false

	local lethality = Riff_AILethality()

	if ( lethality <= eAILethality.Default )
	{
		if ( GetTitanSoulBeingRodeoed( player ) != null )
			return true
	}

	if ( player.ContextAction_IsActive() )
	{
		// less chance to hit "involved" player
		return RandomFloat( 0, 1 ) >= 0.25
	}

	if ( player.IsFastPlayer() )
    {
		local frac

		switch( lethality )
		{
			case eAILethality.Default:
				if ( npc.IsSpectre() )
					frac = 0.25
				else
					frac = 0.1
				break

			case eAILethality.TD_Low:
			case eAILethality.TD_Medium:
			case eAILethality.TD_High:
			case eAILethality.High:
				frac = 0.5
				break

			case eAILethality.VeryHigh:
				frac = 0.75
				break
		}

		return RandomFloat( 0, 1 ) >= frac
    }

	return false
}

function CodeCallback_OnTouchHealthKit( ent )
{
}


function ShouldPlayEMPEffectEvenWhenDamageIsZero( ent, attacker )
{
	if ( ent.IsTitan() && IsTitanWithinBubbleShield( ent ) )
		return false

	if  ( !IsValid( attacker ) )
		return true

	if ( attacker.GetTeam() != ent.GetTeam() )
		return true

	return false
}


function CodeCallback_SpawnDummyPilot_or_Titan( isTitan )
{
	thread SpawnDummyPilotOrTitan(isTitan)
}



function SpawnDummyPilotOrTitan(isTitan)
{
	if( isTitan == false)
	{
		FlagSet( "PilotBot" )
	}
	else
	{
		FlagClear("PilotBot")
	}

	local player = GetPlayerArray()[0]
	local team = GetTeamIndex(GetOtherTeams(1 << player.GetTeam()))

	if( team == TEAM_MILITIA)
		ServerCommand( "bot_dummy -team 3" )
	else
		ServerCommand( "bot_dummy -team 2" )

}
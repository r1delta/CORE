function main()
{
	Globalize( Wallrun_AddPlayer )
	Globalize( Wallrun_OnPlayerSpawn )
	Globalize( Wallrun_OnPlayerDeath )
	Globalize( Wallrun_PlayerTookDamage )
	Globalize( Wallrun_EnforceWeaponDefaults )
	Globalize( PilotWithinBubbleShield )
	Globalize( Wallrun_GiveLoadout )
	Globalize( Wallrun_CreateCopyOfPilotModel )

	// Make weapons less effective when playing at higher difficulty.
	level.lethalityMods <- {}
	//AddLethalityMod( eAILethality.High, "mp_weapon_smart_pistol", "ai_lethality_high_hack" )
	//AddLethalityMod( eAILethality.VeryHigh, "mp_weapon_smart_pistol", "ai_lethality_very_high_hack" )
}

function Wallrun_AddPlayer( player )
{
	player.playerClassData[level.pilotClass] <- {}
}


function Wallrun_EnforceWeaponDefaults( player )
{
	if ( player.playerClassData[ level.pilotClass ].primaryWeapon )
	{
		// settings already exist
		return
	}

	// player.playerClassData[ level.pilotClass ].primaryWeapon = "mp_weapon_r97"
	// player.playerClassData[ level.pilotClass ].secondaryWeapon = "mp_weapon_sniper"

	// local table = AddEmptyOffhand()
	// table.weapon = "mp_weapon_frag_grenade"
	// local offhandTable = {}
	// offhandTable[ 0 ] <- table
	// player.playerClassData[ level.pilotClass ].offhandWeapons = offhandTable
	// player.playerClassData[ level.pilotClass ].playerSetFile = "pilot_male_fastest"
}


function Wallrun_OnPlayerSpawn( player )
{
	Wallrun_EnforceWeaponDefaults( player )

	local playerClassDataTable = GetPlayerClassDataTable( player, level.pilotClass )

	if (GetMapName() == "mp_npe")
		return

	Wallrun_GiveLoadout( player, playerClassDataTable )
}


function LegalOrigin( origin )
{
	if ( fabs( origin.x ) > 16000 )
		return false
	if ( fabs( origin.y ) > 16000 )
		return false
	if ( fabs( origin.z ) > 16000 )
		return false
	return true
}

function Wallrun_GiveLoadout( player, loadoutTable )
{
	local table = clone loadoutTable

	if ( player.IsBot() )
	{
		local bot_randomize_loadout = GetConVarInt( "bot_randomize_loadout" )
		if ( bot_randomize_loadout )
			RandomizeBotLoadout( table, false )
		OverrideBotLoadout( table, false )
	}

	UpdateLastPilotLoadout( player )

	if ( Riff_OSPState() != eOSPState.Default )
	{
		switch( Riff_OSPState() )
		{
			case eOSPState.PistolsOnly:
				table.primaryWeapon = null
				break

			case eOSPState.FirstSpawnOnly:
				if ( player.s.respawnCount > 1 )
				{
					table.primaryWeapon = null
				}
				break
		}
	}

	TakeAllPassives( player )

	OnSpawned_GivePassiveLifeLong_Pilot( player )

	if ( !LegalOrigin( player.GetOrigin() ) )
	{
		printt( "Failed to give loadout: Illegal origin" )
		return
	}


	
	local activeWeapon
	if ( table.primaryWeapon )
	{
		local mods = GetAdjustedPrimaryWeaponMods( table.primaryWeapon, table.primaryWeaponMods )
		player.GiveWeapon( table.primaryWeapon, mods )
		player.SetActiveWeapon( table.primaryWeapon )
		activeWeapon = table.primaryWeapon
	}

	if ( table.secondaryWeapon )
		player.GiveWeapon( table.secondaryWeapon )
	

	if ( table.sidearmWeapon )
	{
		player.GiveWeapon( table.sidearmWeapon )

		if ( !activeWeapon )
			activeWeapon = table.sidearmWeapon
	}

	if ( table.offhandWeapons )
	{
	    local offhands = table.offhandWeapons

	    if ( "weapon" in offhands[0] )
	    {
	    	if ( !TryAssignOffhand( player, player, offhands, 0, "weapons_pilot_offhands" ) )
		    	player.GiveOffhandWeapon( offhands[0].weapon, 0, [] )
		}
		
	    if ( "weapon" in offhands[1] )
	    {
	    	if ( !TryAssignOffhand( player, player, offhands, 1, "weapons_pilot_offhands" ) )
		    	player.GiveOffhandWeapon( offhands[1].weapon, 1, [] )
		}
		
	}

	if ( Riff_AmmoLimit() != eAmmoLimit.Default )
	{
		switch( Riff_AmmoLimit() )
		{
			case eAmmoLimit.Limited:
				local weapons = player.GetMainWeapons()
				foreach ( weapon in weapons )
				{
					local clipAmmo = player.GetWeaponAmmoMaxLoaded( weapon )

					if ( clipAmmo > 0 )
						weapon.SetWeaponPrimaryAmmoCount( clipAmmo * 2 )
				}

				local offhand = player.GetOffhandWeapon( 0 )
				if ( offhand )
				{
					local ammoLoaded = player.GetWeaponAmmoMaxLoaded( offhand )
					offhand.SetWeaponPrimaryClipCount( max( 1, ammoLoaded - 2 ) )
				}
				break

			case eAmmoLimit.None:
				local weapons = player.GetMainWeapons()
				foreach ( weapon in weapons )
				{
					weapon.SetWeaponPrimaryAmmoCount( 0 )
					
					local offhand = player.GetOffhandWeapon( 0 )
					if ( offhand )
					{
						offhand.SetWeaponPrimaryClipCount( 1 )
					}	
				}
				break
		}
	}

	if ( activeWeapon )
		player.SetActiveWeapon( activeWeapon )

	if ( table.playerSetFile )
	{
		if ( "customPlayerSettings" in player.s )
		{
			player.SetPlayerSettings( player.s.customPlayerSettings )
			player.SetPlayerPilotSettings( player.s.customPlayerSettings )
			delete player.s.customPlayerSettings
			
			local head = player.GetPlayerHeadIndex()
			SelectHead(player, head)
			return
		}

		player.SetPlayerSettings( table.playerSetFile )
		player.SetPlayerPilotSettings( table.playerSetFile )
		// *** START NEW MODEL OVERRIDE CODE ***
		// Now, explicitly determine and set the correct model using the detour function
		local modelFieldName
		if ( player.GetTeam() == TEAM_MILITIA )
		{
			modelFieldName = "bodymodel_militia"
		}
		else // Assume IMC or other default
		{
			modelFieldName = "bodymodel_imc"
		}

		// Use the provided detour function to get the correct model file name
		local correctModelName = GetPlayerSettingsFieldForClassName( table.playerSetFile, modelFieldName )

		// Check if we got a valid model name
		if ( correctModelName != null && correctModelName != "" )
		{
			// Explicitly set the player's model
			printt( "Wallrun_GiveLoadout: Setting model for player " + player + " (Team: " + player.GetTeam() + ") using " + modelFieldName + " from " + table.playerSetFile + " -> " + correctModelName )
			player.SetModel( correctModelName )
			local skin = 0
			if ( table.playerSetFile.find("female") != null )  //JFS. Hard Assumption that females are the only pilot models that are skin swaps Should come up with a more elegant way to do this.
				skin = player.GetTeam() == TEAM_MILITIA ? 1 : 0
			else
				skin = 0

			player.SetSkin( skin )
			printt("SET SKIN " + skin)

		}
		else
		{
			// Log a warning if the model couldn't be determined
			printt( "Wallrun_GiveLoadout: WARNING - Could not determine correct model name for player " + player + " using playerSetFile '" + table.playerSetFile + "' and field '" + modelFieldName + "'" )
			// Consider falling back to a default model if needed:
			// player.SetModel( "models/humans/pilots/imc_pilot_light.mdl" )
		}

	}

	local head = player.GetPlayerHeadIndex()
	if ( table.playerSetFile.find("female") != null )  //JFS. Hard Assumption that females are the only pilot models that are skin swaps Should come up with a more elegant way to do this.
		head = player.GetTeam() == TEAM_MILITIA ? 1 : 0
	else
		head = 0
	SelectHead(player, head)

	// if (level.onChangeLoadout)
	// 	level.onChangeLoadout.func.acall([level.onChangeLoadout.scope, player])
}

function AddLethalityMod( lethality, weaponName, modName )
{
	if ( !( weaponName in level.lethalityMods ) )
		level.lethalityMods[ weaponName ] <- {}

	Assert( !( lethality in level.lethalityMods[ weaponName ] ), "The weapon already has a mod for this lethality." )

	level.lethalityMods[ weaponName ][ lethality ] <- modName
}

function GetAdjustedPrimaryWeaponMods( primaryWeapon, existingMods )
{
	local mods = clone existingMods

	local aiLethality = Riff_AILethality()
	if ( primaryWeapon in level.lethalityMods )
	{
		if ( aiLethality in level.lethalityMods[ primaryWeapon ] )
		{
			local mod = level.lethalityMods[ primaryWeapon ][ aiLethality ]
			foreach ( existingMod in mods )
			{
				Assert( existingMod != mod, "Should not be possible to have this mod set at this time: " + mod )
			}
			mods.append( mod )
		}
	}

	return mods
}

function PilotWithinBubbleShield( player )
{
	if ( !IsAlive( player ) )
		return false

	if ( !player.IsPlayer() )
		return false

	if ( player.IsTitan() )
		return false

	if ( !IsAlive( player.GetPetTitan() ) )
		return false

	local soul = player.GetPetTitan().GetTitanSoul()
	if ( !IsValid( soul.bubbleShield ) )
		return false

	/*local result = Distance( soul.bubbleShield.GetOrigin(), player.GetOrigin() )
	printt( "Distance from bubble shield is ", result )*/
	return Distance( soul.bubbleShield.GetOrigin(), player.GetOrigin() ) < PILOT_BUBBLE_SHIELD_INVULNERABILITY_RANGE
}


function Wallrun_PlayerTookDamage( player, damageInfo, attacker )
{
	if ( player.IsDemigod() )
	{
		EntityDemigod_TryAdjustDamageInfo( player, damageInfo )
		return
	}

	AdjustDamageForRodeoPlayers( player, damageInfo, attacker )

	if ( VERBOSE_DAMAGE_PRINTOUTS )
		printt( "    After Wallrun_PlayerTookDamage:", damageInfo.GetDamage() )
}


function AdjustDamageForRodeoPlayers( player, damageInfo, attacker )
{
	if ( player == attacker )
		return

	local titanSoulRodeoed = GetTitanSoulBeingRodeoed( player )
	if ( !IsValid( titanSoulRodeoed ) )
		return

	local playerParent = titanSoulRodeoed.GetTitan()

	// dont let npcs hurt rodeo player
	if ( attacker.IsNPC() && attacker != playerParent && damageInfo.GetDamageSourceIdentifier() != eDamageSourceId.mp_titanability_smoke )
	{
		damageInfo.SetDamage( 0 )
		return
	}

	local damage = damageInfo.GetDamage()

	if ( !ShouldAdjustDamageForRodeoPlayer( damageInfo ) )
		return

	local maxPer500ms

	if ( attacker == playerParent )
	{
		// rodeo'd player can't damage quite as much
		maxPer500ms = 56
	}
	else
	if ( playerParent.GetTeam() == player.GetTeam() )
	{
		// riding same team titan protects you a bit from random fire on that titan
		if ( damageInfo.GetCustomDamageType() & DF_EXPLOSION )
		{
			maxPer500ms = 75
		}
		else if ( damageInfo.GetCustomDamageType() & DF_MELEE  ) //If melee, players still die in one hit
		{
			maxPer500ms = player.GetMaxHealth() + 1
		}
		else
		{
			maxPer500ms = 175
		}
	}
	else
	{
		return
	}

	//Set a cap on how much damage the playerParent can do.
	local damageTaken = GetTotalDamageTakenInTime( player, 0.5 )

	local allowedDamage = maxPer500ms - damageTaken
	if ( damage < allowedDamage )
		return

	damage = allowedDamage
	if ( damage <= 0 )
		damage = 0

	damageInfo.SetDamage( damage )
}


function ShouldAdjustDamageForRodeoPlayer( damageInfo )
{
	local sourceID = damageInfo.GetDamageSourceIdentifier()

	switch( sourceID )
	{
		case eDamageSourceId.rodeo_trap:
		case eDamageSourceId.mp_titanweapon_vortex_shield:
		case eDamageSourceId.mp_titanability_smoke:
		case eDamageSourceId.mp_weapon_satchel:	//added so that rodeoing players are no longer invulnerable to their satchels when detonated by Titan's smoke
			return false

		default:
			return true

	}
}


function Wallrun_OnPlayerDeath( player, damageInfo )
{
	if ( IsValidHeadShot( damageInfo, player ) )
	{
		local damageType = damageInfo.GetCustomDamageType()
		local soundAlias
		if ( damageType & DF_SHOTGUN )
		{
			EmitSoundOnEntityOnlyToPlayer( player, player, "Flesh.Shotgun.BulletImpact_Headshot_3P_vs_1P" )
			soundAlias = "Flesh.Shotgun.BulletImpact_Headshot_3P_vs_3P"
		}
		else if ( damageType & damageTypes.Bullet || damageType & damageTypes.SmallArms )
		{
			EmitSoundOnEntityOnlyToPlayer( player, player, "Flesh.Light.BulletImpact_Headshot_3P_vs_1P" )
			soundAlias = "Flesh.Light.BulletImpact_Headshot_3P_vs_3P"
		}
		else if ( damageType & damageTypes.LargeCaliber ||  damageType & DF_GIB  )
		{
			EmitSoundOnEntityOnlyToPlayer( player, player, "Flesh.Heavy.BulletImpact_Headshot_3P_vs_1P" )
			soundAlias = "Flesh.Heavy.BulletImpact_Headshot_3P_vs_3P"
		}

		if ( soundAlias )
		{
			local attacker = damageInfo.GetAttacker()
			local pilotArray = GetPlayerArray()
			//Iterating because we need to not play this sound on 2 pilots and the function only allows for 1. Performance difference is negligible according to Eric M between this and adding a specific code function.
			foreach ( pilot in pilotArray )
			{
				if ( !IsValid( pilot ) )
					continue

				if ( pilot == player || pilot == attacker )
					continue

				EmitSoundOnEntityOnlyToPlayer( player, pilot, soundAlias )
			}
		}
	}
}


function Wallrun_CreateCopyOfPilotModel( player )
{
	local modelName
	local playerTeam = player.GetTeam()

	local skin

	if ( player.IsTitan() )
	{
		modelName =   GetPlayerSettingsFieldForClassName( player.s.storedPlayerSettings, player.GetTeam() == TEAM_MILITIA ? "bodymodel_militia" : "bodymodel_imc" )
	}
	else
	{
		modelName =   player.GetPlayerSettingsField( player.GetTeam() == TEAM_MILITIA ? "bodymodel_militia" : "bodymodel_imc" )
	}

	local model = CreatePropDynamic( modelName )

	model.SetTeam( player.GetTeam() )

	local skin
	local head = player.GetPlayerHeadIndex()
	if ( table.playerSetFile.find("female") != null )  //JFS. Hard Assumption that females are the only pilot models that are skin swaps Should come up with a more elegant way to do this.
		head = player.GetTeam() == TEAM_MILITIA ? 1 : 0
	else
		head = 0

	if ( PlayerIsFemale( player ) && !PlayerHasSpectreCamo( player ) )  //JFS. Hard Assumption that females are the only pilot models that are skin swaps Should come up with a more elegant way to do this.
		skin = player.GetPlayerModelSkinIndex()
	else
		skin = 0

	model.SetSkin( skin )

	SelectHead(model, head)

	return model
}

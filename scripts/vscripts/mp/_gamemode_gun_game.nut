function main()
{
	IncludeScript( "mp/_free_for_all" )

	AddCallback_PlayerOrNPCKilled( GunGame_OnPlayerOrNPCKilled )
	AddCallback_OnChangeLoadout( GunGame_OnChangeLoadout )

	thread dumbbullshit()
}

function dumbbullshit() // EntitiesDidLoad
{
	FlagWait( "EntitiesDidLoad" )

	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	level.gunGameWeapons <- []
	level.ampedGunGame <- RandomInt( 0, 1000 ) == 0

	Weapon_SetDespawnTime( 0 )

	local className
	local numWeapons = PersistenceGetEnumCount( "loadoutItems" )
	for ( local i = 0 ; i < numWeapons ; i++ )
	{
		className = PersistenceGetEnumItemNameForIndex( "loadoutItems", i )
		if ( className == "NULL" )
			continue

		AddSpawnCallback( className, GunGame_CleanupWeapon )

		if ( className == WEAPON_THROWING_KNIFE_NAME )
			continue

		local type = GetItemType( className )
		if ( type == itemType.PILOT_PRIMARY || type == itemType.PILOT_SECONDARY || type == itemType.PILOT_SIDEARM )
			level.gunGameWeapons.append( className )
	}

	ArrayRandomize( level.gunGameWeapons )
	level.gunGameWeapons.append( WEAPON_THROWING_KNIFE_NAME )
}

function GunGame_OnPlayerOrNPCKilled( victim, attacker, damageInfo )
{
	if ( GetGameState() >= eGameState.WinnerDetermined )
		return

	TakeAllWeapons( victim )

	if ( !victim.IsPlayer() )
		return

	if ( !attacker.IsPlayer() )
		return

	if ( ShouldPreventFriendlyFire( victim, attacker ) )
		return

	local weapon = attacker.GetActiveWeapon()
	if ( !weapon )
		return

	if ( weapon.GetClassname() != GetCurrentGunGameWeaponForPlayer( attacker ) )
	{
		thread GiveNextGunGameWeapon( attacker )
		return
	}

	local scoreLimit = GetScoreLimit_FromPlaylist()

	local damageSourceID = damageInfo.GetDamageSourceIdentifier()
	if ( damageSourceID == eDamageSourceId.human_execution )
	{
		local victimScore = victim.GetAssaultScore()
		if ( victimScore > 2 )
			victim.SetAssaultScore( victimScore - 2 )
	}
	else if ( damageSourceID == eDamageSourceId.mp_weapon_mega5 ) // Throwing knife
	{
		attacker.SetAssaultScore( scoreLimit )
		return
	}

	local score = attacker.GetAssaultScore()
	attacker.SetAssaultScore( score + 1 )

	if ( score < scoreLimit )
		thread GiveNextGunGameWeapon( attacker )
}

function GunGame_OnChangeLoadout( player, loadoutTable, isTitan )
{
	TakeAllPassives( player )

	thread GiveNextGunGameWeapon( player )
}

function GiveNextGunGameWeapon( player )
{
	wait 0.1

	local score = player.GetAssaultScore()
	if ( score > GetScoreLimit_FromPlaylist() || score > level.gunGameWeapons.len() - 1 )
		return

	local amped = level.ampedGunGame

	TakeAllWeapons( player )

	if ( amped )
	{
		player.Signal( "SonarDeactivate" )
		player.GiveOffhandWeapon( "mp_ability_heal", 1, [ "bc_super_stim" ] )
	}
	else
		player.GiveOffhandWeapon( "mp_ability_heal", 1 )

	local weapon = GetCurrentGunGameWeaponForPlayer( player )
	local attachment = amped ? GetAmpedGunGameAttachment( weapon ) : GetGunGameAttachment( weapon )

	if ( attachment != "" )
	{
		if ( type( attachment ) == "string" )
			player.GiveWeapon( weapon, [ attachment ] )
		else
			player.GiveWeapon( weapon, attachment )
	}
	else
		player.GiveWeapon( weapon )
}

function GetCurrentGunGameWeaponForPlayer( player )
{
	local score = clamp( player.GetAssaultScore(), 0, level.gunGameWeapons.len() - 1 )
	return level.gunGameWeapons[ score ]
}
Globalize( GetCurrentGunGameWeaponForPlayer )

function GetGunGameAttachment( weapon )
{
	local attachment = "iron_sights"
	switch ( weapon )
	{
		case "mp_weapon_shotgun":
		case WEAPON_TWINB_NAME:
		case "mp_weapon_autopistol":
		case "mp_weapon_semipistol":
		case "mp_weapon_smart_pistol":
		case "mp_weapon_wingman":
		case "mp_weapon_smr":
		case "mp_weapon_defender":
		case WEAPON_THROWING_KNIFE_NAME:
			attachment = ""
			break

		case "mp_weapon_dmr":
		case "mp_weapon_sniper":
		case WEAPON_VALKYRIE_NAME:
			attachment = "aog"
			break
		
		case "mp_weapon_rocket_launcher":
			attachment = "guided_missile"
			break

		case "mp_weapon_mgl":
			attachment = [ "burn_mod_mgl", "gun_game" ]
			break
	}

	return attachment
}

function GetAmpedGunGameAttachment( weapon )
{
	local attachment = ""
	switch ( weapon )
	{
		case "mp_weapon_rspn101":
			attachment = "burn_mod_rspn101"
			break

		case "mp_weapon_r97":
			attachment = "burn_mod_r97"
			break

		case "mp_weapon_hemlok":
			attachment = "burn_mod_hemlok"
			break

		case "mp_weapon_g2":
			attachment = "burn_mod_g2"
			break

		case "mp_weapon_lmg":
			attachment = "burn_mod_lmg"
			break

		case "mp_weapon_car":
			attachment = "burn_mod_car"
			break

		case "mp_weapon_shotgun":
			attachment = "burn_mod_shotgun"
			break

		case WEAPON_TWINB_NAME:
			attachment = "burn_mod_twinb"
			break

		case "mp_weapon_autopistol":
			attachment = "burn_mod_autopistol"
			break

		case "mp_weapon_semipistol":
			attachment = "burn_mod_semipistol"
			break

		case "mp_weapon_smart_pistol":
			attachment = "burn_mod_smart_pistol"
			break

		case "mp_weapon_wingman":
			attachment = "burn_mod_wingman"
			break

		case "mp_weapon_smr":
			attachment = "burn_mod_smr"
			break

		case "mp_weapon_defender":
			attachment = "burn_mod_defender"
			break

		case WEAPON_THROWING_KNIFE_NAME:
			attachment = "burn_mod_throwing_knife"
			break

		case "mp_weapon_dmr":
			attachment = "burn_mod_dmr"
			break

		case "mp_weapon_sniper":
			attachment = "burn_mod_sniper"
			break

		case WEAPON_VALKYRIE_NAME:
			attachment = "burn_mod_valkyrie"
			break
		
		case "mp_weapon_rocket_launcher":
			attachment = [ "burn_mod_rocket_launcher", "guided_missile" ]
			break

		case "mp_weapon_mgl":
			attachment = [ "burn_mod_mgl", "gun_game" ]
			break
	}

	return attachment
}

function GunGame_CleanupWeapon( weapon )
{
	thread GunGame_CleanupWeaponThink( weapon )
}

function GunGame_CleanupWeaponThink( weapon )
{
	wait 0.1

	if ( !IsValid( weapon ) )
		return

	if ( !weapon.GetOwner() || !IsAlive( weapon.GetOwner() ) )
		weapon.Kill()
}

main()

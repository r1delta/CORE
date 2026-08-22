function main()
{
	AddCallback_PlayerOrNPCKilled( GunGame_OnPlayerOrNPCKilled )
	AddCallback_OnChangeLoadout( GunGame_OnChangeLoadout )

	AddDeathCallback( "npc_soldier", GunGame_NPCCleanupWeapon )
	AddDeathCallback( "npc_spectre", GunGame_NPCCleanupWeapon )

	level.spawnRatingFunc_Pilot = RateSpawnpoint_Generic
	level.spawnRatingFunc_Generic = RateSpawnpoint_Generic

	SetFFABased( true )
	thread FFAOwnedNPCRelationshipMonitor()
}

function EntitiesDidLoad()
{
	SetupAssaultPointKeyValues()

	//no turrets in TDM for now
	local turrets = GetNPCArrayByClass( "npc_turret_sentry" )
	foreach( turret in turrets )
	{
		turret.DisableTurret()
	}

	//monitor population and respawns
	thread SetupTeamDeathmatchNPCs()
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	level.gunGameWeapons <- []

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

	if ( attacker.GetActiveWeapon().GetClassname() != GetCurrentGunGameWeaponForPlayer( attacker ) )
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

	TakeAllWeapons( player )

	local weapon = GetCurrentGunGameWeaponForPlayer( player )
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
		case "mp_weapon_mgl":
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
	}

	if ( attachment != "" )
		player.GiveWeapon( weapon, [ attachment ] )
	else
		player.GiveWeapon( weapon )
}

function GetCurrentGunGameWeaponForPlayer( player )
{
	local score = clamp( player.GetAssaultScore(), 0, level.gunGameWeapons.len() - 1 )
	return level.gunGameWeapons[ score ]
}
Globalize( GetCurrentGunGameWeaponForPlayer )

function GunGame_CleanupWeapon( weapon )
{
	thread GunGame_CleanupWeaponThink( weapon )
}

function GunGame_NPCCleanupWeapon( npc, damageInfo )
{
	local weapon = npc.GetActiveWeapon()
	if ( !IsValid( weapon ) )
		return

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

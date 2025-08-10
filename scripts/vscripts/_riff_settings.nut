function main()
{
	Globalize( Riff_TitanAvailability )
	Globalize( Riff_SpawnAsTitan )
	Globalize( Riff_ShouldSpawnAsTitan )
	Globalize( Riff_IsTitanAvailable )
	Globalize( Riff_AllowNPCs )
	Globalize( Riff_AILethality )
	Globalize( Riff_MinimapState )
	Globalize( Riff_OSPState )
	Globalize( Riff_AmmoLimit )
	Globalize( Riff_EliminationMode )

	if ( !IsServer() )
		return

	level.damageModifierForAiLethality <- {}

	SetupDamageModifiersForAiLethality()

	Globalize( Riff_ForceSetSpawnAsTitan )
	Globalize( Riff_ForceTitanAvailability )

	local spawnAsTitan = GetCurrentPlaylistVarInt( "riff_spawn_as_titan", eSpawnAsTitan.Default )
	Assert( spawnAsTitan < eSpawnAsTitan.LastSpawnAsTitan )
	level.nv.spawnAsTitan = spawnAsTitan

	local titanAvailability = GetCurrentPlaylistVarInt( "riff_titan_availability", eTitanAvailability.Default )
	Assert( titanAvailability < eTitanAvailability.LastTitanAvailability )
	level.nv.titanAvailability = titanAvailability

	local allowNPCs = GetCurrentPlaylistVarInt( "riff_allow_npcs", eAllowNPCs.Default )
	Assert( allowNPCs < eAllowNPCs.LastAllowNPCs )
	level.nv.allowNPCs = allowNPCs

	local aiLethality = GetCurrentPlaylistVarInt( "riff_ai_lethality", eAILethality.Default )
	Assert( aiLethality < eAILethality.LastAILethality )
	level.nv.aiLethality = aiLethality

	local minimapState = GetCurrentPlaylistVarInt( "riff_minimap_state", eMinimapState.Default )
	Assert( minimapState < eMinimapState.LastMinimapState )
	level.nv.minimapState = minimapState

	local ospState = GetCurrentPlaylistVarInt( "riff_osp", eOSPState.Default )
	Assert( ospState < eOSPState.LastOSPState )
	level.nv.ospState = ospState

	local ammoLimit = GetCurrentPlaylistVarInt( "riff_ammo_limit", eAmmoLimit.Default )
	Assert( ammoLimit < eAmmoLimit.LastAmmoLimit )
	level.nv.ammoLimit = ammoLimit

	local eliminationMode = GetCurrentPlaylistVarInt( "riff_elimination", eEliminationMode.Default )
	Assert( eliminationMode < eEliminationMode.LastEliminationMode )
	level.nv.eliminationMode = eliminationMode

	local floorIsLava = GetCurrentPlaylistVarInt( "riff_floorislava", eFloorIsLava.Default )
	Assert( floorIsLava < eFloorIsLava.LastFloorIsLava )
	level.nv.floorIsLava = floorIsLava

	level.titanAvailabilityCheck <- function( player ) { return false }

	switch ( aiLethality )
	{
		case eAILethality.High:
		case eAILethality.TD_Medium:
		case eAILethality.TD_High:
			NPCSetAimConeFocusParams( 2, 0.4 )
			NPCSetAimPatternFocusParams( 0.5, 0.5, 2 )
			break
		case eAILethality.VeryHigh:
			NPCSetAimConeFocusParams( 2, 0.2 )
			NPCSetAimPatternFocusParams( 0.5, 0.3, 2 )
			break
	}
}

function SetupDamageModifiersForAiLethality()
{
//	AddDamageModifierForAiLethality( eDamageSourceId.mp_weapon_yh803_bullet, eAILethality.TD_Medium, "npc_soldier", 2.0 )
//	AddDamageModifierForAiLethality( eDamageSourceId.mp_weapon_yh803_bullet, eAILethality.TD_High, "npc_soldier", 1.0 )
//	AddDamageModifierForAiLethality( eDamageSourceId.mp_weapon_yh803_bullet, eAILethality.TD_Medium, "npc_spectre", 2.0 )
//	AddDamageModifierForAiLethality( eDamageSourceId.mp_weapon_yh803_bullet, eAILethality.TD_High, "npc_spectre", 1.0 )

	// mini turrets
	AddDamageModifierForAiLethality( eDamageSourceId.mp_weapon_yh803_bullet, eAILethality.TD_Medium, "npc_dropship", 0.15 )

	// emp grenade
	AddDamageModifierForAiLethality( eDamageSourceId.mp_weapon_grenade_emp, eAILethality.TD_High, "npc_spectre", 0.8 )
	AddDamageModifierForAiLethality( eDamageSourceId.mp_weapon_grenade_emp, eAILethality.High, "npc_spectre", 0.8 )
	AddDamageModifierForAiLethality( eDamageSourceId.mp_weapon_grenade_emp, eAILethality.VeryHigh, "npc_spectre", 0.6 )

	// arc cannon
	AddDamageModifierForAiLethality( eDamageSourceId.mp_titanweapon_arc_cannon, eAILethality.TD_High, "npc_spectre", 0.75 )
	AddDamageModifierForAiLethality( eDamageSourceId.mp_titanweapon_arc_cannon, eAILethality.High, "npc_spectre", 0.75 )
	AddDamageModifierForAiLethality( eDamageSourceId.mp_titanweapon_arc_cannon, eAILethality.VeryHigh, "npc_spectre", 0.61 )
}


function Riff_ForceSetSpawnAsTitan( eState )
{
	Assert( eState < eSpawnAsTitan.LastSpawnAsTitan )
	level.nv.spawnAsTitan = eState
}


function Riff_ForceTitanAvailability( eState )
{
	Assert( eState < eTitanAvailability.LastTitanAvailability )
	level.nv.titanAvailability = eState
}


function Riff_AmmoLimit()
{
	return GetServerVar( "ammoLimit" )
}

function Riff_FloorIsLava()
{
	return GetServerVar( "floorIsLava" )
}
Globalize( Riff_FloorIsLava )

function Riff_OSPState()
{
	return GetServerVar( "ospState" )
}


function Riff_MinimapState()
{
	return GetServerVar( "minimapState" )
}


function Riff_AILethality()
{
	return GetServerVar( "aiLethality" )
}


function Riff_SpawnAsTitan()
{
	return GetServerVar( "spawnAsTitan" )
}


function Riff_TitanAvailability()
{
	return GetServerVar( "titanAvailability" )
}


function Riff_AllowNPCs()
{
	return GetServerVar( "allowNPCs" )
}


function Riff_EliminationMode()
{
	return GetServerVar( "eliminationMode" )
}


function Riff_ShouldSpawnAsTitan( player )
{
	switch ( GetServerVar( "spawnAsTitan" ) )
	{
		case eSpawnAsTitan.Always:
			return true

		case eSpawnAsTitan.Never:
			return false

		case eSpawnAsTitan.Once:
			return (player.s.respawnCount == 0)

		default:
			Assert( 0, "Should not query this when setting is default" )
	}
}


function Riff_IsTitanAvailable( player )
{
	switch ( GetServerVar( "titanAvailability" ) )
	{
		case eTitanAvailability.Always:
			return true

		case eTitanAvailability.Custom:
			return level.titanAvailabilityCheck( player )

		case eTitanAvailability.Never:
				return false

		case eTitanAvailability.Once:
			return (player.titansBuilt == 0)

		default:
			Assert( 0, "Should not query this when setting is default" )
	}
}

function ShouldIntroSpawnAsTitan()
{
	return ( Riff_SpawnAsTitan() == eSpawnAsTitan.Always || Riff_SpawnAsTitan() == eSpawnAsTitan.Once )
}
Globalize( ShouldIntroSpawnAsTitan )

function AddDamageModifierForAiLethality( id, aiLethality, classname, multiplier )
{
	Assert( "damageModifierForAiLethality" in level )

	if ( !( id in level.damageModifierForAiLethality ) )
	{
		level.damageModifierForAiLethality[id] <- {}
		AddDamageCallbackSourceID( id, ModifyDamageForAiLethality )
	}

	if ( !( classname in level.damageModifierForAiLethality[id] ) )
		level.damageModifierForAiLethality[id][classname] <- {}

	Assert( !( aiLethality in level.damageModifierForAiLethality[id][classname] ) )
	level.damageModifierForAiLethality[id][classname][aiLethality] <- multiplier
}

// use AddDamageModifierForAiLethality( damageSourceId, aiLethality, classname, multiplier ) to register damage multipliers
function ModifyDamageForAiLethality( ent, damageInfo )
{
	local damageSourceId = damageInfo.GetDamageSourceIdentifier()
	Assert( damageSourceId in level.damageModifierForAiLethality )

	local aiLethality = Riff_AILethality()
	local classname = ent.GetClassname()

	if ( !( classname in level.damageModifierForAiLethality[damageSourceId] ) )
		return

	if ( !( aiLethality in level.damageModifierForAiLethality[damageSourceId][classname] ) )
		return

	local multiplier = level.damageModifierForAiLethality[damageSourceId][classname][aiLethality]
	local newDamage = damageInfo.GetDamage() * multiplier
	damageInfo.SetDamage( newDamage )
}
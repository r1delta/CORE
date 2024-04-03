const NUKE_TITAN_PLAYER_DETECT_RANGE 	= 500
const NUKE_TITAN_RANGE_CHECK_SLEEP_SECS = 1.0
const NUKE_TITAN_DAMAGES_OTHER_NPCS = false

function main()
{
	AddDamageCallback( "npc_titan", AutoTitan_NuclearPayload_DamageCallback )
}


function SpawnNukeTitan( origin, angles, team )
{
	local table 	= CreateDefaultNPCTitanTemplate( team )
	table.title 	= "#NPC_TITAN_NUKE"
	table.origin 	= origin
	table.angles 	= angles
	table.model 	= OGRE_MODEL
	table.settings  = "titan_ogre"

	local randomMod = RandomInt( 0, 100 ) <= 40 //40 % chance
	SetRandomWeaponOnTitanTemplate( table, randomMod )

	local titan = SpawnNPCTitan( table )
	titan.Minimap_SetEnemyMaterial( "vgui/hud/coop/minimap_coop_nuke_titan" )
	titan.Minimap_SetAlignUpright( true )
	titan.Minimap_SetZOrder( 10 )

	//titan.PreferSprint( true )
	//titan.NoForceWalk( true )
	titan.kv.faceEnemyWhileMovingDistSq = 500 * 500
	titan.SetMoveSpeedScale( 0.8 )

	NPC_SetNuclearPayload( titan, true )
	titan.SetSubclass( eSubClass.nukeTitan )
	titan.s.nukeTitanDamagesOtherTitans <- NUKE_TITAN_DAMAGES_OTHER_NPCS

	GiveTitanTacticalAbility( titan, TAC_ABILITY_VORTEX )

	return titan
}
Globalize( SpawnNukeTitan )


function AutoTitan_SelfDestruct( titan )
{
	thread TitanEjectPlayer( titan )
}
Globalize( AutoTitan_SelfDestruct )


// intercept damage to nuke titans in damage callback so we can nuke them before death 100% of the time
function AutoTitan_NuclearPayload_DamageCallback( titan, damageInfo )
{
	if ( !IsAlive( titan ) )
		return

	local titanOwner = titan.GetBossPlayer()
	if ( IsValid( titanOwner ) )
	{
		Assert( titanOwner.IsPlayer() )
		Assert( GetPlayerTitanInMap( titanOwner ) == titan )
		return
	}

	local nuclearPayload = NPC_GetNuclearPayload( titan )
	if ( !nuclearPayload )
		return

	if ( !titan.GetDoomedState() )
		return

	if ( titan.GetTitanSoul().IsEjecting() )
		return

	// - if a player titan is nearby, try to nuke right next to him
	if ( !AutoTitan_IsPlayerTitanInRange( titan, NUKE_TITAN_PLAYER_DETECT_RANGE ) )
	{
		// Otherwise try to nuke at a semirandom doomed state health fraction. (Like a player, more random.)
		if ( !( "doomedStateNukeTriggerHealth" in titan.s ) )
		{
			local lowEnd = floor( ( titan.GetMaxHealth() * 0.95 ) + 0.5 )
			local highEnd = floor( ( titan.GetMaxHealth() * 0.99 ) + 0.5 )

			titan.s.doomedStateNukeTriggerHealth <- RandomInt( lowEnd, highEnd )
		}

		if ( titan.GetHealth() > titan.s.doomedStateNukeTriggerHealth )
		{
			//printt( "titan health:", titan.GetHealth(), "health to nuke:", titan.s.doomedStateNukeTriggerHealth )
			return
		}

		printt( "NUKE TITAN DOOMED TRIGGER HEALTH REACHED, NUKING! Health:", titan.s.doomedStateNukeTriggerHealth )
	}
	else
	{
		printt( "PLAYER TITAN IN RANGE, NUKING!" )
	}

	thread TitanEjectPlayer( titan )
}

function AutoTitan_IsPlayerTitanInRange( autoTitan, maxDist )
{
	// Distance checks are expensive, don't do them as often as a damage callback could happen (every frame)
	if ( !AutoTitan_CanDoRangeCheck( autoTitan ) )
		return false

	local testOrg = autoTitan.GetOrigin()
	foreach ( player in GetPlayerArray() )
	{
		local playerTitan = player
		if ( !player.IsTitan() )
		{
			playerTitan = GetPlayerTitanInMap( player )

			if ( !playerTitan )
				continue
		}

		if ( Distance( testOrg, playerTitan.GetOrigin() ) <= maxDist )
			return true
	}

	return false
}

function AutoTitan_CanDoRangeCheck( autoTitan )
{
	if ( !( "nextPlayerTitanRangeCheckTime" in autoTitan.s ) )
		autoTitan.s.nextPlayerTitanRangeCheckTime <- -1

	if ( Time() < autoTitan.s.nextPlayerTitanRangeCheckTime )
	{
		return false
	}
	else
	{
		autoTitan.s.nextPlayerTitanRangeCheckTime = Time() + NUKE_TITAN_RANGE_CHECK_SLEEP_SECS
		return true
	}
}

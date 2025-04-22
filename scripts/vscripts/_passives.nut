function main()
{
	Globalize( InitPassives )
	Globalize( GivePassive )
	Globalize( GivePassiveLifeLong )
	Globalize( GiveTitanPassiveLifeLong )
	Globalize( TakePassive )
	Globalize( TakeAllPassives )
	Globalize( UpdateMinimapStatus ) // moves to minimap script eventually?
	Globalize( ScanMinimap )
	Globalize( MinimapPlayerConnected )
	Globalize( OnSpawned_GivePassiveLifeLong_Pilot )
	Globalize( SoulHasPassive )
	Globalize( ScanMinimapUntilDeath )
	Globalize( GivePlayerPassivesFromSoul )
	Globalize( PrintAllPassives )

	Globalize( IsConscript )

	AddSpawnCallback( "npc_spectre", MinimapNPCSpawned )
	AddSpawnCallback( "npc_soldier", MinimapNPCSpawned )
	AddDeathCallback( "player", PassiveDeathCallback )

	level.wifiLeachInterval <- 2.5
	switch ( Riff_AILethality() )
	{
		case eAILethality.TD_Medium:
		case eAILethality.TD_High:
		case eAILethality.High:
			break
		case eAILethality.VeryHigh:
//			level.wifiLeachInterval = 2.5
			break
	}

}

function InitPassives( player )
{
	player.s.removePassiveOnDeath <- {}
}

function GivePassive( player, passive )
{
	if ( IsSoul( player ) )
	{
		local soul = player
		Assert( passive in level.titanPassives, "This is not a titan passive" )
		soul.passives = AddBitMask( soul.passives, passive )

		local titan = soul.GetTitan()
		if ( IsValid( titan ) && titan.IsPlayer() )
			GiveTitanPassiveLifeLong( titan, passive ) //This actually loops back around to GivePassive
		return
	}

	//printt( "give passive " + PassiveEnumFromBitfield( passive ) )
	local passives = AddBitMask( player.GetPassives(), passive )
	player.SetPassives( passives )

	// enter/exit functions for specific passives
	switch ( passive )
	{
		case PAS_MINIMAP_AI:
		case PAS_MINIMAP_ALL:
		case PAS_MINIMAP_PLAYERS:
			UpdateMinimapStatus( player )
			break

		case PAS_CONSCRIPT:
			thread PlayerConscription( player )
			break

		case PAS_WIFI_SPECTRE:
			thread PlayerSpectreWifi( player )
			break

		case PAS_POWER_CELL:
			player.GiveExtraWeaponMod( "pas_power_cell" )
			break

		case PAS_DEFENSIVE_CORE:
			player.GiveExtraWeaponMod( "pas_defensive_core" )
			break

		case PAS_RUN_AND_GUN:
			player.GiveExtraWeaponMod( "pas_run_and_gun" )
			break

		case PAS_ORDNANCE_PACK:
			player.GiveExtraWeaponMod( "pas_ordnance_pack" )
			break

		case PAS_FAST_RELOAD:
			player.GiveExtraWeaponMod( "pas_fast_reload" )
			break

		case PAS_ASSAULT_REACTOR:
			player.GiveExtraWeaponMod( "mod_ordnance_core" )
			break

		case PAS_MARATHON_CORE:
			player.GiveExtraWeaponMod( "mod_marathon_core" )
			break
	}
}

function GetPassiveName( passive )
{
	local passiveNameFromBitField = TableInvert( level.passiveBitfieldFromEnum )

	if ( !( passive in passiveNameFromBitField ) )
	{
		printt( "Passive bitfield: " + passive + " does not exist" )
		return null
	}

	return passiveNameFromBitField[ passive ]

}

function TakePassive( player, passive )
{
	if ( IsSoul( player ) )
	{
		local soul = player
		Assert( passive in level.titanPassives, "This is not a titan passive" )
		soul.passives = RemoveBitMask( soul.passives, passive )
		local titan = soul.GetTitan()
		if ( IsValid( titan ) && titan.IsPlayer() )
			TakePassive( titan, passive )
		return
	}

	//printt( "take passive " + PassiveEnumFromBitfield( passive ) )
	local passives = RemoveBitMask( player.GetPassives(), passive )
	player.SetPassives( passives )

	// enter/exit functions for specific passives
	switch ( passive )
	{
		case PAS_MINIMAP_AI:
		case PAS_MINIMAP_ALL:
		case PAS_MINIMAP_PLAYERS:
			UpdateMinimapStatus( player )
			break

		case PAS_POWER_CELL:
			player.TakeExtraWeaponMod( "pas_power_cell" )
			break

		case PAS_DEFENSIVE_CORE:
			player.TakeExtraWeaponMod( "pas_defensive_core" )
			break

		case PAS_RUN_AND_GUN:
			player.TakeExtraWeaponMod( "pas_run_and_gun" )
			break

		case PAS_ORDNANCE_PACK:
			player.TakeExtraWeaponMod( "pas_ordnance_pack" )
			break

		case PAS_FAST_RELOAD:
			player.TakeExtraWeaponMod( "pas_fast_reload" )
			break

		case PAS_ASSAULT_REACTOR:
			player.TakeExtraWeaponMod( "mod_ordnance_core" )
			break

		case PAS_MARATHON_CORE:
			player.TakeExtraWeaponMod( "mod_marathon_core" )
			break
	}
}

function PassiveDeathCallback( player, damageInfo )
{
	foreach ( passive in player.s.removePassiveOnDeath )
	{
		TakePassive( player, passive )
	}

	player.s.removePassiveOnDeath = {}
}

function GivePassiveLifeLong( player, passive )
{
	//Note: Badness happens if a burn card with passive tries to give a server flag!
	Assert( !( passive in level.titanPassives ), "This is a titan passive" )

	// give the passive for one life
	player.s.removePassiveOnDeath[ passive ] <- passive
	GivePassive( player, passive )
}

function GiveTitanPassiveLifeLong( player, passive )
{
	Assert( passive in level.titanPassives, "This is a titan passive" )

	// give the passive for one life
	player.s.removePassiveOnDeath[ passive ] <- passive
	GivePassive( player, passive )
}

function TakeAllPassives( player )
{
	local currentPassives = player.GetPassives()
	foreach( passiveName, passiveBit in level.passiveBitfieldFromEnum )
	{
		if ( currentPassives & passiveBit )
			TakePassive( player, passiveBit )
	}

	player.SetPassives( 0 )
	player.s.removePassiveOnDeath = {}
}

function OnSpawned_GivePassiveLifeLong_Pilot( player )
{
	local table = GetPlayerClassDataTable( player, level.pilotClass )

	if ( table.passive1 )
	{
		GivePassiveLifeLong( player, table.passive1 )
	}
	if ( table.passive2 )
	{
		GivePassiveLifeLong( player, table.passive2 )
	}
	local cardRef = GetActiveBurnCard( player )//GetActiveBurnCard( player )
	if ( cardRef )
	{
		local passive = GetBurnCardPassive( cardRef )//GetBurnCardPassive( cardRef )
		if ( passive )
			GivePassive( player, passive )
	}
}

function GivePlayerPassivesFromSoul( player, soul )
{
	Assert( player == soul.GetTitan() )

	local currentPassives = soul.passives
	foreach( passiveName, passiveBit in level.passiveBitfieldFromEnum ) //Since this is just a bitmask, we could just add all the soul's passives directly instead of trying to break it down to its components first like we do here. However, while it is less efficent, it's also easier to debug.
	{
		if ( currentPassives & passiveBit )
			GiveTitanPassiveLifeLong( player, passiveBit )
	}

}

function GetRevealParms( player )
{
	local table = {}

	local passives = player.GetPassives()

	if ( passives & PAS_MINIMAP_ALL )
	{
		table.ai <- true
		table.players <- true
		table.titans <- true
	}
	else
	{
		table.titans <- false

		if ( passives & PAS_MINIMAP_PLAYERS )
			table.players <- true
		else
			table.players <- false

		if ( passives & PAS_MINIMAP_AI )
			table.ai <- true
		else
			table.ai <- false
	}

	return table
}

function UpdateMinimapStatusToOtherPlayers( player )
{
	local team = player.GetTeam()
	local players = GetPlayerArray()
	foreach ( otherPlayer in players )
	{
		// teammates are on minimap by default
		if ( team == otherPlayer.GetTeam() )
			continue

		local reveal = GetRevealParms( otherPlayer )
		if ( reveal.players )
		{
			player.Minimap_AlwaysShow( TEAM_MILITIA, otherPlayer )
			player.Minimap_AlwaysShow( TEAM_IMC, otherPlayer )

		}
	}
}
Globalize( UpdateMinimapStatusToOtherPlayers )

function UpdateTitanMinimapStatusToOtherPlayers( titan )
{
	local team = titan.GetTeam()
	local players = GetPlayerArray()
	foreach ( otherPlayer in players )
	{
		// teammates are on minimap by default
		if ( team == otherPlayer.GetTeam() )
			continue

		local reveal = GetRevealParms( otherPlayer )
		if ( reveal.titans )
		{
			titan.Minimap_AlwaysShow( TEAM_IMC, otherPlayer )
			titan.Minimap_AlwaysShow( TEAM_MILITIA, otherPlayer )
		}
	}
}
Globalize( UpdateTitanMinimapStatusToOtherPlayers )

function UpdateAIMinimapStatusToOtherPlayers( guy )
{
	local team = guy.GetTeam()
	local players = GetPlayerArray()
	foreach ( otherPlayer in players )
	{
		// teammates are on minimap by default
		if ( team == otherPlayer.GetTeam() )
			continue

		local reveal = GetRevealParms( otherPlayer )
		if ( reveal.ai )
		{
			guy.Minimap_AlwaysShow( TEAM_IMC, otherPlayer )
			guy.Minimap_AlwaysShow( TEAM_MILITIA, otherPlayer )
		}
	}
}
Globalize( UpdateAIMinimapStatusToOtherPlayers )

function UpdateMinimapStatus( player )
{
	local team = player.GetTeam()
	local reveal = GetRevealParms( player )

	local players = GetPlayerArray()
	if ( reveal.players )
	{
		foreach ( target in players )
		{
			if ( team != target.GetTeam() )
			{
				player.Minimap_AlwaysShow( TEAM_IMC, target )
				player.Minimap_AlwaysShow( TEAM_MILITIA, target )
			}
		}
	}
	else
	{
		foreach ( target in players )
		{
			if ( team != target.GetTeam() )
			{
				player.Minimap_DisplayDefault( TEAM_IMC, target )
				player.Minimap_DisplayDefault( TEAM_MILITIA, target )
			}
		}
	}

	local titans  = GetNPCArrayByClass( "npc_titan" )
	if ( reveal.titans )
	{
		foreach ( target in titans )
		{
			if ( team != target.GetTeam() )
			{
				player.Minimap_AlwaysShow( TEAM_IMC, target )
				player.Minimap_AlwaysShow( TEAM_MILITIA, target )
			}
		}
	}
	else
	{
		foreach ( target in titans )
		{
			if ( team != target.GetTeam() )
			{
				player.Minimap_DisplayDefault( TEAM_IMC, target )
				player.Minimap_DisplayDefault( TEAM_MILITIA, target )
			}
		}
	}

	local ai = GetNPCArrayByClass( "npc_soldier" )
	ai.extend( GetNPCArrayByClass( "npc_spectre" ) )

	if ( reveal.ai )
	{
		foreach ( target in ai )
		{
			if ( team != target.GetTeam() )
			{
				player.Minimap_AlwaysShow( TEAM_IMC, target )
				player.Minimap_AlwaysShow( TEAM_MILITIA, target )
			}
		}
	}
	else
	{
		foreach ( target in ai )
		{
			if ( team != target.GetTeam() )
			{
				player.Minimap_DisplayDefault( TEAM_IMC, target )
				player.Minimap_DisplayDefault( TEAM_MILITIA, target )
			}
		}
	}

//	foreach ( target in ai )
//	{
//		if ( target.GetBossPlayer() == player )
//			target.Minimap_AlwaysShow( 0, player )
//	}
}

function ScanMinimapUntilDeath( player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )
	for ( ;; )
	{
 		thread ScanMinimap( player )
 		wait 10.0
 	}
}

function ScanMinimap( player )
{
	// already has the passive?
	if ( PlayerHasPassive( player, PAS_MINIMAP_ALL ) )
		return

	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )

	EmitSoundOnEntity( player, "AngelCity_Scr_SearchLaserSweep"	)
	local handle = player.GetEncodedEHandle()
	Remote.CallFunction_Replay( player, "ServerCallback_MinimapPulse", handle )

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
				TakePassive( player, PAS_MINIMAP_ALL )
		}
	)

	GivePassive( player, PAS_MINIMAP_ALL )
	EmitSoundOnEntityOnlyToPlayer( player, player, "BurnCard_SatUplink_Ping" )
	wait 3.0
}

function MinimapNPCSpawned( guy )
{
	// show up on minimap for player that has the passive

	local team = guy.GetTeam()
	local otherTeam = GetOtherTeam( team )
	local players = GetPlayerArrayOfTeam( otherTeam )
	foreach ( player in players )
	{
		if ( !PlayerRevealsNPCs( player ) )
			continue

		guy.Minimap_AlwaysShow( TEAM_IMC, player )
		guy.Minimap_AlwaysShow( TEAM_MILITIA, player )
	}
}

function PlayerRevealsPlayers( player )
{
	local passives = player.GetPassives()
	if ( passives & PAS_MINIMAP_PLAYERS )
		return true
	return passives & PAS_MINIMAP_ALL
}

function MinimapPlayerConnected( guy )
{
	local team = guy.GetTeam()
	local otherTeam = GetOtherTeam( team )
	local players = GetPlayerArrayOfTeam( otherTeam )
	foreach ( player in players )
	{
		if ( !PlayerRevealsPlayers( player ) )
			continue

		guy.Minimap_AlwaysShow( TEAN_IMC, player )
		guy.Minimap_AlwaysShow( TEAM_MILITIA, player )
	}
}

function PlayerSpectreWifi( player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )

	for ( ;; )
	{
		if ( !PlayerHasPassive( player, PAS_WIFI_SPECTRE ) )
			return

		LeechSurroundingSpectres( player.GetOrigin(), player )

		wait level.wifiLeachInterval
	}
}

const CLEAR_CONSCRIPTED_GRUNTS_ON_DEATH = false

function PlayerConscription( player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )

	if ( CLEAR_CONSCRIPTED_GRUNTS_ON_DEATH )
	{
		if ( "conscriptedGrunts" in player.s )
			return

		local conscriptedGrunts
		if ( "conscriptedGrunts" in player.s )
		{
			conscriptedGrunts = player.s.conscriptedGrunts
		}
		else
		{
			conscriptedGrunts = {}
			player.s.conscriptedGrunts <- conscriptedGrunts
		}

		OnThreadEnd(
			function () : ( player, conscriptedGrunts )
			{
				ClearConscriptedGrunts( player, conscriptedGrunts )
			}
		)
	}

	for ( ;; )
	{
		if ( !PlayerHasPassive( player, PAS_CONSCRIPT ) )
			return

		if ( IsAlive( player ) )
		{
			ConscriptNearbyGrunts( player )
		}
		wait 1.5
	}
}

function ConscriptNearbyGrunts( player )
{
	local team = player.GetTeam()
	local grunts = GetNPCArrayEx( "npc_soldier", team, player.GetOrigin(), 220 )

	foreach ( grunt in grunts )
	{
		if ( !IsValid( grunt ) )
			continue

		if ( IsAlive( grunt.GetBossPlayer() ) )
			continue

		ConscriptGruntSquad( grunt, player, team )
		wait 0
	}
}

function ConscriptGrunt( grunt, player, team )
{
	EmitSoundOnEntity( grunt, "BurnCard_Conscription_TurnSoldier" )
	grunt.Signal( "StopHardpointBehavior" )
	grunt.SetTeam( team )
	grunt.SetBossPlayer( player )
	grunt.SetTitle( "#NPC_CONSCRIPT" )
	grunt.s.preventOwnerDamage <- true

	UpdatePlayerStat( player, "misc_stats", "gruntsConscripted", 1 )

	if ( CLEAR_CONSCRIPTED_GRUNTS_ON_DEATH )
	{
		player.s.conscriptedGrunts[ grunt ] <- grunt
		// printt( player + " Conscripted " + grunt + " to squadname " + grunt.kv.squadname )
	}
}

function MakePlayerSquad( player )
{
	local squad = "player" + player.entindex() + "gruntSquad"
	local index = 0
	local squadName = squad + index
	for ( ;; )
	{
		if ( GetNPCSquadSize( squadName ) == 0 )
			return squadName

		index++
		squadName = squad + index
	}
}

function ConscriptGruntSquad( grunt, player, team )
{
	local grunts
	local gruntSquad = grunt.Get( "squadname" )
	if ( gruntSquad == "" )
	{
		grunts = [ grunt ]
	}
	else
	{
		grunts = GetNPCArrayBySquad( gruntSquad )
	}

	foreach ( guy in grunts )
	{
		if ( IsAlive( guy.GetBossPlayer() ) )
			continue
		if ( guy.GetTeam() != team )
			continue

		ConscriptGrunt( guy, player, team )
	}
}

function ClearConscriptedGrunts( player, conscriptedGrunts )
{
	foreach ( grunt in conscriptedGrunts )
	{
		if ( !IsAlive( grunt ) )
			continue

		local owner = grunt.GetBossPlayer()
		if ( IsValid( owner ) && owner != player )
			continue

		grunt.ClearBossPlayer()
		delete grunt.s.preventOwnerDamage
		local model = grunt.GetModelName()
		local team
		if ( model.find( "imc" ) != null )
		{
			team = TEAM_IMC
		}
		else
		{
			team = TEAM_MILITIA
		}

		SetGruntTitleFromTeam( grunt, team )
		grunt.Signal( "StopHardpointBehavior" )
		grunt.SetTeam( team )
	}

	delete player.s.conscriptedGrunts
}

function IsConscript( guy )
{
	return IsAlive( guy.GetBossPlayer() )
}


function SoulHasPassive( soul, passive )
{
	return soul.passives & passive
}

function PrintAllPassives( player )
{
	local passives = player.GetPassives()

	foreach( passiveName, passiveBit in level.passiveBitfieldFromEnum )
	{
		if ( passiveBit & passives )
			printt( "Player " + player + " has passive: " + passiveName )
	}
}

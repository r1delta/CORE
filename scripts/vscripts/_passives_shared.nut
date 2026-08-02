//::PAS_						<- 0x00001
::PAS_MINIMAP_ALL				<- 0x00002		// sees enemies on minimap
::PAS_SHIELD_REGEN				<- 0x00004
::PAS_MINIMAP_PLAYERS			<- 0x00008 		// sees players on minimap
::PAS_MINIMAP_AI				<- 0x00010

//::PAS_BURST_BOOSTERS			<- 0x00011 //i bet this is behind the occasional crash
//::PAS_PILOT_LINK			<- 0x00012 //becomes passive "18"
//::PAS_DUAL_TACTICAL				<- 0x00014

::PAS_ENHANCED_TITAN_AI			<- 0x00020
::PAS_LONGER_BUBBLE				<- 0x00040
::PAS_DASH_RECHARGE				<- 0x00080
::PAS_AUTO_EJECT				<- 0x00100
::PAS_DOOMED_TIME				<- 0x00200
::PAS_NUCLEAR_CORE				<- 0x00400
::PAS_TURBO_DROP				<- 0x00800
::PAS_TITAN_PUNCH				<- 0x01000
::PAS_CONSCRIPT					<- 0x02000
::PAS_DETECT_RESPAWN 			<- 0x04000
::PAS_FUSION_CORE 				<- 0x08000
::PAS_STEALTH_MOVEMENT			<- 0x10000		//Have quieter pilot movement sounds
::PAS_ORDNANCE_PACK				<- 0x20000		// Carry 1 extra ordnance ammo ( frag, satchel, etc )
::PAS_POWER_CELL				<- 0x40000		// Pilot LB abilities recharge faster
::PAS_DEFENSIVE_CORE			<- 0x80000		// Titan LB defensive abilities recharge faster
::PAS_RUN_AND_GUN				<- 0x100000
::PAS_WIFI_SPECTRE				<- 0x200000
::PAS_FAST_HACK					<- 0x400000
::PAS_DEAD_MANS_TRIGGER 		<- 0x800000
::PAS_SHIELD_BOOST				<- 0x1000000
::PAS_WALL_RUNNER				<- 0x2000000
::PAS_FAST_RELOAD				<- 0x4000000
::PAS_AUTO_SONAR				<- 0x8000000
::PAS_ASSAULT_REACTOR			<- 0x10000000
::PAS_HYPER_CORE				<- 0x20000000
::PAS_MARATHON_CORE				<- 0x40000000
::PAS_BUILD_UP_NUCLEAR_CORE		<- 0x80000000
// No more allowed... there are only 32 bits. nu uh

//::PAS_BURST_BOOSTERS			<- 0x00000011 //i bet this is behind the occasional crash
//::PAS_FLIGHT_CORE
//::PAS_DUAL_ORDNANCE				<- 0x00000012 //moved upwards
//::PAS_DUAL_TACTICAL				<- 0x00000014

level.passiveBitfieldFromEnum <- {}

level.passiveBitfieldFromEnum[ "pas_shield_regen" ]				<- PAS_SHIELD_REGEN
level.passiveBitfieldFromEnum[ "pas_wall_runner" ]				<- PAS_WALL_RUNNER
level.passiveBitfieldFromEnum[ "pas_minimap_all" ]				<- PAS_MINIMAP_ALL
level.passiveBitfieldFromEnum[ "pas_minimap_players" ]			<- PAS_MINIMAP_PLAYERS
level.passiveBitfieldFromEnum[ "pas_minimap_ai" ]				<- PAS_MINIMAP_AI
level.passiveBitfieldFromEnum[ "pas_enhanced_titan_ai" ]		<- PAS_ENHANCED_TITAN_AI
level.passiveBitfieldFromEnum[ "pas_longer_bubble" ]			<- PAS_LONGER_BUBBLE
level.passiveBitfieldFromEnum[ "pas_dash_recharge" ]			<- PAS_DASH_RECHARGE
level.passiveBitfieldFromEnum[ "pas_auto_eject" ]				<- PAS_AUTO_EJECT
level.passiveBitfieldFromEnum[ "pas_doomed_time" ]				<- PAS_DOOMED_TIME
level.passiveBitfieldFromEnum[ "pas_turbo_drop" ]				<- PAS_TURBO_DROP
level.passiveBitfieldFromEnum[ "pas_titan_punch" ]				<- PAS_TITAN_PUNCH
level.passiveBitfieldFromEnum[ "pas_conscript" ]				<- PAS_CONSCRIPT
level.passiveBitfieldFromEnum[ "pas_detect_respawn" ]			<- PAS_DETECT_RESPAWN
level.passiveBitfieldFromEnum[ "pas_fusion_core" ]				<- PAS_FUSION_CORE
level.passiveBitfieldFromEnum[ "pas_stealth_movement" ]			<- PAS_STEALTH_MOVEMENT
level.passiveBitfieldFromEnum[ "pas_fast_hack" ]				<- PAS_FAST_HACK
level.passiveBitfieldFromEnum[ "pas_ordnance_pack" ]			<- PAS_ORDNANCE_PACK
level.passiveBitfieldFromEnum[ "pas_power_cell" ]				<- PAS_POWER_CELL
level.passiveBitfieldFromEnum[ "pas_defensive_core" ]			<- PAS_DEFENSIVE_CORE
level.passiveBitfieldFromEnum[ "pas_run_and_gun" ]				<- PAS_RUN_AND_GUN
level.passiveBitfieldFromEnum[ "pas_dead_mans_trigger" ]		<- PAS_DEAD_MANS_TRIGGER
level.passiveBitfieldFromEnum[ "pas_fast_reload" ]				<- PAS_FAST_RELOAD
level.passiveBitfieldFromEnum[ "pas_auto_sonar" ]				<- PAS_AUTO_SONAR
level.passiveBitfieldFromEnum[ "pas_assault_reactor" ]			<- PAS_ASSAULT_REACTOR
level.passiveBitfieldFromEnum[ "pas_hyper_core" ]				<- PAS_HYPER_CORE
level.passiveBitfieldFromEnum[ "pas_marathon_core" ]			<- PAS_MARATHON_CORE
level.passiveBitfieldFromEnum[ "pas_build_up_nuclear_core" ]	<- PAS_BUILD_UP_NUCLEAR_CORE
//level.passiveBitfieldFromEnum[ "pas_burst_boosters" ]			<- PAS_BURST_BOOSTERS
//level.passiveBitfieldFromEnum[ "pas_pilot_link" ]			<- PAS_PILOT_LINK
//level.passiveBitfieldFromEnum[ "pas_dual_tactical" ]			<- PAS_DUAL_TACTICAL
//level.passiveBitfieldFromEnum[ "pas_flight_core" ]				<- PAS_FLIGHT_CORE



function main()
{
	// these passives are put on the titan soul, and then given to players when they get in the titan
	// and taken away from players when they get out of a titan.
	level.titanPassives <- {}
	level.titanPassives[ PAS_DEFENSIVE_CORE ] <- true
	level.titanPassives[ PAS_SHIELD_REGEN ] <- true
	level.titanPassives[ PAS_DOOMED_TIME ] <- true
	level.titanPassives[ PAS_AUTO_EJECT ] <- true
	level.titanPassives[ PAS_DASH_RECHARGE ] <- true
	level.titanPassives[ PAS_FUSION_CORE ] <- true
//	level.titanPassives[ PAS_ENHANCED_TITAN_AI ] <- true
	level.titanPassives[ PAS_TITAN_PUNCH ] <- true
	level.titanPassives[ PAS_SHIELD_BOOST ] <- true
	level.titanPassives[ PAS_ASSAULT_REACTOR ] <- true
	level.titanPassives[ PAS_HYPER_CORE ] <- true
	level.titanPassives[ PAS_MARATHON_CORE ] <- true
	level.titanPassives[ PAS_BUILD_UP_NUCLEAR_CORE ] <- true
	//level.titanPassives[ PAS_BURST_BOOSTERS ] <- true
	//level.titanPassives[ PAS_PILOT_LINK ] <- true
	//level.titanPassives[ PAS_DUAL_TACTICAL ] <- true
	//level.titanPassives[ PAS_FLIGHT_CORE ] <- true

	level.playerSettingsPassiveEnums <- {}

	// these are player settings mods
	level.playerSettingsPassiveEnums[ level.pilotClass ] <- [
		"pas_stealth_movement",
		"pas_wall_runner"
	]

	// these are player settings mods
	level.playerSettingsPassiveEnums[ "titan" ] <- [
		"pas_dash_recharge",
		"pas_doomed_time"
		//"pas_burst_boosters",
		//"pas_flight_core"
	]


	level.passiveEnumFromBitfield <- {}
	foreach ( name, bitfield in level.passiveBitfieldFromEnum )
	{
		level.passiveEnumFromBitfield[ bitfield ] <- name
	}

	Globalize( PassiveBitfieldFromEnum )
	Globalize( PlayerRevealsNPCs )
	Globalize( PlayerHasPassive )
	Globalize( PassiveEnumFromBitfield )
	Globalize( TakeAllTitanPassives )
	Globalize( GetModsFromPlayerSettings )

	if ( IsClient() )
	{
		Globalize( ClientCodeCallback_OnPassivesChanged )
		PrecacheParticleSystem( "P_core_DMG_boost_screen" )

		level.coreColorCorrection <- ColorCorrection_Register( "materials/correction/overdrive1.raw" )
		ColorCorrection_SetExclusive( level.coreColorCorrection, false )
	}
}

function TakeAllTitanPassives( player )
{
	foreach ( passive, _ in level.titanPassives )
	{
		TakePassive( player, passive )
	}
}

if ( IsClient() )
{
	function ClientCodeCallback_OnPassivesChanged( player, oldValue )
	{
		if ( !IsValid( player ) )
			return

		local passives = player.GetPassives()

		if ( passiveStatusChanged( player, passives, oldValue, PAS_SHIELD_BOOST ) || passiveStatusChanged( player, passives, oldValue, PAS_FUSION_CORE ) )
		{
			UpdateCoreFX( player )
		}

		if ( passiveStatusChanged( player, passives, oldValue, PAS_MINIMAP_AI ) || passiveStatusChanged( player, passives, oldValue, PAS_MINIMAP_ALL ) )
		{
			UpdateOverheadIcons( player )
		}

		if ( passiveStatusChanged( player, passives, oldValue, PAS_AUTO_SONAR ) )
		{
			thread Burncard_AutoSonar( player )
		}
	}

	function RefreshPassiveStatus( player )
	{
		if ( player.GetPassives() & PAS_AUTO_SONAR )
			thread Burncard_AutoSonar( player )
	}
	Globalize( RefreshPassiveStatus )
}

function passiveStatusChanged( player, passives, oldValue, passive )
{
	if ( oldValue & passive )
	{
		return !( passives & passive )
	}
	else
	{
		return ( passives & passive )
	}
}

function PassiveBitfieldFromEnum( passive )
{
	if ( passive in level.passiveBitfieldFromEnum )
		return level.passiveBitfieldFromEnum[ passive ]
	return null
}

function PassiveEnumFromBitfield( passiveEnum )
{
	if ( passiveEnum in level.passiveEnumFromBitfield )
		return level.passiveEnumFromBitfield[ passiveEnum ]
	return null
}

function PlayerRevealsNPCs( player )
{
	local passives = player.GetPassives()

	if ( passives & PAS_MINIMAP_AI )
		return true
	return passives & PAS_MINIMAP_ALL
}

function PlayerHasPassive( player, passive )
{
	return player.GetPassives() & passive
}

function GetModsFromPlayerSettings( player, settings )
{
	local playerClass = GetPlayerSettingsFieldForClassName( settings, "class" )

	if ( !( playerClass in level.playerSettingsPassiveEnums ) )
		return []

	local mods = []

	local passives = level.playerSettingsPassiveEnums[ playerClass ]
	foreach ( passiveEnum in passives )
	{
		local passiveBitFlag = level.passiveBitfieldFromEnum[ passiveEnum ]
		if ( PlayerHasPassive( player, passiveBitFlag ) )
			mods.append( passiveEnum )
	}

	return mods
}

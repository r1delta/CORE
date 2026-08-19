function main()
{
	Globalize( AddEnergyOrb )
	Globalize( GetOrbNameFromId )

	level.energyOrbs <- {}
	level.higestID <- 0

	level.waveNames <- {}

	local mapScriptName = GetMapName() + "_orbs.nut"
	if ( ScriptExists( mapScriptName ) )
		IncludeFile( mapScriptName )

	// FlagSet( "PlayersMustRevive" ) flagset doesnt work early on client scripts?
	// level.flags[ "PlayersMustRevive" ] = true

	IncludeFile( "_COOBJ_towerdefense_waves_common" )

	Generator_SetupStatusColors()

	// Run level-specific coop setup after common setup is done
	local TD_scriptName = "mp/" + GetMapName() + "_towerdefense.nut"
	if ( ScriptExists( TD_scriptName ) )
		IncludeFile( TD_scriptName )

	// HACKY wait
	WaitEndFrame() // these vars are created after this script runs
	level.capPointPilotScoring 		= eCapPointPilotScoring.REWARD_MORE_PLAYERS
	level.capPointAIScoring 		= eCapPointAIScoring.CONTEST_ALWAYS

	level.enemyAnnounceCardInfos <- {}
	Coop_CreateEnemyAnnounceCards()
	SetWaveSpawnType( eWaveSpawnType.PLAYER_DEATH )
}


// -------------------
// ---- GENERATOR ----
// -------------------
function Generator_SetupStatusColors()
{
	if ( !reloadingScripts )
	{
		level.generatorColor_Full <- null
		level.generatorColor_Med <- null
		level.generatorColor_Low <- null
	}

	// color spectrum: goes from full to med to low. Full = 100% of meter
	level.generatorColor_Full 	= { r = 126, 	g = 188, 	b = 236} 	// blue
	level.generatorColor_Med 	= { r = 242, 	g = 172, 	b = 50 } 	// orange
	level.generatorColor_Low 	= { r = 255, 	g = 74, 	b = 44 } 	// red-orange
}

function Generator_GetHealthStatusColorTable()
{
	local healthRatio = Generator_GetHealthRatio()
	//printt( "healthRatio:", healthRatio )

	local color1 = level.generatorColor_Full
	local color2 = level.generatorColor_Med
	local color3 = level.generatorColor_Low

	local blendStartFrac 	= 0.95
	local midFrac 			= 0.6
	local blendEndFrac 		= 0.2

	local r = null
	local g = null
	local b = null
	// 1 = full meter, 0 = empty meter
	if ( healthRatio > midFrac )
	{
		r = GraphCapped( healthRatio, blendStartFrac, midFrac, color1.r, color2.r )
		g = GraphCapped( healthRatio, blendStartFrac, midFrac, color1.g, color2.g )
		b = GraphCapped( healthRatio, blendStartFrac, midFrac, color1.b, color2.b )
	}
	else
	{
		r = GraphCapped( healthRatio, midFrac, blendEndFrac, color2.r, color3.r )
		g = GraphCapped( healthRatio, midFrac, blendEndFrac, color2.g, color3.g )
		b = GraphCapped( healthRatio, midFrac, blendEndFrac, color2.b, color3.b )
	}

	return { r = r, g = g, b = b }
}
Globalize( Generator_GetHealthStatusColorTable )


function Generator_GetShieldStatusColorTable()
{
	local shieldRatio = Generator_GetShieldRatio()

	local blendStartVal = 0.9
	local blendEndVal 	= 0.25
	local colors = GraphCapped_GetColorBlend( shieldRatio, blendStartVal, blendEndVal, level.generatorColor_Full, level.generatorColor_Med )

	return colors
}
Globalize( Generator_GetShieldStatusColorTable )


// uses color tables, ex: { r = 255, g = 0, b = 0 }
//  blendStartVal 	= solid color1 until this value, where it starts blending
//  blendEndVal 	= blend to color2 until this value, where it becomes solid
function GraphCapped_GetColorBlend( inputVal, blendStartVal, blendEndVal, color1, color2 )
{
	local colors = {}
	colors.r <- GraphCapped( inputVal, blendStartVal, blendEndVal, color1.r, color2.r )
	colors.g <- GraphCapped( inputVal, blendStartVal, blendEndVal, color1.g, color2.g )
	colors.b <- GraphCapped( inputVal, blendStartVal, blendEndVal, color1.b, color2.b )

	//printt( "colorblend:", colors.r, colors.g, colors.b )

	return colors
}
Globalize( GraphCapped_GetColorBlend )


function Generator_GetShieldRatio()
{
	local shieldMaxHealth = TD_GENERATOR_SHIELD_HEALTH
	local shieldHealth = level.nv.TDGeneratorShieldHealth
	local shieldRatio = shieldHealth / shieldMaxHealth.tofloat()

	return max( 0, shieldRatio )
}
Globalize( Generator_GetShieldRatio )


function Generator_GetHealthRatio()
{
	local totalHealth = TD_GENERATOR_HEALTH
	local health = level.nv.TDGeneratorHealth
	local healthRatio = health.tofloat() / totalHealth.tofloat()

	return max( 0, healthRatio )
}
Globalize( Generator_GetHealthRatio )



// -------------------------
// ---- ENEMY ANNOUNCES ----
// -------------------------
function Coop_CreateEnemyAnnounceCards()
{
	CreateEnemyAnnounceCard( eCoopAIType.grunt, 				"#NPC_GRUNT", 					"#NPC_GRUNT_IMC_DESC", 				SCOREBOARD_MATERIAL_COOP_GRUNT, 			"burncards/burncard_art_41" )
	CreateEnemyAnnounceCard( eCoopAIType.spectre, 				"#NPC_SPECTRE", 				"#NPC_SPECTRE_DESC", 				SCOREBOARD_MATERIAL_COOP_SPECTRE, 				"burncards/burncard_art_43" )
	CreateEnemyAnnounceCard( eCoopAIType.suicideSpectre, 		"#NPC_SPECTRE_SUICIDE", 		"#NPC_SPECTRE_SUICIDE_DESC", 		SCOREBOARD_MATERIAL_COOP_SUICIDE_SPECTRE, 				"burncards/burncard_art_03" )
	CreateEnemyAnnounceCard( eCoopAIType.sniperSpectre, 		"#NPC_SPECTRE_SNIPER", 			"#NPC_SPECTRE_SNIPER_DESC", 		SCOREBOARD_MATERIAL_COOP_SNIPER_SPECTRE, 				"burncards/burncard_art_36" )
	CreateEnemyAnnounceCard( eCoopAIType.cloakedDrone, 			"#NPC_CLOAK_DRONE", 			"#NPC_CLOAK_DRONE_DESC", 			SCOREBOARD_MATERIAL_COOP_CLOAK_DRONE, 		"burncards/burncard_art_01" )
	CreateEnemyAnnounceCard( eCoopAIType.titan, 				"#NPC_TITAN", 					"#NPC_TITAN_IMC_DESC", 				SCOREBOARD_MATERIAL_COOP_TITAN, 						"burncards/burncard_art_54" )
	CreateEnemyAnnounceCard( eCoopAIType.nukeTitan, 			"#NPC_TITAN_NUKE", 				"#NPC_TITAN_NUKE_DESC", 			SCOREBOARD_MATERIAL_COOP_NUKE_TITAN, 			"burncards/burncard_art_59" )
	CreateEnemyAnnounceCard( eCoopAIType.mortarTitan, 			"#NPC_TITAN_MORTAR", 			"#NPC_TITAN_MORTAR_DESC", 			SCOREBOARD_MATERIAL_COOP_MORTAR_TITAN, 		"burncards/amped_multi_target" )
	CreateEnemyAnnounceCard( eCoopAIType.empTitan, 				"#NPC_TITAN_EMP", 				"#NPC_TITAN_EMP_DESC", 				SCOREBOARD_MATERIAL_COOP_EMP_TITAN, 			"burncards/amped_electric_smoke" )
}

function CreateEnemyAnnounceCard( aiTypeIdx, title, description, icon, image )
{
	ValidateCoopAITypeIdx( aiTypeIdx )

	Assert( !( aiTypeIdx in level.enemyAnnounceCardInfos ), "Already created enemy announce card for aiTypeIdx: " + aiTypeIdx )

	local table = {}
	level.enemyAnnounceCardInfos[ aiTypeIdx ] <- table

	table.aiTypeIdx <- aiTypeIdx
	table.title <- title

	if ( IsServer() )
	{
		PrecacheMaterial( "vgui/" + image )
	}
	else
	{
		table.icon <- icon
		table.description <- description
	}

	return table
}

function ValidateCoopAITypeIdx( aiTypeIdx )
{
	local foundIt = false
	foreach ( aiNameKey, id in getconsttable().eCoopAIType )
	{
		if ( id == aiTypeIdx )
		{
			foundIt = true
			break
		}
	}
	Assert( foundIt, "Couldn't find aiTypeIdx " + aiTypeIdx + " in eCoopAIType enum" )
}
Globalize( ValidateCoopAITypeIdx )


function GetCoopAITypeID_ByString( aiTypeStr )
{
	local aiTypeID = null
	foreach ( name, id in getconsttable().eCoopAIType )
	{
		if ( name == aiTypeStr )
		{
			aiTypeID = id
			break
		}
	}

	return aiTypeID
}
Globalize( GetCoopAITypeID_ByString )


function GetCoopAITypeString_ByID( aiTypeID )
{
	local aiTypeNameStr = null
	foreach ( name, id in getconsttable().eCoopAIType )
	{
		if ( id == aiTypeID )
		{
			aiTypeNameStr = name
			break
		}
	}

	return aiTypeNameStr
}
Globalize( GetCoopAITypeString_ByID )


function Coop_GetAITypeID_ByClassAndSubclass( classname, subclass = null )
{
	local aiTypeID = null

	if ( classname == "script_mover" || classname == "prop_dynamic" )
	{
		aiTypeID = eCoopAIType.cloakedDrone
	}
	else if ( classname == "npc_titan" )
	{
		switch( subclass )
		{
			case eSubClass.nukeTitan:
				aiTypeID = eCoopAIType.nukeTitan
				break

			case eSubClass.empTitan:
				aiTypeID = eCoopAIType.empTitan
				break

			case eSubClass.mortarTitan:
				aiTypeID = eCoopAIType.mortarTitan
				break

			default:
				aiTypeID = eCoopAIType.titan
		}
	}
	else if ( classname == "npc_spectre" )
	{
		switch( subclass )
		{
			case eSubClass.suicideSpectre:
				aiTypeID = eCoopAIType.suicideSpectre
				break

			case eSubClass.sniperSpectre:
				aiTypeID = eCoopAIType.sniperSpectre
				break

			default:
				aiTypeID = eCoopAIType.spectre
		}
	}
	else if ( classname == "npc_soldier" )
	{
		aiTypeID = eCoopAIType.grunt
	}

	Assert( aiTypeID != null, "Couldn't determine aiTypeID for: " + classname + " / " + subclass )
	return aiTypeID
}
Globalize( Coop_GetAITypeID_ByClassAndSubclass )


function GetCoopEnemyCount_ByAITypeIdx( aiTypeIdx )
{
	ValidateCoopAITypeIdx( aiTypeIdx )

	local netVar = null
	switch ( aiTypeIdx )
	{
		case eCoopAIType.grunt:
			netVar = "TD_numGrunts"
			break

		case eCoopAIType.spectre:
			netVar = "TD_numSpectres"
			break

		case eCoopAIType.suicideSpectre:
			netVar = "TD_numSuicides"
			break

		case eCoopAIType.sniperSpectre:
			netVar = "TD_numSnipers"
			break

		case eCoopAIType.cloakedDrone:
			netVar = "TD_numCloakedDrone"
			break

		case eCoopAIType.titan:
			netVar = "TD_numTitans"
			break

		case eCoopAIType.nukeTitan:
			netVar = "TD_numNukeTitans"
			break

		case eCoopAIType.mortarTitan:
			netVar = "TD_numMortarTitans"
			break

		case eCoopAIType.empTitan:
			netVar = "TD_numEMPTitans"
			break
	}
	Assert( netVar != null, "Couldn't find netVar for aiTypeIdx " + cardInfo.aiTypeIdx )

	return level.nv[ netVar ]
}
Globalize( GetCoopEnemyCount_ByAITypeIdx )


// --------------------
// ---- WAVE SETUP ----
// --------------------
// alias = used by LD to plug into wave
// string = what actually displays on screen
function AddWaveName( waveNameAlias, waveNameStr )
{
	foreach ( idx, nameInfo in level.waveNames )
		Assert( nameInfo.waveNameAlias != waveNameAlias, "Wave name alias " + waveNameAlias + " was already set up." )

	local newIdx = level.waveNames.len()
	level.waveNames[ newIdx ] <- { waveNameAlias = waveNameAlias, waveNameStr = waveNameStr }
}
Globalize( AddWaveName )


function GetWaveNameIdByAlias( waveNameAlias )
{
	local nameID = null
	foreach ( idx, nameInfo in level.waveNames )
	{
		if ( nameInfo.waveNameAlias == waveNameAlias )
		{
			nameID = idx
			break
		}
	}
	Assert( nameID != null, "Couldn't find wave name with alias: " + waveNameAlias )

	return nameID
}
Globalize( GetWaveNameIdByAlias )


function GetWaveNameStrByID( idx )
{
	local waveName = null

	if ( idx in level.waveNames )
		waveName = level.waveNames[ idx ].waveNameStr

	return waveName
}
Globalize( GetWaveNameStrByID )


// --------------------
// ---- MISC STUFF ----
// --------------------
function AddEnergyOrb( orbID, origin, angles )
{
	floorVector( origin )
	floorVector( angles )

	local orbName = GetOrbNameFromId( orbID )
	Assert( !( orbName in level.energyOrbs ) )
	level.energyOrbs[ orbName ] <- { orbID = orbID, origin = origin, angles = angles }

	if ( orbID > level.higestID )
		level.higestID = orbID
}

function floorVector( vector )
{
	vector.x = vector.x.tointeger()
	vector.y = vector.y.tointeger()
	vector.z = vector.z.tointeger()
}

function GetOrbNameFromId( orbID )
{
	local orbName = "energy_orb_" + orbID
	return orbName
}

function GetTotalEnemyNum()
{
	local total = 0

	local TD_numSuicides 		= level.nv.TD_numSuicides
	local TD_numSnipers			= level.nv.TD_numSnipers
	local TD_numSpectres 		= level.nv.TD_numSpectres
	local TD_numGrunts 			= level.nv.TD_numGrunts

	total+= GetTitanEnemyCount()

	if ( TD_numSuicides > 0 )
		total += TD_numSuicides

	if ( TD_numSnipers > 0 )
		total += TD_numSnipers

	if ( TD_numSpectres > 0 )
		total += TD_numSpectres

	if ( TD_numGrunts > 0 )
		total += TD_numGrunts

	return total
}
Globalize( GetTotalEnemyNum )

function GetTitanEnemyCount()
{
	local total = 0

	local TD_numTitans 			= level.nv.TD_numTitans
	local TD_numNukeTitans		= level.nv.TD_numNukeTitans
	local TD_numMortarTitans	= level.nv.TD_numMortarTitans
	local TD_numEMPTitans 		= level.nv.TD_numEMPTitans

	if ( TD_numTitans > 0 )
		total += TD_numTitans

	if ( TD_numNukeTitans > 0 )
		total += TD_numNukeTitans

	if ( TD_numMortarTitans > 0 )
		total += TD_numMortarTitans

	if ( TD_numEMPTitans > 0 )
		total += TD_numEMPTitans

	return total
}

function Coop_HasRestarted()
{
	return GetRoundsPlayed() > 0
}
Globalize( Coop_HasRestarted )


function Coop_PlayersHaveRestartsLeft()
{
	return Coop_GetNumRestartsLeft() > 0
}
Globalize( Coop_PlayersHaveRestartsLeft )


function Coop_GetNumRestartsLeft()
{
	return level.nv.coopRestartsAllowed
}
Globalize( Coop_GetNumRestartsLeft )


function Coop_SetNumAllowedRestarts( num )
{
	level.nv.coopRestartsAllowed = num

	if ( IsServer() )
		Coop_SetMaxAllowedRestarts( num )
}
Globalize( Coop_SetNumAllowedRestarts )


function Coop_DecrementRestarts()
{
	level.nv.coopRestartsAllowed--
}
Globalize( Coop_DecrementRestarts )


function Coop_IsGameOver()
{
	if (IsWinningTeam(level.nv.attackingTeam))
		return true

	if ( GetGameState() >= eGameState.WinnerDetermined && !Coop_PlayersHaveRestartsLeft() )
		return true

	return false
}
Globalize( Coop_IsGameOver )


if ( IsServer() )
{
	function Coop_GetMaxAllowedRestarts()
	{
		return level.maxAllowedRestarts
	}
	Globalize( Coop_GetMaxAllowedRestarts )


	function Coop_SetMaxAllowedRestarts( newMax )
	{
		level.maxAllowedRestarts = newMax
	}
	Globalize( Coop_SetMaxAllowedRestarts )
}

function AddEnterMenuFunction( player, func )
{
	// used for running a function when the player enters the class menus
	if ( !( "enterMenuFunctions" in player.s ) )
		player.s.enterMenuFunctions <- []

	foreach ( menuFunc in player.s.enterMenuFunctions )
	{
		Assert( menuFunc != func, "This function has already been added to the player" )
	}

	player.s.enterMenuFunctions.append( func )

}

// dev function
function summonplayers()
{
	local guy = GetPlayerArray()[0]
	local players = GetLivingPlayers()
	foreach ( player in players )
	{
		if ( player == guy )
			continue
		player.SetOrigin( guy.GetOrigin() )
		player.SetVelocity( RandomVec( 250 ) )
	}
}


function TryAssignOffhand( player, targetEnt, offhands, index, unlockType )
{
	if ( !( index in offhands ) )
		return false


	if ( offhands[index] != null )
	{
		local mods = offhands[index].mods
		if ( offhands[index].weapon != null )
		{
			targetEnt.GiveOffhandWeapon( offhands[index].weapon, index, mods )

		}
	}
	return true
}

function PlayerIsFemale( player )
{
	local playerClassDataTable = GetPlayerClassDataTable( player, level.pilotClass )
	local tokens = split( playerClassDataTable.playerSetFile, "_" )

	if( "female" in tokens )
	{
		return true
	}

	return false
}

function GetTeamMinions( team )
{
	local ai = GetNPCArrayByClass( "npc_soldier" )
	ai.extend( GetNPCArrayByClass( "npc_spectre" ) )

	for ( local i = 0; i < ai.len(); i++ )
	{
		if ( ai[i].GetTeam() != team )
		{
			ai.remove(i)
			i--
		}
	}

	return ai
}

function GetAllMinions()
{
	local ai = GetNPCArrayByClass( "npc_soldier" )
	ai.extend( GetNPCArrayByClass( "npc_spectre" ) )

	return ai
}

function HandleRematchEdgeCases( player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )
	wait 0
	player.SetVelocity( Vector(50,50,50) ) // force you to move, so you hit kill triggers

	PlayerInSolidFailsafe( player, player.GetOrigin(), null ) //Might spawn into incompatible clip, e.g. spawn as pilot into a pilot-clipped area since player was a Titan before death
}

function killtitans()
{
	printt( "Script command: Kill all titans" )
	local titans = GetAllTitans()
	foreach ( titan in titans )
	{
		titan.Die()
	}
}

function killminions()
{
	printt( "Script command: Kill all minions" )
	local titans = GetAllMinions()
	foreach ( titan in titans )
	{
		titan.Die()
	}
}

function SetOnScoreEventFunc( callbackFunc )
{
	Assert( level.onScoreEventFunc == null, "Already set onScoreEventFunc" )
	printt("Setting onScoreEventFunc")
	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onScoreEventFunc = callbackInfo
}

function GiveAllTitans()
{
	local players = GetPlayerArray()
	foreach ( player in players )
	{
		ForceTitanBuildComplete( player )
		if ( player.IsTitan() )
		{
			local soul = player.GetTitanSoul()
			if ( soul )
			{
				soul.SetNextCoreChargeAvailable( 1 )
			}
		}
	}
}

function TitanMaker() // for testing
{
	local player = GetPlayerArray()[0]

	local origin = Vector(0,0,0)
	local angles = Vector(0,0,0)
	local team = GetOtherTeam(player.GetTeam())
	local weapon = "mp_titanweapon_xo16"
	local titan = CreateNPCTitanFromSettings( "titan_atlas", team, origin, angles )
	titan.GiveWeapon( weapon )
	titan.SetTitle( "Joe" )
}

function teamswap()  // for debug
{
	local players = GetPlayerArray()
	foreach ( player in players )
	{
		if ( player.GetTeam() == TEAM_IMC )
		{
			player.SetTeam( TEAM_MILITIA )
		}
		else
		{
			player.SetTeam( TEAM_IMC )
		}
	}
}

function DefaultStayPut( guys )
{
	foreach ( guy in guys )
	{
		guy.AssaultPoint( guy.GetOrigin() )
		guy.StayPut( true )
	}
}

function GetAllTitans()
{
	local titans = []
	// returns the first owned titan found
	local souls = GetTitanSoulArray()
	foreach ( soul in souls )
	{
		if ( !IsValid( soul ) )
			continue

		local titan = soul.GetTitan()
		if ( !IsAlive( titan ) )
			continue

		titans.append( titan )
	}

	return titans
}

function CompareTitanTeamCount( myTeam )
{
	local enemyTeam = GetOtherTeam(myTeam)
	local titans = GetAllTitans()

	local myTitans = []
	local enemyTitans = []

	foreach ( titan in titans )
	{
		local team = titan.GetTeam()
		if ( team < 2 )
			continue
		if ( team == myTeam )
			myTitans.append( titan )
		else
			enemyTitans.append( titan )
	}

	return myTitans.len() - enemyTitans.len()
}

function GetSpectreCount( team )
{
	local aiClass = "npc_spectre"
	local spectres = GetNPCArrayByClass( aiClass )

	local count = 0

	foreach ( spectre in spectres )
	{
		if ( spectre.GetTeam() == team )
			count++
	}

	// to account for spectres that are dropping into the map
	count += GetReservedAISquadSlotsOfClassForTeam( aiClass, team )
	return count
}

function GetTitanCount( team )
{
	local titans = GetAllTitans()

	local teamTitans = []

	foreach ( titan in titans )
	{
		if ( titan.GetTeam() == team )
			teamTitans.append( titan )
	}

	return teamTitans.len()
}

function ReloadScriptsInternal()
{


	reloadingScripts = true
	SetReloadingScripts( true )

	local root = getroottable()
	local operators = GetEntArrayByClass_Expensive( "game_operator" )
//	local script = GetGameOperatorScript()

	if ( developer() > 0 && ScriptExists( "test/myscript" ) )
		IncludeScript( "test/myscript", root )

//	foreach ( operator in operators )
//	{
//		IncludeScript( script, operator.GetScriptScope() )
//	}

	local mapname = GetMapName()

	if ( ScriptExists( mapname ) )
	{
		IncludeScript( mapname, root )
	}
	else
	if ( ScriptExists( "test/" + mapname ) )
	{
		//level.isTestmap = true
		IncludeScript( "test/" + mapname, root )
	}
	else
	if ( ScriptExists( "sp/" + mapname + "/" + mapname ) )
	{
		IncludeScript( "sp/" + mapname + "/" + mapname, root )
	}
	else
	if ( ScriptExists( "mp/" + mapname ) )
	{
		IncludeScript( "mp/" + mapname, root )
	}

	IncludeFile( "weapons/_vortex" )
	IncludeFile( "weapons/_grenade" )
	IncludeFile( "mp/_replacement_titans_drop" )
	IncludeFile( "mp/_replacement_titans" )
	IncludeFile( "mp/_titan_transfer" )

	IncludeFile( "mp/_ai_soldiers" )

	IncludeFile( "_riff_settings" )
	IncludeFile( "_passives" )

	IncludeGameModeServerScripts()

	IncludeFile( "mp/player_cloak" )

	IncludeFile( "mp/_hardpoints" )

	IncludeFile( "mp/capture_point" )
	//IncludeFile( "client/cl_scoreboard" )

	IncludeFile( "_flightpath_shared" )
	IncludeFile( "_flightpath_shared_utility" )

	if ( /*!IsLobby() &&*/ GetCurrentPlaylistVarInt( "riff_floorislava", eFloorIsLava.Default ) )
		IncludeFile( "mp/_riff_floor_is_lava" )
	IncludeFile( "mp/_rodeo" )

	IncludeFile( "mp/_vehicle_dropship_new" )
	IncludeFile( "superbar/smokescreen" )
	IncludeFile( "superbar/orbitalstrike" )
	IncludeFile( "entities/_droppod_fireteam" )
	IncludeFile( "mp/_score" )
	IncludeFile( "mp/_titan_health" )
	IncludeFile( "_damage_utility" )

	IncludeFile( "mp/_dogfighter" )

	switch ( GetMapName() )
	{
		case "mp_angel_city":
			IncludeFile( "mp/mp_angel_city_intro" )
			break

	}

	IncludeScript( "_utility", root )
	//IncludeFile( "mp/_utility_dropzone" )
	IncludeScript( "mp/_utility_mp", root )
	IncludeFile( "_titan_shared" )
	IncludeFile( "mp/_titan_npc" )
	IncludeFile( "mp/_cinematic" )
	IncludeFile( "mp/_titan_npc_behavior" )
	IncludeTitanEmbark()
	IncludeFile( "entities/_droppod" )
	IncludeFile( "mp/_anim" )
	IncludeFile( "_rodeo_shared" )
	IncludeFile( "mp/_dialogue_chatter" )
	IncludeFile( "mp/_control_panel" )

	// [LJS]
	IncludeFile( "mp/_rush_panel" )

	IncludeFile( "weapons/_arc_cannon" )
	IncludeFile( "mp/_goblin_dropship" )
	IncludeFile( "_melee_shared" )
	IncludeFile( "mp/_melee_titan" )
	IncludeFile( "mp/_zipline" )
	IncludeFile( "mp/_titan_hotdrop" )
	IncludeFile( "mp/_player_leeching" )
	IncludeFile( "_player_leeching_shared" )
	IncludeFile( "_damage_history" )
	IncludeFile( "_player_view_shared" )

	IncludeFile( "mp/_classic_mp" )

	IncludeFile( "mp/_player_revive" )


	IncludeFile( "_dialogue_shared" )
	IncludeFile( "mp/_music" )


	IncludeScript( "_codecallbacks_shared", root )

	//if ( !IsMenuLevel() )
	if ( !IsLobby() )
		IncludeScript( "_codecallbacks_mp", getroottable() )


	IncludeFile( "mp/_gamestate" )
	IncludeFile( "mp/_gamerules")
	IncludeScript( "_utility_shared", root )
	IncludeScript( "_utility_shared_all", root )
	IncludeScript( "mp/mp_titanbuild_rule" )
	IncludeFile( "mp/spawn" )
	IncludeFile( "mp/_ai_game_modes" )

	IncludeFile( "weapons/_smart_ammo" )

	IncludeScript( "weapons/_weapon_utility", root )

	local players = GetPlayerArray()
	local tokens

//	foreach ( player in players )
//	{
//		local weapon = player.GetActiveWeapon()
//		if ( weapon )
//		{
//			local name = weapon.GetClassname()
//			if ( !weapon.IsWeaponOffhand() )
//				player.ReplaceActiveWeapon( name )
//		}
//
//		for ( local i = 0; i < 2; i++ )
//		{
//			local weapon = player.GetOffhandWeapon( i )
//			if ( !IsValid( weapon ) )
//				continue
//
//			local classname = weapon.GetClassname()
//			player.TakeOffhandWeapon( i )
//			player.GiveOffhandWeapon( classname, i )
//		}
//	}

	if ( GAMETYPE == COOPERATIVE )
		IncludeFile( "mp/_COOBJ_towerdefense" )

	IncludeScript( "mp/_base_gametype", root )

	IncludeFile( "mp/class_titan" )
	IncludeFile( "mp/class_wallrun" )

	if ( !( "CreateOperatorTargetBeam" in level ) )
		level.CreateOperatorTargetBeam <- CreateOperatorTargetBeam
	else
		level.CreateOperatorTargetBeam = CreateOperatorTargetBeam

	ReloadScriptCallbacks()

	reloadingScripts = false
	SetReloadingScripts( false )

	return ( "reloaded server scripts" )
}

function ReloadScripts()
{
	ServerCommand( "fs_report_sync_opens 0" ) // makes reload scripts slow
	level.ent.Fire( "CallScriptFunction", "ReloadScriptsInternal" )

	return ( "reloaded server scripts" )
}

function ReloadScript( scriptName )
{
	SetReloadingScripts( true )
	IncludeScript(  scriptName, getroottable() )
	SetReloadingScripts( false )
}

function DissolveEntity( ent = null )
{
	if ( ent == null )
		ent = self

	if ( !ent )
		return

	if ( "dissolving" in ent.s )
		return
	ent.s.dissolving <- true

	ent.Signal( "OnDissolve" )

	local scope = ent.scope()
	if ( "Cleanup" in scope )
		ent.scope().Cleanup() // dissolve doesnt trigger onbreak
	level.podDissolver.Fire( "Dissolve", ent.GetName(), 0 )
}

function AddCallback_PlayerOrNPCKilled( func )
{
	local name = FunctionToString( func )
	Assert( !( name in level.onPlayerOrNPCKilledCallbacks ), "Already added " + name + " to level.onPlayerOrNPCKilledCallbacks" )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- func
	callbackInfo.scope <- this

	level.onPlayerOrNPCKilledCallbacks[name] <- callbackInfo
}

function AddCallback_NPCKilled( func )
{
	local name = FunctionToString( func )
	Assert( !( name in level.onNPCKilledCallbacks ), "Already added " + name + " to level.onNPCKilledCallbacks" )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- func
	callbackInfo.scope <- this

	level.onNPCKilledCallbacks[name] <- callbackInfo
}

function AddCallback_NPCLeeched( callbackFunc )
{
	Assert( "onLeechedCustomCallbackFunc" in level )
	Assert( type( this ) == "table", "onLeechedCustomCallbackFunc can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 2, "npc, leecher" )

	local name = FunctionToString( callbackFunc )
	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onLeechedCustomCallbackFunc[name] <- callbackInfo
}

function RemoveCallback_PlayerOrNPCKilled( func )
{
	local name = FunctionToString( func )
	Assert( name in level.onPlayerOrNPCKilledCallbacks, "Have not added " + name + " to level.onPlayerOrNPCKilledCallbacks" )

	delete level.onPlayerOrNPCKilledCallbacks[ name ]
}

function HasCallback_PlayerOrNPCKilled( func )
{
	local name = FunctionToString( func )
	return( name in level.onPlayerOrNPCKilledCallbacks )
}

function VectorProject( vec1, vec2 )
{
	local var1 = vec1.Dot( vec2 )
	local var2 = vec2.Deot( vec2 )
	local var3 = var1 / var2
	var3 *= vec2

	return var3
}

function VectorDotToUp( vec )
{
	local up = Vector(0,0,1)
	local angles = VectorToAngles( vec )
	local forward = angles.AnglesToForward()

	return forward.Dot( up )
}

function PointDotToUp( org1, org2 )
{
	local vec = org1 - org2
	local up = Vector(0,0,1)
	local angles = VectorToAngles( vec )
	local forward = angles.AnglesToForward()

	return forward.Dot( up )
}

function VectorSubtract( a, b, c )
{
	c.x = a.x - b.x
	c.y = a.y - b.y
	c.z = a.z - b.z
}

function CalcClosestPointOnLine( P, A, B, clamp = false )
{
	local table = {}
    local AP = P - A
    local AB = B - A

    local ab2 = AB.Dot( AB ) // AB.x*AB.x + AB.y*AB.y
    local ap_ab = AP.Dot( AB ) // AP.x*AB.x + AP.y*AB.y
    local t = ap_ab / ab2

    if ( clamp )
    {
         if ( t < 0.0 )
			t = 0.0
         else
         if ( t > 1.0 )
         	t = 1.0
    }
	table.t <- t

    local closest = A + AB * t
    table.point <- closest
	return table
}

function CalcProgressOnLine( P, A, B )
{
    local AP = P - A
    local AB = B - A

    local ab2 = AB.Dot( AB ) // AB.x*AB.x + AB.y*AB.y
    local ap_ab = AP.Dot( AB ) // AP.x*AB.x + AP.y*AB.y
    local t = ap_ab / ab2
    return t
}

function MpOperatorEnabled()
{
	return "mpOperatorEnabled" in level
}

function GiveMoney( amount = 5000 )
{
	// FOR CONSOLE EXEC ONLY! DO NOT CALL THIS FROM SCRIPT!!!

	local players = GetPlayerArray()
	foreach ( player in players )
	{
		GiveOperatorScore( player, amount )
	}
}

function PlayHumanDeathSound( entity )
{
	if ( IsValid_ThisFrame( entity ) )
		EmitSoundOnEntity( entity, "ai_mp_human_death" )
}

class CGameTimer
{
	function TimeLimitSeconds()
	{
		if ( IsRoundBased() )
		{
			return ( GetRoundTimeLimit_ForGameMode() * 60.0 ).tointeger()
		}
		else
		{
			if ( IsSuddenDeathGameMode() && GetGameState() == eGameState.SuddenDeath )
				return ( GetTimeLimit_ForGameMode() * 60.0 ).tointeger() + ( GetSuddenDeathTimeLimit_ForGameMode() * 60.0 ).tointeger()
			else
				return ( GetTimeLimit_ForGameMode() * 60.0 ).tointeger()
		}
	}

	function TimeLimitMinutes()
	{
		if ( IsRoundBased() )
			return floor( GetRoundTimeLimit_ForGameMode() ).tointeger()
		else
			return floor( GetTimeLimit_ForGameMode() ).tointeger()
	}

	function TimeLeftMinutes()
	{
		if ( GetGameState() == eGameState.WaitingForPlayers )
			return 0
		if ( GetGameState() == eGameState.Prematch )
			return ( (GetServerVar( "gameStartTime" ) - Time()) / 60.0 )

		return floor( TimeLimitMinutes() - PlayingTime() / 60 ).tointeger()
	}

	function TimeLeftSeconds()
	{
		if ( GetGameState() == eGameState.Prematch )
			return (GetServerVar( "gameStartTime" ) - Time()).tointeger()

		return floor( TimeLimitSeconds() - PlayingTime() ).tointeger()
	}

	function Seconds()
	{
		return floor( Time() ).tointeger()
	}

	function Minutes()
	{
		return floor( Seconds() / 60 ).tointeger()
	}

	function IsTick()
	{
		return (Time() % 1) < 0.001
	}

	function PlayingTime()
	{
		local gameState = GetGameState()

		if ( gameState < eGameState.Playing )
			return 0

		if ( IsRoundBased() )
		{
			if ( gameState > eGameState.SuddenDeath )
				return (GetServerVar( "roundEndTime" ) - GetServerVar( "roundStartTime" ) )
			else
				return Time() - GetServerVar( "roundStartTime" )

		}
		else
		{
			if ( gameState > eGameState.SuddenDeath )
				return (GetServerVar( "gameEndTime" ) - GetServerVar( "gameStartTime" ) )
			else
				return Time() - GetServerVar( "gameStartTime" )
		}
	}

	function TimeSpentInCurrentState()
	{
		return Time() - GetServerVar( "gameStateChangeTime" )
	}
}

GameTime <- CGameTimer()

class CGameScore
{
	// prevents ties... need an option to disable in the future
	firstToScoreLimit = 0

	function GetScoreLimit()
	{
		if ( IsRoundBased() )
			return GetRoundScoreLimit_FromPlaylist()
		else
			return GetScoreLimit_FromPlaylist()
	}

	function GetTeamScore( teamNum )
	{
		return GameRules.GetTeamScore( teamNum )
	}

	function AddTeamScore( teamIndex, addScore )
	{
		Assert( addScore > 0 )

		// don't allow anymore scoring... we already have a winner
		if ( GetFirstToScoreLimit() )
			return

		if ( !GamePlayingOrSuddenDeath() )
			return

		local curScore = GameRules.GetTeamScore( teamIndex )
		local newScore = (curScore + addScore)

		if ( GetScoreLimit() )
			newScore = min( newScore, GetScoreLimit() )

		local otherTeamIndex = GetOtherTeam(teamIndex)
		local otherTeamScore = GameRules.GetTeamScore( otherTeamIndex )

		SetTeamScore( teamIndex, newScore )

		if ( !IsRoundBased() && ShouldDoScoreSwapVO( curScore, newScore, otherTeamScore ) ) //RoundBased Modes will trigger ScoreSwapVO in SetWinner if necessary
			thread ScoreSwapVO( teamIndex, otherTeamIndex )
	}

	function SetTeamScore( teamIndex, newScore )
	{
		GameRules.SetTeamScore( teamIndex, newScore )

		if ( newScore == GetScoreLimit() && !GetFirstToScoreLimit() )
			firstToScoreLimit = teamIndex
	}

	function GetTotalPoints()
	{
		return GameRules.GetTeamScore( TEAM_MILITIA ) + GameRules.GetTeamScore( TEAM_IMC )
	}

	function GetFirstToScoreLimit()
	{
		return firstToScoreLimit
	}

	function GS_GetWinningTeam()
	{
		if ( GetFirstToScoreLimit() )
			return GetFirstToScoreLimit()

		if ( GetTeamScore( TEAM_IMC ) > GetTeamScore( TEAM_MILITIA ) )
			return TEAM_IMC
		else if ( GetTeamScore( TEAM_MILITIA ) > GetTeamScore( TEAM_IMC ) )
			return TEAM_MILITIA

		return null
	}

	function GS_GetScoreRatio()
	{
		local winningTeam = GS_GetWinningTeam()

		if ( !winningTeam )
			return 1.0

		local winningTeamScore = GetTeamScore( winningTeam )
		local losingTeamScore = GetTeamScore(GetOtherTeam(winningTeam))
		//print( "winningScore: " + winningTeamScore + ", losingScore: " + losingTeamScore + ", ratio: " + ( losingTeamScore.tofloat() / winningTeamScore ) )
		return losingTeamScore.tofloat() / winningTeamScore

	}

	function GS_GetScoreNeededRatio()
	{
		local winningTeam = GS_GetWinningTeam()

		if ( !winningTeam )
			return 1.0

		local scoreLimit = GetScoreLimit()

		if ( scoreLimit == 0 )
			return

		local winningTeamScore = GetTeamScore( winningTeam )
		local losingTeamScore = GetTeamScore(GetOtherTeam(winningTeam))

		local winningTeamLeftToScore = scoreLimit - winningTeamScore
		local losingTeamLeftToScore = scoreLimit - losingTeamScore

		//printt( "winningScore: " + winningTeamScore + ", losingScore: " + losingTeamScore + ", scoreLimit: " + scoreLimit + ", scoreNeededRatio: " + ( winningTeamLeftToScore.tofloat() / losingTeamLeftToScore ) )

		return ( winningTeamLeftToScore.tofloat() / losingTeamLeftToScore )
	}

}

function GetLivingPlayers( teamIndex = null )
{
	local livingPlayers = []

	local players
	if ( teamIndex == null )
		players = GetPlayerArray()
	else
		players = GetPlayerArrayOfTeam( teamIndex )

	foreach ( player in players )
	{
		if ( !IsAlive( player ) )
			continue

		livingPlayers.append( player )
	}

	return livingPlayers
}


if ( !reloadingScripts )
{
	GameScore <- CGameScore()

	class CGameTeams
	{
		teamIDs = [ TEAM_IMC, TEAM_MILITIA ]
		teamSpawnCounts = {} // is creating a table in a class legal?
		lastTeamKilled = null

		constructor()
		{
			teamSpawnCounts[TEAM_IMC] <- 0
			teamSpawnCounts[TEAM_MILITIA] <- 0
		}

		function GetLosingTeams()
		{
			local losingTeams = []

			foreach ( teamIndex in teamIDs )
			{
				if ( teamIndex == GetTeamIndex(GetWinningTeam()) )
					continue

				losingTeams.append( teamIndex )
			}

			return losingTeams
		}

		function GetNumLivingPlayers( teamIndex = null )
		{
			local noOfLivingPlayers = 0

			local players
			if ( teamIndex == null )
				players = GetPlayerArray()
			else
				players = GetPlayerArrayOfTeam( teamIndex )

			foreach ( player in players )
			{
				if ( !IsAlive( player ) )
					continue

				++noOfLivingPlayers
			}

			return noOfLivingPlayers
		}
	}

	GameTeams <- CGameTeams()
}

function SetupAssaultPointKeyValues()
{
	printt( "WARNING, USED GETENTARRAY INSTEAD OF ADDSPAWNCALLBACK" )
	local assaultpoints = GetEntArrayByClass_Expensive( "assault_assaultpoints" )
	foreach ( point in assaultpoints )
	{
		SetupAssaultPoint( point )
	}
}

function SetupAssaultPoint( point )
{
	point.kv.stopToFightEnemyRadius = 1000
	point.kv.allowdiversionradius = 0
	point.kv.allowdiversion = 1
	point.kv.faceAssaultPointAngles = 1
	point.kv.assaulttolerance = 120
	point.kv.nevertimeout = 1
	point.kv.strict = 0	// what does this do
	point.kv.forcecrouch = 0
	point.kv.spawnflags = 0
	point.kv.clearoncontact = 0
	point.kv.assaulttimeout = 3.0
	point.kv.arrivaltolerance = 0
}

function boom( player )
{
	local origin = player.GetOrigin() + Vector(0,0,150 )
	local env_explosion = CreateEntity( "env_explosion" )
//	env_explosion.kv.spawnflags = 1  // No Damage
	env_explosion.SetName( "flash_explosion_" + UniqueString() )
	env_explosion.SetOrigin( origin )

	if ( IsAlive( player ) )
		env_explosion.kv.iMagnitude = 1000
	else
		env_explosion.kv.iMagnitude = 50


	env_explosion.kv.iRadiusOverride = 400
	env_explosion.kv.iInnerRadius = 400
	env_explosion.kv.fireballsprite = "sprites/zerogxplode.spr"
	env_explosion.kv.rendermode = 5
//	env_explosion.SetTeam(3)
	DispatchSpawn( env_explosion, false )

	env_explosion.Fire( "Explode" )
	env_explosion.Kill( 5 )
}


function PushEntWithDamageInfo( ent, damageInfo, amount, direction )
{
	local source = damageInfo.GetDamageSourceIdentifier()
	if ( source == eDamageSourceId.mp_titanweapon_vortex_shield )
		return

	PushEntWithDamage( ent, amount, direction )
}


function PushEntWithDamage( ent, damage, direction )
{
	direction.z *= 0.25
	local speed = GraphCapped( damage, 0, 4000, 0, 2000 )
	local force = direction * speed

//	printt( " " )
//	printt( "pushed", ent )
//	printt( "damage", damage )
//	printt( "force length", force.Length() )
//	printt( "speed", speed )
//	printt( "direction", direction )
//	printt( "direction length", direction.Length() )

	force += Vector(0,0,speed * -0.25 )

	force *= level.damagePushScale

//	printt( speed )

//	local org = ent.GetOrigin()
//	DebugDrawLine( org, org + force * 100, 255, 0, 0, false, 5 )
//	DebugDrawLine( org, org + Vector(0,0,5), 255, 255, 0, false, 5 )

	//printt( "!force ", force, force.Length() )
	local velocity = ent.GetVelocity()
	velocity += force
	ent.SetVelocity( velocity )
//	printt ( "result:", force, force.Length() )
//	printt( "hihi2")
}


function PushEntWithVortex( ent, vortexPush, direction )
{
	direction.z *= 0.25
	local speed = GraphCapped( vortexPush, 0, 4000, 0, 2000 )
	local force = direction * speed

//	printt( " " )
//	printt( "pushed", ent )
//	printt( "vortexPush", vortexPush )
//	printt( "force length", force.Length() )
//	printt( "speed", speed )
//	printt( "direction", direction )
//	printt( "direction length", direction.Length() )

	force += Vector(0,0,speed * -0.25 )

	force *= level.vortexPushScale

//	printt( speed )

//	local org = ent.GetOrigin()
//	DebugDrawLine( org, org + force, 255, 0, 0, false, 5 )
//	DebugDrawLine( org, org + Vector(0,0,5), 255, 255, 0, false, 5 )

	//printt( "!force ", force, force.Length() )
	local velocity = ent.GetVelocity()
	velocity += force
	ent.SetVelocity( velocity )
//	printt ( "result:", force, force.Length() )
//	printt( "hihi2")
}

function GetPetTitanOwner( titan )
{
	local players = GetPlayerArray()
	local foundPlayer
	foreach ( player in players )
	{
		if ( player.GetPetTitan() == titan )
		{
			Assert( foundPlayer == null, player + " and " + foundPlayer + " both own " + titan )
			foundPlayer = player
		}
	}

	return foundPlayer
}

function HasGameStateProtection( ent )
{
	// return true if the ent CAN'T die in the current gamestate
	switch ( GetGameState() )
	{
		case eGameState.WaitingForCustomStart:
		case eGameState.WaitingForPlayers:
		case eGameState.PickLoadout:
		case eGameState.Playing:
		case eGameState.SuddenDeath:
		case eGameState.Epilogue:
			// can die
			return false

		case eGameState.Prematch:

			if ( "canDieInPrematch" in ent.s )
				return false // some ents could die in Prematch

			return true // most ents doesn't die in Prematch

		case eGameState.SwitchingSides:
		case eGameState.Postmatch:
			// nothing dies
			return true

		case eGameState.WinnerDetermined:

			if ( GAMETYPE == COOPERATIVE )
				return false

			// this currently is to accomodate last titan standing
			// we should probably split WinnerDetermined into round and match versions.
			return IsRoundBased()

		default:
			Assert( 0, "Unknown gamestate " + GetGameState() )
	}


	return false
}

function GetTimeTillIntroStarts( introLength )
{
	local gametime = GetTimeTillGameStarts()

	if ( gametime < introLength )
		return 0

	else
		return gametime - introLength
}

function GetTimeTillGameStarts()
{
	return level.nv.gameStartTime - Time()
}

function satchel()
{
	local players = GetPlayerArray()
	foreach ( player in players )
	{
		player.TakeOffhandWeapon( 0 )
		player.GiveOffhandWeapon( "mp_weapon_satchel", 0 )
	}
}


function SetSquad( guy, squadName )
{
	Assert( IsValid( guy ) )

	if ( guy.kv.squadname == squadName )
		return

	// we only want squads containing NPCs of the same class
	Assert( SquadValidForClass( squadName, guy.GetClassname() ), "Can't put AI " + guy + " in squad " + squadName + ", because it contains one or more AI with a different class." )

	Assert( SquadCanAcceptNewMembers( guy, squadName ), "Can't add AI " + guy + " to squad " + squadName + ", because that squad already has " + SQUAD_SIZE + " slots filled or reserved." )

	guy.__SetSquad( squadName )
}

function SquadCanAcceptNewMembers( guy, squadName )
{
	// if the guy has a boss player, don't restrict his squad size, because he's on a special mission of some kind
	local bossPlayer = guy.GetBossPlayer()

	if ( IsMultiplayer() && IsCaptureMode() && !IsValidPlayer( bossPlayer ) )
	{
		// CP mode - need squads to be SQUAD_SIZE or smaller
		local squadSize = GetReservedSquadSize( squadName )
		if ( squadSize >= SQUAD_SIZE )
			return false
	}

	return true
}

////////////////////////////////////////////////////////////////////////////
// Forces AI to take notice/engage enemy even if out of fov
function UpdateEnemyMemory( npc, enemy )
{
	Assert( IsValid( npc ), "Tried to UpdateEnemyMemory on an invalid npc." )
	Assert( IsValid( enemy ), "Tried to UpdateEnemyMemory on an invalid enemy." )
	npc.FireNow( "UpdateEnemyMemory", enemy.GetName() )
}

function RandomizeHeadByTeam( model, headIndex, numOfHeads ) //Randomize head across heads available to a particular team. Assumes for a model all imc heads are first, then all militia heads are later.
{
	local midPoint =  numOfHeads / 2

	local randomHeadIndex = 0
	if ( model.GetTeam() == TEAM_IMC )
	{
		randomHeadIndex = RandomInt( 0, midPoint )
	}
	else if ( model.GetTeam() == TEAM_MILITIA )
	{
		randomHeadIndex = RandomInt( midPoint, numOfHeads )
	}
	//printt( "Set head to: : " + randomHeadIndex )
	model.SetBodygroup( headIndex, randomHeadIndex )
}

function SelectHead(model, index)
{
	local headIndex = model.FindBodyGroup( "head" )

	if ( headIndex == -1 )
		return

	model.SetBodygroup(headIndex, index)
}

function RandomizeHead( model ) //Randomize head across all available heads
{
	local headIndex = model.FindBodyGroup( "head" )
	if ( headIndex == -1 )
	{
		//printt( "HeadIndex == -1, returning" )
		return
	}
	local numOfHeads = model.GetBodyGroupModelCount( headIndex )
	//printt( "Num of Heads: " + numOfHeads )

	if ( HasTeamSkin( model ) )
	{
		RandomizeHeadByTeam( model, headIndex, numOfHeads )
		return
	}
	else
	{
		local randomHeadIndex = RandomInt( 0, numOfHeads )
		//printt( "Set head to: : " + randomHeadIndex )
		model.SetBodygroup( headIndex, randomHeadIndex )
	}
}

function HasTeamSkin( model )
{
	local modelTable = model.CreateTableFromModelKeyValues()

	if ( !modelTable )
		return false

	return  "teamSkin" in modelTable
}

//////////////////////////////////////////////////////////////
// No death screams from npcs
function SetSilentDeath( npc, bool )
{
	Assert( IsNPC( npc ), "Cannot call SetSilentDeath on a non-npc: " + npc.GetClassname() )
	Assert( IsAlive( npc ), "Cannot call SetSilentDeath on a dead npc" )

	if ( bool )
	{
		if ( !("silentDeath" in npc.s ) )
	 		npc.s.silentDeath <- true
	}
	else
	{
		if ( "silentDeath" in npc.s )
		 	delete npc.s.silentDeath
	}
}


function MessageToPlayer( player, eventID, entity = null, eventVal = null )
{
	local eHandle = null
	if ( entity )
		eHandle = entity.GetEncodedEHandle()

	Remote.CallFunction_NonReplay( player, "ServerCallback_EventNotification", eventID, eHandle, eventVal )
	//SendHudMessage( player, message, 0.33, 0.28, 255, 255, 255, 255, 0.15, 3.0, 0.5 )
}


function MessageToTeam( team, eventID, excludePlayer = null, entity = null, eventVal = null )
{
	local players = GetPlayerArray()

	foreach ( player in players )
	{
		if ( player.GetTeam() != team )
			continue

		if ( player == excludePlayer )
			continue

		MessageToPlayer( player, eventID, entity, eventVal )
	}
}

function MessageToAll( eventID, excludePlayer = null, entity = null, eventVal = null )
{
	local players = GetPlayerArray()

	foreach ( player in players )
	{
		if ( player == excludePlayer )
			continue

		MessageToPlayer( player, eventID, entity, eventVal )
	}
}

// for dropship intro sequences
function AddRideAnims( anims, initialTime, thirdPersonAnim, firstPersonAnim, localAnglesYaw = null, tag = "origin", viewConeFunction = ViewConeRampFree )
{
	local sequence = CreateRideAnim( initialTime, thirdPersonAnim, firstPersonAnim, localAnglesYaw, tag, viewConeFunction )
	anims.append( sequence )
}

function CreateRideAnim( initialTime, thirdPersonAnim, firstPersonAnim, localAnglesYaw = null, tag = "origin", viewConeFunction = ViewConeRampFree )
{
	local sequence = CreateFirstPersonSequence()
	sequence.thirdPersonAnim = thirdPersonAnim
	sequence.firstPersonAnim = firstPersonAnim
	sequence.attachment = tag
	sequence.viewConeFunction = viewConeFunction
	sequence.setInitialTime = initialTime
	sequence.teleport = true
	sequence.hideProxy = true
	if ( localAnglesYaw != null )
	sequence.localAnglesYaw <- localAnglesYaw
	return sequence
}

function GetSpectreNodeCount()
{
	local specNodes = 0
	local nodeCount = GetNodeCount()
    for ( local i = 0; i < nodeCount; i++ )
    {
        if ( IsSpectreNode( i ) )
        	specNodes++
	}

	return specNodes
}

//////////////////////////////////////////////////////////////
// Shows spectre nodes in red, grunt nodes in green
function DebugShowSpectreNodes()
{
    local nodeCount = GetNodeCount()
    local origin

    while ( true )
    {
	    for ( local i = 0; i < nodeCount; i++ )
	    {
	        origin = GetNodePos( i, 0 )
	        if ( IsSpectreNode( i ) )
	            DebugDrawLine( origin, origin + Vector(0,0,64), 255, 0, 0, false, 1.0 )
	        else
	            DebugDrawLine( origin, origin + Vector(0,0,64), 0, 255, 0, false, 1.0 )
		}
		wait 0.1
	}
}

function IsPlayerMalePilot( player )
{
	Assert( player.IsPlayer() )

	if ( player.IsTitan() )
		return false

	local playerClassDataTable = GetPlayerClassDataTable( player, level.pilotClass )
	local tokens = split( playerClassDataTable.playerSetFile, "_" )
	foreach ( token in tokens )
	{
		if(token == "female") {
			return false
		}
	}
	if( "female" in tokens )
	{
		return false
	}

	return true
}

function IsPlayerFemalePilot( player )
{
	Assert( player.IsPlayer() )

	if ( player.IsTitan() )
		return false

	local playerClassDataTable = GetPlayerClassDataTable( player, level.pilotClass )
	local tokens = split( playerClassDataTable.playerSetFile, "_" )
	foreach ( token in tokens )
	{
		if(token == "female") {
			return true
		}
	}
	
	return false
}

function IsCloakedDrone( drone )
{
	return ( "isCloakedDrone" in drone.s )
}

function IsFacingEnemy( guy, enemy, viewAngle = 75 )
{
	local dir = enemy.GetOrigin() - guy.GetOrigin()
	dir.Normalize()
	local dot = guy.GetViewVector().Dot( dir )
	local yaw = DotToAngle( dot )

	return ( yaw < viewAngle )
}

function PlayerProgressionAllowed( player = null )
{
	if ( !PlayerFullyConnected( player ) )
		return false

	
	return true
}

function PlayerFullyConnected( player )
{
	if ( !player.hasConnected )
		return false

	if ( player.IsMarkedForDeletion() )
		return false

	return true
}

// [LJS]
function MoveEntity( targetName, origin, angles )
{
	local ent = GetEnt( targetName )

	Assert( ent != null )

	ent.SetOrigin( origin )
	ent.SetAngles( angles )
}

function UpdatePlayerStat( player, category, stat, value = null )
{
	printt( "UpdatePlayerStat: " + player + " " + category + " " + stat + " " + value )
	
}

function SetPlayerActiveObjectiveWithTime( player, objective, time )
{
	printt( "SetPlayerActiveObjectiveWithTime: " + player + " " + objective + " " + time )
}

function GetActiveBurnCard(player) {
	local index = player.GetActiveBurnCardIndex()
	if(index == -1) {
		return null
	}
	local ref = GetPlayerActiveBurnCard(player)
	return ref
}


function GetTitanCoreTimer( titan )
{
	Assert( titan.IsTitan() )
	local soul = titan.GetTitanSoul()
	Assert( soul )

	return soul.GetNextCoreChargeAvailable() - Time()
}

function DecrementBuildTimer( player, amount )
{
	if( !player.IsTitan() )
	{
		// printt( "DecrementBuildTimer: " + player.GetTitanRespawnTime() + " " + amount )
		local newRespawnTime = player.GetTitanRespawnTime() - amount
		if (newRespawnTime >= 0) {
			player.SetTitanRespawnTime(newRespawnTime)
		}
		else if (newRespawnTime < 0) {
			player.SetTitanRespawnTime(1)
		}
		return
	}

	// core ability in use
	if ( TitanCoreInUse( player ) )
		return

	if ( !IsAlive( player ) )
		return

	local newCoreTimer = max(GetTitanCoreTimer( player ) - amount, 0)
	SetTitanCoreTimer( player, newCoreTimer )

	Remote.CallFunction_NonReplay( player, "ServerCallback_UpdateTitanModeHUD" )
}

function InitBurnCardPersistence( player )
{
	//printt("InitBurnCardPersistence: " + player )
}

function ResetRankSkillHistory( player )
{
	//printt("ResetRankSkillHistory: " + player )
}

function InitPlayerStats( player )
{
	RegisterSignal( "RefreshDice" )
	// InitXP( player )
	player.XPChanged()
	player.GenChanged()
	printt("InitPlayerStats: " + player )
}

function AddCoins(player,ammount,type) {
	local currentCount = player.GetPersistentVar("bm.coinCount")
	player.SetPersistentVar("bm.coinCount", currentCount + ammount)
}


function GetBurnCardSetForIndex(setIndex) {
	// printt("GetBurnCardSetForIndex: " + setIndex )
	//TODO: Actually get the list of burn cards for pm options - Allusive
	local deck = []
	switch (setIndex) {
		case 0:
			deck = []
			break
		case 1:
			deck = [    "bc_frag_m2",
    "bc_arc_m2",
    "bc_prox_m2",
    "bc_satchel_m2",
    "bc_autopistol_m2",
    "bc_semipistol_m2",
    "bc_wingman_m2",
    "bc_smart_pistol_m2",
    "bc_car_m2",
    "bc_r97_m2",
    "bc_shotgun_m2",
    "bc_rspn101_m2",
    "bc_hemlok_m2",
    "bc_g2_m2",
    "bc_lmg_m2",
    "bc_dmr_m2",
    "bc_sniper_m2",
    "bc_smr_m2",
    "bc_rocket_launcher_m2",
    "bc_mgl_m2",
    "bc_defender_m2",
    "bc_super_cloak",
    "bc_cloak_forever",
    "bc_fast_movespeed",
    "bc_super_stim",
    "bc_stim_forever",
    "bc_pilot_warning",
    "bc_auto_sonar",
    "bc_super_sonar",
    "bc_sonar_forever",
    "bc_minimap_scan",
    "bc_minimap",
    "bc_double_agent",
    "bc_conscription",
    "bc_wifi_spectre_hack",
    "bc_nuclear_core",
    "bc_core_charged",
    "bc_rematch",
    "bc_play_spectre",
    "bc_free_build_time_1",
    "bc_free_build_time_2",
    "bc_fast_build_2",
    "bc_hunt_soldier",
    "bc_hunt_spectre",
    "bc_hunt_pilot",
    "bc_hunt_titan",
    "bc_summon_atlas",
    "bc_summon_ogre",
    "bc_summon_stryder",
    "bc_auto_refill",
    "bc_dice_ondeath",
    "bc_titan_40mm_m2",
    "bc_titan_arc_cannon_m2",
    "bc_titan_rocket_launcher_m2",
    "bc_titan_sniper_m2",
    "bc_titan_triple_threat_m2",
    "bc_titan_xo16_m2",
    "bc_titan_dumbfire_missile_m2",
    "bc_titan_homing_rockets_m2",
    "bc_titan_salvo_rockets_m2",
    "bc_titan_shoulder_rockets_m2",
    "bc_titan_vortex_shield_m2",
    "bc_titan_electric_smoke_m2",
    "bc_titan_shield_wall_m2",
    "bc_extra_dash"]
			break
		case 2:
			deck = []
			break
		case 3:
			deck = []
			break
		case 4:
			deck = []
			break
		case 5:
			deck = []
			break
		case 6:
			deck = []
			break
		case 7:
			deck = []
			break
		case 8:
			deck = []
			break
		case 9:
			deck = []
			break
		case 10:
			deck = []
			break
	}
	return deck
}

function ChangedPlayerBurnCards(player) {
	//printt("ChangedPlayerBurnCards: " + player )	
}

function FillBurnCardDeckFromArray( player, array )
{
	local max = PersistenceGetArrayCount( _GetBurnCardDeckPersDataPrefix() )
	for ( local i = 0; i < max; i++ )
	{
		player.SetPersistentVar( _GetBurnCardDeckPersDataPrefix() + "[" + i + "]", null )
		player.SetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".burnCardIsNew[" + i + "]", false )
	}

	foreach (index,card in array)
	{
		if(card == null)
			player.SetPersistentVar( _GetBurnCardDeckPersDataPrefix() + "[" + index + "]", null )
		
		player.SetPersistentVar( _GetBurnCardDeckPersDataPrefix() + "[" + index + "]", card.cardRef )
		player.SetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".burnCardIsNew[" + index + "]", card.new )
	}
}

function Ranked_PlayerConnected( player )
{
	
	printt("Ranked_PlayerConnected: " + player )
	printt("Rank mode: " + level.ui.rankEnableMode )

	// eRankEnabledModes.ALLOWED_DURING_PERSONAL_GRACE_PERIOD

	}

function BurnCard_RefreshPlayer( player )
{
	
}

function BurnCard_PlayerConnected( player )
{
}

function BlackMarket_PlayerConnected( player )
{
	//printt( "BlackMarket_PlayerConnected: " + player )
}

function GetTrainingHasEverBeenStarted( player )
{
	return true
}


function _GetActiveBurnCardsPersDataPrefix()
{
	if ( UsingAlternateBurnCardPersistence() )
		return "persData_pm_activeBurnCards"
	else
		return "persData_activeBurnCards"
}


function BurnCardOnDeath( target, attacker, idx )
{
	local activeBCID = target.GetPersistentVar("activeBCID")
	if(activeBCID == -1)
	{
		return
	}
	local activeCard = GetActiveBurnCard( target )
	if(!activeCard)
	{
		return
	}
	local cardData = GetBurnCardData( activeCard )
	if (cardData.lastsUntil == BC_NEXTDEATH) 
	{
		target.SetPersistentVar( "activeBCID", -1 )
		target.SetActiveBurnCardIndex( -1 )
		target.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + activeBCID + "].cardRef", null )
		target.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + activeBCID + "].clearOnStart", 0 )
	}

	// if(cardData.lastsUntil == BC_NEXTSPAWN)
	// {
	// 	player.SetPersistentVar( "activeBCID", -1 )
	// 	player.SetActiveBurnCardIndex( -1 )
	// 	player.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + activeBCID + "].cardRef", null )
	// 	player.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + activeBCID + "].clearOnStart", 0 )
	// }

	
}

// -----------------------------------------------------------
// Spawnpoint nodes
//
// _start player spawns are used at the beggining of the match, and they're team specific
// non _start player spawns are used after the intro sequence, and they're usually generic, so they should be set to TEAM_UNASSIGNED (team 0)
//
// to find positions:
// 1. open a local server
// 2. turn on sv_cheats
// 3. go to a spot that you think is nice
// 4. run: script ( printt( "POSITION: " + GetPlayerArray()[0].GetOrigin(), "ANGLES: " + GetPlayerArray()[0].GetAngles() ) )
// -----------------------------------------------------------

// Start spawnpoint for Pilots
function CreatePilotStartSpawnPoint( origin, angles, team, name )
{
	local ent = CreateEntity( "info_spawnpoint_human_start" )
	ent.SetName( name )
	ent.SetOrigin( origin )
	ent.SetAngles( angles )
	ent.SetTeam( team )
	DispatchSpawn( ent )
}

// Start spawnpoint for Titans
function CreateTitanPilotStartSpawnPoint( origin, angles, team, name )
{
	local ent = CreateEntity( "info_spawnpoint_titan_start" )
	ent.SetName( name )
	ent.SetOrigin( origin )
	ent.SetAngles( angles )
	ent.SetTeam( team )
	DispatchSpawn( ent )
}

// Spawnpoint for Pilots ( generic )
function CreatePilotSpawnPoint( origin, angles, team, name )
{
	local ent = CreateEntity( "info_spawnpoint_human" )
	ent.SetName( name )
	ent.SetOrigin( origin )
	ent.SetAngles( angles )
	ent.SetTeam( team )
	DispatchSpawn( ent )
}

// Spawnpoint for Titans ( generic )
function CreateTitanPilotSpawnPoint( origin, angles, team, name )
{
	local ent = CreateEntity( "info_spawnpoint_titan" )
	ent.SetName( name )
	ent.SetOrigin( origin )
	ent.SetAngles( angles )
	ent.SetTeam( team )
	DispatchSpawn( ent )
}

//////////////////////////////////////////////////////////////////////////

// Spawnpoint for Marvins

// These have a "bodytype" and "headType" options that select which type of Marvin to spawn
// bodyType 1, headType 0 = regular marvin
// bodyType 0, headType 4 = regular marvin with weird head (wargames)
// bodyType 3, headType 0 = firefighter marvin (demeter)

function CreateMarvinSpawnPoint( origin, angles, team, name, bodyType = 1, headType = 0 )
{
	local ent = CreateEntity( "info_spawnpoint_marvin" )
	ent.SetName( name )
	ent.SetOrigin( origin )
	ent.SetAngles( angles )
	ent.SetTeam( team )

	ent.kv.bodytype = bodyType
	ent.kv.headtype = headType

	DispatchSpawn( ent )
}

// Start spawnpoint for Droppods
function CreateDropPodStartSpawnPoint( origin, angles, team, name )
{
	local ent = CreateEntity( "info_spawnpoint_droppod_start" )
	ent.SetName( name )
	ent.SetOrigin( origin )
	ent.SetAngles( angles )
	ent.SetTeam( team )
	ent.s.inUse <- false
	DispatchSpawn( ent )
}

// Spawnpoint for Droppods ( generic )
function CreateDropPodSpawnPoint( origin, angles, team, name )
{
	local ent = CreateEntity( "info_spawnpoint_droppod" )
	ent.SetName( name )
	ent.SetOrigin( origin )
	ent.SetAngles( angles )
	ent.SetTeam( team )
	ent.s.inUse <- false
	DispatchSpawn( ent )
}

// Start spawnpoint for Dropships
function CreateDropShipStartSpawnPoint( origin, angles, team, name )
{
	local ent = CreateEntity( "info_spawnpoint_dropship_start" )
	ent.SetName( name )
	ent.SetOrigin( origin )
	ent.SetAngles( angles )
	ent.SetTeam( team )
	ent.s.inUse <- false
	DispatchSpawn( ent )
}

// Spawnpoint for Dropships ( generic )
function CreateDropShipSpawnPoint( origin, angles, team, name )
{
	local ent = CreateEntity( "info_spawnpoint_dropship" )
	ent.SetName( name )
	ent.SetOrigin( origin )
	ent.SetAngles( angles )
	ent.SetTeam( team )
	ent.s.inUse <- false
	DispatchSpawn( ent )
}

// Spawnpoint for Flags
function CreateFlagSpawnPoint( origin, angles, team, name )
{
	local ent = CreateEntity( "info_spawnpoint_flag" )
	ent.SetName( name )
	ent.SetOrigin( origin )
	ent.SetAngles( angles )
	ent.SetTeam( team )
	DispatchSpawn( ent )
}

// Create info_targets (used for evac nodes and some other stuff)
function CreateInfoTarget( origin, angles, name, target = "" )
{
	local ent = CreateEntity( "info_target" )
	ent.SetName( name )
	ent.SetOrigin( origin )
	ent.SetAngles( angles )

	if ( target != "" )
	{
		ent.kv.target = target
	}

	DispatchSpawn( ent )
}

// Create info_frontlines (they tell npcs where they should go and shoot at eachother)
// the "is[gamemode]" bools tell code if the frontline should be removed in that mode. 0 = gone
// not entirely sure what "spectrepoint" does, so leave it off i guess
function CreateInfoFrontline( origin, angles, team, name, group = "aaa", isTDM = 0, isLTS = 0, isCTF = 0, spectrepoint = 0 )
{
	local ent = CreateEntity( "info_frontline" )
	ent.SetName( name )
	ent.SetOrigin( origin )
	ent.SetAngles( angles )
	ent.kv.group = group

	local boolSettings = [ team, isTDM, isLTS, isCTF, spectrepoint ]

	foreach( setting in boolSettings )
	{
		Assert( setting >= 0 && setting <= 1, "Setting [" + setting + "] for info_frontline [" + name + "] should ALWAYS be either 0 or 1" )
	}

	ent.SetTeam( team )

	ent.kv.gamemode_tdm = isTDM
	ent.kv.gamemode_lts = isLTS
	ent.kv.gamemode_ctf = isCTF
	ent.kv.spectrepoint = spectrepoint

	DispatchSpawn( ent )
}

function CreateAssaultPointFromArray( locationArray, name = "assaultpoint", isNear = false ) {
	local ENT_ASSAULTPOINT_COUNT = GetEntArrayByClass_Expensive("assault_assaultpoint").len()
	foreach( idx, location in locationArray ) {
		local assaultPoint = CreateAssaultPoint()
		if( isNear ) {
			assaultPoint.SetName(name + "_near_ass_" + (ENT_ASSAULTPOINT_COUNT+1))
		} else {
			assaultPoint.SetName(name + "_ass_" + (ENT_ASSAULTPOINT_COUNT+1))
		}
		assaultPoint.SetOrigin(location.origin)
		assaultPoint.SetAngles(location.angles)
		ENT_ASSAULTPOINT_COUNT++
	}
}

// Debug thing
function KillAllEntitiesOfType( name )
{
	//local entarray = GetEntArrayByClass_Expensive( "info_frontline" )
	local entarray = GetEntArrayByClass_Expensive( name )

	foreach( ent in entarray )
	{
		ent.Destroy()
	}
}

// TODO: Could theoretically create hardpoint spawns like this as well
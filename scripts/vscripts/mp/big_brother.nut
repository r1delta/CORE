const EXPLO_TIME = 30.0 // 폭파 시간
const BLUESUN_TIME = 0.7 // 핵폭발 전 blue sun effect 시간
const EXPLO_CAM_LIMIT_DIST	= 0 // 폭발 시 패널과 이 거리 안에있는 플레이어는 카메라 이동 안시킴.

const FX_BIGBROTHER_PANEL_EXPLOSION = "building_exp"

function main()
{
	PrecacheParticleSystem( FX_BIGBROTHER_PANEL_EXPLOSION )

	Assert( !GetCinematicMode(), "Cannot play bb in cinematic mode" )

	RegisterSignal( "StopProgress" )
	RegisterSignal( "StopHacking" )

	SetRoundWinningKillEnabled( false )

	level.nv.attackingTeam = TEAM_IMC
	level.nv.bbHackStartTime = 0.0
	// 드랍쉽 스폰 사용.
	//FlagSet( "GameModeAlwaysAllowsClassicIntro" )

	// 공격팀인 IMC 만 드랍쉽 스폰, 방어팀은 지상스폰
	//EnableDropshipSpawnForTeam( TEAM_IMC )
	DisableDropshipSpawnForTeam( TEAM_IMC )
	DisableDropshipSpawnForTeam( TEAM_MILITIA )

	SetRoundBased( true )
	level.nv.eliminationMode = eEliminationMode.Pilots

	SetSwitchSidesBased( true )
	FlagSet( "ForceStartSpawn" )
	GM_AddStartRoundFunc( BBRoundStart )
	//AddCallback_PlayerOrNPCKilled( SecondsPlayerOrNPCKilled )



	// AddSpawnCallback( "prop_control_panel", OnBigBrotherPanelSpawn )

	level.bbPanels <- []
	file.bigBrotherPanelNames <- [ "bb_panel_a", "bb_panel_b" ]
	level.bbPanelHackTime <- 0.0
	level.bbHacked <- false
	level.HackedPlayer <- null


}

function GetHardpointMats( panelIndex )
{
	local panelNames = [ "a", "b" ]
	local panelMaterials = {}
	panelMaterials.a <- { friendly = "hardpoint_friendly_a", neutral = "hardpoint_neutral_a", enemy = "hardpoint_enemy_a" }
	panelMaterials.b <- { friendly = "hardpoint_friendly_b", neutral = "hardpoint_neutral_b", enemy = "hardpoint_enemy_b" }

	Assert( panelIndex < panelNames.len(), "Too many big brother control panels." )
	local panelLetter = panelNames[ panelIndex ]
	local panelMats = panelMaterials[ panelLetter ]
	return panelMats
}

function EntitiesDidLoad()
{
	local bbPanels = GetEntArrayByClass_Expensive( "prop_bigbrother_panel" )

	if ( !bbPanels.len() )
	{
		local attackerStartOrigin = Vector( 0, 0, 0 )
		local attackerStartSpawns = GetEntArrayByClass_Expensive( "info_spawnpoint_human_start" )
		Assert( attackerStartSpawns.len() )
		foreach ( spawnpoint in attackerStartSpawns )
		{
			if ( spawnpoint.GetTeam() != level.nv.attackingTeam )
				continue

			attackerStartOrigin += spawnpoint.GetOrigin()
		}

		attackerStartOrigin.x /= attackerStartSpawns.len()
		attackerStartOrigin.y /= attackerStartSpawns.len()
		attackerStartOrigin.z /= attackerStartSpawns.len()

		local hardpoints = ArrayFarthest( GetEntArrayByClass_Expensive( "info_hardpoint" ), attackerStartOrigin )

		foreach ( i,hardpoint in hardpoints )
		{
			// hardpoint.SetHardpointID( i )
			hardpoint.SetTeam( TEAM_UNASSIGNED )

			hardpoint.SetName( level.bbPanels.len() ? "bb_panel_a" : "bb_panel_b" )
			
			local panel = CreateEntity( "prop_control_panel" )
			panel.kv.model = "models/communication/terminal_usable_imc_01.mdl"
			panel.kv.solid = 2
			panel.SetName( level.bbPanels.len() ? "bb_panel_a" : "bb_panel_b" )

			DispatchSpawn( panel, false )

			panel.SetOrigin( hardpoint.GetOrigin() )
			panel.SetAngles( hardpoint.GetAngles() )

			panel.SetTeam(level.nv.attackingTeam)
			panel.UnsetUsable()
			// local panelMats = GetHardpointMats(  )
			local panelMats = GetHardpointMats( level.bbPanels.len() ? 0 : 1 )
				//local icon = "VIP_friendly"
			panel.Minimap_SetDefaultMaterial( GetMinimapMaterial( panelMats.neutral ) )
			panel.Minimap_SetFriendlyMaterial( GetMinimapMaterial( panelMats.friendly ) )
			panel.Minimap_SetEnemyMaterial( GetMinimapMaterial( panelMats.enemy ) )
			panel.Minimap_SetObjectScale( 0.11 )
			panel.Minimap_SetAlignUpright( true )
			panel.Minimap_SetClampToEdge( true )
			panel.Minimap_SetFriendlyHeightArrow( true )
			panel.Minimap_SetEnemyHeightArrow( true )
			panel.Minimap_SetZOrder( 10 )
			panel.Minimap_AlwaysShow( TEAM_IMC, null )
			panel.Minimap_AlwaysShow( TEAM_MILITIA, null )
			hardpoint.SetTerminal( panel )

			thread BBPanelThink( panel,hardpoint )

			// hardpoint.SetTerminal( panel )

			level.bbPanels.append( panel )
			if( level.bbPanels.len() >= 2 )
				break
		}
	}
	else {
		foreach (levelPanel in bbPanels) {

			local hardpoint = GetEntByHardpointID( levelPanel.GetHardpointID() )
			// hardpoint.SetHardpointID( levelPanel.GetHardpointID() )
			hardpoint.SetTeam( TEAM_UNASSIGNED )
			hardpoint.SetName( level.bbPanels.len() ? "bb_panel_a" : "bb_panel_b" )
			hardpoint.SetTerminal( levelPanel )

			local panel = CreateEntity( "prop_control_panel" )
			panel.kv.model = "models/communication/terminal_usable_imc_01.mdl"
			panel.kv.solid = 1

			panel.SetName( level.bbPanels.len() ? "bb_panel_a" : "bb_panel_b" )
			DispatchSpawn( panel, false )

			panel.SetOrigin( levelPanel.GetOrigin() )
			panel.SetAngles( levelPanel.GetAngles() )
			levelPanel.Destroy()

			panel.SetTeam(level.nv.attackingTeam)
			panel.UnsetUsable()

			local panelMaterials = {}
			panelMaterials.a <- { friendly = "hardpoint_friendly_a", neutral = "hardpoint_neutral_a", enemy = "hardpoint_enemy_a" }
			panelMaterials.b <- { friendly = "hardpoint_friendly_b", neutral = "hardpoint_neutral_b", enemy = "hardpoint_enemy_b" }

			local panelMats = panelMaterials[ level.bbPanels.len() ? "b" : "a" ]

			//local icon = "VIP_friendly"
			panel.Minimap_SetDefaultMaterial( GetMinimapMaterial( panelMats.neutral ) )
			panel.Minimap_SetFriendlyMaterial( GetMinimapMaterial( panelMats.friendly ) )
			panel.Minimap_SetEnemyMaterial( GetMinimapMaterial( panelMats.enemy ) )
			panel.Minimap_SetObjectScale( 0.11 )
			panel.Minimap_SetAlignUpright( true )
			panel.Minimap_SetClampToEdge( true )
			panel.Minimap_SetFriendlyHeightArrow( true )
			panel.Minimap_SetEnemyHeightArrow( true )
			panel.Minimap_SetZOrder( 10 )
			panel.Minimap_AlwaysShow( TEAM_IMC, null )
			panel.Minimap_AlwaysShow( TEAM_MILITIA, null )
			hardpoint.SetTerminal( panel )

			thread BBPanelThink( panel )

			level.bbPanels.append( panel )
			if( level.bbPanels.len() >= 2 )
				break
		}
	}
}

function BBPanelThink( panel, hardpoint )
{
	
	while( true )
	{

		panel.WaitSignal( "PanelReprogram_Success" )
		// if(level.bbHacked) {
		// 	continue
		// }
		// hardpoint.SetHardpointState(CAPTURE_POINT_STATE_NEXT)
		// hardpoint.SetHardpointEstimatedCaptureTime( Time() + EXPLO_TIME )

		local team = panel.GetTeam()
		
		// 

		foreach ( exfilPanel in level.bbPanels )
		{
			exfilPanel.UnsetUsable()
			if( exfilPanel != panel ) {
				exfilPanel.SetTeam( TEAM_UNASSIGNED )
				exfilPanel.Minimap_Hide( TEAM_IMC, null )
				exfilPanel.Minimap_Hide( TEAM_MILITIA, null )
			}
		}

		local owner = panel.GetBossPlayer()
		level.HackedPlayer = owner;
		// swap the team of the panel that was hacked
		panel.SetTeam((level.nv.attackingTeam))
		panel.SetUsableByGroup( "enemies pilot" )
		
		
		foreach(guy in GetPlayerArray())
		{
			Remote.CallFunction_Replay( guy, "SCB_BBUpdate", owner.GetEncodedEHandle() )
			if( guy.GetTeam() != level.nv.attackingTeam )
			{
				Remote.CallFunction_Replay( guy, "SCB_BBVdu", panel.GetEncodedEHandle(), 1 )
			}
		}

		level.nv.bbHackStartTime = Time()
		level.bbHacked = true
		waitthread BBBombCountdown(hardpoint)


	}
}

function BBRoundStart() {

	local startTime = IsRoundBased() ? level.nv.roundStartTime : level.nv.gameStartTime
	foreach ( bbPanel in level.bbPanels )
	{
		bbPanel.SetUsableByGroup( "enemies pilot" )
		bbPanel.SetTeam(GetOtherTeam(level.nv.attackingTeam))
	}
}


function BBBombCountdown(hardpoint) {
	local panel = hardpoint.GetTerminal()
	printt("BB Panel Explosion Countdown Started")
	while(true) {
		foreach(guy in GetPlayerArray())
		{
			Remote.CallFunction_Replay( guy, "SCB_BBUpdate",null)
		}
		local startTime = IsRoundBased() ? level.nv.roundStartTime : level.nv.gameStartTime
		local timeElapsed = startTime - level.nv.bbHackStartTime
		printt("panel team: " + panel.GetTeam())
		printt("attacking team: " + level.nv.attackingTeam)
		printt("timeElapsed: " + timeElapsed)
		printt("timeElapsed: " + (EXPLO_TIME - timeElapsed))
		local result = WaitSignalTimeout(panel, EXPLO_TIME, "PanelReprogram_Success")
		if(result != null && result.signal == "PanelReprogram_Success") {
			printt("BB Panel Reprogrammed - Stop Explosion Countdown, panel reprogrammed")
			if (GamePlayingOrSuddenDeath())
			{
				SetWinLossReasons( "#BIG_BROTHER_PANEL_HACKED", "#BIG_BROTHER_PANEL_HACKED" )
				SetWinner( GetOtherTeam(level.nv.attackingTeam) )
			}
			level.nv.bbHackStartTime = 0.0
			level.bbHacked = false
			return
		}
		level.nv.bbHackStartTime = 0.0
		level.bbHacked = false
		thread NuclearCoreExplosion( panel.GetOrigin(), panel )
		// if (GamePlayingOrSuddenDeath())
		// {
		// 	SetWinLossReasons( "#HEIST_DATA_STOLEN", "#HEIST_TEAM_HACKED_PANEL" )
		// 	SetWinner( level.nv.attackingTeam )
		// }
		printt("BB Panel Explosion Countdown Tick")
		printt(timeElapsed)


	}



}

// function EntitiesDidLoad()
// {
// 	level.evacEnabled = false

// 	SetupAssaultPointKeyValues()
// }

// //LTS 플레이어 스폰 가능하게
// function LTS_OnPlayerRespawned( player )
// {
// 	if ( GetGameState() > eGameState.Playing )
// 		return

// 	if ( Riff_TitanAvailability() == eTitanAvailability.Once )
// 	{

// 	}
// }


// /*function BBEpilogueStart( )
// {
// 	local players = GetPlayerArray()

// 	foreach ( player in players )
// 	{
// 		if ( IsAlive( player ) )
// 			continue

// 		if ( !IsPlayerEliminated( player ) )
// 			continue

// 		ClearPlayerEliminated( player )
// 		DecideRespawnPlayer( player )
// 	}
// }*/

// //플레이어 위치 켜고 끄기 시작
// function UpdateMinimap()  //!ky 평소에도 플레이어 위치 보여주기
// {
// 	local players = GetPlayerArray()
// 	//wait 3.0
// 	foreach ( guy in players )
// 	{
// 		guy.Minimap_SetDefaultMaterial( "vgui/hud/cloak_drone_minimap_orange" )
// 		//guy.Minimap_SetAlignUpright( true )
// 		guy.Minimap_AlwaysShow(GetOtherTeam(guy.GetTeam()), null ) //상대팀만
// 		//guy.Minimap_AlwaysShow( TEAM_MILITIA, null )
// 		//guy.Minimap_SetObjectScale( MINIMAP_CLOAKED_DRONE_SCALE )
// 		guy.Minimap_SetZOrder( 10 )
// 	}
// 	wait 1.0
// 	DeleteMinimap ();
// }

// function DeleteMinimap()  //!ky 플레이어 위치 숨기기
// {
// 	local players = GetPlayerArray()
// 	foreach ( guy in players )
// 	{
// 		guy.Minimap_Hide(GetOtherTeam(guy), null ) //상대팀만
// 		//guy.Minimap_Hide( TEAM_MILITIA, null )
// 	}
// 	wait 8.0
// 	UpdateMinimap ();
// }

// //플레이어 위치 켜고 끄기 종료
// function BBPlayingStart()
// {
// 	FlagClear( "ForceStartSpawn" )

// 	local players = GetPlayerArray()
// 	foreach ( guy in players )
// 	{
// 		Remote.CallFunction_NonReplay( guy, "ServerCallback_GameModeAnnouncement" )

// 		//!ky 플레이어 위치 보여주기
// 		//thread UpdateMinimap ()
// 	}
// }

// function BBPrematchStart()
// {
// 	FlagSet( "ForceStartSpawn" )
// 	ClearTeamEliminationProtection()

// 	//!ky LTS 플레이어 스폰 가능하게

// 	local callOnce = false;
// 	local players = GetPlayerArray()
// 	foreach ( player in players )
// 	{
// 		player.titansBuilt = 0
// 		player.s.respawnCount = 0
// 		if ( Riff_TitanAvailability() == eTitanAvailability.Once )
// 		{
// 		}

// 		if(callOnce == false)
// 		{
// 			player.OnBBPrematchStart(GetOtherTeam(level.nv.attackingTeam))
// 			callOnce = true
// 		}
// 	}

// 	FlagSet( "DefendersWinDraw" )

// 	local players = GetPlayerArray()
// 	foreach ( guy in players )
// 	{
// 		guy.ResetObserverModeStaticPosition()
// 		guy.ResetObserverModeStaticAngles()

// 		Remote.CallFunction_NonReplay( guy, "ServerCallback_GameModeAnnouncement" )
// 		Remote.CallFunction_Replay( guy, "SCB_BBPreMatchStart" )

// 		//!ky 플레이어 위치 보여주기
// 		//thread UpdateMinimap ();
// 	}

// 	foreach ( panel in file.panels )
// 	{
// 		panel.SetTeam(GetOtherTeam(level.nv.attackingTeam))
// 		panel.SetUsable()
// 		panel.SetUsableByGroup( "enemies pilot" )
// 		panel.Minimap_AlwaysShow( TEAM_IMC, null )
// 		panel.Minimap_AlwaysShow( TEAM_MILITIA, null )

// 		panel.SetBBPanelEstimatedHackingTime( 0 )
// 		panel.SetBBPanelStartHackingTime( 0 )
// 		panel.SetBBPanelInProgress( false )
// 		panel.SetOtherPanelHacked( false )

// 		// 패널의 폭파 진행 정지.
// 		panel.Signal( "StopProgress" )

// 		// 패널 초기화
// 		local players = GetPlayerArray()
// 		foreach ( guy in players )
// 		{
// 			Remote.CallFunction_Replay( guy, "ServerCallback_BBPanelRefresh", panel.GetEncodedEHandle() )
// 			Remote.CallFunction_Replay( guy, "ServerCallback_BBPanelHud_Visible", panel.GetEncodedEHandle(), true )
// 		}
// 	}

// 	level.nv.BigbrotherPanelHacked = false
// 	level.nv.HackedBigbrotherPanelIndex = 0
// 	level.nv.BigBrotherPanelExplosion = false

// 	file.HackedPlayer = null

// 	// 터렛 방어팀으로.
// 	local turrets = GetNPCArrayByClass( "npc_turret_mega_bb" )
// 	printt( "[LJS] bbturret Size: ", turrets.len() )
// 	foreach( turret in turrets )
// 	{
// 		local newturret
// 		newturret = ReplaceDeadBBTurret( turret )
// 		thread CaptureBBTurret( newturret, GetOtherTeam(level.nv.attackingTeam))
// 		//thread CaptureBBTurret( turret, GetOtherTeam( level.nv.attackingTeam ) )
// 	}

// 	printl("BBPrematchStart")
// }

// function BBSwitchingSidesEnter()
// {
// 	// 공격팀인 MILITIA 만 드랍쉽 스폰, 방어팀은 지상스폰
// 	//EnableDropshipSpawnForTeam( TEAM_MILITIA )
// 	DisableDropshipSpawnForTeam( TEAM_MILITIA )
// 	DisableDropshipSpawnForTeam( TEAM_IMC )
// }

// function BBWinnerDeterminedStart()
// {
// 	local playerArray = GetPlayerArrayOfTeam( level.nv.attackingTeam )

// 	foreach ( guy in playerArray )
// 	{
// 		Remote.CallFunction_Replay( guy, "SCB_BBPanelHackingEnd" );
// 	}
// }

// function SecondsPlayerOrNPCKilled( entity, attacker, damageInfo )
// {
// 	if ( !entity.IsPlayer() && !entity.IsTitan() )
// 	return

// 	if ( attacker.IsPlayer() && attacker.GetTeam() != entity.GetTeam() && !attacker.IsTitan() )
// 	{
// 		//attacker.SetNextTitanRespawnAvailable( 0 )
// 		//thread TryETATitanReadyAnnouncement( attacker )
// 	}

// 	if ( GetGameState() != eGameState.Playing )
// 		return

// 	if ( !CheckEliminationModeWinner() )
// 		return

// 	thread EndingKillReplay( attacker )
// }

// function EndingKillReplay( attacker )
// {
// 	if ( !IsValid( attacker ) )
// 		return

// 	// npc kill replay at ending doesn't work perfectly yet.
// 	if ( attacker.IsNPC() )
// 		return

// 	attacker.EndSignal( "OnDestroy" )

// 	level.nv.replayDisabled = true
// 	wait 2.5

// 	local attackerViewIndex = attacker.GetIndexForEntity()
// 	local players = GetPlayerArray()
// 	foreach ( player in players )
// 	{
// 		player.Signal( "OnRespawned" ) // kill any active kill replays or respawning
// 		player.SetViewIndex( attackerViewIndex )
// 		player.SetKillReplayDelay( 7.0, true )
// 	}

// 	wait 7.0

// 	foreach ( player in players )
// 	{
// 		if ( !IsValid( player ) )
// 			continue

// 		player.SetKillReplayDelay( 0, true )
// 		player.ClearViewEntity()
// 	}

// 	level.nv.replayDisabled = false
// }

// function PanelIsHacked()
// {
// 	// disable the other panel
// 	foreach ( panel in file.panels )
// 	{
// 		if ( panel.GetTeam() == level.nv.attackingTeam )
// 			return true
// 	}
// 	return false
// }

// function BigBrother_UseSuccessPanel( panel, player )
// {
// 	printt( "panel " + panel + " hacked by " + player )

// 	local panelTeam = panel.GetTeam()
// 	if ( panelTeam == TEAM_UNASSIGNED )
// 		return

// 	if ( panelTeam == level.nv.attackingTeam )
// 	{
// 		DefenderHacksPanel( panel, player )
// 		return
// 	}

// 	if ( panelTeam == GetOtherTeam(level.nv.attackingTeam))
// 	{
// 		AttackerHacksPanel( panel, player )
// 		return
// 	}
// }

// // 패널 다시 활성 화
// function BigBrother_UseFailPanel( panel, player )
// {
// 	if( player.GetTeam() == level.nv.attackingTeam)
// 		return;

// 	// disable the other panelㄴ
// 	foreach ( other in file.panels )
// 	{
// 		if ( other == panel )
// 			continue

// 		other.SetTeam(GetOtherTeam(level.nv.attackingTeam))
// 		other.SetUsable()
// 		//other.Minimap_Hide( TEAM_IMC, null )
// 		//other.Minimap_Hide( TEAM_MILITIA, null )
// 	}
// }

// // 패널 해킹 시작 시 다른 패널 무효화.
// function BigBrother_UseStartPanel( panel, player )
// {
// 	if( player.GetTeam() == GetOtherTeam(level.nv.attackingTeam))
// 		return;

// 	// disable the other panel
// 	foreach ( other in file.panels )
// 	{
// 		if ( other == panel )
// 			continue

// 		// 패널 해킹 진행 정지.
// 		//other.Signal( "StopHacking")

// 		other.UnsetUsable()
// 		//other.Minimap_Hide( TEAM_IMC, null )
// 		//other.Minimap_Hide( TEAM_MILITIA, null )
// 		//other.SetTeam( TEAM_UNASSIGNED )
// 	}
// }

// function AttackerHacksPanel( panel, player )
// {
// 	Assert( player.GetTeam() == level.nv.attackingTeam, "Player of team " + player.GetTeam() + " used panel when it was on his team!" )

// 	// 이미 해킹된 패널이 있다면 건너뛴다.
// 	if( level.nv.BigbrotherPanelHacked == true )
// 		return

// 	//JumpTimeLimit( 10 )
// 	JumpTimeLimit( EXPLO_TIME )

// 	panel.SetTeam( level.nv.attackingTeam )
// 	panel.SetUsableByGroup( "enemies pilot" )

// 	// disable the other panel
// 	foreach ( other in file.panels )
// 	{
// 		if ( other == panel )
// 			continue

// 		other.UnsetUsable()
// 		other.Minimap_Hide( TEAM_IMC, null )
// 		other.Minimap_Hide( TEAM_MILITIA, null )
// 		other.SetTeam( TEAM_UNASSIGNED )

// 		other.SetOtherPanelHacked( true )
// 	}

// 	// attackers win if time runs out
// 	FlagClear( "DefendersWinDraw" )

// 	level.nv.BigbrotherPanelHacked = true
// 	foreach ( index, panelName in file.bigBrotherPanelNames )
// 	{
// 		if( panelName == panel.GetName() )
// 		{
// 			level.nv.HackedBigbrotherPanelIndex = index+1 // 1 Base
// 			break
// 		}
// 	}

// 	printt( "[LJS] HackedBigbrotherPanelIndex = ", level.nv.HackedBigbrotherPanelIndex )

// 	player.OnAttackerHacksPanel( level.nv.HackedBigbrotherPanelIndex )


// 	//Minimap_CreatePingForTeam( TEAM_IMC, panel.GetOrigin(), "vgui/HUD/firingPing", 3.0 )
// 	//Minimap_CreatePingForTeam( TEAM_MILITIA, panel.GetOrigin(), "vgui/HUD/firingPing", 3.0 )

// 	ProtectTeamFromElimination( level.nv.attackingTeam )

// 	panel.SetBBPanelEstimatedHackingTime( EXPLO_TIME )
// 	panel.SetBBPanelStartHackingTime( Time() )
// 	panel.SetBBPanelInProgress( true )

// 	file.HackedPlayer = player

// 	local players = GetPlayerArray()
// 	foreach ( guy in players )
// 	{
// 		Remote.CallFunction_Replay( guy, "SCB_BBAttackerHacks", player.GetEncodedEHandle() )
// 	}


// 	local turret = GetBBTurretLinkedToPanel( panel )
// 	thread CaptureBBTurret( turret, level.nv.attackingTeam, player )

// 	// 다른 터렛은 disable 상태로.
// 	local turrets = GetNPCArrayByClass( "npc_turret_mega_bb" )
// 	foreach( otherTurret in turrets )
// 	{
// 		if( otherTurret == turret )
// 			continue

// 		ReleaseBBTurret( otherTurret )
// 	}


// 	thread ExplosionProgress( panel, EXPLO_TIME )

// 	/* 폭파 테스트
// 	thread RadiusDamage( panel.GetOrigin(),	// origin
// 	100000,								// titan damage
// 	1000,								// pilot damage
// 	100000,		// radiusFalloffMax
// 	0,								// radiusFullDamage
// 	null, 						// owner
// 	eDamageSourceId.nuclear_core,  // damage source id
// 	true,							// alive only
// 	false,							// selfDamage
// 	null,							// team
// 	null )							// scriptFlags
// 	*/
// }

// function JumpTimeLimit( val )
// {
// 	local timeLimit = (GetRoundTimeLimit_ForGameMode() * 60.0).tointeger()
// 	level.nv.roundStartTime = Time() - ( timeLimit - val )
// 	level.nv.roundEndTime = Time() + val
// 	level.nv.gameStateChangeTime = Time() - ( timeLimit - val )
// }
// Globalize( JumpTimeLimit )

// function DefenderHacksPanel( panel, player )
// {
// 	Assert( player.GetTeam() != level.nv.attackingTeam, "Player of team " + player.GetTeam() + " used panel when it was on his team!" )
// 	panel.SetTeam(GetOtherTeam(level.nv.attackingTeam))

// 	local players = GetPlayerArray()
// 	foreach ( guy in players )
// 	{
// 		Remote.CallFunction_Replay( guy, "ServerCallback_BBPanelRefresh", panel.GetEncodedEHandle() )
// 		Remote.CallFunction_Replay( guy, "SCB_BBDefenderHacks", player.GetEncodedEHandle() )
// 		//guy.Signal( "StopProgress" );
// 	}

// 	SetWinLossReasons( "#BIG_BROTHER_PANEL_HACKED", "#BIG_BROTHER_PANEL_HACKED" )
// 	SetWinner(GetOtherTeam(level.nv.attackingTeam))

// 	panel.SetBBPanelEstimatedHackingTime( 0 )
// 	panel.SetBBPanelStartHackingTime( 0 )
// 	panel.SetBBPanelInProgress( false )

// 	if ( GetTitanBuildRule()/*GameRules.GetTitanBuildRule()*/ == eTitanBuildRule.RULE_POINT )
// 	{
// 		// 해체한 플레이어에게 빌드포인트 추가.+
// 		AddTitanBuildPoint( player, "DefenderHacksPanel" )
// 	}

// 	// 패널의 폭파 진행 정지.
// 	panel.Signal( "StopProgress" )

// 	local turret = GetBBTurretLinkedToPanel( panel )
// 	ReleaseBBTurret( turret )

// 	player.OnDefenderHacksPanel()
// }

// function CreateBigBrotherPanel( origin, angles )
// {
// 	local panel = CreateEntity( "prop_bigbrother_panel" )
// 	panel.kv.model = MODEL_BIGBROTHER_PANEL
// 	panel.kv.solid = 2
// 	panel.s.gamemode_bb <- true

// 	DispatchSpawn( panel, false )

// 	panel.SetOrigin( origin )
// 	panel.SetAngles( angles )

// }
// Globalize( CreateBigBrotherPanel )

// function BBPanelHackStartFunc( panel, player )
// {
// 	Remote.CallFunction_Replay( player, "SCB_BBVdu", panel.GetEncodedEHandle(), 1 )


// 	// 공격팀에만 해킹중이라는 메세지 출력.
// 	if( player.GetTeam() != level.nv.attackingTeam )
// 		return;

// 	local playerArray = GetPlayerArrayOfTeam( player.GetTeam() )

// 	foreach ( guy in playerArray )
// 	{
// 		if( guy == player )
// 			continue

// 		Remote.CallFunction_Replay( guy, "SCB_BBPanelHackingStart" );
// 	}
// }

// function BBPanelHackEndFunc( panel, player )
// {
// 	// 판넬의 팀이 방어 팀일 경우에는 수정 하지 않는다.
// 	if(panel.GetTeam() == GetOtherTeam(level.nv.attackingTeam))
// 	{
// 		panel.SetTeam(GetOtherTeam(level.nv.attackingTeam)) //공격팀을 다른 팀으로 바꾼다
// 		panel.SetUsable() //해킹 가능
// 		panel.SetUsableByGroup( "enemies pilot" ) //공격팀이 바뀌었으므로, 적 파일럿만 해킹 가능
// 		panel.Minimap_AlwaysShow( TEAM_IMC, null ) //해킹한 패널을 미니맵에 보여준다
// 		panel.Minimap_AlwaysShow( TEAM_MILITIA, null ) //해킹한 패널을 미니맵에 보여준다
// 	}
// 	else //??
// 	{
// 		panel.SetTeam( level.nv.attackingTeam ) //공격팀을 다른 팀으로 바꾼다
// 		panel.SetUsable() //해킹 가능
// 		panel.SetUsableByGroup( "enemies pilot" ) //공격팀이 바뀌었으므로, 적 파일럿만 해킹 가능
// 		panel.Minimap_AlwaysShow( TEAM_IMC, null ) //해킹한 패널을 미니맵에 보여준다
// 		panel.Minimap_AlwaysShow( TEAM_MILITIA, null ) //해킹한 패널을 미니맵에 보여준다

// 	}

// 	Remote.CallFunction_Replay( player, "SCB_BBVdu", panel.GetEncodedEHandle(), 0 )

// 	// 공격팀에만 해킹중이라는 메세지 끄기.
// 	local team = player.GetTeam();

// 	if( team == level.nv.attackingTeam )
// 	{
// 		local playerArray = GetPlayerArrayOfTeam( team )

// 		foreach ( guy in playerArray )
// 		{
// 			if( guy == player )
// 				continue

// 			Remote.CallFunction_Replay( guy, "SCB_BBPanelHackingEnd" );
// 		}
// 	}
// }

// function PanelHasGameModeKey( panel )
// {
// 	if ( "gamemode_bb" in panel.s )
// 		return true

// 	local key = "gamemode_bb"
// 	if ( !panel.HasKey( key ) )
// 		return false
// 	return panel.kv[ key ] == "1"
// }

// function OnBigBrotherPanelSpawn( panel )
// {
// 	if ( !PanelHasGameModeKey( panel ) )
// 		return

// 	//local panelIndex = file.panels.len()

// 	// panel name is prop_bigbrother_panel_(number)
// 	local temp = split( panel.kv.targetname, "prop_bigbrother_panel_" );
// 	printt( temp[0] )
// 	local panelIndex = ( temp[0].tointeger() ) - 1 // 0 base

// 	printt( "[LJS] Spawn Panel: ", panel.kv.targetname )
// 	printt( "[LJS] Spawn Panel Index: ", panelIndex )

// 	local name = file.bigBrotherPanelNames[ panelIndex ]
// 	panel.SetName( name )

// 	panel.s.panelHackStartFunc 	= BBPanelHackStartFunc
// 	panel.s.panelHackEndFunc 	= BBPanelHackEndFunc
// 	panel.s.panelHackScope 		= this

// 	//panel.s.leechTimeNormal = 7.0 *테스트 사양으로 수정 by kyjung
// 	panel.s.leechTimeNormal = 4.0
// 	//panel.s.leechTimeFast = 4.5
// 	panel.s.leechTimeFast = 3.0


// 	//local hardpoint = CreateEntity( "info_hardpoint" )
// 	//DispatchSpawn( hardpoint, false )
// 	//hardpoint.SetHardpointID( panelIndex )
// 	//hardpoint.SetTerminal( panel )

// 	local panelMats = GetHardpointMats( panelIndex )

// 	//local icon = "VIP_friendly"
// 	panel.Minimap_SetDefaultMaterial( GetMinimapMaterial( panelMats.neutral ) )
// 	panel.Minimap_SetFriendlyMaterial( GetMinimapMaterial( panelMats.friendly ) )
// 	panel.Minimap_SetEnemyMaterial( GetMinimapMaterial( panelMats.enemy ) )
// 	panel.Minimap_SetObjectScale( 0.11 )
// 	panel.Minimap_SetAlignUpright( true )
// 	panel.Minimap_SetClampToEdge( true )
// 	panel.Minimap_SetFriendlyHeightArrow( true )
// 	panel.Minimap_SetEnemyHeightArrow( true )
// 	panel.Minimap_SetZOrder( 10 )

// 	SetBBPanelUseSuccessFunc( panel, BigBrother_UseSuccessPanel, this )
// 	SetBBPanelUseFailFunc( panel, BigBrother_UseFailPanel, this )
// 	SetBBPanelUseStartFunc( panel, BigBrother_UseStartPanel, this )

// 	file.panels.append( panel )
// }

// function GetHardpointMats( panelIndex )
// {
// 	local panelNames = [ "a", "b" ]
// 	local panelMaterials = {}
// 	panelMaterials.a <- { friendly = "hardpoint_friendly_a", neutral = "hardpoint_neutral_a", enemy = "hardpoint_enemy_a" }
// 	panelMaterials.b <- { friendly = "hardpoint_friendly_b", neutral = "hardpoint_neutral_b", enemy = "hardpoint_enemy_b" }

// 	Assert( panelIndex < panelNames.len(), "Too many big brother control panels." )
// 	local panelLetter = panelNames[ panelIndex ]
// 	local panelMats = panelMaterials[ panelLetter ]
// 	return panelMats
// }


// //! 폭파 관련 처리
function NuclearCoreExplosion( origin, panel )
{
	//! 기존의 핵 FX 삭제
	/*
	OnThreadEnd(
		function() : ( panel )
		{
			ClearNuclearBlueSunEffect( panel )
		}
	)
	wait 1.3
	*/
	local panelEHandle = IsValid( panel ) ? panel.GetEncodedEHandle() : null
	local callOnce = false
	local players = GetPlayerArray()
	foreach( player in players )
	{
		// Remote.CallFunction_Replay( player, "ServerCallback_BBPanelHud_Visible", panelEHandle, false )
		if(callOnce == false)
		{
			player.OnNuclearCoreExplosion()
			callOnce = true
		}
	}

	//local attachmentIndex = panel.LookupAttachment( "PANEL_SCREEN_MIDDLE" )
	//local fxOrigin = panel.GetAttachmentOrigin( attachmentIndex )

	local fxEnt
	local fxOrigin

	if( StringContains( panel.GetName(), "_a" ) )
	{
		fxEnt = GetEnt( "out_A" )
	}
	else if( StringContains( panel.GetName(), "_b" ) )
	{
		fxEnt = GetEnt( "out_B" )
	}

	if( fxEnt )
	{
		fxOrigin = fxEnt.GetOrigin()
	}
	else
	{
		local attachmentIndex = panel.LookupAttachment( "PANEL_SCREEN_MIDDLE" )
		fxOrigin = panel.GetAttachmentOrigin( attachmentIndex )
	}


	EmitSoundAtPosition( fxOrigin, "titan_nuclear_death_charge" )

	wait BLUESUN_TIME

	//! 폭파 처리
	thread NuclearCoreExplosionChainReaction( fxOrigin, panel )
}

//! 핵 FX 처리 루틴
function NuclearCoreExplosionChainReaction( origin, panel )
{
	local explosions
	local explosionDist
	local time
	local IsNPC

	local titanDamage 		= 20000
	local nonTitanDamage 	= 15000

	explosions = 1
	explosionDist = 2100	// 6000
	time = 1.7

	local waitPerExplosion = time / explosions

	//! 핵 사운드 출력
	EmitSoundAtPosition( origin, "titan_nuclear_death_explode" )

	//! FX 출력origin, Vector(0,RandomInt(360),0) )
	PlayFX( FX_BIGBROTHER_PANEL_EXPLOSION, origin, Vector(0,RandomInt(360),0) )

	// one extra explosion that does damage to physics entities at smaller radius
	explosions += 1

	for ( local i = 0; i < explosions; i++ )
	{
		local explosionOwner = level.HackedPlayer

		//RadiusDamage( origin, titanDamage, nonTitanDamage, explosionDist, 0, explosionOwner, eDamageSourceId.nuclear_core, true, true, null, null )

		RadiusDamage( panel.GetOrigin(),	// origin
		titanDamage,								// titan damage
		nonTitanDamage,								// pilot damage
		explosionDist,		// radiusFalloffMax
		0,								// radiusFullDamage
		null, 					// owner
		eDamageSourceId.nuclear_core,  // damage source id
		false,							// alive only
		true,							// selfDamage
		null,							// team
		null							// scriptFlags
		)
		wait waitPerExplosion
	}

	wait 1.0

	// 폭탄이 터지기 직전에 방어팀이 엘리된 경우, 처리 스레드가 달라서 꼬임. 그래서 여기에 조건 추가.
	if (GamePlayingOrSuddenDeath())
	{
		SetWinLossReasons( "#HEIST_DATA_STOLEN", "#HEIST_TEAM_HACKED_PANEL" )
		SetWinner( level.nv.attackingTeam )
	}
}

// //! AttackerHacksPanel 에서 호출
// function ExplosionProgress( panel, waitTime )
// {
// 	WaitSignalTimeout( panel, waitTime, "StopProgress" )

// 	// 패널이 방어팀 소유라면 해킹 실패
// 	if( panel.GetTeam() != level.nv.attackingTeam )
// 	{
// 		return
// 	}

// 	// 방어팀이 엘리라면 정지.
// 	if( IsTeamElimination(GetOtherTeam(level.nv.attackingTeam)))
// 	{
// 		return
// 	}


// 	level.nv.BigBrotherPanelExplosion = true

// 	panel.Signal( "StopHacking" )

// 	// player 및 같은 팀 플레이어의 옵저버 모드를 바꿈.
// 	local playerArray = GetPlayerArray()
// 	foreach ( guy in playerArray )
// 	{
// 		local vec = panel.GetOrigin() - guy.GetOrigin()
//   		local dist = vec.Length()

//   		if( dist <= EXPLO_CAM_LIMIT_DIST )
//   			continue

//   		// 카메라 이동
// 		local panelCam
// 		if( GetHackedBBPanelIndex() == 1 )
// 		{
// 			panelCam = level.DeathCamOutSide_A
// 			printt( "[LJS] Set panel_cam10" )
// 		}
// 		else
// 		{
// 			panelCam = level.DeathCamOutSide_B
// 			printt( "[LJS] Set panel_cam20" )
// 		}

// 		local camOrigon = panelCam.GetOrigin()
// 		local camAngles = panelCam.GetAngles()
//   		Remote.CallFunction_Replay( guy, "SCB_BBExplosion", camOrigon.x, camOrigon.y, camOrigon.z, camAngles.x, camAngles.y, camAngles.z )
// 	}

// 	thread NuclearCoreExplosion( panel.GetOrigin(), panel )

// }
const RUSH_POINT_CNT = 2
//const PANEL_RUSH_DELAY = 60
const PANEL_RUSH_DELAY = 45
const MAX_HACKED_COUNT = 3

function main()
{
	Assert( !GetCinematicMode(), "Cannot play tr in cinematic mode" )

	// 엘리 로 게임 종료
	//level.nv.eliminationMode = eEliminationMode.Pilots

	// 타이탄 빌드 한번만
	//if ( Riff_SpawnAsTitan() == eSpawnAsTitan.Default )
	//level.nv.spawnAsTitan = eSpawnAsTitan.Once

	/*
	local rule = GameRules.GetTitanBuildRule()

	if ( rule == eTitanBuildRule.RULE_POINT )
	{
		//level.nv.titanAvailability = eTitanAvailability.Custom 함수 등록해서 사용하자. todo.
		level.nv.titanAvailability = eTitanAvailability.Default
	}
	else
	{
		if ( Riff_TitanAvailability() == eTitanAvailability.Default )//처음부터 타이탄 사용 가능
			level.nv.titanAvailability = eTitanAvailability.Once //타이탄은 라운드에 한 번만 사용 가능
	}
	*/

	level.nv.titanAvailability = eTitanAvailability.Default

	level.nv.attackingTeam = TEAM_IMC

	// 드랍쉽 스폰 사용.
	FlagSet( "GameModeAlwaysAllowsClassicIntro" )
	// 공격팀인 IMC 만 드랍쉽 스폰, 방어팀은 지상스폰
	EnableDropshipSpawnForTeam( TEAM_IMC )
	DisableDropshipSpawnForTeam( TEAM_MILITIA )

	//SetRoundBased( true )
	//SetSwitchSidesBased( true )
	FlagSet( "ForceStartSpawn" )

	//RegisterSignal( "ChangeSpawnPoint" )
	RegisterSignal( "StopRushPanelProgress" )
	
	SetGameModeAnnouncement( "GameModeAnnounce_AT" )

	AddCallback_GameStateEnter( eGameState.Prematch, TRPrematchStart )
	AddCallback_GameStateEnter( eGameState.Playing, TRPlayingStart )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, TRWinnerDeterminedStart )

	//AddCallback_GameStateEnter( eGameState.Epilogue, BBEpilogueStart )

	AddSpawnCallback( "prop_rush_panel", 		OnRushPanelSpawn )

	file.rushpanels <- []
	file.rushPanelNames <- [ "rush_panel_a", "rush_panel_b" ]

	file.HackedRushPanels <- []
	file.HackedPlayers <- []
	file.RushCount <- 0

	for( local i = 0; i < RUSH_POINT_CNT; i++ )
	{
		file.HackedRushPanels.append( null );
		file.HackedPlayers.append( null ); 
	}
}

function EntitiesDidLoad()
{
	//level.evacEnabled = false
	level.evacEnabled = true

	SetupAssaultPointKeyValues()
	//thread SetupTeamDeathmatchNPCs()
}

function TRPlayingStart()
{
	FlagClear( "ForceStartSpawn" )
}


function TRPrematchStart()
{
	FlagSet( "ForceStartSpawn" )
	ClearTeamEliminationProtection()

	FlagSet( "DefendersWinDraw" )

	foreach ( rushpanel in file.rushpanels )
	{
		rushpanel.SetTeam(GetTeamIndex(GetOtherTeams(1 << level.nv.attackingTeam)))
		//rushpanel.SetTeam( TEAM_UNASSIGNED )
		rushpanel.SetUsable()
		rushpanel.SetUsableByGroup( "enemies pilot" )

		rushpanel.Minimap_AlwaysShow( TEAM_IMC, null )
		rushpanel.Minimap_AlwaysShow( TEAM_MILITIA, null )
	}

	for( local i = 0; i < RUSH_POINT_CNT; i++ )
	{
		file.HackedRushPanels[i]	= null
		file.HackedPlayers[i]		= null; 
	}

	printl("TRPrematchStart")
}

function APanelIsHacked()
{
	// disable the other panel
	foreach ( rushpanel in file.rushpanels )
	{
		if ( rushpanel.GetTeam() == level.nv.attackingTeam )
			return true
	}
	return false
}

function TitanRush_UsePanel( rushpanel, player )
{
	local panelIndex

	foreach ( Index, panel in file.rushpanels )
	{
		if( panel == rushpanel )
		{
			panelIndex = Index;
			break;
		}
	}

	Assert( panelIndex < file.rushpanels.len() )

	printt( "panel " + rushpanel + " hacked by " + player )

	local panelTeam = rushpanel.GetTeam()
	if ( panelTeam == TEAM_UNASSIGNED )
		return

	if ( panelTeam == level.nv.attackingTeam )
	{
		DefenderHacksPanel( rushpanel, panelIndex, player )
		return
	}

	//if ( panelTeam == TEAM_UNASSIGNED )
	if ( panelTeam == GetTeamIndex(GetOtherTeams(1 << level.nv.attackingTeam)))
	{
		AttackerHacksPanel( rushpanel, panelIndex, player )
		return
	}
}

function AttackerHacksPanel( rushpanel, panelIndex, player )
{
	Assert( player.GetTeam() == level.nv.attackingTeam, "Player of team " + player.GetTeam() + " used panel when it was on his team!" )
	rushpanel.SetTeam( level.nv.attackingTeam )
	rushpanel.SetUsableByGroup( "enemies pilot" )

	local players = GetPlayerArray()
	foreach ( guy in players )
	{
		Remote.CallFunction_Replay( guy, "SCB_TRUpdate", player.GetEncodedEHandle(), eRushPanelState.ATTACK )
	}
	// attackers win if time runs out
	//FlagClear( "DefendersWinDraw" )

	//JumpTimeLimit( 10 )
	//JumpTimeLimit( 45 )


	ProtectTeamFromElimination( level.nv.attackingTeam )


	local hackedCount = GetHackedPanelCount()
	local result = {}
	result.spawnCase <- eTitanRushSpawnCase.NORMAL;

	// 이전에 아무것도 해킹되어있지 않고
	if( hackedCount == 0)
	{
		if( rushpanel.GetName() == file.rushPanelNames[0] ) // A 패널만 해킹 시
		{
			result.spawnCase = eTitanRushSpawnCase.HACKED_A
		}
		else // B 패널만 해킹 시
		{
			result.spawnCase = eTitanRushSpawnCase.HACKED_B
		}
	}
	// 이전에 해킹이 되어있었다면 현재 해킹 후 둘다 해킹된 상태.
	else
	{
		result.spawnCase = eTitanRushSpawnCase.HACKED_A_B
	}

	printt(" Signal ChangeSpawnPoint")
	Signal( level.ent, "ChangeSpawnPoint", result )


	//! 판넬 저장
	file.HackedRushPanels[panelIndex]	= rushpanel
	file.HackedPlayers[panelIndex]		= player

	// 폭탄 설치 플레이어에게 빌드포인트 부여
	if ( IsTitanBuildPointRule() )
	{
		AddTitanBuildPoint( player, "TeamAttackRushPanel" )
	}
	else if( IsTitanBuildTimeRule() )
	{
		// 기본 빌드룰일 경우 5초깎기
		DecrementBuildCondition( player, 5 )
	}

	//local delayTime = PANEL_RUSH_DELAY - (5 * rushpanel.s.hackedCount )
	local delayTime = PANEL_RUSH_DELAY - (5 * rushpanel.s.hackedCount )

	rushpanel.SetRushPanelEstimatedRushTime( delayTime )
	rushpanel.SetRushPanelInProgress(true)
	rushpanel.SetRushPanelStartRushTime( Time() )

	thread RushWait( rushpanel, delayTime )
}

function DefenderHacksPanel( rushpanel, panelIndex, player )
{
	Assert( player.GetTeam() != level.nv.attackingTeam, "Player of team " + player.GetTeam() + " used panel when it was on his team!" )
	//SetWinLossReasons( "#BIG_BROTHER_PANEL_HACKED", "#BIG_BROTHER_PANEL_HACKED" )
	//SetWinner( GetOtherTeam( level.nv.attackingTeam ) )
	
	rushpanel.SetTeam( player.GetTeam() )
	//rushpanel.SetTeam( TEAM_UNASSIGNED )


	//! 판넬 초기화
	file.HackedRushPanels[panelIndex]	= null
	file.HackedPlayers[panelIndex]		= null; 

	local players = GetPlayerArray()
	foreach ( guy in players )
	{
		Remote.CallFunction_Replay( guy, "SCB_TRUpdate", player.GetEncodedEHandle(), eRushPanelState.DEFENCE )
	}

	local result = {}
	result.spawnCase <- eTitanRushSpawnCase.NORMAL;

	local hackedCount = GetHackedPanelCount()

	if( rushpanel.GetName() == file.rushPanelNames[0] ) // A 패널 해제
	{
		if( hackedCount != 0 || file.RushCount != 0 ) // B 가 해킹되어있거나 파괴되어있는 상태
		{
			result.spawnCase = eTitanRushSpawnCase.HACKED_B
		}
	}
	else // B 패널 해제
	{
		if( hackedCount != 0 || file.RushCount != 0 ) // A 가 해킹되어있거나 파괴되어있는 상태
		{
			result.spawnCase = eTitanRushSpawnCase.HACKED_A
		}
	}

	// 패널의 해킹 히스토리 카운트 증가
	rushpanel.s.hackedCount++

	if( rushpanel.s.hackedCount > MAX_HACKED_COUNT )
	{
		rushpanel.s.hackedCount = MAX_HACKED_COUNT
	}

	rushpanel.SetRushPanelEstimatedRushTime(0)
	rushpanel.SetRushPanelInProgress(false)
	rushpanel.SetRushPanelStartRushTime( 0 )

	// 패널의 폭파 진행 정지.
	rushpanel.Signal( "StopRushPanelProgress" )

	printt(" Signal ChangeSpawnPoint")
	Signal( level.ent, "ChangeSpawnPoint", result )
}

function GetHackedPanelCount()
{
	local count = 0

	for( local i = 0; i < RUSH_POINT_CNT; i++ )
	{
		if( file.HackedRushPanels[i] != null )
		{
			count++
		}
	}

	return count
}

function RushWait( rushPanel, rushTime )
{
	OnThreadEnd(
		function() : ( rushPanel, rushTime )
		{

		}
	)

	WaitSignalTimeout( rushPanel,  rushTime, "StopRushPanelProgress" )

	// 폭발
	// 만약 해제된 패널이면 pass
	if(  rushPanel.GetTeam() == GetTeamIndex(GetOtherTeams(1 << level.nv.attackingTeam)))
	{
		return
	}
	else if( rushPanel.GetTeam() == level.nv.attackingTeam )
	{
		foreach ( index, panel in file.HackedRushPanels )
		{
			if( panel == rushPanel )
			{
				// 폭발
				file.RushCount++

				// 패널 비활성화
				local destroyPanelName = rushPanel.GetName()

				rushPanel.UnsetUsable()
				rushPanel.Minimap_Hide( TEAM_IMC, null )
				rushPanel.Minimap_Hide( TEAM_MILITIA, null )
				rushPanel.SetTeam( TEAM_UNASSIGNED )

				panel.SetRushed( true )

				local players = GetPlayerArray()
				foreach ( guy in players )
				{
					// 폭탄 설치한 플레이어를 제외한 공격 팀원에게 빌드포인트 2점씩.
					if( guy.GetTeam() == level.nv.attackingTeam && guy != file.HackedPlayers[index])
					{
						// 폭탄 설치 플레이어에게 빌드포인트 부여
						if ( IsTitanBuildPointRule() )
						{
							AddTitanBuildPoint( guy, "TeamRushPanelDestroy" )
						}
						else if( IsTitanBuildTimeRule() )
						{
							// 기본 빌드룰일 경우 2초깎기
							DecrementBuildCondition( guy, 2 )
						}
					}
					
					Remote.CallFunction_Replay( guy, "SCB_TRUpdate", file.HackedPlayers[index].GetEncodedEHandle(), eRushPanelState.DESTROY )
				}

				thread NuclearCoreExplosion(file.HackedRushPanels[index].GetOrigin(), file.HackedPlayers[index] )

				// 폭탄 폭발시 설치한 플레이어에게 빌드포인트 부여
				if ( IsTitanBuildPointRule() )
				{
					AddTitanBuildPoint( file.HackedPlayers[index], "PlayerRushPanelDestroy" )
				}
				else if( IsTitanBuildTimeRule() )
				{
					// 기본 빌드룰일 경우 5초깎기
					DecrementBuildCondition( file.HackedPlayers[index], 5 )
				}
				
				file.HackedRushPanels[index] = null
				file.HackedPlayers[index] = null

				if( file.RushCount ==  RUSH_POINT_CNT )
				{
					SetWinner( level.nv.attackingTeam )
				}
				else // SpawnCase 설정
				{
					local hackedCount = GetHackedPanelCount()
					local result = {}
					result.spawnCase <- eTitanRushSpawnCase.NORMAL;

					if( destroyPanelName == file.rushPanelNames[0] ) // A 패널 파괴
					{
						// A 파괴 B 해킹
						if( hackedCount != 0 )
						{
							result.spawnCase = eTitanRushSpawnCase.HACKED_B	
						}
						else // A 파괴
						{
							result.spawnCase = eTitanRushSpawnCase.DESTROY_A	
						}
					}
					else // B 패널 파괴
					{
						// B 파괴 A 해킹
						if( hackedCount != 0 )
						{
							result.spawnCase = eTitanRushSpawnCase.HACKED_A	
						}
						else // B 파괴
						{
							result.spawnCase = eTitanRushSpawnCase.DESTROY_B
						}
					}

					printt(" Signal ChangeSpawnPoint")
					Signal( level.ent, "ChangeSpawnPoint", result )
				}
				
				break
			}
		}
	}

}

function TRPanelHackStartFunc( rushpanel, player )
{
	Remote.CallFunction_Replay( player, "SCB_TRVdu", rushpanel.GetEncodedEHandle(), 1 )
}

function TRPanelHackEndFunc( rushpanel, player )
{
	// 패널의 팀이 방어팀 일 경우 Time 리셋
	//if(rushpanel.GetTeam() == TEAM_UNASSIGNED )
	if(rushpanel.GetTeam() == GetTeamIndex(GetOtherTeams(1 <<level.nv.attackingTeam)))
	{
		rushpanel.SetTeam(GetTeamIndex(GetOtherTeams(1 << level.nv.attackingTeam)))
		//rushpanel.SetTeam( TEAM_UNASSIGNED )
		rushpanel.SetUsable() //해킹 가능
		rushpanel.SetUsableByGroup( "enemies pilot" ) //공격팀이 바뀌었으므로, 적 파일럿만 해킹 가능

		// 미니맵 이미지 다시 중립으로
		local panelIndex = GetRushPanelIndex( rushpanel )

		Assert( panelIndex != -1 )

		local panelMats = GetRushpointMats( panelIndex )
		rushpanel.Minimap_SetDefaultMaterial( GetMinimapMaterial( panelMats.neutral ) )
		rushpanel.Minimap_SetFriendlyMaterial( GetMinimapMaterial( panelMats.neutral ) )
		rushpanel.Minimap_SetEnemyMaterial( GetMinimapMaterial( panelMats.neutral ) )
		//

		rushpanel.Minimap_AlwaysShow( TEAM_IMC, null ) //해킹한 패널을 미니맵에 보여준다
		rushpanel.Minimap_AlwaysShow( TEAM_MILITIA, null ) //해킹한 패널을 미니맵에 보여준다

		//local delayTime = PANEL_RUSH_DELAY - (5 * rushpanel.s.hackedCount )
		//ChangeTimeLimit( -delayTime )
	}
	// 패널의 팀이 공격팀인 경우 Time 셋팅
	else if( rushpanel.GetTeam() == level.nv.attackingTeam )
	{
		rushpanel.SetTeam( level.nv.attackingTeam ) //공격팀을 다른 팀으로 바꾼다
		rushpanel.SetUsable() //해킹 가능
		rushpanel.SetUsableByGroup( "enemies pilot" ) //공격팀이 바뀌었으므로, 적 파일럿만 해킹 가능

		// // 미니맵 이미지 설정
		local panelIndex = GetRushPanelIndex( rushpanel )

		Assert( panelIndex != -1 )

		local panelMats = GetRushpointMats( panelIndex )
		rushpanel.Minimap_SetDefaultMaterial( GetMinimapMaterial( panelMats.neutral ) )
		rushpanel.Minimap_SetFriendlyMaterial( GetMinimapMaterial( panelMats.friendly ) )
		rushpanel.Minimap_SetEnemyMaterial( GetMinimapMaterial( panelMats.enemy ) )
		//

		rushpanel.Minimap_AlwaysShow( TEAM_IMC, null ) //해킹한 패널을 미니맵에 보여준다
		rushpanel.Minimap_AlwaysShow( TEAM_MILITIA, null ) //해킹한 패널을 미니맵에 보여준다

		//ChangeTimeLimit( delayTime )
	}

	Remote.CallFunction_Replay( player, "SCB_TRVdu", rushpanel.GetEncodedEHandle(), 0 )
}

function PanelHasGameModeKey( rushpanel )
{
	if ( "gamemode_tr" in rushpanel.s )
		return true

	local key = "gamemode_tr"
	if ( !rushpanel.HasKey( key ) )
		return false
	return rushpanel.kv[ key ] == "1"
}

function OnRushPanelSpawn( rushpanel )
{
	if ( !PanelHasGameModeKey( rushpanel ) )
		return

	printt( "[LJS] call OnRushPanelSpawn" )

	local panelIndex = file.rushpanels.len()

	local name = file.rushPanelNames[ panelIndex ]

	printt( "[panel Name] : ", name )

	rushpanel.SetName( name )

	rushpanel.s.panelHackStartFunc 	= TRPanelHackStartFunc
	rushpanel.s.panelHackEndFunc 	= TRPanelHackEndFunc
	rushpanel.s.panelHackScope 		= this

	rushpanel.s.leechTimeNormal = 5.0 ///패널 해킹 시간 
	//panel.s.leechTimeFast = 4.5
	rushpanel.s.leechTimeFast = 3.5

	local panelMats = GetRushpointMats( panelIndex )

	local icon = "VIP_friendly"

	// 초기 이미지 셋팅은 무조건 중립으로.
	rushpanel.Minimap_SetDefaultMaterial( GetMinimapMaterial( panelMats.neutral ) )
	rushpanel.Minimap_SetFriendlyMaterial( GetMinimapMaterial( panelMats.neutral ) )
	rushpanel.Minimap_SetEnemyMaterial( GetMinimapMaterial( panelMats.neutral ) )
	//

	rushpanel.Minimap_SetObjectScale( 0.11 )
	rushpanel.Minimap_SetAlignUpright( true )
	rushpanel.Minimap_SetClampToEdge( true )
	rushpanel.Minimap_SetFriendlyHeightArrow( true )
	rushpanel.Minimap_SetEnemyHeightArrow( true )
	rushpanel.Minimap_SetZOrder( 10 )

	SetRushPanelUseFunc( rushpanel, TitanRush_UsePanel, this )

	file.rushpanels.append( rushpanel )

	printt("rushpanel: ", rushpanel )
}

function GetRushPanelIndex( rushpanel )
{
	if( file.rushpanels.len() == 0 )
	{
		return -1
	}

	foreach ( index, panel in file.rushpanels )
	{
		if( panel == rushpanel )
		{
			return index
		}
	}

	return -1
}

function GetRushpointMats( panelIndex )
{
	local panelNames = [ "a", "b" ]
	local panelMaterials = {}
	panelMaterials.a <- { friendly = "hardpoint_friendly_a", neutral = "hardpoint_neutral_a", enemy = "hardpoint_enemy_a" }
	panelMaterials.b <- { friendly = "hardpoint_friendly_b", neutral = "hardpoint_neutral_b", enemy = "hardpoint_enemy_b" }

	Assert( panelIndex < panelNames.len(), "Too many titan rush control panels." )
	local panelLetter = panelNames[ panelIndex ]
	local panelMats = panelMaterials[ panelLetter ]
	return panelMats
}


//! 폭파 관련 처리
function NuclearCoreExplosion( origin, rushpanel )
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

	//! 핵 사운드 출력
	EmitSoundAtPosition( origin, "titan_nuclear_death_explode" )

	//! 폭파 처리
	thread NuclearCoreExplosionChainReaction( origin, rushpanel )
}

//! 핵 FX 처리 루틴
function NuclearCoreExplosionChainReaction( origin, rushpanel )
{
	local explosions
	local explosionDist
	local time
	local IsNPC

	local titanDamage 		= 15000
	local nonTitanDamage 	= 500

	explosions = 1
	explosionDist = 2500
	time = 1.7

	local waitPerExplosion = time / explosions

	//ClearNuclearBlueSunEffect( e )

	//! FX 출력
	PlayFX( TITAN_NUCLEAR_CORE_FX_3P, origin, Vector(0,RandomInt(360),0) )

	// one extra explosion that does damage to physics entities at smaller radius
	explosions += 1

	for ( local i = 0; i < explosions; i++ )
	{
		local explosionOwner = rushpanel

		//RadiusDamage( origin, titanDamage, nonTitanDamage, explosionDist, 0, explosionOwner, eDamageSourceId.nuclear_core, true, true, null, null )

		RadiusDamage( rushpanel.GetOrigin(),	// origin
		titanDamage,								// titan damage
		nonTitanDamage,								// pilot damage
		explosionDist,		// radiusFalloffMax
		0,								// radiusFullDamage
		rushpanel, 						// owner
		eDamageSourceId.nuclear_core,  // damage source id
		true,							// alive only
		false,							// selfDamage
		null,							// team
		null )							// scriptFlags

		wait waitPerExplosion
	}
}

//function ChangeTimeLimit( val )
//{
//	level.nv.roundEndTime += val
//}

//! 라운드 끝날때 호출
function TRWinnerDeterminedStart()
{

}

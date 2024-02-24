
function main()
{
	if ( reloadingScripts )
		return

	GM_AddEndRoundFunc( EndRoundMain )
}

function EntitiesDidLoad()
{
	if ( EvacEnabled() )
		{
			EvacSetup()
		/*{ //!ky 승패 결과에 따른 탈출 노드 변경
			if ( level.nv.winningTeam = TEAM_IMC)
				EvacSetup_IMCWin()
			else 
				EvacSetup_MilWin()
		}*/
		}

	RegisterSignal( "ChangeSpawnPoint" )

	thread ChangeSpawnPoint()
}

function EvacSetup()
{
    PrintFunc()
	local spectatorNode1 = GetEnt( "spec_cam1" )
	local spectatorNode2 = GetEnt( "spec_cam2" )
	local spectatorNode3 = GetEnt( "spec_cam3" )

	Evac_AddLocation( "escape_node1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles() )
	Evac_AddLocation( "escape_node2", spectatorNode2.GetOrigin(), spectatorNode2.GetAngles() )
	Evac_AddLocation( "escape_node3", spectatorNode3.GetOrigin(), spectatorNode3.GetAngles() )

	local spacenode = GetEnt( "intro_SpaceNode" )

	Evac_SetSpaceNode( spacenode )
	Evac_SetupDefaultVDUs()
}

/*function EvacSetup_MilWin() //!ky 저항군이 이기면 이 탈출 노드를 사용
{
    PrintFunc()
	local spectatorNode1 = GetEnt( "spec_cam1" )
	local spectatorNode2 = GetEnt( "spec_cam2" )
	local spectatorNode3 = GetEnt( "spec_cam3" )

	Evac_AddLocation( "escape_node1", spectatorNode1.GetOrigin(), spectatorNode1.GetAngles() )
	Evac_AddLocation( "escape_node2", spectatorNode2.GetOrigin(), spectatorNode2.GetAngles() )
	Evac_AddLocation( "escape_node3", spectatorNode3.GetOrigin(), spectatorNode3.GetAngles() )

	local spacenode = GetEnt( "intro_SpaceNode" )

	Evac_SetSpaceNode( spacenode )
	Evac_SetupDefaultVDUs()
}

function EvacSetup_IMCWin() //!ky IMC가 이기면 이 탈출 노드를 사용
{
    PrintFunc()
	local spectatorNode4 = GetEnt( "spec_cam4" )
	local spectatorNode5 = GetEnt( "spec_cam5" )
	local spectatorNode6 = GetEnt( "spec_cam6" )
	
	Evac_AddLocation( "escape_node4", spectatorNode4.GetOrigin(), spectatorNode4.GetAngles() )
	Evac_AddLocation( "escape_node5", spectatorNode5.GetOrigin(), spectatorNode5.GetAngles() )
	Evac_AddLocation( "escape_node6", spectatorNode6.GetOrigin(), spectatorNode6.GetAngles() )

	local spacenode = GetEnt( "intro_SpaceNode" )

	Evac_SetSpaceNode( spacenode )
	Evac_SetupDefaultVDUs()
}*/

function EndRoundMain()
{
	if ( EvacEnabled() )
		GM_SetObserverFunc( EvacObserverFunc )
}

function EvacObserverFunc( player )
{
	player.SetObserverModeStaticPosition( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorPos )
	player.SetObserverModeStaticAngles( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorAng )

	player.StartObserverMode( OBS_MODE_CHASE )
	player.SetObserverTarget( null )
}

// [LJS] titan rush. 조건에 따라 스폰포인트 이동.
function ChangeSpawnPoint()
{
	/*
	enum eTitanRushSpawnCase
	{
		NORMAL,
		HACKED_A,
		HACKED_B,
		HACKED_A_B,
		DESTROY_A,
		DESTROY_B,
	}
	*/

	for(;;)
	{
		local result = WaitSignal( level.ent, "ChangeSpawnPoint" )

		if( result == null )
		{
			continue
		}
		
		printt( "[LJS]ChangeSpawnPoint result: ", result.spawnCase )

		// 조건에 따라 스폰포인트 이동
		switch ( result.spawnCase )
		{
			// 기본 //양각이 될 경우 시계 반대방향으로 회전
			case eTitanRushSpawnCase.NORMAL: 
				//MoveEntity( "info_spawnpoint_human_1",	Vector( -4754.31, 530.761, 425 ),	Vector( 0, 0.0, 0 )	)
				//파일럿 (IMC/공격)
				MoveEntity( "info_spawnpoint_human_1",	Vector( -672, -2776, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_2",	Vector( -672, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_3",	Vector( -544, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_4",	Vector( -280, -2776, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_5",	Vector( -280, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_6",	Vector( -408, -2896, -392 ),	Vector( 0, 0.0, 0 )	) 
				//파일럿 (저항군/방어)
				//MoveEntity( "info_spawnpoint_human_7",	Vector( -1130, 2405, -104 ),	Vector( 0, -90.0, 0 )	) // 
			break

			// A 지점 해킹
			case eTitanRushSpawnCase.HACKED_A: 
				//MoveEntity( "info_spawnpoint_human_1",	Vector( -4754.31, 530.761, 425 ),	Vector( 0, 0.0, 0 )	)
				//파일럿 (IMC/공격)
				MoveEntity( "info_spawnpoint_human_1",	Vector( -672, -2776, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_2",	Vector( -672, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_3",	Vector( -544, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_4",	Vector( -280, -2776, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_5",	Vector( -280, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_6",	Vector( -408, -2896, -392 ),	Vector( 0, 0.0, 0 )	) 
				//파일럿 (저항군/방어)
				//MoveEntity( "info_spawnpoint_human_7",	Vector( -1130, 2405, -104 ),	Vector( 0, -90.0, 0 )	) // 
			break

			// B 지점 해킹
			case eTitanRushSpawnCase.HACKED_B:
				//MoveEntity( "info_spawnpoint_human_1",	Vector( -4754.31, 530.761, 425 ),	Vector( 0, 0.0, 0 )	)
				//파일럿 (IMC/공격)
				MoveEntity( "info_spawnpoint_human_1",	Vector( -672, -2776, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_2",	Vector( -672, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_3",	Vector( -544, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_4",	Vector( -280, -2776, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_5",	Vector( -280, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_6",	Vector( -408, -2896, -392 ),	Vector( 0, 0.0, 0 )	) 
				//파일럿 (저항군/방어)
				//MoveEntity( "info_spawnpoint_human_7",	Vector( -1130, 2405, -104 ),	Vector( 0, -90.0, 0 )	) // 
			break

			// A, B 지점 해킹
			case eTitanRushSpawnCase.HACKED_A_B: 
				//MoveEntity( "info_spawnpoint_human_1",	Vector( -4754.31, 530.761, 425 ),	Vector( 0, 0.0, 0 )	)
				//파일럿 (IMC/공격)
				MoveEntity( "info_spawnpoint_human_1",	Vector( -672, -2776, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_2",	Vector( -672, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_3",	Vector( -544, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_4",	Vector( -280, -2776, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_5",	Vector( -280, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_6",	Vector( -408, -2896, -392 ),	Vector( 0, 0.0, 0 )	) 
				//파일럿 (저항군/방어)
				//MoveEntity( "info_spawnpoint_human_7",	Vector( -1130, 2405, -104 ),	Vector( 0, -90.0, 0 )	) // 
			break

			
			// A 지점 파괴
			case eTitanRushSpawnCase.DESTROY_A: 
				//MoveEntity( "info_spawnpoint_human_1",	Vector( -4754.31, 530.761, 425 ),	Vector( 0, 0.0, 0 )	)
				//파일럿 (IMC/공격)
				MoveEntity( "info_spawnpoint_human_1",	Vector( -672, -2776, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_2",	Vector( -672, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_3",	Vector( -544, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_4",	Vector( -280, -2776, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_5",	Vector( -280, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_6",	Vector( -408, -2896, -392 ),	Vector( 0, 0.0, 0 )	) 
				//파일럿 (저항군/방어)
				//MoveEntity( "info_spawnpoint_human_7",	Vector( -1130, 2405, -104 ),	Vector( 0, -90.0, 0 )	) // 
			break

			// B 지점 파괴
			case eTitanRushSpawnCase.DESTROY_B: 
//MoveEntity( "info_spawnpoint_human_1",	Vector( -4754.31, 530.761, 425 ),	Vector( 0, 0.0, 0 )	)
				//파일럿 (IMC/공격)
				MoveEntity( "info_spawnpoint_human_1",	Vector( -672, -2776, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_2",	Vector( -672, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_3",	Vector( -544, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_4",	Vector( -280, -2776, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_5",	Vector( -280, -2896, -392 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_6",	Vector( -408, -2896, -392 ),	Vector( 0, 0.0, 0 )	) 
				//파일럿 (저항군/방어)
				//MoveEntity( "info_spawnpoint_human_7",	Vector( -1130, 2405, -104 ),	Vector( 0, -90.0, 0 )	) // 
			break
			
		}
	}
}

main()
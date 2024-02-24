
function main()
{
	if ( reloadingScripts )
		return

	GM_AddEndRoundFunc( EndRoundMain )
}

function EntitiesDidLoad()
{
	if ( EvacEnabled() )
		EvacSetup()
		/*{ //!ky 승패 결과에 따른 탈출 노드 변경
			if ( level.nv.winningTeam = TEAM_IMC)
				EvacSetup_IMCWin()
			else 
				EvacSetup_MilWin()
		}*/

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
			// 기본
			case eTitanRushSpawnCase.NORMAL: 
				//MoveEntity( "info_spawnpoint_human_1",	Vector( -4754.31, 530.761, 425 ),	Vector( 0, 0.0, 0 )	)
				//파일럿 (IMC/공격)
				MoveEntity( "info_spawnpoint_human_1",	Vector( 304, -3000, 528 ),	Vector( 0, 90.0, 0 )	) //A
				MoveEntity( "info_spawnpoint_human_2",	Vector( 1048, -3000, 496 ),	Vector( 0, 90.0, 0 )	) //중앙
				MoveEntity( "info_spawnpoint_human_3",	Vector( 1952, -2840, 336 ),	Vector( 0, 90.0, 0 )	) //B
				MoveEntity( "info_spawnpoint_human_4",	Vector( 1136, -3688, 256 ),	Vector( 0, 90.0, 0 )	) //B
				MoveEntity( "info_spawnpoint_human_5",	Vector( 1072, -3688, 256 ),	Vector( 0, 90.0, 0 )	) //중앙
				MoveEntity( "info_spawnpoint_human_6",	Vector( 1008, -3688, 256 ),	Vector( 0, 90.0, 0 )	) //A
				//파일럿 (저항군/방어/전방/레벨에디터상A=왼쪽, B=왼쪽)
				MoveEntity( "info_spawnpoint_human_13",	Vector( 416, 3104, 536 ),	Vector( 0, -90.0, 0 )	) // A측방
				MoveEntity( "info_spawnpoint_human_14",	Vector( 2248, 3112, 168 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_15",	Vector( 1360, 4752, 456 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_16",	Vector( 1856, 3024, 184 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_17",	Vector( 1632, 3120, 152 ),	Vector( 0, -90.0, 0 )	) //
				MoveEntity( "info_spawnpoint_human_18",	Vector( 1400, 4496, 440 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_19",	Vector( 760, 3664, 176 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_20",	Vector( 1456, 3992, 496 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_21",	Vector( 1120, 3968, 200 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_22",	Vector( 352, 4704, 184 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_23",	Vector( 960, 4920, 504 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_24",	Vector( 56, 4720, 160 ),	Vector( 0, -90.0, 0 )	) // 
				//타이탄
				MoveEntity( "info_spawnpoint_titan_1",	Vector( -280, -1184, 256 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_2",	Vector( 0, -1184, 256 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_3",	Vector( 294, -1184, 256 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_4",	Vector( -280, -1416, 256 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_5",	Vector( 0, -1416, 256 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_6",	Vector( 280, -1416, 256 ),	Vector( 0, 90.0, 0 )	)				
			break

			// A 지점 해킹
			case eTitanRushSpawnCase.HACKED_A: 
				//파일럿 (IMC/공격)
				MoveEntity( "info_spawnpoint_human_1",	Vector( 488, -2000, 552 ),	Vector( 0, 90.0, 0 )	) //A
				MoveEntity( "info_spawnpoint_human_2",	Vector( 1208, -2608, 544 ),	Vector( 0, 90.0, 0 )	) //중앙
				MoveEntity( "info_spawnpoint_human_3",	Vector( 976, -2800, 464 ),	Vector( 0, 90.0, 0 )	) //B
				MoveEntity( "info_spawnpoint_human_4",	Vector( 648, -1904, 144 ),	Vector( 0, 90.0, 0 )	) //B
				MoveEntity( "info_spawnpoint_human_5",	Vector( 1552, -1872, 152 ),	Vector( 0, 90.0, 0 )	) //중앙
				MoveEntity( "info_spawnpoint_human_6",	Vector( 240, -2240, 536 ),	Vector( 0, 90.0, 0 )	) //A
				//파일럿 (저항군/방어/전방/레벨에디터상A=왼쪽, B=왼쪽)
				MoveEntity( "info_spawnpoint_human_13",	Vector( 272, 4536, 336 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_14",	Vector( 1896, 3112, 168 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_15",	Vector( 1056, 4768, 488 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_16",	Vector( 1856, 3024, 184 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_17",	Vector( 1632, 3120, 152 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_18",	Vector( 1400, 4496, 440 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_19",	Vector( 760, 3664, 176 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_20",	Vector( 1456, 3992, 496 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_21",	Vector( 1120, 3968, 200 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_22",	Vector( 352, 4704, 184 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_23",	Vector( 960, 4920, 504 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_24",	Vector( 56, 4720, 160 ),	Vector( 0, -90.0, 0 )	) // 
				//타이탄
				MoveEntity( "info_spawnpoint_titan_1",	Vector( 864, -880, 376 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_2",	Vector( 352, -992, 376 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_3",	Vector( 288, 448, 376 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_4",	Vector( -232, -224, 376 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_5",	Vector( -2616, -120, 376 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_6",	Vector( -2960, 520, 376 ),	Vector( 0, 90.0, 0 )	)				
			break

			// B 지점 해킹
			case eTitanRushSpawnCase.HACKED_B:
				//파일럿 (IMC/공격)
				MoveEntity( "info_spawnpoint_human_1",	Vector( 1872, -2336, 624 ),	Vector( 0, 90.0, 0 )	) //A
				MoveEntity( "info_spawnpoint_human_2",	Vector( 1208, -2608, 544 ),	Vector( 0, 90.0, 0 )	) //중앙
				MoveEntity( "info_spawnpoint_human_3",	Vector( 1656, -2048, 136 ),	Vector( 0, 90.0, 0 )	) //B
				MoveEntity( "info_spawnpoint_human_4",	Vector( 1648, -2544, 608 ),	Vector( 0, 90.0, 0 )	) //B
				MoveEntity( "info_spawnpoint_human_5",	Vector( 1552, -1872, 152 ),	Vector( 0, 90.0, 0 )	) //중앙
				MoveEntity( "info_spawnpoint_human_6",	Vector( 1872, -2336, 624 ),	Vector( 0, 90.0, 0 )	) //A
				//파일럿 (저항군/방어/전방/레벨에디터상A=왼쪽, B=왼쪽)
				MoveEntity( "info_spawnpoint_human_13",	Vector( 416, 3104, 536 ),	Vector( 0, -90.0, 0 )	) // A측방
				MoveEntity( "info_spawnpoint_human_14",	Vector( 1896, 3112, 168 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_15",	Vector( 1360, 4752, 456 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_16",	Vector( 1344, 4872, 472 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_17",	Vector( 1872, 4152, 144 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_18",	Vector( 1400, 4496, 440 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_19",	Vector( 760, 3664, 176 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_20",	Vector( 1456, 3992, 496 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_21",	Vector( 1120, 3968, 200 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_22",	Vector( 352, 4704, 184 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_23",	Vector( 960, 4920, 504 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_24",	Vector( 56, 4720, 160 ),	Vector( 0, -90.0, 0 )	) // 
				//타이탄
				MoveEntity( "info_spawnpoint_titan_1",	Vector( 1840, -416, 376 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_2",	Vector( 3464, 120, 376 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_3",	Vector( 2560, 120, 376 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_4",	Vector( 3720, 792, 376 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_5",	Vector( 1424, -1096, 376 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_6",	Vector( 1272, -552, 376 ),	Vector( 0, 90.0, 0 )	)
			break

			// A, B 지점 해킹
			case eTitanRushSpawnCase.HACKED_A_B: 
				//파일럿 (IMC/공격)
				MoveEntity( "info_spawnpoint_human_1",	Vector( 1208, -2608, 544 ),	Vector( 0, 90.0, 0 )	) //중앙
				MoveEntity( "info_spawnpoint_human_2",	Vector( 1552, -1872, 152 ),	Vector( 0, 90.0, 0 )	) //중앙
				MoveEntity( "info_spawnpoint_human_3",	Vector( 240, -2240, 536 ),	Vector( 0, 90.0, 0 )	) //A
				MoveEntity( "info_spawnpoint_human_4",	Vector( 1872, -2336, 624 ),	Vector( 0, 90.0, 0 )	) //A
				MoveEntity( "info_spawnpoint_human_5",	Vector( 1656, -2048, 136 ),	Vector( 0, 90.0, 0 )	) //B
				MoveEntity( "info_spawnpoint_human_6",	Vector( 216, -1696, 608 ),	Vector( 0, 90.0, 0 )	) //중앙
				//파일럿 (저항군/방어/전방/레벨에디터상A=왼쪽, B=왼쪽)
				MoveEntity( "info_spawnpoint_human_13",	Vector( 272, 4536, 336 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_14",	Vector( 1896, 3112, 168 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_15",	Vector( 1056, 4768, 488 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_16",	Vector( 1344, 4872, 472 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_17",	Vector( 1872, 4152, 144 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_18",	Vector( 1400, 4496, 440 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_19",	Vector( 760, 3664, 176 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_20",	Vector( 1456, 3992, 496 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_21",	Vector( 1120, 3968, 200 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_22",	Vector( 352, 4704, 184 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_23",	Vector( 960, 4920, 504 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_24",	Vector( 56, 4720, 160 ),	Vector( 0, -90.0, 0 )	) // 

				//타이탄
				MoveEntity( "info_spawnpoint_titan_1",	Vector( 1840, -416, 376 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_2",	Vector( 2560, 120, 376 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_3",	Vector( 288, 448, 376 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_4",	Vector( -232, -224, 376 ),	Vector( 0, 90.0, 0 )	)				
				MoveEntity( "info_spawnpoint_titan_5",	Vector( 3464, 120, 376 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_6",	Vector( 1272, -552, 376 ),	Vector( 0, 90.0, 0 )	)
			break

			/*
			// A 지점 파괴 //작동을 안한다?
			case eTitanRushSpawnCase.DESTROY_A: 
				//파일럿 (저항군/방어/전방/레벨에디터상A=왼쪽, B=왼쪽)
				MoveEntity( "info_spawnpoint_human_13",	Vector( 1344, 4872, 472 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_14",	Vector( 1896, 3112, 168 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_15",	Vector( 1056, 4768, 488 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_16",	Vector( 1344, 4872, 472 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_17",	Vector( 1872, 4152, 144 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_18",	Vector( 1400, 4496, 440 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_19",	Vector( 760, 3664, 176 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_20",	Vector( 1456, 3992, 496 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_21",	Vector( 1400, 4496, 440 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_22",	Vector( 1400, 4496, 440 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_23",	Vector( 960, 4920, 504 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_24",	Vector( 1896, 3112, 168 ),	Vector( 0, -90.0, 0 )	) // 
			break

			// B 지점 파괴
			case eTitanRushSpawnCase.DESTROY_B: 
				MoveEntity( "info_spawnpoint_human_13",	Vector( 272, 4536, 336 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_14",	Vector( 352, 4704, 184 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_15",	Vector( 1056, 4768, 488 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_16",	Vector( 272, 4536, 336 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_17",	Vector( 56, 4720, 160 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_18",	Vector( 1400, 4496, 440 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_19",	Vector( 760, 3664, 176 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_20",	Vector( 1456, 3992, 496 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_21",	Vector( 1120, 3968, 200 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_22",	Vector( 352, 4704, 184 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_23",	Vector( 960, 4920, 504 ),	Vector( 0, -90.0, 0 )	) // 
				MoveEntity( "info_spawnpoint_human_24",	Vector( 56, 4720, 160 ),	Vector( 0, -90.0, 0 )	) // 
			break
			*/
		}
	}
}

main()
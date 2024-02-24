
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
				MoveEntity( "info_spawnpoint_human_1",	Vector( -768, -488, 384 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_2",	Vector( -24, -488, 496 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_3",	Vector( 880, -328, 448 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_4",	Vector( 64, -1176, 256 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_5",	Vector( 0, -1176, 256 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_6",	Vector( -64, -1176, 256 ),	Vector( 0, 90.0, 0 )	)
				//파일럿 (저항군/방어)
				MoveEntity( "info_spawnpoint_human_13",	Vector( 776, 6448, 624 ),	Vector( 0, -90.0, 0 )	) // A후방
				MoveEntity( "info_spawnpoint_human_14",	Vector( -320, 3888, 568 ),	Vector( 0, -90.0, 0 )	) // B전방
				MoveEntity( "info_spawnpoint_human_15",	Vector( -792, 4280, 568 ),	Vector( 0, -90.0, 0 )	) // B전방
				MoveEntity( "info_spawnpoint_human_16",	Vector( 840, 5736, 1120 ),	Vector( 0, -90.0, 0 )	) // A전방
				MoveEntity( "info_spawnpoint_human_17",	Vector( -952, 5552, 424 ),	Vector( 0, -90.0, 0 )	) // B후방 
				MoveEntity( "info_spawnpoint_human_18",	Vector( -1080, 6360, 624 ),	Vector( 0, -90.0, 0 )	) // B후방
				MoveEntity( "info_spawnpoint_human_19",	Vector( 160, 5736, 1008 ),	Vector( 0, -90.0, 0 )	) // AB후방
				MoveEntity( "info_spawnpoint_human_20",	Vector( -952, 4952, 1040 ),	Vector( 0, -90.0, 0 )	) // B전방
				MoveEntity( "info_spawnpoint_human_21",	Vector( 848, 3696, 568 ),	Vector( 0, -90.0, 0 )	) // A전방 
				MoveEntity( "info_spawnpoint_human_22",	Vector( 840, 6448, 624 ),	Vector( 0, -90.0, 0 )	) // A후방
				MoveEntity( "info_spawnpoint_human_23",	Vector( -376, 5552, 920 ),	Vector( 0, -90.0, 0 )	) // B후방 
				MoveEntity( "info_spawnpoint_human_24",	Vector( 1048, 5280, 1048 ),	Vector( 0, -90.0, 0 )	) // A전방
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
				MoveEntity( "info_spawnpoint_human_1",	Vector( -832, 1528, 176 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_2",	Vector( -704, 1528, 176 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_3",	Vector( -832, 992, 640 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_4",	Vector( -640, 992, 640 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_5",	Vector( -64, 1784, 184 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_6",	Vector( 64, 1784, 184 ),	Vector( 0, 90.0, 0 )	)
				//파일럿 (저항군/방어)
				MoveEntity( "info_spawnpoint_human_13",	Vector( 776, 6448, 624 ),	Vector( 0, -90.0, 0 )	) // A후방
				MoveEntity( "info_spawnpoint_human_14",	Vector( -320, 3888, 568 ),	Vector( 0, -90.0, 0 )	) // B전방
				MoveEntity( "info_spawnpoint_human_15",	Vector( -792, 4280, 568 ),	Vector( 0, -90.0, 0 )	) // B전방
				//MoveEntity( "info_spawnpoint_human_16",	Vector( 840, 5736, 1120 ),	Vector( 0, -90.0, 0 )	) // A전방
				MoveEntity( "info_spawnpoint_human_16",	Vector( 776, 6448, 624 ),	Vector( 0, -90.0, 0 )	) // A후방
				MoveEntity( "info_spawnpoint_human_17",	Vector( -952, 5552, 424 ),	Vector( 0, -90.0, 0 )	) // B후방 
				MoveEntity( "info_spawnpoint_human_18",	Vector( -1080, 6360, 624 ),	Vector( 0, -90.0, 0 )	) // B후방
				MoveEntity( "info_spawnpoint_human_19",	Vector( 160, 5736, 1008 ),	Vector( 0, -90.0, 0 )	) // AB후방
				MoveEntity( "info_spawnpoint_human_20",	Vector( -952, 4952, 1040 ),	Vector( 0, -90.0, 0 )	) // B전방
				//MoveEntity( "info_spawnpoint_human_21",	Vector( 848, 3696, 568 ),	Vector( 0, -90.0, 0 )	) // A전방 
				MoveEntity( "info_spawnpoint_human_21",	Vector( 776, 6448, 624 ),	Vector( 0, -90.0, 0 )	) // A후방
				MoveEntity( "info_spawnpoint_human_22",	Vector( 840, 6448, 624 ),	Vector( 0, -90.0, 0 )	) // A후방
				MoveEntity( "info_spawnpoint_human_23",	Vector( -376, 5552, 920 ),	Vector( 0, -90.0, 0 )	) // B후방 
				//MoveEntity( "info_spawnpoint_human_24",	Vector( 1048, 5280, 1048 ),	Vector( 0, -90.0, 0 )	) // A전방
				MoveEntity( "info_spawnpoint_human_24",	Vector( 776, 6448, 624 ),	Vector( 0, -90.0, 0 )	) // A후방
				//타이탄
				MoveEntity( "info_spawnpoint_titan_1",	Vector( -1176, 2240, 136 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_2",	Vector( -952, 2240, 136 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_3",	Vector( -800, 1688, 136 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_4",	Vector( -576, 1688, 136 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_5",	Vector( -112, 1696, 136 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_6",	Vector( 112, 1696, 136 ),	Vector( 0, 90.0, 0 )	)				
			break

			// B 지점 해킹
			case eTitanRushSpawnCase.HACKED_B: 
				//파일럿 (IMC/공격)
				MoveEntity( "info_spawnpoint_human_1",	Vector( 632, 960, 640 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_2",	Vector( 824, 960, 640 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_3",	Vector( 808, 1792, 136 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_4",	Vector( 936, 1792, 136 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_5",	Vector( 1072, 2672, 392 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_6",	Vector( 1200, 2672, 392 ),	Vector( 0, 90.0, 0 )	)
				//파일럿 (저항군/방어)
				MoveEntity( "info_spawnpoint_human_13",	Vector( 776, 6448, 624 ),	Vector( 0, -90.0, 0 )	) // A후방
				//MoveEntity( "info_spawnpoint_human_14",	Vector( -320, 3888, 568 ),	Vector( 0, -90.0, 0 )	) // B전방
				//MoveEntity( "info_spawnpoint_human_15",	Vector( -792, 4280, 568 ),	Vector( 0, -90.0, 0 )	) // B전방
				MoveEntity( "info_spawnpoint_human_14",	Vector( -952, 5552, 424 ),	Vector( 0, -90.0, 0 )	) // B후방 
				MoveEntity( "info_spawnpoint_human_15",	Vector( -1080, 6360, 624 ),	Vector( 0, -90.0, 0 )	) // B후방
				MoveEntity( "info_spawnpoint_human_16",	Vector( 840, 5736, 1120 ),	Vector( 0, -90.0, 0 )	) // A전방
				MoveEntity( "info_spawnpoint_human_17",	Vector( -952, 5552, 424 ),	Vector( 0, -90.0, 0 )	) // B후방 
				MoveEntity( "info_spawnpoint_human_18",	Vector( -1080, 6360, 624 ),	Vector( 0, -90.0, 0 )	) // B후방
				MoveEntity( "info_spawnpoint_human_19",	Vector( 160, 5736, 1008 ),	Vector( 0, -90.0, 0 )	) // AB후방
				//MoveEntity( "info_spawnpoint_human_20",	Vector( -952, 4952, 1040 ),	Vector( 0, -90.0, 0 )	) // B전방
				MoveEntity( "info_spawnpoint_human_20",	Vector( -376, 5552, 920 ),	Vector( 0, -90.0, 0 )	) // B후방 
				MoveEntity( "info_spawnpoint_human_21",	Vector( 848, 3696, 568 ),	Vector( 0, -90.0, 0 )	) // A전방 
				MoveEntity( "info_spawnpoint_human_22",	Vector( 840, 6448, 624 ),	Vector( 0, -90.0, 0 )	) // A후방
				MoveEntity( "info_spawnpoint_human_23",	Vector( -376, 5552, 920 ),	Vector( 0, -90.0, 0 )	) // B후방 
				MoveEntity( "info_spawnpoint_human_24",	Vector( 1048, 5280, 1048 ),	Vector( 0, -90.0, 0 )	) // A전방
				//타이탄
				MoveEntity( "info_spawnpoint_titan_1",	Vector( -112, 1696, 136 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_2",	Vector( 112, 1696, 136 ),	Vector( 0, 90.0, 0 )	)				
				MoveEntity( "info_spawnpoint_titan_3",	Vector( 592, 1824, 136 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_4",	Vector( 816, 1824, 136 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_5",	Vector( 752, 2360, 136 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_6",	Vector( 976, 2360, 136 ),	Vector( 0, 90.0, 0 )	)				
			break

			// A, B 지점 해킹
			case eTitanRushSpawnCase.HACKED_A_B: 
				//파일럿 (IMC/공격)
				MoveEntity( "info_spawnpoint_human_1",	Vector( -64, 2128, 184 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_2",	Vector( 64, 2128, 184 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_3",	Vector( -832, 1528, 176 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_4",	Vector( 64, 1784, 184 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_5",	Vector( 1072, 2672, 392 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_6",	Vector( 1200, 2672, 392 ),	Vector( 0, 90.0, 0 )	)
				//파일럿 (저항군/방어)
				MoveEntity( "info_spawnpoint_human_13",	Vector( 776, 6448, 624 ),	Vector( 0, -90.0, 0 )	) // A후방
				//MoveEntity( "info_spawnpoint_human_14",	Vector( -320, 3888, 568 ),	Vector( 0, -90.0, 0 )	) // B전방
				//MoveEntity( "info_spawnpoint_human_15",	Vector( -792, 4280, 568 ),	Vector( 0, -90.0, 0 )	) // B전방
				MoveEntity( "info_spawnpoint_human_14",	Vector( -952, 5552, 424 ),	Vector( 0, -90.0, 0 )	) // B후방 
				MoveEntity( "info_spawnpoint_human_15",	Vector( -1080, 6360, 624 ),	Vector( 0, -90.0, 0 )	) // B후방
				//MoveEntity( "info_spawnpoint_human_16",	Vector( 840, 5736, 1120 ),	Vector( 0, -90.0, 0 )	) // A전방
				MoveEntity( "info_spawnpoint_human_16",	Vector( 776, 6448, 624 ),	Vector( 0, -90.0, 0 )	) // A후방
				MoveEntity( "info_spawnpoint_human_17",	Vector( -952, 5552, 424 ),	Vector( 0, -90.0, 0 )	) // B후방 
				MoveEntity( "info_spawnpoint_human_18",	Vector( -1080, 6360, 624 ),	Vector( 0, -90.0, 0 )	) // B후방
				MoveEntity( "info_spawnpoint_human_19",	Vector( 160, 5736, 1008 ),	Vector( 0, -90.0, 0 )	) // AB후방
				//MoveEntity( "info_spawnpoint_human_20",	Vector( -952, 4952, 1040 ),	Vector( 0, -90.0, 0 )	) // B전방
				MoveEntity( "info_spawnpoint_human_20",	Vector( -376, 5552, 920 ),	Vector( 0, -90.0, 0 )	) // B후방
				//MoveEntity( "info_spawnpoint_human_21",	Vector( 848, 3696, 568 ),	Vector( 0, -90.0, 0 )	) // A전방
				MoveEntity( "info_spawnpoint_human_21",	Vector( 840, 6448, 624 ),	Vector( 0, -90.0, 0 )	) // A후방 
				MoveEntity( "info_spawnpoint_human_22",	Vector( 840, 6448, 624 ),	Vector( 0, -90.0, 0 )	) // A후방
				MoveEntity( "info_spawnpoint_human_23",	Vector( -376, 5552, 920 ),	Vector( 0, -90.0, 0 )	) // B후방 
				//MoveEntity( "info_spawnpoint_human_24",	Vector( 1048, 5280, 1048 ),	Vector( 0, -90.0, 0 )	) // A전방
				MoveEntity( "info_spawnpoint_human_24",	Vector( 776, 6448, 624 ),	Vector( 0, -90.0, 0 )	) // A후방

				//타이탄
				MoveEntity( "info_spawnpoint_titan_1",	Vector( -1176, 2240, 136 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_2",	Vector( -952, 2240, 136 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_3",	Vector( -112, 1696, 136 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_4",	Vector( 112, 1696, 136 ),	Vector( 0, 90.0, 0 )	)				
				MoveEntity( "info_spawnpoint_titan_5",	Vector( 752, 2360, 136 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_6",	Vector( 976, 2360, 136 ),	Vector( 0, 90.0, 0 )	)						
			break

			// A 지점 파괴
			/*case eTitanRushSpawnCase.DESTROY_A: 
			break

			// B 지점 파괴
			case eTitanRushSpawnCase.DESTROY_B: 
			break*/
		}
	}
}

main()
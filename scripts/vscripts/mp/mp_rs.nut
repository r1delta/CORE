
function main()
{
	if ( reloadingScripts )
		return

	GM_AddEndRoundFunc( EndRoundMain )
}

function EntitiesDidLoad()
{
	//if ( EvacEnabled() )
	//	EvacSetup()

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
				//파일럿
				MoveEntity( "info_spawnpoint_human_9",	Vector( -128, -3304, 4384 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_10",	Vector( -72, -3304, 4384 ),		Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_5",	Vector( 40, -3304, 4384 ),		Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_6",	Vector( 96, -3304, 4384 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_11",	Vector( 208, -3304, 4384 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_12",	Vector( 264, -3304, 4384 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_14",	Vector( 40, -3304, 4384 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_15",	Vector( 96, -3304, 4384 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_16",	Vector( 208, -3304, 4384 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_17",	Vector( 264, -3304, 4384 ),	Vector( 0, 90.0, 0 )	)
				//타이탄
				MoveEntity( "info_spawnpoint_titan_6",	Vector( -496, -2936, 4552 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_5",	Vector( -304, -2936, 4552 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_3",	Vector( -104, -2936, 4552 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_4",	Vector( 144, -2936, 4552 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_7",	Vector( 336, -2936, 4552 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_8",	Vector( 536, -2936, 4552 ),	Vector( 0, 90.0, 0 )	)
				/*MoveEntity( "info_spawnpoint_titan_start_6",	Vector( -512, -2920, 4888 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_5",	Vector( -320, -2920, 4888 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_3",	Vector( -120, -2920, 4888 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_4",	Vector( 128, -2920, 4888 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_7",	Vector( 320, -2920, 4888 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_8",	Vector( 520, -2920, 4888 ),	Vector( 0, 0.0, 0 )	)*/
			break

			// A 지점 해킹
			case eTitanRushSpawnCase.HACKED_A: 
				//파일럿
				MoveEntity( "info_spawnpoint_human_9",	Vector( 1440, 5048, 5312 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_10",	Vector( 1496, 5048, 5312 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_5",	Vector( 1608, 5048, 5312 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_6",	Vector( 1664, 5048, 5312 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_11",	Vector( 1776, 5048, 5312 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_12", Vector( 1832, 5048, 5312 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_14",	Vector( 736, 6488, 6240 ),	Vector( 0, 45.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_15",	Vector( 1184, 6488, 6240 ),	Vector( 0, 45.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_16",	Vector( 1234, 6488, 6240 ),	Vector( 0, 45.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_17",	Vector( 792, 6488, 6240 ),	Vector( 0, 45.0, 0 )	)
				//타이탄
				MoveEntity( "info_spawnpoint_titan_6",	Vector( 224, 4984, 5648 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_5",	Vector( 416, 4984, 5648 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_3",	Vector( 616, 4984, 5648 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_4",	Vector( 864, 4984, 5648 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_7",	Vector( 1056, 4984, 5648 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_8",	Vector( 1256, 4984, 5648 ),	Vector( 0, 90.0, 0 )	)
				/*MoveEntity( "info_spawnpoint_titan_start_6",	Vector( 224, 4984, 5648 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_5",	Vector( 416, 4984, 5648 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_3",	Vector( 616, 4984, 5648 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_4",	Vector( 864, 4984, 5648 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_7",	Vector( 1056, 4984, 5648 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_8",	Vector( 1256, 4984, 5648 ),	Vector( 0, 0.0, 0 )	)*/
			break

			// B 지점 해킹
			case eTitanRushSpawnCase.HACKED_B: 
				//파일럿
				MoveEntity( "info_spawnpoint_human_9",	Vector( -1640, 4144, 5312 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_10",	Vector( -1584, 4144, 5312 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_5",	Vector( -1472, 4144, 5312 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_6",	Vector( -1416, 4144, 5312 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_11",	Vector( -1304, 4144, 5312 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_12",	Vector( -1248, 4144, 5312 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_14",	Vector( -736, 6488, 6240 ),	Vector( 0, 45.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_15",	Vector( -400, 6488, 6240 ),	Vector( 0, 45.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_16",	Vector( -456, 6488, 6240 ),	Vector( 0, 45.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_17",	Vector( -792, 6488, 6240 ),	Vector( 0, 45.0, 0 )	)
				//타이탄
				MoveEntity( "info_spawnpoint_titan_6",	Vector( -1728, 5352, 5648 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_5",	Vector( -1536, 5352, 5648 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_3",	Vector( -1336, 5352, 5648 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_4",	Vector( -1728, 5136, 5648 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_7",	Vector( -1536, 5136, 5648 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_8",	Vector( -1336, 5136, 5648 ),	Vector( 0, 90.0, 0 )	)
				/*MoveEntity( "info_spawnpoint_titan_start_6",	Vector( -1728, 5352, 5648 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_5",	Vector( -1536, 5352, 5648 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_3",	Vector( -1336, 5352, 5648 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_4",	Vector( -1728, 5136, 5648 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_7",	Vector( -1536, 5136, 5648 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_8",	Vector( -1336, 5136, 5648 ),	Vector( 0, 0.0, 0 )	)*/
			break

			// A, B 지점 해킹
			case eTitanRushSpawnCase.HACKED_A_B: 
				//파일럿
				MoveEntity( "info_spawnpoint_human_9",	Vector( 1440, 5048, 5312 ),	Vector( 0, 45.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_10",	Vector( 1496, 5048, 5312 ),	Vector( 0, 45.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_5",	Vector( 1608, 5048, 5312 ),	Vector( 0, 45.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_6",	Vector( -1416, 4144, 5312 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_11",	Vector( -1304, 4144, 5312 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_12",	Vector( -1248, 4144, 5312 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_14",	Vector( -736, 6488, 6240 ),	Vector( 0, 45.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_15",	Vector( 1184, 6488, 6240 ),	Vector( 0, 45.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_16",	Vector( 1234, 6488, 6240 ),	Vector( 0, 45.0, 0 )	)
				MoveEntity( "info_spawnpoint_human_17",	Vector( -792, 6488, 6240 ),	Vector( 0, 45.0, 0 )	)
				//타이탄
				MoveEntity( "info_spawnpoint_titan_6",	Vector( 224, 4984, 5648 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_5",	Vector( 416, 4984, 5648 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_3",	Vector( 616, 4984, 5648 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_4",	Vector( -1728, 5136, 5648 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_7",	Vector( -1536, 5136, 5648 ),	Vector( 0, 90.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_8",	Vector( -1336, 5136, 5648 ),	Vector( 0, 90.0, 0 )	)
				/*MoveEntity( "info_spawnpoint_titan_start_6",	Vector( 224, 4984, 5648 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_5",	Vector( 416, 4984, 5648 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_3",	Vector( 616, 4984, 5648 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_4",	Vector( -1728, 5136, 5648 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_7",	Vector( -1536, 5136, 5648 ),	Vector( 0, 0.0, 0 )	)
				MoveEntity( "info_spawnpoint_titan_start_8",	Vector( -1336, 5136, 5648 ),	Vector( 0, 0.0, 0 )	)*/
			break

			default:
				Assert( false, "result.spawnCase is Invalid value" )
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
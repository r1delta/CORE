function main()
{
	//=========================================================
	//	_mapspawn_mp.nut
	//  Called on newgame or transitions, BEFORE entities have been created and initialized
	//=========================================================
	Assert( IsMultiplayer() )

	IncludeScript( "mp/_utility_mp" )

	IncludeFile( "_xp" )



	IncludeFile( "mp/_serverflags" )
	IncludeFile( "_passives_shared" )


	IncludeFile( "mp/_npc_taclight" )

	IncludeFile( "_hardpoints_shared" )

	IncludeFile( "mp/_changemap" )
	IncludeFile( "mp/_gamestate" )

	IncludeFile( "mp/_music" )

	IncludeFile( "_score_shared" )
	IncludeFile( "mp/_score" )

	IncludeFile( "mp/_replacement_titans" )
	IncludeFile( "mp/_ai_soldiers" )
	IncludeFile( "mp/_ai_marvins" )
	IncludeFile( "mp/_ai_game_modes" )
	IncludeFile( "mp/_classic_mp" )
	IncludeFile( "mp/_control_panel" )
	IncludeFile( "mp/_ai_turret" )

	IncludeFile( "mp/_hardpoints" )

	// [LJS] titan_rush
	IncludeFile( "mp/_rush_panel" )

	// [LJS] big_brother
	IncludeFile( "mp/_bigbrother_panel" )
	IncludeFile( "mp/_ai_turret_bb" )

	IncludeFile( "mp/class_titan" )
	IncludeFile( "mp/class_wallrun" )

	IncludeFile( "mp/spawn" )
	IncludeFile( "mp/_health_regen" )
	IncludeFile( "_sonar_shared" )

	IncludeScript( "mp/mp_titanbuild_rule" )

	IncludeScript( "mp/_base_gametype" )
	IncludeFile( "mp/_player_revive" )
	IncludeFile( "mp/player_cloak" )

	IncludeFile( "superbar/smokescreen" )
	IncludeFile( "superbar/orbitalstrike" )

	IncludeFile( "_riff_settings" )
	IncludeFile( "_network_marker_shared" )

	if ( /*!IsLobby() &&*/ GetCurrentPlaylistVarInt( "riff_floorislava", eFloorIsLava.Default ) )
		IncludeFile( "mp/_riff_floor_is_lava" )

	if ( developer() > 0 )
		PrecacheWeapon( "weapon_cubemap" )

	IncludeGameModeServerScripts()
}

function IncludeGameModeServerScripts()
{
	switch ( GAMETYPE )
	{
		case TEAM_DEATHMATCH:
			IncludeFile( "mp/team_deathmatch" )
			break
		case UPLINK:
			IncludeFile( "mp/uplink" )
			break
		case EXFILTRATION:
			IncludeFile( "mp/exfiltration" )
			break
		case ELIMINATION:
			IncludeFile( "mp/elimination" )
			break
		case ATDM:
			IncludeFile( "mp/atdm" )
			break
		case ATTRITION:
			IncludeFile( "mp/attrition" )
			break
		case CAPTURE_THE_FLAG:
			IncludeFile( "_capture_the_flag_shared" )
			IncludeFile( "mp/capture_the_flag" )
			break
		case HEIST:
			IncludeFile( "mp/_gamemode_heist" )
			break
		case BIG_BROTHER:
			IncludeFile( "mp/big_brother" )
			break
		case TITAN_TAG:
			IncludeFile( "mp/titan_tag" )
			break

		// case TITAN_RUSH:
		// 	IncludeFile( "mp/_gamemode_tr" )
		// 	break

		default:
			GameMode_RunSharedScripts( GAMETYPE )
			GameMode_RunServerScripts( GAMETYPE )
	}
}


function SetWorldFadeIntro()
{
	GetEnt( "worldspawn" ).kv.startdark = true
}


function ScriptCallback_OnNewMap()
{
	local allDropPoints = GetEntArrayByClass_Expensive( "point_droppoint" )
	foreach ( point in allDropPoints )
	{
		if ( point.GetName() == "" )
			point.SetName( "point_droppoint" + UniqueString() )
		point.s.inUse <- false
	}
}

function dpuse()
{
	local allDropPoints = GetEntArrayByClass_Expensive( "point_droppoint" )
	foreach ( point in allDropPoints )
	{
		if ( point.s.inUse )
			printl( point.GetName() + " in use" )
	}
}

main()
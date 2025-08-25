
function main()
{
	IncludeFile( "mp/capture_the_flag" )
	SetRoundBased( true )
	SetAttackDefendBased( true )

	FlagInit( "DefendersWinDraw" )

	//level.classicMPDropshipIntroLength = CLASSIC_MP_DROPSHIP_IDLE_ANIM_TIME - 2.0
	level.nv.attackingTeam = TEAM_MILITIA
	level.ctf_pro_evac_started <- false
	//DisableDropshipSpawnForTeam( TEAM_IMC )

	AddCallback_GameStateEnter( eGameState.SwitchingSides, CTF_Pro_SwitchingSidesEnter )
	AddCallback_GameStateEnter( eGameState.Prematch, CTF_Pro_PrematchEnter )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, CTF_Pro_PrematchWinnerDetermined )
}

function CTF_Pro_SwitchingSidesEnter()
{
	//EnableDropshipSpawnForTeam( TEAM_IMC )
	//DisableDropshipSpawnForTeam( TEAM_MILITIA )
}

function EntitiesDidLoad()
{
	FlagClear( "EvacEndsMatch" )
}

function CTF_Pro_PrematchEnter()
{
	SetGlobalForcedDialogueOnly( false ) //Reset from evac from previous round
	foreach( player in GetPlayerArray() )
	{
		SetPlayerForcedDialogueOnly( player, false )
	}

	//HideEvacShipIconOnMinimap()
	ClearTeamActiveObjective( TEAM_IMC )
	ClearTeamActiveObjective( TEAM_MILITIA )
	level.ctf_pro_evac_started = false
	FlagClear( "EvacFinished" )
}

function CTF_Pro_PrematchWinnerDetermined()
{
	FlagSet( "EvacFinished" )
}


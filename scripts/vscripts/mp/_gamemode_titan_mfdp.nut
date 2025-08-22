
function main()
{
	IncludeFile( "mp/_gamemode_mfd_pro" )

	level.nv.eliminationMode = eEliminationMode.PilotsTitans

	FlagSet( "ForceStartSpawn" )

	AddCallback_GameStateEnter( eGameState.Prematch, TitanMFD_Pro_PrematchStart )
	AddCallback_GameStateEnter( eGameState.Playing, TitanMFD_Pro_PlayingStart )
}


function EntitiesDidLoad()
{
	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Always )
	Riff_ForceTitanExitEnabled( eTitanExitEnabled.Never )
}

function TitanMFD_Pro_PrematchStart()
{
	FlagSet( "ForceStartSpawn" )

	local players = GetPlayerArray()
	foreach ( player in players )
	{
		player.titansBuilt = 0
		player.s.respawnCount = 0
		ForceTitanBuildComplete( player )
	}
}

function TitanMFD_Pro_PlayingStart()
{
	FlagClear( "ForceStartSpawn" )
}

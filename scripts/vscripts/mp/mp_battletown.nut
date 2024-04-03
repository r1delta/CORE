function main()
{

	AddSpawnCallback( "npc_titan", BattleTown_SpawnTitan )
	AddSpawnCallback( "npc_soldier_shield", BattleTown_SpawnSoldier )
	AddSpawnCallback( "npc_soldier_heavy", 	BattleTown_SpawnSoldier )
	AddSpawnCallback( "npc_soldier", 		BattleTown_SpawnSoldier )

	//PrecacheModel( "models/vehicle/goblin_dropship/goblin_dropship.mdl" )
	//PrecacheEntity( "npc_dropship" )
	//FlagSet( "Zipline_Spawning" )
	//FlagSet( "Enable_Instamissions" )
}

function BattleTown_SpawnSoldier( guy )
{
	guy.SetTitle( "#NPC_GRUNT" )
	local team = guy.GetTeam()
	if ( team == TEAM_IMC )
		guy.SetModel( TEAM_IMC_GRUNT_MDL )
	else
		guy.SetModel( TEAM_MILITIA_GRUNT_MDL )

	thread AssignAssaultPoint( guy )
}

function AssignAssaultPoint( guy )
{
	local ent = CreateAssaultPointNew( guy )
	guy.s.titanPathAssaultPoint <- ent
	guy.WaitSignal( "OnDeath" )

	wait 1
	ent.Kill()
}

function BattleTown_SpawnTitan( guy )
{
	guy.SetTitle( "#NPC_TITAN" )
	SetSkinForTeam( guy, guy.GetTeam() )
	thread AssignAssaultPoint( guy )

	TakeAllWeapons( guy )
	local rand = RandomInt( 7 )
	local weapon
	switch ( rand )
	{
		case 0:
			weapon = "mp_titanweapon_xo16"
			break
		case 1:
			weapon = "mp_titanweapon_shotgun"
			break
		case 2:
			weapon = "mp_titanweapon_sniper"
			break
		case 3:
			weapon = "mp_titanweapon_triple_threat"
			break
		case 4:
			weapon = "mp_titanweapon_40mm"
			break
		case 5:
			weapon = "mp_titanweapon_arc_cannon"
			break
		case 6:
			weapon = "mp_titanweapon_rocket_launcher"
			break
	}

	guy.GiveWeapon( weapon )
}

function ClearForceSpawn()
{
	wait 25
	FlagClear( "ForceStartSpawn" )
}


function EntitiesDidLoad()
{
	FlagSet( "ForceStartSpawn" )
	thread ClearForceSpawn()

	local nodes = GetEntArrayByNameWildCard_Expensive( "titanpath*" )

	foreach ( node in nodes )
	{
		SpawnInfoNodeHint( node )
	}


	local min_imc = 5
	local min_militia = 4

	thread MarvKiller()

	wait 8

	thread spawntest( "imc_start" )
	thread spawntest( "militia_start" )
	thread spawntest( "imc_spawn" )

	FlagWait( "GamePlaying" )



	for ( ;; )
	{

		local titans = GetNPCArrayByClass( "npc_titan" )
		local teams = {}
		teams[ TEAM_IMC ] <- []
		teams[ TEAM_MILITIA ] <- []

		foreach ( titan in titans )
		{
			local team = titan.GetTeam()
			Assert( team == TEAM_IMC || team == TEAM_MILITIA, "Titan " + titan.GetName() + " at " + titan.GetOrigin() + " has team " + team )
			teams[ team ].append( titan )
		}

		if ( teams[ TEAM_IMC ].len() < min_imc )
		{
			spawntest( "imc_start" )
		}

		if ( teams[ TEAM_MILITIA ].len() < min_militia )
		{
			spawntest( "militia_start" )
		}

		wait 5
	}

}

function MarvKiller()
{
	for ( ;; )
	{
		local marvs = GetNPCArrayByClass( "npc_marvin" )
		foreach ( marv in clone marvs )
		{
			marv.Kill()
		}
		wait 5
	}
}



thread main()
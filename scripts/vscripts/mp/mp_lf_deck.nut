// R2 map level script stub (tools\combo\evac): evac setup shared by the converted Titanfall 2 maps

function main()
{
	IncludeScript( "mp/_r2port_evac" )

	//AddSpawnCallback_ScriptName( "worker_drone_spawn", DeckSpawnWorkerDrone )
	//AddSpawnCallback_ScriptName( "marvin_idle_node", DeckSpawnMarvinForIdleNode )
}

function EntitiesDidLoad()
{
	//thread fjfw9rfjwiofjwiofvjwiofwj2()

	R2Port_EntitiesDidLoad()

	local marvinSpawns = [
		{ origin = Vector( 1050.27, 758.08, 208 ), angles = Vector( 0, -176.34, 0 ), job = "" },
		{ origin = Vector( 100.186, -25, 7.99992 ), angles = Vector( 0, -0.1917, 0 ), job = "" },
		{ origin = Vector( 96.186, 356.697, 7.99992 ), angles = Vector( 0, -0.1917, 0 ), job = "" },
		{ origin = Vector( 1115.74, 1887.75, 426 ), angles = Vector( 0, 180, 0 ), job = "window" },
		{ origin = Vector( 592, -12, 480 ), angles = Vector( 0, -90, 0 ), job = "window" },
		{ origin = Vector( 400, -12, 480 ), angles = Vector( 0, -90, 0 ), job = "window" },
		{ origin = Vector( 1209.98, 1139.33, 209 ), angles = Vector( 0, 113.506, 0 ), job = "weapon" },
		{ origin = Vector( 1351.06, 1139.67, 210 ), angles = Vector( 0, 107.961, 0 ), job = "weapon" },
		{ origin = Vector( 1200.4, 1059.17, 208 ), angles = Vector( 0, 48.5, 0 ), job = "" },
		{ origin = Vector( 1359.71, 1016.14, 208 ), angles = Vector( 0, 88.04, 0 ), job = "" },
		{ origin = Vector( 1127.01, 1311.83, 208 ), angles = Vector( 0, 178.04, 0 ), job = "welding" },
		{ origin = Vector( 274, 2.66454e-015, 480.001 ), angles = Vector( 0, -96.171, 0 ), job = "welding" },
		{ origin = Vector( 1225, -162, 208.001 ), angles = Vector( 0, -27.667, 0 ), job = "" },
		{ origin = Vector( 1044, -330, 208.001 ), angles = Vector( 0, -176.34, 0 ), job = "" },
		{ origin = Vector( -142.234, -57.5177, 7.99998 ), angles = Vector( 0, -112.85, 0 ), job = "welding" },
	]

	foreach ( idx, info in marvinSpawns )
	{
		local npc_marvin = CreateEntity( "npc_marvin" )
		npc_marvin.SetName( UniqueString( "mp_random_marvin") )
		npc_marvin.SetOrigin( info.origin )
		npc_marvin.SetAngles( info.angles )

		npc_marvin.kv.health = -1
		npc_marvin.kv.max_health = -1
		npc_marvin.kv.spawnflags = 516  // Fall to ground, Fade Corpse

		npc_marvin.kv.AccuracyMultiplier = 1.0
		npc_marvin.kv.reactChance = 100
		npc_marvin.kv.physdamagescale = 1.0
		npc_marvin.kv.WeaponProficiency = 1
		npc_marvin.kv.additionalequipment = "Nothing"

		DispatchSpawn( npc_marvin, true )
		npc_marvin.SetTeam( TEAM_UNASSIGNED )

		if ( info.job != "" )
		{
			local job = CreateEntity( "script_marvin_job" )
			job.SetOrigin( info.origin )
			job.SetAngles( info.angles )
			DispatchSpawn( job, true )
			InitMarvinJob( job, info.job )

			// They stop spawning if i actually give one a job
			//thread GivePreferredJobToMarvin( marvin, job )
		}
	}
}

function DeckSpawnMarvinForIdleNode( ent )
{
	local marvin = SpawnAmbientMarvin( ent )
	GiveJobToMarvin( marvin, "welding" )
}

/*
function fjfw9rfjwiofjwiofvjwiofwj()
{
	wait 30.0
	for ( local i = 0; i < 30; i++ )
	{
		printt( "==============================" )
		wait 0.1
	}
}

function fjfw9rfjwiofjwiofvjwiofwj2()
{
	wait 30.0
	for ( local i = 0; i < 30; i++ )
	{
		printt( "+++++++++++++++++++++++++++++++++++" )
		wait 0.1
	}
}
*/

main()

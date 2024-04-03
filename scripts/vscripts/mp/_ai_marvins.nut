function main()
{
	FlagInit( "Disable_Marvins")

	level.livingMarvins <- {}
	AddSpawnCallback( "npc_marvin", LivingMarvinSpawned )
}

function EntitiesDidLoad()
{
	if ( !IsNPCSpawningEnabled() )
		return

	FlagEnd( "disable_npcs" )

	local marvin_spawners = GetEntArrayByClass_Expensive( "info_spawnpoint_marvin" )

	if ( !marvin_spawners.len() )
		return

	for ( ;; )
	{
		if ( !Flag( "Disable_Marvins" ) )
		{
			if ( TotalLivingMarvins() < 5 )
			{
				SpawnRandomMarvin( marvin_spawners )
			}
		}

		wait 3
	}
}

function LivingMarvinSpawned( self )
{
	level.livingMarvins[ self ] <- self
}

function TotalLivingMarvins()
{
	local count = 0
	foreach ( marvin in clone level.livingMarvins )
	{
		if ( IsAlive( marvin ) )
		{
			count++
			continue
		}

		// cleanup dead marvins
		delete level.livingMarvins[ marvin ]
	}
	return count
}

function SpawnRandomMarvin( marvin_spawners )
{
	ArrayRandomize( marvin_spawners )
	local spawnpoint = marvin_spawners[0] // if no valid spawn is found use this one
	for ( local i = 0; i < marvin_spawners.len(); i++ )
	{
		if ( IsMarvinSpawnpointValid( marvin_spawners[ i ] ) )
		{
			spawnpoint = marvin_spawners[ i ]
			break
		}
	}

	local marvin = SpawnAmbientMarvin( spawnpoint )
	return marvin
}

function IsMarvinSpawnpointValid( spawnpoint )
{
	// ensure spawnpoint is not occupied (i.e. would spawn inside another player or object )
	if ( spawnpoint.IsOccupied() )
		return false

	local visible = spawnpoint.IsVisibleToEnemies( TEAM_IMC ) || spawnpoint.IsVisibleToEnemies( TEAM_MILITIA )
	if ( visible )
		return false

	return true
}

function SpawnAmbientMarvin( spawnpoint )
{
	local npc_marvin = CreateEntity( "npc_marvin" )
	npc_marvin.SetName( UniqueString( "mp_random_marvin") )
	npc_marvin.SetOrigin( spawnpoint.GetOrigin() )
	npc_marvin.SetAngles( spawnpoint.GetAngles() )
	//npc_marvin.kv.rendercolor = "255 255 255"
	npc_marvin.kv.health = -1
	npc_marvin.kv.max_health = -1
	npc_marvin.kv.spawnflags = 516  // Fall to ground, Fade Corpse
	//npc_marvin.kv.FieldOfView = 0.5
	//npc_marvin.kv.FieldOfViewAlert = 0.2
	npc_marvin.kv.AccuracyMultiplier = 1.0
	npc_marvin.kv.reactChance = 100
	npc_marvin.kv.physdamagescale = 1.0
	npc_marvin.kv.WeaponProficiency = 1
	npc_marvin.kv.additionalequipment = "Nothing"

	Marvin_SetModels( npc_marvin, spawnpoint )

	DispatchSpawn( npc_marvin, true )

	npc_marvin.SetTeam( TEAM_UNASSIGNED )

	return npc_marvin
}

function Marvin_SetModels( npc_marvin, spawnpoint )
{
	//default
	local modelpath = "models/robots/marvin/marvin.mdl"
	npc_marvin.s.bodytype <- MARVIN_TYPE_WORKER

	// set body and head based on KVP
	if ( spawnpoint.HasKey( "bodytype" ) )
	{
		local bodytype = spawnpoint.GetValueForKey( "bodytype" ).tointeger()

		Assert( bodytype >= MARVIN_TYPE_SHOOTER && bodytype <= MARVIN_TYPE_FIREFIGHTER, "Specified invalid body type index " + bodytype + " for info_spawnpoint_marvin " + spawnpoint + ", Use values from 0-2 instead." )

		npc_marvin.s.bodytype = bodytype
	}

	npc_marvin.kv.model = modelpath

	if ( spawnpoint.HasKey( "headtype" ) )
	{
		local headtype = spawnpoint.GetValueForKey( "headtype" )
		npc_marvin.kv.body = headtype
	}
}

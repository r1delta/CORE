function main()
{
	Globalize( CreateDogFighterAttack )
	Globalize( LaunchRandomDogFighterAttacks )
	Globalize( CreateDogFighter )
	Globalize( DogFighterAssistsPlayerRepeatedly )
	Globalize( DogFighterAssistsPlayer )

	AddDeathCallback( "npc_dropship", OnDogFighterDeath )
	IncludeFileAllowMultipleLoads( "mp/_vehicle_gunship" )

	RegisterSignal( "new_attack_thread" )
}

function LaunchRandomDogFighterAttacks( team )
{
	level.ent.Signal( "new_attack_thread" )
	level.ent.EndSignal( "new_attack_thread" )

	for ( ;; )
	{
		thread CreateDogFighterAttack( team )
		wait RandomFloat( 3, 9 )
	}
}

function CreateDogFighterAttack( team )
{
	local analysis = GetAnalysisForModel( STRATON_MODEL, STRATON_ATTACK_FULL )

	local drop = CreateCallinTable()
	drop.style = eDropStyle.RANDOM_FROM_YAW // spawn at a random node that points the right direction
	drop.yaw = RandomInt( 360 )

 	local spawnPoint = GetSpawnPointForStyle( analysis, drop )
 	if ( !spawnPoint )
 		return

	local ship = CreateDogFighter( Vector(0,0,0), Vector(0,0,0), team )

	local hornet_health = 2000
	ship.SetHealth( hornet_health )
	ship.SetMaxHealth( hornet_health )

	ship.EndSignal( "OnDeath" )

	//AddBulletTurrets( ship, team )

	waitthread PlayAnimTeleport( ship, "st_AngelCity_IMC_Win_ComeIn", spawnPoint.origin, spawnPoint.angles )

	thread PlayAnim( ship, "st_AngelCity_IMC_Win_Idle", spawnPoint.origin, spawnPoint.angles )
	waitthread DogFighterWaitsUntilLeave( ship )

	waitthread PlayAnim( ship, "st_AngelCity_IMC_Win_Leave", spawnPoint.origin, spawnPoint.angles, 0.5 )

	ship.Kill()
}


function DogFighterWaitsUntilLeave( ship, idleMin = 10, idleMax = 15 )
{
	local duration = ship.GetSequenceDuration( "st_AngelCity_IMC_Win_Idle" )

	// make it play full increments of the idle anim
	local maxHealth = ship.GetMaxHealth().tofloat()
	local idleTime = RandomFloat( idleMin, idleMax )
	local reps = ( duration / idleTime ).tointeger()
	local totalTime = reps * duration
	local endTime = Time() + totalTime

	for ( ;; )
	{
		if ( ship.GetHealth().tofloat() / maxHealth < 0.2 )
			return
		if ( Time() >= endTime )
			return
		wait 0.1
	}
}

function CreateDogFighter( origin, angles, team )
{
	local hornet = CreateEntity( "npc_dropship" )
	hornet.s.dogfighter <- true
	hornet.kv.vehiclescript = "scripts/vehicles/airvehicle_default.txt"
	hornet.kv.teamnumber = team

	local title
	switch ( team )
	{
		case TEAM_MILITIA:
			hornet.SetModel( HORNET_MODEL )
			title = "Militia Hornet"
			break

		case TEAM_IMC:
			hornet.SetModel( STRATON_MODEL )
			title = "IMC Phantom"
			break
	}

	hornet.SetTitle( title )
	hornet.SetShortTitle( title )

	hornet.SetOrigin( origin )
	hornet.SetAngles( angles )
	DispatchSpawn( hornet, true )

	//hornet.EnableRenderAlways()
	//hornet.SetAimAssistAllowed( false )

	return hornet
}

function OnDogFighterDeath( ent, damageInfo )
{
	if ( !IsValid( ent ) )
		return

	if ( !( "dogfighter" in ent.s ) )
		return

	if ( ent.GetHealth() <= 0 )
		FighterExplodes( ent )
}


function DogFighterAssistsPlayerRepeatedly( player )
{
	if ( !IsAlive( player ) )
		return
	player.EndSignal( "OnDeath" )

	local e = {}
	e.startingHealth <- 2500
	e.currentHealth <- e.startingHealth
	e.foundSpawn <- false

	for ( ;; )
	{
		thread CreateDogFighterAssist( player, e )
		WaitSignal( e, "OnDestroy" )

		if ( e.currentHealth <= 0 )
		{
			wait 6
			e.startingHealth = 2500
			e.currentHealth = e.startingHealth
		}
		wait 2
	}
}

function DogFighterAssistsPlayer( player )
{
	player.EndSignal( "Disconnected" )
	local e = {}
	e.startingHealth <- 2500
	e.currentHealth <- e.startingHealth
	e.foundSpawn <- false

	for ( ;; )
	{
		thread CreateDogFighterAssist( player, e )
		WaitSignal( e, "OnDestroy" )

		if ( e.foundSpawn )
			return

		wait RandomFloat( 1, 2 )
	}
}

function CreateDogFighterAssist( player, e )
{
	local team = player.GetTeam()
	local analysis = GetAnalysisForModel( STRATON_MODEL, STRATON_ATTACK_FULL )

	//local angles = player.EyeAngles()
	//local yaw = angles.y

	local drop = CreateCallinTable()
	drop.dist = 1000
	drop.yaw = RandomInt( 360 )
	drop.ownerEyePos = player.EyePosition()
	drop.style = eDropStyle.DOGFIGHTER

 	local spawnPoint = GetSpawnPointForStyle( analysis, drop )
 	if ( !spawnPoint )
 	{
 		wait 2.0 // wait then try again
		Signal( e, "OnDestroy" )
 		return
 	}

 	e.foundSpawn = true

	local ship = CreateDogFighter( Vector(0,0,0), Vector(0,0,0), team )
	ship.SetBossPlayer( player )
	ship.SetHealth( e.currentHealth )
	ship.SetMaxHealth( e.startingHealth )
	ship.EndSignal( "OnDeath" )
	ship.Minimap_AlwaysShow( 0, player )
	ship.Minimap_SetDefaultMaterial( GetMinimapMaterial( "VIP_friendly" ) )
	ship.Minimap_SetFriendlyMaterial( GetMinimapMaterial( "VIP_friendly" ) )
	ship.Minimap_SetEnemyMaterial( GetMinimapMaterial( "VIP_enemy" ) )
	ship.Minimap_SetBossPlayerMaterial( GetMinimapMaterial( "VIP_friendly" ) )
	ship.Minimap_SetObjectScale( 0.11 )
	ship.Minimap_SetZOrder( 10 )

	OnThreadEnd(
		function () : ( ship, e )
		{
			// track the health for return visit
			if ( IsAlive( ship ) )
			{
				e.currentHealth = ship.GetHealth()
				ship.Kill()
			}
			else
			{
				e.currentHealth = 0
			}

			Signal( e, "OnDestroy" )
		}
	)

	//AddRocketTurrets( ship, team )

	//DrawArrow( spawnPoint.origin, spawnPoint.angles, 10, 50 )
	waitthread PlayAnimTeleport( ship, "st_AngelCity_IMC_Win_ComeIn", spawnPoint.origin, spawnPoint.angles )

	thread PlayAnim( ship, "st_AngelCity_IMC_Win_Idle", spawnPoint.origin, spawnPoint.angles )
	local duration = ship.GetSequenceDuration( "st_AngelCity_IMC_Win_Idle" )
	wait duration * 2.0

	waitthread PlayAnim( ship, "st_AngelCity_IMC_Win_Leave", spawnPoint.origin, spawnPoint.angles, 0.5 )
}


function AddRocketTurrets( ship, team, prof = 3 )
{
	local turret
 	turret = AddTurret( ship, team, "mp_weapon_yh803", "l_exhaust_front_1" )
 	turret.kv.WeaponProficiency = 3
	turret.NotSolid()
	turret.Show()
	local weapon = turret.GetActiveWeapon()
	weapon.Show()

	turret = AddTurret( ship, team, "mp_weapon_yh803", "r_exhaust_front_1" )
	turret.kv.WeaponProficiency = 3
	turret.NotSolid()
	turret.Show()
	local weapon = turret.GetActiveWeapon()
	weapon.Show()
}

function AddBulletTurrets( ship, team, prof = 3 )
{
	local turret
 	turret = AddTurret( ship, team, TURRET_WEAPON_BULLETS, "l_exhaust_front_1" )
 	turret.kv.WeaponProficiency = prof
	turret.NotSolid()
	turret = AddTurret( ship, team, TURRET_WEAPON_BULLETS, "r_exhaust_front_1" )
	turret.kv.WeaponProficiency = prof
	turret.NotSolid()
}
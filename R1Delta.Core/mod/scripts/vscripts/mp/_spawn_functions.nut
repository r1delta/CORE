const AI_FLASH_PROTOTYPE_DIST = 1

function main()
{
	if ( !IsMultiplayer() )
		return

	//if ( IsLobby() )
	//	return

	// shared OnSpawned callbacks
	AddSpawnCallback( "script_mover", 		SpawnScriptMover )

	AddSpawnCallback( "npc_gunship", SpawnGunship )
	AddSpawnCallback( "npc_dropship", SpawnDropship )

	AddSpawnCallback( "point_template", PointTemplateSpawn )
	AddSpawnCallback( "path_track", SpawnPathTrack )

	AddSpawnCallback( "npc_titan", SpawnTitan )
	AddSpawnCallback( "npc_turret_mega", SpawnMegaTurret )
	AddSpawnCallback( "npc_turret_mega_bb", SpawnBBTurret )
	AddSpawnCallback( "npc_turret_sentry", SpawnSmallTurret )
	AddSpawnCallback( "info_hint", SpawnInfoHint )
	//AddSpawnCallback( "info_node_hint", SpawnInfoNodeHint )

	Globalize( SpawnInfoNodeHint )
	Globalize( SpawnMarvin_for_MP )

	level.titanPath <- {}
	level.titanPath.groupNodes <- {}
	level.titanPath.startNodes <- {}
	level.titanPath.startNodes[ TEAM_IMC ] <- {}
	level.titanPath.startNodes[ TEAM_MILITIA ] <- {}

	// Arc Cannon Targets
	foreach( classname, val in level.arcCannonTargetClassnames )
		AddSpawnCallback( classname, AddToArcCannonTargets )

	foreach( classname, val in level.proximityTargetClassnames )
		AddSpawnCallback( classname, AddToProximityTargets )

	AddSpawnCallback( "npc_marvin", SpawnMarvin_for_MP )
	AddSpawnCallback( "npc_spectre", SpawnSpectreFunction )
	AddSpawnCallback( "npc_soldier", SpawnNPCSoldier )

	AddSpawnCallback( "trigger_hurt", TriggerHurtSpawned )

	AddDeathCallback( "npc_titan", EmptyDeathCallback ) // so death info gets sent to client
}

function EmptyDeathCallback( _, _ )
{
}

function DrawUse( node )
{
	local org = node.GetOrigin()
	for ( ;; )
	{
		if ( node.s.titanPathInUse )
		{
			DebugDrawLine( org, node.s.titanPathInUse.GetOrigin(), 255, 0, 0, true, 0.1 )
		}

		wait 0
	}
}


function SpawnInfoNodeHint( ent )
{
	//Assert( 0 )
	if ( ent.HasKey( "titan_start" ) )
	{
		if ( ent.kv.titan_start == "1" )
		{
			Assert( ent.HasKey( "TeamNum" ), "titan start has no team" )
			local team = ent.kv.TeamNum.tointeger()
			level.titanPath.startNodes[ team ][ ent ] <- ent
		}
	}

	if ( ent.HasKey( "titan_node" ) )
	{
		if ( ent.kv.titan_node == "1" )
		{
			ent.s.titanPathLastUsed <- -1
			ent.s.titanPathInUse <- null
			//thread DrawUse( ent )
		}
	}

	if ( !ent.HasKey( "titan_group" ) )
		return

	local group = ent.kv.titan_group
	if ( !( group in level.titanPath.groupNodes ) )
	{
		level.titanPath.groupNodes[ group ] <- []
	}

	level.titanPath.groupNodes[ group ].append( ent )
	Assert( level.titanPath.groupNodes[ group ].len() <= 4, "Too many nodes " + ent.GetOrigin() + " " + group )
}

function InitialSpawnLogicBranch( ent )
{
	// this provides a mechanism for placing a logic_branch in script, which
	// can coexist with hammer

	// should no longer be necessary

	local name = ent.GetName()
	local ents = GetEntArrayByName_Expensive( name )

	if ( ents.len() == 1 )
		return

	// get rid of the scripted logic_branch, because this has been placed in Hammer
	foreach ( otherEnt in ents )
	{
		if ( otherEnt != ent )
		{
			Assert( "scripted" in otherEnt.s, "Multiple logic_branches placed in Hammer with name " + name )
			otherEnt.Kill()
			printl( "kill logic branch" )
		}
	}
}

function NameCheck( self )
{
	wait 0 // for all ents to spawn

	if ( !IsValid_ThisFrame( self ) )
		return

	if ( !HasUniqueName( self ) )
		printl( "*** Warning: Found npc with duplicate name " + self.GetName() + " at " + self.GetOrigin() + ". Entities should have unique names!!" )

	wait 0
}

function OnFailedToPath( self )
{
	local results
	for ( ;; )
	{
		results = self.WaitSignal( "OnFailedToPath" )

		printt( self + " failed to path" )
		foreach ( k, v in results )
		{
			printt( "key " + k + " value " + v )
		}
	}
}

function SpawnNPC( self )
{
//	thread OnFailedToPath( self )

	if ( self.GetName().len() == 0 )
	{
		local classname = self.GetClassname()
		self.SetName( UniqueString( classname ) )
	}

	thread NameCheck( self )
	//self.ConnectOutput( "OnDeath", "LootOnDeath" )
	self.ConnectOutput( "OnDamagedByPlayer", NPC_DamagedByPlayer )
	self.ConnectOutput( "OnDeath", NPC_Died )

	self.s.damagedByPlayer <- false
	self.s.inPlayerCrosshair <- false

	// a global npc death function
	thread MonitorNPCDeath( self )

	// GiveStatusBar( self )

	if ( "NPCDidSpawn" in ::getroottable() )
		::NPCDidSpawn( self )

}

function AddTemplateSpawnFunction( templateName, func )
{
	Assert( type( func ) == "function", "Func " + func + " is not a function" )
	Assert( type( templateName ) == "string", "Name " + templateName + " is not a string" )
	if ( !( templateName in level.pointTemplateSpawnFunctions ) )
	{
		level.pointTemplateSpawnFunctions[ templateName ] <- []
	}
	level.pointTemplateSpawnFunctions[ templateName ].append( func )
}

function PointTemplateSpawn( ent )
{
	if ( ent.HasKey( "deathflag" ) )
	{
		FlagInit( ent.kv.deathflag )
	}

	local scope = ent.scope()
	if ( "PostSpawn" in scope )
		return
	if ( "PreSpawnInstance" in scope )
		return

	scope.PostSpawn <- PointTemplateEntitySpawned
	scope.PreSpawnInstance <- PT_PreSpawnInstance
}

function PT_PreSpawnInstance( entityClass, entityName )
{
//	printl( "prespawn for " + self + " entityclass " + entityClass + " entityname " + entityName )
	return {}
}

function PointTemplateEntitySpawned( entities )
{
	if ( self.HasKey( "deathflag" ) )
	{
		thread SetFlagOnAllDead( entities, self.kv.deathflag )
	}

	local name = self.GetName()

	if ( !( name in level.pointTemplateSpawnFunctions ) )
		return

	foreach ( ent in entities )
	{
		foreach ( func in level.pointTemplateSpawnFunctions[ name ] )
		{
			// uncomment to debug
			// printl( "func is " + FunctionToString( func ) )
			thread func( ent )
		}
	}
}

function SpawnNPCSoldier( soldier )
{
	RandomizeSoldierHead( soldier )
	soldier.s.assaultPoint <- CreateAssaultPoint()
	UpdateAIMinimapStatusToOtherPlayers( soldier )

	//if ( Riff_AILethality() != eAILethality.Default )
	//{
	//	switch ( Riff_AILethality() )
	//	{
	//		case eAILethality.High:
	//			soldier.SetHealth( 160 )
	//			soldier.SetMaxHealth( 160 )
	//			break
	//		case eAILethality.VeryHigh:
	//			soldier.SetHealth( 200 )
	//			soldier.SetMaxHealth( 200 )
	//			break
	//	}
	//}
}

function TriggerHurtSpawned( triggerEnt )
{
	triggerEnt.s.damageNonPlayerEntities <- false
}

function RandomizeSoldierHead( npc_soldier )
{
	//Only for IMC now
	if ( npc_soldier.GetTeam() != TEAM_IMC )
		return

	local headIndex = npc_soldier.FindBodyGroup( "head" )
	if ( headIndex == -1 )
	{
		return
	}
	local numOfHeads = npc_soldier.GetBodyGroupModelCount( headIndex )
	local randomHeadIndex = RandomInt( 0, numOfHeads )
	npc_soldier.SetBodygroup( headIndex, randomHeadIndex )
}


//////////////////////////////////////////////////////////
function SpawnSpectreFunction( spectre )
{
	spectre.SetTitle( "#NPC_SPECTRE" )
	spectre.SetDefaultSchedule( "SCHED_ALERT_SCAN" )
	spectre.SetAISettings( "spectre" )	// do this after spawning
	spectre.AllowFlee( false )
	spectre.AllowHandSignals( false )
	local team = spectre.GetTeam()
	if ( team >= 2 )
		SetupSoldierForRPGs( spectre, team )

	CommonInit( spectre )
	InitLeechable( spectre )
	EnableLeeching( spectre )
	spectre.SetUsableByGroup( "enemies pilot" )

	local health = 300

	if ( Riff_AILethality() != eAILethality.Default )
	{
		switch ( Riff_AILethality() )
		{
			case eAILethality.TD_Low:
				health *= TD_LOW_SCALAR_SPECTREHEALTH //200
				break

			case eAILethality.TD_Medium:
			case eAILethality.TD_High:
				health *= TD_MED_SCALAR_SPECTREHEALTH //250
				break

			case eAILethality.High:
				health = 350
				break

			case eAILethality.VeryHigh:
				health = 400
				break
		}
	}

	spectre.SetHealth( health )
	spectre.SetMaxHealth( health )
	spectre.s.preventOwnerDamage <- true
	spectre.s.assaultPoint <- CreateAssaultPoint()

	spectre.SetMoveSpeedScale( 1.25 )
	UpdateAIMinimapStatusToOtherPlayers( spectre )

	thread SpectreEyeGlow( spectre )
}

function SpawnMarvin_for_MP( self )
{
	local model = self.GetModelName()
	Assert( model == "models/robots/marvin/marvin.mdl" || model == "models/robots/marvin/marvin_no_jiggle.mdl" )
	//printl( "marvin" )
	//self.SetTeam( TEAM_UNASSIGNED )
	//self.SetTeam( TEAM_MILITIA )
	//self.kv.teamnumber = TEAM_MILITIA

	self.SetSensing( false )	// don't do traces to look for enemies or players

	if ( !( "jobs" in self.s ) )
	InitMarvinJobs( self )

	GiveMarvinJobsFromTarget( self )

	self.SetAISettings( "marvin" )

	EnableLeeching( self )

	if ( self.GetTarget() != "" )
		return

	local jobs = GetEntArrayByClass_Expensive( "script_marvin_job" )
	//add the barrel jobs
	local prop_physics = GetEntArrayByClass_Expensive( "prop_physics" )
	foreach ( prop in prop_physics )
	{
		if ( prop.HasKey( "job" ) )
			jobs.append( prop )
	}

	//printt( "Found " + jobs.len() + " jobs" )
	//no non barrel jobs - fall back to just stand at the spawn points
	if ( !jobs.len() )
		return

	GiveJobsToMarvin( self, jobs )
	thread MarvinWorksUntilLeeched( self )

	thread MarvinFace( self )
}


function SpawnMarvin( self )
{
	InitMarvinJobs( self )

	GiveMarvinJobsFromTarget( self )

	self.SetAISettings( "marvin" )

	SpawnNPC( self )

	// needs _marvin_faces for enable
	thread MarvinFace( self )
}


function TrackFastPlayer( self )
{
	self.EndSignal( "OnDestroy" )
	self.s.lastFastTime <- 0

	for ( ;; )
	{
		if ( self.IsFastPlayer() )
		{
			self.s.lastFastTime = Time()
		}
		wait 0
	}
}

function SpawnPlayer( self )
{
	thread TrackFastPlayer( self )

	Assert( !IsMultiplayer() )
	VDU_Init()
	PassiveSonarInit( self )
}

const MINIMAP_TURRET_SCALE	 		= 0.17
//coop = x * 0.572
const MINIMAP_TURRET_SCALE_COOP		= 0.097
function SpawnMegaTurret( turret )
{
	local scale = MINIMAP_TURRET_SCALE
	if ( GAMETYPE == COOPERATIVE )
		scale = MINIMAP_TURRET_SCALE_COOP

	turret.SetAimAssistAllowed( false )
	turret.Minimap_SetDefaultMaterial( GetMinimapMaterial( "turret_neutral" ) )
	turret.Minimap_SetFriendlyMaterial( GetMinimapMaterial( "turret_friendly" ) )
	turret.Minimap_SetEnemyMaterial( GetMinimapMaterial( "turret_enemy" ) )
	turret.Minimap_SetBossPlayerMaterial( GetMinimapMaterial( "turret_friendly" ) )
	turret.Minimap_SetObjectScale( scale )
	turret.Minimap_SetZOrder( 10 )

	if ( !IsCapturePointTurret( turret ) )
	{
		turret.Minimap_AlwaysShow( TEAM_IMC, null )
		turret.Minimap_AlwaysShow( TEAM_MILITIA, null )
		turret.Minimap_SetClampToEdge( true )
	}
}

function SpawnBBTurret( turret )
{
	local scale = MINIMAP_TURRET_SCALE
	if ( GAMETYPE == COOPERATIVE )
		scale = MINIMAP_TURRET_SCALE_COOP

	turret.SetAimAssistAllowed( false )
	turret.Minimap_SetDefaultMaterial( GetMinimapMaterial( "turret_neutral" ) )
	turret.Minimap_SetFriendlyMaterial( GetMinimapMaterial( "turret_friendly" ) )
	turret.Minimap_SetEnemyMaterial( GetMinimapMaterial( "turret_enemy" ) )
	turret.Minimap_SetBossPlayerMaterial( GetMinimapMaterial( "turret_friendly" ) )
	turret.Minimap_SetObjectScale( scale )
	turret.Minimap_SetZOrder( 10 )

	if ( !IsCapturePointTurret( turret ) )
	{
		turret.Minimap_AlwaysShow( TEAM_IMC, null )
		turret.Minimap_AlwaysShow( TEAM_MILITIA, null )
		turret.Minimap_SetClampToEdge( true )
	}
}

function SpawnSmallTurret( turret )
{
	turret.SetAimAssistAllowed( false )
}


function SpawnTitan( self )
{
	MeleeInit( self )
	// used so the titan can stand/kneel without cutting off functionality
	self.s.standQueued <- false
	self.s.kneelQueued <- false
	self.s.enableHealthRegen <- true
	self.s.preventOwnerDamage <- true

	local team = self.GetTeam()
	if ( team <= 0 )
	{
		self.SetTeam( self.kv.teamnumber.tointeger() )
	}

	if ( self.GetTeam() == TEAM_UNASSIGNED )
		printl( self + " " + self.entindex() + " spawned without setting team first" )

	if ( !( "titanSettings" in self.s ) )
	{
		self.s.titanSettings <- "titan_atlas"
	}

	if ( !SpawnWithoutSoul( self ) )
	{
		CreateTitanSoul( self )
	}

	self.GiveOffhandWeapon( "mp_titanweapon_vortex_shield", 1 )
	self.SetTacticalAbility( self.GetOffhandWeapon( 1 ), TTA_VORTEX )

	//self.GiveOffhandWeapon( "mp_titanability_bubble_shield", 1 )
	//self.SetTacticalAbility( self.GetOffhandWeapon( 1 ), TTA_WALL )

	//self.GiveOffhandWeapon( "mp_titanability_smoke", 1 )
	//self.SetTacticalAbility( self.GetOffhandWeapon( 1 ), TTA_SMOKE )

	UpdateTitanMinimapStatusToOtherPlayers( self )
}

function SpawnDropship( vehicle )
{
	vehicle.s.recentDamageHistory <- []

	if ( !( "InitLeanDropship" in getroottable() ) )
	{
		//IncludeFile( "_vehicle_Dropship" )
		printt( "Add IncludeFile( \"_vehicle_dropship_new\" ) to your level" )

		Assert( 0, "Add IncludeFile( \"_vehicle_dropship_new\" ) to your level" )
		return
	}
	vehicle.SetAISettings( "vehicle" )
	InitLeanDropship( vehicle )
	thread VehicleAutoBehavior( vehicle )
}

function SpawnGunship( vehicle )
{
	if ( !( "InitLeanGunship" in getroottable() ) )
	{
		//IncludeFile( "_vehicle_gunship" )
		printt( "Add IncludeFile( \"_vehicle_gunship_new\" ) to your level" )

		Assert( 0, "Add IncludeFile( \"_vehicle_gunship_new\" ) to your level" )
		return
	}
	vehicle.SetAISettings( "vehicle" )
	InitLeanGunship( vehicle )
	thread VehicleAutoBehavior( vehicle )
}

function SpawnPathTrack( node )
{
	if ( node.HasKey( "WaitSignal" ) )
		RegisterSignal( node.kv.WaitSignal )

	if ( node.HasKey( "SendSignal" ) )
		RegisterSignal( node.kv.SendSignal )

	if ( node.HasKey( "WaitFlag" ) )
		FlagInit( node.kv.WaitFlag )

	if ( node.HasKey( "SetFlag" ) )
		FlagInit( node.kv.SetFlag )
}

function SpawnWithoutSoul( ent )
{
	if ( ent.HasKey( "noSoul" ) )
	{
		return ent.kv.noSoul
	}

	return "spawnWithoutSoul" in ent.s
}

function SpawnScriptMover( ent )
{
	if ( ent.HasKey( "custom_health" ) )
	{
		//printt( "setting health on " + ent + " to " + ent.kv.custom_health.tointeger() )
		ent.SetHealth( ent.kv.custom_health.tointeger() )
	}
}

function DisableAimAssisst( self )
{
	self.SetAimAssistAllowed( false )
}

function SpawnInfoHint( ent )
{
	if ( !ent.HasKey( "hotspot" ) )
		return

	local hint = ent.kv.hotspot.tolower()
	Assert( hint in level.hotspotHints, "info_hint at " + ent.GetOrigin() + " has unknown hotspot hint: " + hint )
}
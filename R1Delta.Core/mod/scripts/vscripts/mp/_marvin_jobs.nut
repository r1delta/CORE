const BARREL_HERE = "barrel_placed_here"
const MARVIN_DEFAULT_MOVE = "walk_all"

function main()
{
	Globalize( GiveJobsToMarvin )
	Globalize( InitMarvinJob )
	Globalize( TakeAllJobs )
	Globalize( TakeJobs )
	Globalize( GiveJobToMarvin )
	Globalize( GivePreferredJobToMarvin )
	Globalize( GivePreferredJobsToMarvin )
	Globalize( MarvinGetsAGun )
	Globalize( MarvinGetsAGunUnlessFightingEnts )
	Globalize( MarvinFightsUntilCombatEnds )
	Globalize( MarvinWorksForever )
	Globalize( MarvinWorksUntilCombat )
	Globalize( MarvinWorksUntilLeeched )
	Globalize( MarvinFightsForever )
	Globalize( MarvinHasJob )
	Globalize( MarvinIsWorking )
	Globalize( InitMarvinJobs )
	Globalize( GetCurrentJob )
	Globalize( ClassnameSupportsMarvinJob )
	Globalize( GiveMarvinJobsFromTarget )
	Globalize( SetMarvinShouldFightFire )
	Globalize( SetMaxMarvinJobDistance )

	RegisterSignal( "OnDoneWorking" )
	RegisterSignal( "FinishedJob" )
	RegisterSignal( "StartedJob" )
	RegisterSignal( "NewMarvinWorksThread" )
	RegisterSignal( "pickup_barrel" )
	RegisterSignal( "putdown_barrel" )
	RegisterSignal( "weapon_place" )
	RegisterSignal( "weapon_pickup" )
	RegisterSignal( "StopWorking" )
	RegisterSignal( "OnFinishedJob" )
	RegisterSignal( "StopFighting" )

	level.marvinJobEnts <- {} // stored for ResetGame()

	level.jobFuncs <- {}
	level.jobFuncs[ "fightFire" ] <- MarvinFightsFire
	level.jobFuncs[ "welding" ] <- MarvinDoesWelding
	level.jobFuncs[ "window" ] <- MarvinWashesWindows
	level.jobFuncs[ "barrel" ] <- MarvinPicksUpBarrel
	level.jobFuncs[ "putdown" ] <- MarvinPutsDownBarrel // gets put in barrelPutDownSpots
	level.jobFuncs[ "weapon_rack" ] <- MarvinUsesWeaponRack
	level.jobFuncs[ "weapon" ] <- MarvinUsesWeapon

	level.maxMarvinJobDistance <- 1000

	AddSpawnCallback( "script_marvin_job", InitMarvinJob )
}

function TakeAllJobs( marvin )
{
	if ( testent( marvin ) )
		printt( "Taking all jobs from " + marvin )

	marvin.Signal( "StopWorking" )
	// has jobs at all?
	if ( !( "jobs" in marvin.s ) )
		return

	Assert( marvin, marvin + " is not a marvin" )
	Assert( marvin.GetClassname() == "npc_marvin", marvin + " is not a marvin" )

	foreach ( name, array in marvin.s.jobs )
	{
		marvin.s.jobs[ name ] = {}
	}
}

function SetMarvinShouldFightFire( marvin, value )
{
	Assert( "shouldFightFire" in marvin.s )
	marvin.s.shouldFightFire = value
}

function SetMaxMarvinJobDistance( newMax )
{
	level.maxMarvinJobDistance = newMax
}

function AddJob( marvin, jobtype, job )
{
	Assert( jobtype in marvin.s.jobs, "No jobs of type " + jobtype + " for " + marvin )

	marvin.s.jobs[ jobtype ][ job ] <- true
}


function GetJobs( marvin, jobtype )
{
	Assert( jobtype in marvin.s.jobs, "No jobs of type " + jobtype + " for " + marvin )
	local jobs = marvin.s.jobs[ jobtype ]
	Assert( type( jobs ) == "table", "Not a table" )

	local job
	local removelist = []
	local result = []

	foreach ( job, _ in jobs )
	{
		if ( !IsValid( job ) )
		{
			removelist.append( job )
		}
		else
		{
			result.append( job )
		}
	}

	foreach ( job in removelist )
	{
		delete jobs[ job ]
	}

	return result
}


function TakeJobs( marvin, jobs )
{
	// has jobs at all?
	Assert( "jobs" in marvin.s, "Tried to take jobs but marvin " + marvin + " has no jobs" )
	if ( !("jobs" in marvin.s) )
		return

	Assert( marvin, marvin + " is not a marvin" )
	Assert( marvin.GetClassname() == "npc_marvin", marvin + " is not a marvin" )
	Assert( jobs, "No jobs" )

	foreach ( jobType, jobs in marvin.s.jobs )
	{
		RemoveJobs( marvin, jobs, jobType )
	}

}

function RemoveJobs( marvin, removeJobs, name )
{
	local removeList = []
	local jobs = GetJobs( marvin, name )

	// safe remove from table
	foreach ( job in jobs )
	{
		removeList.append( job )
	}

	foreach ( job in removeList )
	{
		if ( job in jobs )
			delete jobs[ job ]
	}
}

function GiveJobToMarvin( marvin, job )
{
	local jobs = []
	jobs.append( job )

	GiveJobsToMarvin( marvin, jobs )
}

function AddJobType( marvin, jobType )
{
	marvin.s.jobs[ jobType ] <- {}
}

function GivePreferredJobToMarvin( marvin, job )
{
	local jobs = []
	jobs.append( job )
	GiveJobsToMarvin( marvin, jobs, true )
}

function GivePreferredJobsToMarvin( marvin, jobs )
{
	GiveJobsToMarvin( marvin, jobs, true )
}

function MarvinHasJob( marvin, job )
{
	Assert( marvin, "No marvin! " + marvin )
	Assert( job, "No job! " + job )

	foreach ( jobType, jobTable in marvin.s.jobs )
	{
		if ( job in jobTable )
		{
			return true
		}
	}

	return false
}

function InitMarvinJobs( marvin )
{
	Assert( !( "jobs" in marvin.s ), marvin + " already had marvin jobs field!" )
//	if ( !( "jobs" in marvin.s ) )
	{
		marvin.s.jobs <- {}
		marvin.s.shouldFightFire <- false
		AddJobType( marvin, "basic" )
		AddJobType( marvin, "preferred" )
		AddJobType( marvin, "barrelPutDownSpots" )
	}
}

function GiveJobsToMarvin( marvin, jobs, preferred = false )
{

	Assert( marvin, marvin + " is not a marvin" )
	Assert( marvin.GetClassname() == "npc_marvin", marvin + " is not a marvin" )
	Assert( jobs, "No jobs!" )
	Assert( type( jobs ) == "array", jobs + " is not an array" )
	Assert( jobs.len() > 0, "No jobs in array " + jobs )

	local basicJobType = "basic"
	if ( preferred )
		basicJobType = "preferred"

	// all marvin related stuff comes in globbed together as jobs,
	// so separate out the stuff that is just used with jobs,
	// such as put down spots.

	local classname
	foreach ( job in jobs )
	{
		if ( "job" in job.s )
		{
			// job is already initialized
			Assert( "user" in job.s, job + " should be initialized by now." )
			switch ( job.s.job )
			{
				case "putdown":
					DropToGround( job ) // making sure the putdown node is on the ground since it's hard to line up nodes in Hammer.
					AddJob( marvin, "barrelPutDownSpots", job )
					break

				default:
					AddJob( marvin, basicJobType, job )
					break
			}
		}
		else
		{
			classname = job.GetClassname()
			if ( ClassnameSupportsMarvinJob( classname ) )
			{
				Assert( job.HasKey( "job" ), job + " wants to be a job, but has no job key" )

				// these jobs are initiated on assignment because we dont want to do a
				// massive getent on these entity types
				if ( !( "user" in job.s ) )
					InitMarvinJob( job )

				AddJob( marvin, basicJobType, job )
			}
		}
	}

	if ( testent( marvin ) )
	{
		printt( "Giving jobs to " + marvin )
		local types = {}
		foreach ( job in jobs )
		{
			if ( "job" in job.s )
			{
				types[ job.s.job ] <- job.s.job
			}
		}

		foreach ( jtype in types )
		{
			printl( "Job type added: " + jtype )
		}

		DumpStack()
	}

	/*
	if ( testent( marvin ) )
	{
		printl( "Marvin " + marvin + " has " + marvin.s.jobs.len() + " jobs_:" )
		foreach ( job in marvin.s.jobs )
		{
			printl( "Has job " + job.s.job )
		}
	}
	*/
}

function ClassnameSupportsMarvinJob( classname )
{
	switch ( classname )
	{
		case "script_marvin_job":
		case "prop_physics":
			return true
	}

	return classname.find( "weapon" ) != null
}

/*
function MarvinUsesWeapon( marvin, weapon )
{
	MarvinDefaultMoveAnim( marvin )
	// make marvin fight for you

	marvin.AssaultPoint( weapon.GetOrigin() )
	marvin.WaitSignal( "OnFinishedAssault" )

	if ( !IsValid( weapon ) )
	{
		// the weapon got removed?
		return
	}

	local classname = weapon.GetClassname()
	printl( "Marvin " + marvin + " gets " + classname )
	weapon.Kill()
	marvin.GiveWeapon( classname )
}
*/

function MarvinUsesWeapon( marvin, weapon )
{
	MarvinDefaultMoveAnim( marvin )

	local groundpos = GroundPos( weapon )
	marvin.AssaultPoint( groundpos )

	if ( testent( marvin ) )
	{
		printt( marvin + " goes to pick up a weapon" )
	}
	marvin.WaitSignal( "OnFinishedAssault" )

	if ( testent( marvin ) )
	{
		printt( "continuing uses weapon for " + marvin )
	}
	//RunToAnimStart( marvin, "mv_gun_pickup_ground", weapon )

	if ( !IsValid( weapon ) )
		return

	thread PlayAnim( marvin, "mv_gun_pickup_ground", marvin, null, 0.5 )

	if ( testent( marvin ) )
		printt( "playing weapon ground pickup on " + marvin )

	OnThreadEnd(
		function() : ( marvin )
		{
			if ( !IsAlive( marvin ) )
				return

			MarvinDefaultMoveAnim( marvin )

			local ent = marvin.GetActiveWeapon()
			if ( IsValid( ent ) )
			{
				ent.Show()
			}
		}
	)


	local classname = weapon.GetClassname()

	marvin.GiveWeapon( classname )
	weapon.Kill()

	marvin.WaitSignal( "OnAnimationDone" )
}


function MarvinUsesWeaponRack( marvin, rack )
{
	MarvinDefaultMoveAnim( marvin )

//	printl( "111" )
	if ( !RackHasWeapon( rack ) )
		return

	RunToAnimStart( marvin, "mv_gun_pickup_rack_alt", rack )
	Assert( rack.HasKey( "racked_weapon" ), "Rack " + rack + " at " + rack.GetOrigin() + " has no racked_weapon" )

	if ( !RackHasWeapon( rack ) )
		return

	thread PlayAnim( marvin, "mv_gun_pickup_rack_alt", rack, null, 0.5 )

//	printl( "playing weapon pickup on " + marvin )

	OnThreadEnd(
		function() : ( marvin )
		{
			if ( !IsAlive( marvin ) )
				return

			MarvinDefaultMoveAnim( marvin )

			local ent = marvin.GetActiveWeapon()
			if ( IsValid( ent ) )
			{
				ent.Show()
			}
		}
	)

	marvin.GiveWeapon( rack.kv.racked_weapon )
	local ent = marvin.GetActiveWeapon()

	// dont render it, to hide lerp pop
	ent.Hide()

	marvin.WaitSignal( "weapon_pickup" )

	if ( IsValid( ent ) )
	{
		// weapon becomes visible post pop
		ent.Show()
	}

	if ( RackHasWeapon( rack ) )
	{
		rack.s.weapon.Kill()
		rack.s.weapon = null
	}

	marvin.WaitSignal( "OnAnimationDone" )
}


function MarvinGetsBarrel( marvin, barrel )
{
	marvin.EndSignal( "OnDoneWorking" )
	marvin.EndSignal( "OnDamaged" )
	marvin.EndSignal( "putdown_barrel" )
	marvin.EndSignal( "OnStartLeech" )


	OnThreadEnd(
		function () : ( marvin, barrel )
		{
			if ( IsValid( barrel ) )
			{
				delete barrel.s.dontAutoClear
				barrel.kv.solid = 6 // solid again
				ClearJobUser( barrel )
				SetJobNextUsableTime( barrel, Time() + 15 )
				barrel.ClearParent()
				barrel.Fire( "wake" )
				barrel.Fire( "enablemotion" )
			}

			if ( IsAlive( marvin ) )
			{
				MarvinDefaultMoveAnim( marvin )
				marvin.ClearIdleAnim()

				delete marvin.s.GetJobOverwrite
				delete marvin.s.barrel
			}
		}
	)


	local attachment = "PROPGUN"
	marvin.s.barrel <- barrel
	marvin.s.GetJobOverwrite <-	PickBestBarrelJob.bindenv( this ) // you need to do this in IncludeFile scripts, or globalize the function
	marvin.SetMoveAnim( "mv_carry_barrel_walk" )
	marvin.SetIdleAnim( "mv_carry_barrel_idle" )
	barrel.SetParent( marvin, attachment, false, 0.5 )
	barrel.s.dontAutoClear <- true
	barrel.kv.solid = 0 // not solid

	marvin.WaitSignal( "OnDeath" )
}

function MarvinDefaultMoveAnim( marvin )
{
	local debug = testent( marvin )
	if ( debug )
		printt( "\n** setting MOVE ANIM for " + marvin )

	if ( marvin.GetActiveWeapon() )
	{
		if ( debug )
		{
			printt( "run all aim!" )
		}

		if ( Flag( "phase_idle" ) )
		{
			marvin.SetMoveSpeedScale( 1 )
		}
		else
		{
			marvin.SetMoveSpeedScale( 1.5 )
		}

		marvin.SetMoveAnim( "Run_all_aim" )
		return
	}


	if ( debug )
		printt( "Setting default move on " + marvin )

	if ( IsLeeched( marvin ) )
	{
		if ( debug )
			printt( "Leeched so clearing move" )

		if ( Flag( "phase_idle" ) )
		{
			marvin.SetMoveSpeedScale( 1 )
		}
		else
		{
			marvin.SetMoveSpeedScale( 1.5 )
		}

		marvin.SetMoveAnim( "run_unarmed" )

		return
	}

	if ( debug )
		printt( marvin + " not leeched so setting slow walk" )

	marvin.SetMoveSpeedScale( 1.0 )
	marvin.SetMoveAnim( MARVIN_DEFAULT_MOVE )
}

function MarvinPicksUpBarrel( marvin, barrel )
{
	MarvinDefaultMoveAnim( marvin )
	Assert( IsValid( barrel ), "Barrel " + barrel + " is not valid" )

	barrel.EndSignal( "OnDestroy" )

	// this info_target lets us ignore part of the
	// barrel's orientation
	local info_target = CreateEntity( "info_target" )

	OnThreadEnd(
		function () : ( info_target, barrel )
		{
			info_target.Kill()
			if ( IsValid( barrel ) )
				barrel.SetOwner( null )
			//printl( "2 Clear owner" )
		}
	)

	local angles = barrel.GetAngles()

	DispatchSpawn( info_target )

	angles.x = 0
	angles.z = 0
	info_target.SetOrigin( barrel.GetOrigin() )
	info_target.SetAngles( angles )

	local groundPos = GroundPos( info_target )
	if ( groundPos.z < -16000 )
	{
		// fell through map
		return
	}

	//printl( "groundPos is " + groundPos + " for " + info_target.GetOrigin() )
	info_target.SetOrigin( groundPos )


	RunToAnimStart( marvin, "mv_carry_barrel_pickup", info_target )
	thread PlayAnim( marvin, "mv_carry_barrel_pickup", info_target, null, 0.6 )


	barrel.SetOwner( marvin )
	//printl( "2 set owner" )
	marvin.WaitSignal( "pickup_barrel" )
	barrel.SetOwner( null )
	//printl( "3 clear owner" )

	local attachment = "PROPGUN"
	local attachIndex = marvin.LookupAttachment( attachment )
	local origin = marvin.GetAttachmentOrigin( attachIndex )
	local angles = marvin.GetAttachmentAngles( attachIndex )

	local dist = Distance( origin, barrel.GetOrigin() )
	if ( dist > 25 )
	{
		//printl( "Dist: " + dist )
		marvin.Anim_Stop()
		return
	}


	thread MarvinGetsBarrel( marvin, barrel )

	marvin.WaitSignal( "OnAnimationDone" )


	// now this marvin will want to put the barrel down
//	marvin.s.GetJobOverwrite <-	BindLocalFunction( GetAvailableBarrelPutDownSpots )
//	BindLocalFunction( GetAvailableBarrelPutDownSpots ).bindenv( this )
}

function MarvinPutsDownBarrel( marvin, job )
{
	local barrel = marvin.s.barrel
	Assert( !( "BARREL_HERE" in job ), "Job " + job + " already has barrel_here" )

	if ( testent( marvin ) )
		printt( marvin + " carries barrel to " + job )
	RunToAnimStart( marvin, "mv_carry_barrel_putdown", job )

	// don't want this marvin to collide with
	// this barrel during the anim
	barrel.SetOwner( marvin )
	//printl( "1 set owner" )

	thread PlayAnim( marvin, "mv_carry_barrel_putdown", job, null, 0.6 )


	// this is some minor cleanup for the fact that the owner gets set
	OnThreadEnd(
		function () : ( barrel )
		{
			barrel.kv.solid = 6 // solid again
			barrel.SetOwner( null )
			//printl( "1 Clear owner" )
		}
	)

	marvin.WaitSignal( "putdown_barrel" )

	barrel.kv.solid = 6 // solid again

	job.s.BARREL_HERE <- true

	thread PollSpotHasBarrel( job, barrel )

	marvin.WaitSignal( "OnAnimationDone" )

}


function PollSpotHasBarrel( job, barrel )
{
/*
	OnThreadEnd(
		function() : ( barrel )
		{
			printt( "Ended PollSpotHasBarrel for " + barrel )
		}
	)
*/

	barrel.EndSignal( "OnDestroy" )

	// checks to see if this barrel was knocked aside
	// For some things its better to poll
	for ( ;; )
	{
		SetJobNextUsableTime( job, Time() + 10 )
		//DebugDrawLine( job.GetOrigin(), job.GetOrigin() + Vector(0,0,64), 255, 255, 100, true, 10 )

		if ( Distance( job.GetOrigin(), barrel.GetOrigin() ) > 10 )
		{
			delete job.s.BARREL_HERE
			break
		}

		wait 5
	}
}

function PickBestBarrelJob( marvin )
{
	local jobs = GetAvailableBarrelPutDownSpots( marvin )
	return PickFarthestJob( marvin, jobs )
}


function GetAvailableBarrelPutDownSpots( marvin )
{
	// first get only ones that arent in use
	//printl( "Marvin " + marvin + " has " + marvin.s.barrelPutDownSpots.len() + " barrel putdown spots" )
	local jobs = GetJobs( marvin, "barrelPutDownSpots" )
	Assert( jobs.len(), "No putdown spots for poor " + marvin + " at " + marvin.GetOrigin() )
	local spots = GetAvailableJobs( marvin, jobs )


	local available = []

	// then filter for a barrel being placed on them
	foreach ( spot in spots )
	{
		if ( BARREL_HERE in spot.s )
			continue

		available.append( spot )
	}


	return available
}

function MarvinFightsFire( marvin, job )
{
	MarvinDefaultMoveAnim( marvin )

	Assert( IsAlive( marvin ), "Marvin " + marvin + " is not alive" )
	RunToAnimStart( marvin, "mv_fireman_idle", job )

	Assert( IsAlive( marvin ), "Marvin " + marvin + " is not alive" )

	for ( ;; )
	{
 		PlayAnim( marvin, "mv_fireman_idle", job, null, 0.6 )
		PlayAnim( marvin, "mv_fireman_shift", job, null, 0.6 )

		if ( job.HasKey( "tempJob" ) && job.kv.tempJob == "1" )   // Comes back as a string instead of Boolean.  Needs code fix?
			break
	}

	SetJobNextUsableTime( job, Time() + 15 )
}

function MarvinDoesWelding( marvin, job )
{
	MarvinDefaultMoveAnim( marvin )

	Assert( IsAlive( marvin ), "Marvin " + marvin + " is not alive" )
	RunToAnimStart( marvin, "mv_idle_weld", job )

	Assert( IsAlive( marvin ), "Marvin " + marvin + " is not alive" )

	local animLength = marvin.GetSequenceDuration( "mv_idle_weld" )
	for ( ;; )
	{
		// This anim loops, so thread it and then wait so we can move to another job if needed
		thread PlayAnim( marvin, "mv_idle_weld", job, null, 0.6 )
		wait animLength

		if ( job.HasKey( "tempJob" ) && job.kv.tempJob == "1" )   // Comes back as a string instead of Boolean.  Needs code fix?
			break
	}

	//thread PlayAnim( marvin, "mv_idle_weld", job, null, 0.6 )
	//wait RandomFloat( 8, 12 )
	//marvin.Anim_Stop()

	SetJobNextUsableTime( job, Time() + 15 )
}

function MarvinWashesWindows( marvin, job )
{
	MarvinDefaultMoveAnim( marvin )

	Assert( IsAlive( marvin ), "Marvin " + marvin + " is not alive" )
	RunToAnimStart( marvin, "mv_idle_wash_window_noloop", job )

	Assert( IsAlive( marvin ), "Marvin " + marvin + " is not alive" )

	for ( ;; )
	{
		PlayAnim( marvin, "mv_idle_wash_window_noloop", job, null, 0.6 )
		PlayAnim( marvin, "mv_idle_buff_window_noloop", job, null, 0.6 )

		if ( job.HasKey( "tempJob" ) && job.kv.tempJob == "1" )   // Comes back as a string instead of Boolean.  Needs code fix?
			break
	}

	SetJobNextUsableTime( job, Time() + 15 )
}

function SetJobNextUsableTime( job, time )
{
	job.s.nextUsableTime = time
}

function SetJobUser( job, marvin )
{
	if ( testent( marvin ) )
		printt( "Marvin " + marvin + " tries to take job " + job.s.job )

	//printl( "Marvin " + marvin + " uses job " + job + " " + job.s.job )
	Assert( !IsAlive( job.s.user ), "Marvin " + marvin + " wants to use job " + job + ", but it already has living user " + job.s.user )
	job.s.user = marvin
}

function ClearJobUser( job )
{
	Assert( !( "dontAutoClear" in job.s ), "Job " + job + " has dont auto clear, but was cleared" )
	job.s.user = null
}

function GetMarvinJobFunc( jobName )
{
	Assert( jobName, "No job!" )
	Assert( jobName in level.jobFuncs, "No known job " + jobName )
	return level.jobFuncs[ jobName ]
}


function MarvinAutoUsesJobs( marvin, jobs )
{
	marvin.EndSignal( "OnDeath" )

//	if ( !MarvinHasJob( marvin, job ) )
	if ( testent( marvin ) )
	{
		printt( marvin + " auto giving " + jobs.len() + " jobs." )
	}
	GiveJobsToMarvin( marvin, jobs )

	if ( !MarvinIsWorking( marvin ) )
		thread MarvinWorksUntilLeeched( marvin )
}

function GiveMarvinJobsFromTarget( marvin )
{
	local targets = GetEntArrayByNameWildCard_Expensive( marvin.GetTarget() )
	local jobs = []

	if ( testent( marvin ) )
	{
		printt( marvin + " checking jobs for target" )
		printt( "Found " + targets.len() + " potential targets" )
	}

	foreach ( target in targets )
	{
		if ( !target.HasKey( "job" ) )
			continue

		if ( !ClassnameSupportsMarvinJob( target.GetClassname() ) )
			continue

		jobs.append( target )
	}

	if ( jobs.len() )
		thread MarvinAutoUsesJobs( marvin, jobs )
}

function OnFailedToPathCheck( marvin, job )
{
	Assert( marvin, "No marvin!" )
	Assert( IsValid( job ), "No job!" )

	marvin.EndSignal( "FinishedJob" )
	local results = marvin.WaitSignal( "OnFailedToPath" )

	// job may have been deleted during this time
	if ( !IsValid( job ) )
		return

	if ( IsAlive( marvin ) )
	{
		printt( marvin + " at " + marvin.GetOrigin() + " failed to path to job at " + job.GetOrigin() )
		if ( IsValid( job ) )
		{
			printt( "Job was " + job.s.job + " at " + job.GetOrigin() )
			DebugDrawLine( marvin.GetOrigin(), job.GetOrigin(), 255, 0, 0, true, 16 )
		}
		else
		{
			printt( "Job is invalid." )
		}
	}

	SetJobNextUsableTime( job, Time() + 15 ) // lets not try that one again right away
}

function GetCurrentJob( marvin )
{
	if ( IsAlive( marvin ) )
	{
		if ( "currentJob" in marvin.s )
		{
			return marvin.s.currentJob
		}
	}

	return null
}


function MarvinExecutesJobFunc( marvin, job, func )
{
	Assert( marvin, "No marvin!" )
	Assert( IsAlive( marvin ), marvin + " is dead." )
	Assert( job, "No job!" )


	if ( testent( marvin ) )
	{
		printt( marvin + " is starting " + FunctionToString( func ) + " at " + job.GetOrigin() )
	}

	thread OnFailedToPathCheck( marvin, job )

	marvin.EndSignal( "OnDeath" )
	marvin.EndSignal( "OnDoneWorking" )
	marvin.EndSignal( "OnFailedToPath" )
	marvin.EndSignal( "OnDamaged" )

	marvin.s.currentJob <- job
	OnThreadEnd(

		function() : ( marvin, job )
		{
			if ( IsValid( marvin ) )
			{
				if ( testent( marvin ) )
					printt( marvin + " finished current job " + job.s.job )

				marvin.Signal( "OnFinishedJob", { job = job } )
				delete marvin.s.currentJob
			}
		}
	)

	func( marvin, job )
}

function MarvinWorksUntilCombat( marvin )
{
	if ( Flag( "phase_alert" ) )
		return

	OnThreadEnd(
		function() : ( marvin )
		{
			if ( IsAlive( marvin ) )
				marvin.Signal( "StopWorking" )
		}
	)

	thread MarvinWorksForever( marvin )
	FlagWait( "phase_alert" )

}


function testent( marvin )
{
	return false
	// debugging happens here
//	return marvin.GetEntIndex() == 1916

	return false

	return marvin.GetName() == "zauto_134"
	//return marvin.GetName() == "auto_134"
	return false
	//return true
	if ( !( "marvin" in level ) )
		return false

	return marvin == level.marvin
}

function MarvinDoesJob( marvin, job )
{
	if ( testent( marvin ) )
		printt( "marvin " + marvin + " does job " + job.s.job )

	Assert( marvin, "No marvin!" )
	Assert( IsAlive( marvin ), "Marvin is dead!" )
	Assert( job, "No job!" )
	Assert( IsJob( job ), "Job " + job + " not initialized properly" )

	local func = GetMarvinJobFunc( job.s.job )

	marvin.Signal( "StartedJob" )
	SetJobUser( job, marvin )
	SetJobNextUsableTime( job, Time() + 10 ) // minimum debounce
	marvin.Anim_Stop() // quit what you were doing

	if ( testent( marvin ) )
	{
		printt( marvin + " does job " + FunctionToString( func ) )
	}
	waitthread MarvinExecutesJobFunc( marvin, job, func )

	// some jobs clear later, like carried barrels
	if ( !( "dontAutoClear" in job.s ) )
		ClearJobUser( job )

	// no endsignal protection in this thread
	if ( IsAlive( marvin ) )
		marvin.Signal( "FinishedJob" )
}

function InitMarvinJob( job, jobname = null )
{
	if ( "user" in job.s )
		return

	job.s.jobname <- job.GetName() // for debug

	job.s.nextUsableTime <- 0 // marvins set this when they finish a job
	job.s.user <- null // gets filled when there is a marvin using it

	if ( jobname )
	{
		job.s.job <- jobname
	}
	else
	{
		Assert( job.HasKey( "job" ), "Job " + job + " at " + job.GetOrigin() + " has no job key" )
		job.s.job <- job.kv.job
	}

	level.marvinJobEnts[ job ] <- true
}

function IsJob( job )
{
	Assert( job, "No job!" )
	return "nextUsableTime" in job.s
}

function FindClosestAvailableJob( marvin )
{
	if ( testent( marvin ) )
		printt( "Finding closest job for " + marvin )

	local jobs
	local preferredJobs = GetJobs( marvin, "preferred" )

	if ( preferredJobs.len() )
	{
		// try to find a perferred job first
		jobs = GetAvailableJobs( marvin, preferredJobs )

		if ( jobs.len() )
			return PickClosestJob( marvin, jobs )
	}

	jobs = GetJobs( marvin, "basic" )
	if ( jobs.len() )
	{
		jobs = GetAvailableJobs( marvin, jobs )
		return PickClosestJob( marvin, jobs )
	}

	return null
}

function CanMarvinDoJob( marvin, job)
{
	if ( "onlyPickTargettedJobs" in marvin.s )
	{
		if ( job.GetTarget() != marvin.GetTarget() )
			return false
	}

	switch ( job.s.job )
	{
		case "fightFire":
			if ( !marvin.s.shouldFightFire )
				return false
			break
		case "weapon_rack":
			if ( !RackHasWeapon( job ) )
				return false
			break
	}

	if ( Time() < job.s.nextUsableTime )
	{
		//printl( "Job " + job + " next use time " + ( job.s.nextUsableTime - Time() ) )
		return false
	}

	return !IsAlive( job.s.user )
}


function GetAvailableJobs( marvin, jobs )
{
	Assert( jobs, "No jobs!" )
	Assert( type( jobs ) == "array", jobs + " is not an array" )
	Assert( jobs.len() > 0, "No jobs in array " + jobs + " for marvin " + marvin + " at " + marvin.GetOrigin() )


	local availableJobs = []

	foreach ( job in jobs )
	{
		Assert( IsJob( job ), "Job " + job + " not initialized properly" )
		if ( !CanMarvinDoJob( marvin, job ) )
			continue

		availableJobs.append( job )
	}

	return availableJobs
}

function PickClosestJob( marvin, availableJobs )
{
	Assert( marvin, marvin + " is not a marvin" )
	Assert( marvin.GetClassname() == "npc_marvin", marvin + " is not a marvin" )
	Assert( availableJobs, "No array of jobs" )
	Assert( type( availableJobs ) == "array", "No array of jobs" )
	Assert( IsAlive( marvin ), "Marvin " + marvin + " is not alive" )
	if ( !availableJobs.len() )
		return null

	local closest = GetClosest( availableJobs, marvin.GetOrigin(), level.maxMarvinJobDistance )
	if ( testent( marvin ) )
		printt( "Picked job " + closest )
	return closest
}

function PickFarthestJob( marvin, availableJobs )
{
	Assert( marvin, marvin + " is not a marvin" )
	Assert( marvin.GetClassname() == "npc_marvin", marvin + " is not a marvin" )
	Assert( availableJobs, "No array of jobs" )
	Assert( type( availableJobs ) == "array", "No array of jobs" )
	if ( !availableJobs.len() )
		return null

	local closest = GetFarthest( availableJobs, marvin.GetOrigin() )
	if ( testent( marvin ) )
		printt( "Picked job " + closest )
	return closest
}

function MarvinPicksJob( marvin )
{
	if ( testent( marvin ) )
		printt( "marvin " + marvin + " picks a job" )

	Assert( marvin, marvin + " is not a marvin" )
	Assert( marvin.GetClassname() == "npc_marvin", marvin + " is not a marvin" )
	Assert( IsAlive( marvin ), "Marvin " + marvin + " is not alive" )

	local availableJobs

	if ( "GetJobOverwrite" in marvin.s )
	{
		local job = marvin.s.GetJobOverwrite( marvin )
		if ( !job )
		{
			//printl( "1Marvin " + marvin + " could not find a job" )
			return
		}
		//printl( "marvin " + marvin + " found job " + job.s.job )
		return job
	}
	else
	{
		local job = FindClosestAvailableJob( marvin )
		if ( !job )
		{
//			printl( "2Marvin " + marvin + " could not find a job" )
			return
		}
	//	printl( "marvin " + marvin + " found job " + job.s.job )
		return job
	}

	//printl( "marvin " + marvin + " couldnt find job" )

}

function MarvinDoesLeechStuffUntilUnleeched( marvin )
{
	marvin.EndSignal( "OnDeath" )
	marvin.Anim_Stop()
	marvin.WaitSignal( "OnStopLeeched" )
}


function MarvinWorksUntilLeeched( marvin )
{
	marvin.EndSignal( "OnLeeched" )

	MarvinWorksForever( marvin )
}

function MarvinWorksUntilGotGun( marvin )
{
	// this function presumes that the marvin only has "getting a weapon" jobs
	Assert( IsAlive( marvin ) )

	if ( marvin.GetActiveWeapon() )
		return

	if ( testent( marvin ) )
	{
		printt( "idle is " + Flag( "phase_idle" ) + " and alert is " + Flag( "phase_alert" ) )
		printt( "marvin " + marvin + " works until he gets a gun" )
		DumpStack()
	}

	thread MarvinWorksForever( marvin )

	marvin.WaitSignal( "OnGiveWeapon" )

	local job = GetCurrentJob( marvin )

	if ( job )
	{
		Assert( job.s.job.find( "weapon" ) != null, "Job " + job + " is not a weapon job, is " + job.s.job )
		// wait until we finish the weapon pickup job
		if ( job.HasKey( "tempJob" ) && job.kv.tempJob == "1" )   // Comes back as a string instead of Boolean.  Needs code fix?
			marvin.WaitSignal( "OnFinishedJob" )
	}
}

function MarvinIsWorking( marvin )
{
	Assert( marvin, "No marvin " + marvin )
	Assert( IsAlive( marvin ), "Marvin " + marvin + " is dead." )

	return "workingThread" in marvin.s
}

function MarvinWorksForever( marvin )
{
//	printl( "\nWORKWORK by " + marvin )
//	DumpStack()
// just to make sure marvin isnt told to do 2 things at once
	Assert( marvin, "No marvin " + marvin )
	Assert( IsAlive( marvin ), "Marvin " + marvin + " is dead." )

	// lame assert needs an IF because it desperately needs to
	// compile the code in the assert
	//if ( MarvinIsWorking( marvin ) )
	//{
	//	Assert( 0, "Marvin " + marvin + " is already working on " + marvin.s.workingThread )
	//}
	if ( MarvinIsWorking( marvin ) )
	{
		if ( testent( marvin ) )
		{
			printt( marvin + " is already working." )
			DumpStack()
		}
		return
	}

/*
		if ( marvin.s.workingThread == workingThread )
		{
			for ( i = 0;; i++ )
			{
				if ( !( "src" in getstackinfos(i) ) )
					break

				printl( "checking " + getstackinfos(i)["func"] )
				if ( getstackinfos(i)["func"] == workingThread )
				{
					if ( testent( marvin ) )
						printl( "marvin " + marvin + " already doing " + workingThread )

					return
				}
			}

			// already working this way
		}

		if ( testent( marvin ) )
			printl( marvin + " already working on " + marvin.s.workingThread + ", replacing" )
	}
*/

	OnThreadEnd(
		function () : ( marvin )
		{
			delete marvin.s.workingThread

			// when he's done working, let all threads know it!
			if ( IsValid( marvin ) )
			{
				marvin.Signal( "OnDoneWorking" )
				//printl( marvin + " is done working!" )
			}
		}
	)

	marvin.Signal( "NewMarvinWorksThread" )
	marvin.EndSignal( "NewMarvinWorksThread" )
	marvin.EndSignal( "OnDeath" )
	marvin.EndSignal( "StopWorking" )

	// get a good name for what the marvin is doing, this will get worse
	// if threads store the callstack
	local i
	local workingThread
	for ( i = 0;; i++ )
	{
		if ( !( "src" in getstackinfos(i) ) )
			break

		workingThread = getstackinfos(i)["func"]
	}

	if ( testent( marvin ) )
		printt( "\n** " + marvin + " works forever on " + workingThread )


	marvin.s.workingThread <- workingThread

//	printl( "Marvin " + marvin + " starts working on " + marvin.s.workingThread )

	if ( marvin.GetActiveWeapon() )
	{
		marvin.DropWeapon()
	}

	if ( testent( marvin ) )
	{
		printt( "\nMarvin " + marvin + " works until stopped" )
//		DumpStack()
	}

	if ( testent( marvin ) )
		printt( marvin + " works forever" )

	// this really should be a wait frame end. We need to let the jobs also spawn
	// and be initialized
//	wait 0

	local target = marvin.GetTarget()

	local job

	if ( target != "" )
	{
		MarvinDoesJobFromName( marvin, target )
	}
	else
	{
		// this marvin doesn't, so let the marvins that do grab the jobs first
		wait 0
	}

	for ( ;; )
	{
		//printl( "Marvin " + marvin + " goes to pick his next job" )
	 	if ( !IsAlive( marvin ) )
	 	{
	 		printt( "Dead marvin is " + marvin )
	 	}
	 	Assert( IsAlive( marvin ), "Marvin " + marvin + " is not alive" )

		job = MarvinPicksJob( marvin )
		if ( !job )
		{
			if ( testent( marvin ) )
			{
				printt( "no job found for " + marvin )
			}
			wait 2
			continue
		}

		if ( testent( marvin ) )
			printt( "2Marvin " + marvin + " is about to do job " + job.s.job )
		waitthread MarvinDoesJob( marvin, job )
	}
}


function MarvinDoesJobFromName( marvin, target )
{
	marvin.s.onlyPickTargettedJobs <- true
	local job = MarvinPicksJob( marvin )
	delete marvin.s.onlyPickTargettedJobs

	if ( job )
	{

		if ( testent( marvin ) )
			printt( "2Marvin " + marvin + " is about to do job " + job.s.job )
		waitthread MarvinDoesJob( marvin, job )
		return true
	}

	return false
	/*
	local possibleJobs, jobs, availableJobs
	// this marvin wants to do a specific job by default
	possibleJobs = GetEntArrayByNameWildCard_Expensive( target )

	jobs = []
	foreach ( job in possibleJobs )
	{
		if ( IsJob( job ) && MarvinHasJob( marvin, job ) )
		{
			jobs.append( job )
		}
	}

	if ( !jobs.len() )
		return false


	FindClosestAvailableJob( marvin )
	availableJobs = GetAvailableJobs( marvin, jobs )

	if ( !availableJobs.len() )
		return false

	local job = PickClosestJob( marvin, availableJobs )
	Assert( job, "No job??" )

	Assert( IsJob( job ), "Marvin at " + marvin.GetOrigin() + " was targetted to ent at " + job.GetOrigin() + " which is not setup as a job." )
	Assert( CanMarvinDoJob( job ), marvin + " wants to do unavailable job " + job )

	if ( testent( marvin ) )
		printt( "1Marvin " + marvin + " is about to do job " + job.s.job )

	waitthread MarvinDoesJob( marvin, job )
	return true
	*/
}

function MarvinGetsAGunUnlessFightingEnts( marvin, weapon_racks = [] )
{
	if ( Flag( "phase_idle" ) )
		return

	FlagEnd( "phase_idle" )

	MarvinGetsAGun( marvin, weapon_racks )
}


function MarvinGetsAGun( marvin, weapon_racks = [] )
{
	Assert( IsAlive( marvin ) )

	if ( testent( marvin ) )
		printt( "marvin " + marvin + " gets a gun" )

	OnThreadEnd(
		function(): ( marvin )
		{
			printt( "OnThreadEnd " + MarvinGetsAGun + " " + marvin )
			if ( IsAlive( marvin ) )
			{
				if ( testent( marvin ) )
					printt( "Marvin " + marvin + " got his gun" )

				TakeAllJobs( marvin )
//				thread MarvinWeaponsFree( marvin )
			}
		}
	)

	if ( marvin.GetActiveWeapon() )
	{
		printt( marvin + " already has a gun" )
		return
	}

	MarvinDefaultMoveAnim( marvin )

	TakeAllJobs( marvin )

	if ( weapon_racks.len() )
		GiveJobsToMarvin( marvin, weapon_racks )

	local weapons = GetWeaponJobs()
	GiveJobsToMarvin( marvin, weapons )

	waitthread MarvinWorksUntilGotGun( marvin )
}

function GetWeaponJobs()
{
	local allweapons = GetEntArrayByClassWildCard_Expensive( "weapon_*" )
	local weapons = []

	foreach ( weapon in allweapons )
	{
		// has an owner?
		if ( weapon.GetWeaponOwner() )
			continue

		weapons.append( weapon )

		if ( !IsJob( weapon ) )
		{
			// just use weapon_rack for now, eventually replace
			// when we get more appropriate anims
			InitMarvinJob( weapon, "weapon" )
		}
	}

	return weapons
}

function MarvinFightsUntilCombatEnds( marvin )
{
	if ( testent( marvin ) )
		printt( marvin + " fights until combat ends" )
	Assert( IsAlive( marvin ), marvin + " is dead!" )

	OnThreadEnd(
		function() : ( marvin )
		{
			if ( IsAlive( marvin ) )
				marvin.Signal( "StopFighting" )
		}
	)

	if ( Flag( "phase_idle" ) )
		return

	thread MarvinFightsForever( marvin )
	FlagWait( "phase_idle" )
}


function MarvinFightsForever( marvin )
{
	Assert( IsAlive( marvin ), marvin + " is dead!" )
	Assert( marvin.GetActiveWeapon(), marvin + " has no weapon!" )
	marvin.EndSignal( "OnDeath" )
	marvin.EndSignal( "StopFighting" )

	local enemy
	local enemies

	thread MarvinWeaponsFree( marvin )

	for ( ;; )
	{
		enemy = marvin.GetEnemy()

		if ( enemy )
		{
			wait 5
			continue
		}

		// need a GetEnemies()
		enemies = GetAllSoldiers()

		if ( !enemies.len() )
		{
			wait 5
			continue
		}

		ArrayRandomize( enemies )

		foreach ( enemy in enemies )
		{
			if ( !IsAlive( enemy ) )
				continue

			if ( enemy.GetNPCState() == "idle" )
				continue

			waitthread MarvinAssaultsEnemy( marvin, enemy )
			break
		}

		wait 1
	}
}

function MarvinAssaultsEnemy( marvin, enemy )
{
	Assert( IsAlive( marvin ) )
	Assert( IsAlive( enemy ) )

	marvin.EndSignal( "OnFailedToPath" )
	marvin.EndSignal( "OnFinishedAssault" )

	marvin.AssaultPoint( enemy.GetOrigin() )

	enemy.WaitSignal( "OnDeath" )
}

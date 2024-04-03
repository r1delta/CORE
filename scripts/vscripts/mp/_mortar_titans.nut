function main()
{
	RegisterSignal( "InterruptMortarAttack" )
}

function SpawnMortarTitan( origin, angles, team )
{
	local table 	= CreateDefaultNPCTitanTemplate( team )
	table.title 	= "#NPC_TITAN_MORTAR"
	table.origin 	= origin
	table.angles 	= angles
	table.model 	= ATLAS_MODEL
	table.settings  = "titan_atlas"
	table.weapon	= "mp_titanweapon_rocket_launcher"
	table.weaponMod = [ "rapid_fire_missiles" ]

	local titan = SpawnNPCTitan( table )
	titan.Minimap_SetEnemyMaterial( "vgui/hud/coop/minimap_coop_mortar_titan" )
	titan.Minimap_SetAlignUpright( true )
	titan.SetSubclass( eSubClass.mortarTitan )
	titan.s.mortarAnimEnt <- CreateScriptRef()
	titan.s.challengeStartTime <- Time()

	local weapon = titan.GetActiveWeapon()
	weapon.s.missileFiredCallback <- { func = MortarMissileFiredCallback, scope = this }

	GiveTitanTacticalAbility( titan, TAC_ABILITY_WALL )

	thread MortarTitanDeathCleanup( titan )

	return titan
}
Globalize( SpawnMortarTitan )


function MortarTitanDeathCleanup( titan )
{
	titan.EndSignal( "Doomed" )
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( titan )
		{
			local animEnt = titan.s.mortarAnimEnt

			if ( IsValid( animEnt ) )
				animEnt.Destroy()

			if ( IsAlive( titan ) )
			{
				titan.Signal( "InterruptMortarAttack" )
				titan.Anim_Stop()
			}
		}
	)

	WaitForever()
}

function MortarMissileFiredCallback( missile, weaponOwner )
{
	thread MortarMissileThink( missile, weaponOwner )
}

function MortarMissileThink( missile, weaponOwner )
{
	Assert( IsValid( missile ) )

	missile.EndSignal( "OnDestroy" )
	missile.EndSignal( "OnDeath" )

	if ( !( "mortarTarget" in weaponOwner.s ) )
		return

	local targetEnt = weaponOwner.s.mortarTarget

	missile.DamageAliveOnly( true )
	missile.kv.lifetime = 6.0
	missile.s.mortar <- true

	// made a hacky way to get the mortar arc to go higher and still have it hit it's target.

	local uniqueID = UniqueString( "missile" )
	local dist = Distance( missile.s.startPos, targetEnt.GetOrigin() )

	local radius = 220 // impact radius
	missile.SetTarget( targetEnt, Vector( RandomInt( -radius, radius ), RandomInt( -radius, radius ), 0 ) )

	local homingSpeedMin = 10
	local homingSpeedMax = Graph( dist, 2500, 7000, 400, 200 )
	local estTravelTime = GraphCapped( dist, 0, 7000, 0, 5 )

	local startTime = Time()
	while( true )
	{
		local frac = min( 1, pow( ( Time() - startTime ) / estTravelTime, 2.0 ) )
		local homingSpeed = GraphCapped( frac, 0, 1, homingSpeedMin, homingSpeedMax )

	 	missile.SetHomingSpeeds( homingSpeed, 0 )
	 	wait 0.25
	}
}

function MoveToMortarPosition( titan, origin, target )
{
	titan.EndSignal( "Doomed" )
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )

	titan.SetLookDist( 320 )
	titan.SetHearingSensitivity( 0 )
	titan.PreferSprint( true )

	local animEnt = titan.s.mortarAnimEnt

	local vector = target.GetOrigin() - origin
	local dist = vector.Norm()
	local angles = vector.GetAngles()
	angles.x = 0
	angles.z = 0

	local frac = TraceLineSimple( origin + Vector( 0, 0, 32 ), origin + Vector( 0, 0, -32 ), titan )
	if ( frac > 0 && frac < 1 )
		origin = origin + Vector( 0, 0, 32 ) - Vector( 0, 0, 64 * frac )

	animEnt.SetOrigin( origin )
	animEnt.SetAngles( angles )

	local goalRadius = 32
	local assaultEnt = CreateStrictAssaultEnt( origin, angles, goalRadius )

	OnThreadEnd(
		function() : ( titan, assaultEnt )
		{
			if ( IsValid( assaultEnt ) )
				assaultEnt.Destroy()

			if ( !IsValid( titan ) )
				return

			local classname = titan.GetClassname()
			titan.SetLookDist( level.lookDist[ classname ] )
			titan.SetHearingSensitivity( level.hearingSensitivity[ classname ] )
			titan.PreferSprint( false )
		}
	)

	local tries = 0
	while( true )
	{
		// temp to see if AssaultPointEnt() is more reliable now days. I'll believe it when I see it.
		local dist = Distance( titan.GetOrigin(), origin )
		if ( dist <= goalRadius * 2 )
			break

		printt( "Mortar titan moving toward his goal", dist, tries++ )
		titan.AssaultPointEnt( assaultEnt )

		local result = WaitSignal( titan, "OnFinishedAssault", "OnAssaultPathStopped", "OnEnterAssaultTolerance" )
	}
}
Globalize( MoveToMortarPosition )

function MortarTitanKneelToAttack( titan )
{
	titan.EndSignal( "Doomed" )
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )

	local animEnt = titan.s.mortarAnimEnt
	waitthread PlayAnim( titan, "at_mortar_stand2knee", animEnt )
}
Globalize( MortarTitanKneelToAttack )

function MortarTitanAttack( titan, target )
{
	titan.EndSignal( "Doomed" )
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "InterruptMortarAttack" )

	OnThreadEnd(
		function() : ( titan )
		{
			if ( !IsValid( titan ) )
				return

			if ( "mortarTarget" in titan.s )
				delete titan.s.mortarTarget

			if ( "selectedPosition" in titan.s )
			{
				titan.s.selectedPosition.inUse = false
				delete titan.s.selectedPosition
			}

			if ( IsAlive( titan ) )
				thread MortarTitanAttackEnd( titan )
		}
	)

	titan.s.mortarTarget <- target
	local animEnt = titan.s.mortarAnimEnt

	// add the mortar mod, we do this so we can get mortar sounds and fx only when firing into the sky
	local weapon = titan.GetActiveWeapon()
	weapon.SetMods(  [ "coop_mortar_titan", "rapid_fire_missiles" ] )

	while( true )
	{
		waitthread PlayAnim( titan, "at_mortar_knee", animEnt )
	}
}
Globalize( MortarTitanAttack )

function MortarTitanAttackEnd( titan )
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )

	local animEnt = titan.s.mortarAnimEnt

	// remove the mortar mod, we do this so that we don't get mortar sound and fx when firing normal
	local weapon = titan.GetActiveWeapon()
	weapon.SetMods(  [ "rapid_fire_missiles" ] )

	WaitEndFrame() // if I didn't add this PlayAnim, below, would return immediately for some unknown reason.

	if ( IsValid( animEnt ) && IsAlive( titan ) )
		waitthread PlayAnim( titan, "at_mortar_knee2stand", animEnt )
}

function MortarTitanStopAttack( titan )
{
	titan.Signal( "InterruptMortarAttack" )
	titan.Anim_Stop()
}
Globalize( MortarTitanStopAttack )

function MortarTitanWaitToEngage( titan, timeFrame )
{
	local endtime = Time() + timeFrame
	local lastHealth = titan.GetHealth()
 	local tickTime = 1.0
 	local minDamage = 75

	while ( Time() < endtime )
	{
		wait tickTime

		local currentHealth = titan.GetHealth()
		if ( lastHealth > ( currentHealth + minDamage ) ) // add minDamage so that we ignore low amounts of damage.
		{
			lastHealth = currentHealth
			endtime = Time() + timeFrame
		}
	}
}
Globalize( MortarTitanWaitToEngage )
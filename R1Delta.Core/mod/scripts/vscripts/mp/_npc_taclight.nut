// _npc_taclight: util for giving NPCs taclights and laser sights
function main()
{
	const WEAPON_TACLIGHT_ATTACHPOINT = "flashlight"
	const WEAPON_TACLIGHT_ATTACHPOINT_HL2 = "muzzle"
	const TACLIGHT_ON_SFX = "VFX.SphereFlashlightOn"
	const TACLIGHT_ON_TITAN_SFX = "TitanTaclight.TurnOn"

	Globalize( GiveTaclight   )
	Globalize( RemoveTaclight )
	Globalize( TaclightOff    )
	Globalize( TaclightOn     )
	Globalize( HasTaclight    )
	Globalize( HasLaserSight  )
	Globalize( LaserSightOff  )
	Globalize( LaserSightOn   )
	Globalize( GiveLaserSight )
	Globalize( EnableAutoTaclightAndLaser )
	Globalize( DisableAutoTaclightAndLaser )
	Globalize( AdjustTacLightAndLaser )

	PrecacheEntity( "point_spotlight" )
	PrecacheEntity( "beam_spotlight" )
}

function GetTaclightAttachInfo( guy )
{
	local weapon = guy.GetActiveWeapon()
	Assert( weapon != null, "Tried to get taclight attachinfo from " + guy + " but he has no weapon." )

	// setup defaults
	local info = {}
	info.weapon <- weapon
	info.attachPoint <- ""
	info.attachIdx <- null
	info.origin <- weapon.GetOrigin()
	info.angles <- weapon.GetAngles()

	// R1 weapons have different naming conventions for attachpoints than old HL2 weapons
	local attachPoints = []
	attachPoints.append( WEAPON_TACLIGHT_ATTACHPOINT )
	attachPoints.append( WEAPON_TACLIGHT_ATTACHPOINT_HL2 )

	local attachIdx = null
	local attachPoint = null

	foreach( point in attachPoints )
	{
		local thisIndex = weapon.LookupAttachment( point )

		if ( thisIndex != null && thisIndex != 0 )
		{
			attachIdx = thisIndex
			attachPoint = point
			break
		}
	}

	if ( attachIdx != null )
	{
		info.attachPoint = attachPoint
		info.attachIdx = attachIdx
		info.origin = weapon.GetAttachmentOrigin( attachIdx )
		info.angles = weapon.GetAttachmentAngles( attachIdx )
	}
	else
	{
		printl( "Couldn't find an attachpoint index for alias " + WEAPON_TACLIGHT_ATTACHPOINT + " in weapon " + weapon + " being held by " + guy + ". Using default attachpoint instead. Taclight/laser may not show up in game." )
	}

	return info
}

function HasTaclight( guy )
{
	Assert( IsValid_ThisFrame( guy ), guy + " is not valid." )
	return "taclights" in guy.s
}

function GiveTaclight( guy, useProjTex = false )
{
	Assert( IsAlive( guy ), guy + " is not alive!" )
	if ( HasTaclight( guy ) )
		return

	// cant give taclight to AI that have no weapon
	if ( !guy.GetActiveWeapon() )
		return

	local beamLength = 120
	local beamWidth = 22
	local beamHDRColorScale = 0.25 // affects beam alpha, range from 0 to 1.0
	local beamSourceHDRColorScale = 0.30
	local beamColor = "200 200 200"

	local projTexFOV = 45
	local projTexFarZ = 550
	local projTexAlpha = 70

	if ( guy.GetClassname() == "npc_titan" )
	{
		beamLength = 300
		beamWidth = 60
		beamHDRColorScale = 0.9
		beamSourceHDRColorScale = 0.8
		beamColor = "0 190 235"

		projTexFOV = 55
		projTexFarZ = 1024
		projTexAlpha = 205
	}

	local attachInfo = GetTaclightAttachInfo( guy )
	local weapon = attachInfo.weapon
	local attachPoint = attachInfo.attachPoint

	guy.s.taclights <- []

	// long thin beam of light
	local point_spotlight = CreateEntity( "point_spotlight" )
	point_spotlight.SetName( UniqueString( "point_spotlight_taclight" ) )
	point_spotlight.SetParent( weapon, attachPoint )
	point_spotlight.kv.spawnflags = 0
	point_spotlight.kv.renderamt = 255
	point_spotlight.kv.rendercolor = beamColor
	point_spotlight.kv.spotlightlength = beamLength
	point_spotlight.kv.spotlightwidth = beamWidth
	point_spotlight.kv.HDRColorScale = beamHDRColorScale
	DispatchSpawn( point_spotlight, false )

	guy.s.taclights.append( point_spotlight.weakref() )

	// the "source" of the beam
	local beam_spotlight = CreateEntity( "beam_spotlight" )
	beam_spotlight.SetName( "beam_spotlight_taclight" )
	beam_spotlight.SetParent( weapon, attachPoint )
	beam_spotlight.kv.renderamt = 255
	beam_spotlight.kv.rendercolor = beamColor
	beam_spotlight.kv.spawnflags = 1
	beam_spotlight.kv.maxspeed = 100
	beam_spotlight.kv.spotlightlength = beamLength
	beam_spotlight.kv.spotlightwidth = beamWidth
	beam_spotlight.kv.HDRColorScale = beamSourceHDRColorScale
	DispatchSpawn( beam_spotlight, false )

	guy.s.taclights.append( beam_spotlight.weakref() )

	// projected texture for the full effect
	if ( useProjTex )
	{
		local env_projectedtexture = CreateEntity( "env_projectedtexture" )
		env_projectedtexture.SetName( UniqueString( "proj_tex_taclight" ) )
		env_projectedtexture.SetParent( weapon, attachPoint )
		env_projectedtexture.kv.spawnflags = 3 // Enabled, Always Update (moving light)
		env_projectedtexture.kv.lightfov = projTexFOV
		env_projectedtexture.kv.nearz = 4.0
		env_projectedtexture.kv.farz = projTexFarZ
		env_projectedtexture.kv.enableshadows = 1
		env_projectedtexture.kv.shadowquality = 1
		env_projectedtexture.kv.lightworld = 1
		env_projectedtexture.kv.brightnessscale = 3
		env_projectedtexture.kv.lightcolor = beamColor + " " + projTexAlpha.tostring()
		env_projectedtexture.kv.colortransitiontime = 0.5
		env_projectedtexture.kv.texturename = "effects/flashlight001"
		DispatchSpawn( env_projectedtexture, false )

		//printl( "projected texture light " + env_projectedtexture )

		guy.s.taclightProjTex <- env_projectedtexture.weakref()
	}

	thread Taclight_CleanupOnDeath( guy )

	TaclightOn( guy, false )
}

function RemoveTaclight( guy )
{
	TaclightOff( guy )

	foreach ( light in guy.s.taclights )
		if ( IsValid_ThisFrame( light ) )
			light.Kill()

	delete guy.s.taclights
}

function Taclight_CleanupOnDeath( guy )
{
	Assert( "taclights" in guy.s )

	local taclights = guy.s.taclights
	local projTexLight = null
	if ( "taclightProjTex" in guy.s )
		projTexLight = guy.s.taclightProjTex

	guy.WaitSignal( "OnDeath" )

	//printl( "guy is valid? " + IsValid_ThisFrame( guy ) )
	TaclightOff( guy )

	//printl( "cleaning up taclight on " + guy )

	foreach ( light in taclights )
	{
		if ( IsValid_ThisFrame( light ) )
		{
			//printl( "killing light " + light )
			light.Kill()
		}
	}

	if ( projTexLight != null && IsValid_ThisFrame( projTexLight ) )
	{
		//printl( "killing projtex " + projTexLight )
		projTexLight.Kill()
	}
}

function TaclightOff( guy )
{
	if ( !IsValid_ThisFrame( guy ) )
		return
	if ( !HasTaclight( guy ) )
		return

	Assert( "taclights" in guy.s )

	foreach ( light in guy.s.taclights )
	{
		if ( IsValid_ThisFrame( light ) )
			light.Fire( "LightOff" )

	//	Assert( IsValid_ThisFrame( light ), "Light " + light + " was not valid, report with repro" )
		//printl( "turning off taclight element: " + light )
	}

	if ( "taclightProjTex" in guy.s )
	{
		Assert( IsValid_ThisFrame( guy.s.taclightProjTex ), "taclightProjTex " + guy.s.taclightProjTex + " was not valid, report with repro" )
		//printl( "turning off taclight element: " + guy.s.taclightProjTex )
		guy.s.taclightProjTex.Fire( "TurnOff" )
	}
}


function TaclightOn( guy, playSound = true )
{
	Assert( "taclights" in guy.s )
	foreach ( light in guy.s.taclights )
		light.Fire( "LightOn" )

	if ( "taclightProjTex" in guy.s )
		guy.s.taclightProjTex.Fire( "TurnOn" )

	if ( playSound )
	{
		local onsound = TACLIGHT_ON_SFX
		if ( guy.GetClassname() == "npc_titan" )
			onsound = TACLIGHT_ON_TITAN_SFX

		EmitSoundOnEntity( guy, onsound )
	}
}

function HasLaserSight( guy )
{
	Assert( IsValid_ThisFrame( guy ), guy + " is not valid." )
	return "lasersight" in guy.s
}

function GiveLaserSight( guy )
{
	//he might have died just before being given the rocket launcher + laser sight
	if( !( IsAlive( guy ) ) )
		return

	if ( HasLaserSight( guy ) )
		return

	// need a weapon to get laser sight
	if ( !guy.GetActiveWeapon() )
		return

	local laserColorStr = "255 0 0"
	local laserFriendlyColorStr = "0 1 0" //was 0 192 0 which is a green beam
	local laserWidth = 2 //was 0.9
	local laserLength = 200

	if( guy.GetClassname() == "npc_titan" )
	{
		return
		/*
		laserColorStr = "255 128 0"
		laserWidth = 4
		laserLength = 4000
		*/
	}

	local attachInfo = GetTaclightAttachInfo( guy )
	local weapon = attachInfo.weapon
	local attachPoint = attachInfo.attachPoint
	local attachIdx = attachInfo.attachIdx
	local attachOrg = attachInfo.origin
	local attachAngles = attachInfo.angles

	local startForward = attachAngles.AnglesToForward()
	local targetSpawnOrg = attachOrg + ( startForward * laserLength )

	local endTarget = CreateEntity( "info_target" )
	endTarget.SetName( UniqueString( "lasersight_info_target" ) )
	endTarget.SetOrigin( targetSpawnOrg )
	endTarget.SetParent( weapon, attachPoint, true )

	DispatchSpawn( endTarget, false )

	local env_beam = CreateEntity( "env_beam" )
	env_beam.SetName( UniqueString( "lasersight_env_beam" ) )
	env_beam.SetParent( weapon, attachPoint )
	env_beam.kv.spawnflags = 513  // Start On, Taper Out
	env_beam.kv.renderamt = 192
	env_beam.kv.rendercolor = laserColorStr
	env_beam.kv.rendercolorFriendly = laserFriendlyColorStr
	env_beam.kv.Radius = 256
	env_beam.kv.BoltWidth = laserWidth
	env_beam.kv.texture = "sprites/laserbeam.spr"
	env_beam.kv.TextureScroll = 35
	env_beam.kv.StrikeTime = "1"
	env_beam.kv.LightningStart = env_beam.GetName()
	env_beam.kv.LightningEnd = endTarget.GetName()
	env_beam.kv.decalname = "Bigshot"
	env_beam.kv.HDRColorScale = 1.0
	env_beam.kv.targetpoint = "-391 64 0"
	env_beam.kv.ClipStyle = 2
	DispatchSpawn( env_beam, false )
	env_beam.SetTeam( guy.GetTeam() )

	env_beam.s.lasersightTarget <- endTarget.weakref()
	guy.s.lasersight <- env_beam.weakref()

	thread LaserSight_CleanupOnDeathOrWeaponRemoved( guy )

	LaserSightOn( guy )
}

function LaserSight_CleanupOnDeathOrWeaponRemoved( guy )
{
	Assert( "lasersight" in guy.s )

	WaitSignal( guy, "OnDeath", "OnTakeWeapon" )

	if ( IsValid_ThisFrame( guy.s.lasersight ) )
	{
		if ( IsValid_ThisFrame( guy.s.lasersight.s.lasersightTarget ) )
			guy.s.lasersight.s.lasersightTarget.Kill()

		guy.s.lasersight.Kill()
	}

	delete guy.s.lasersight
}

function LaserSightOn( guy )
{
	Assert( "lasersight" in guy.s )
	guy.s.lasersight.Fire( "TurnOn" )
}

function LaserSightOff( guy )
{
	if ( !HasLaserSight( guy ) )
		return

	Assert( "lasersight" in guy.s )
	guy.s.lasersight.Fire( "TurnOff" )
}

function DisableAutoTaclightAndLaser( guy )
{
	Assert( IsAlive( guy ), guy + " is not living!" )
	Assert( guy.IsNPC(), guy + " is not an npc!" )

	if ( !( "_adjustTacLightAndLaser_Disable" in guy.s ) )
		guy.s._adjustTacLightAndLaser_Disable <- true
}

function EnableAutoTaclightAndLaser( guy )
{
	Assert( IsAlive( guy ), guy + " is not living!" )
	Assert( guy.IsNPC(), guy + " is not an npc!" )

	if ( ( "_adjustTacLightAndLaser_Disable" in guy.s ) )
		delete guy.s._adjustTacLightAndLaser_Disable
}

function AdjustTacLightAndLaser( self )
{
	if ( "_adjustTacLightAndLaser_Disable" in self.s )
		return

	switch ( self.GetNPCState() )
	{
		case "idle":
			if ( HasTaclight( self ) )
				TaclightOff( self )

			if ( HasLaserSight( self ) )
				LaserSightOff( self )
			break

		case "alert":
			if ( HasTaclight( self ) )
				TaclightOn( self )

			if ( HasLaserSight( self ) )
				LaserSightOff( self )
			break

		case "combat":
			if ( HasTaclight( self ) )
				TaclightOn( self )

			if ( HasLaserSight( self ) )
				LaserSightOn( self )
			break
	}
}


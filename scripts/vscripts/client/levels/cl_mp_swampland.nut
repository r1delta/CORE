const TOWER_LIGHT = "tower_light_red"

enum eRadarState
{
	IDLE_ROTATE,
	DECEL,
	BLEND_TO_ATTACHMENT,
	DONE
}

function main()
{
	AddCreateCallback( "prop_dynamic", CreateCallback_PropDynamic )

	level.propDynamicCreateCallbacks	<- {	prop_airbase_tower_main =	PropAirbaseTowerMainCreated,
												leviathan1 =				LeviathanMiscCreated,
												leviathan2 =				LeviathanMiscCreated }


	PrecacheParticleSystem( TOWER_LIGHT )

	level.skyboxCamOrigin <- Vector( -8192, 9216, -8960 )
	level.towerMain <- null
	
	SetFullscreenMinimapParameters( 4.0, -3000, -200, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 2 )
}

function EntitiesDidLoad()
{
	TowerInit()
}

function CreateCallback_PropDynamic( self, isRecreate )
{
	local name = self.GetName()

	if ( name == "" )
		return

	if ( name in level.propDynamicCreateCallbacks )
	{
		local funcToCall = level.propDynamicCreateCallbacks[ name ]
		if ( funcToCall != null )
		{
			thread funcToCall( self )
		}
	}
}

/*--------------------------------------------------------------------------------------------------------*\
|
|											TOWER
|
\*--------------------------------------------------------------------------------------------------------*/

function PropAirbaseTowerMainCreated( ent )
{
	level.towerMain = ent
}

function TowerInit()
{
	while ( !IsValid( level.towerMain ) )
		wait( 0.0 )

	local radar_lights = [ "light1", "light2", "light3" ]

	local tower_info = {
		tower = level.towerMain,
		towerID = 0,
		radars = [
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_A_MODEL, attachment = "def_radar_a", lights = radar_lights, rotate_time = 40.0, rotation_offset = Vector( 0.0, -90.0, 0.0 ), reversed_rotation = false },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_B_MODEL, attachment = "def_radar_b", lights = radar_lights, rotate_time = 25.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = false },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_C_MODEL, attachment = "def_radar_c", lights = radar_lights, rotate_time = 30.0, rotation_offset = Vector( 0.0, -90.0, 0.0 ), reversed_rotation = true },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_D_MODEL, attachment = "def_radar_d", lights = radar_lights, rotate_time = 70.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = false },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_E_MODEL, attachment = "def_radar_e", lights = radar_lights, rotate_time = 35.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = true },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_F_MODEL, attachment = "def_radar_f", lights = radar_lights, rotate_time = 60.0, rotation_offset = Vector( 0.0, -90.0, 0.0 ), reversed_rotation = false },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_G_MODEL, attachment = "def_radar_g", lights = radar_lights, rotate_time = 50.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = true },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_H_MODEL, attachment = "def_radar_h", lights = radar_lights, rotate_time = 90.0, rotation_offset = Vector( 0.0, -90.0, 0.0 ), reversed_rotation = true },
			{ state = eRadarState.IDLE_ROTATE, model = RADAR_I_MODEL, attachment = "def_radar_i", lights = radar_lights, rotate_time = 45.0, rotation_offset = Vector( 0.0, 90.0, 0.0 ), reversed_rotation = false }
		]
	}

	thread TowerSpawnAndRotateRadars( tower_info )
}

function TowerRadarSpawnLight( script_mover, attachment )
{
	local fxID = GetParticleSystemIndex( TOWER_LIGHT )
	local attachID = script_mover.LookupAttachment( attachment )
	local fx = StartParticleEffectOnEntity( script_mover, fxID, FX_PATTACH_POINT_FOLLOW, attachID )
	return fx
}

function TowerSpawnAndRotateRadars( tower_info )
{
	local tower = tower_info.tower
	tower.s.spawnedFX <- []

	// SPAWN
	foreach ( radar in tower_info.radars )
	{
		Assert( radar.rotate_time > 0, "rotate_time must be greater than 0" )

		radar.is_rotating <- false
		radar.degrees_per_second <- 360.0 / radar.rotate_time
		if ( radar.reversed_rotation )
			radar.degrees_per_second *= -1.0
		radar.rotation_end_time <- 0.0

		radar.attachment_id <- tower.LookupAttachment( radar.attachment )
		radar.attachment_angles <- tower.GetAttachmentAngles( radar.attachment_id )

		radar.rotation_angles <- Vector( 0.0, 0.0, 0.0 )

		radar.decel_start_time <- 0.0
		radar.decel_time <- 0.0
		radar.blend_start_time <- 0.0
		radar.blend_time <- 0.0
		radar.blend_accel_decel_time <- 0.0

		radar.script_mover <- CreateClientsideScriptMover( radar.model, Vector( 0.0, 0.0, 0.0 ), Vector( 0.0, 0.0, 0.0 ) )
		radar.script_mover.NonPhysicsSetRotateModeLocal( true )

		local attachmentID = tower.LookupAttachment( radar.attachment )

		radar.script_mover.SetOrigin( tower.GetAttachmentOrigin( attachmentID ) )
		radar.script_mover.SetParent( tower, radar.attachment, true, 0 )
		radar.script_mover.MarkAsNonMovingAttachment()
		radar.script_mover.NonPhysicsRotateTo( radar.rotation_offset.AnglesCompose( radar.rotation_angles ), 0.016, 0.0, 0.0 )

		foreach ( light in radar.lights )
			tower.s.spawnedFX.append( TowerRadarSpawnLight( radar.script_mover, light ) )
	}

	wait( 0.0 )

	while ( true )
	{
		foreach ( radar in tower_info.radars )
		{
			// IDLE
			if ( radar.state == eRadarState.IDLE_ROTATE )
			{
//				if ( tower_info.towerID == 0 && level.nv.towerMainFalling > 0.0 ||
//					 tower_info.towerID == 1 && level.nv.towerAlphaFalling > 0.0 ||
//					 tower_info.towerID == 2 && level.nv.towerCharlieFalling > 0.0 )
//				{
//					radar.is_rotating = false
//					radar.state = eRadarState.DECEL
//					radar.decel_start_time = Time()
//					radar.decel_time = abs( radar.degrees_per_second ) * 0.25
//				}
//				else
//				{
					if ( Time() >= radar.rotation_end_time )
						radar.is_rotating = false

					if ( !radar.is_rotating )
					{
						radar.is_rotating = true
						radar.rotation_end_time = Time() + 1.0
						radar.rotation_angles.y = AngleNormalize( radar.rotation_angles.y + radar.degrees_per_second )
						radar.script_mover.NonPhysicsRotateTo( radar.rotation_offset.AnglesCompose( radar.rotation_angles ), 1.0, 0.0, 0.0 )
					}
//				}
			}

			// DECEL
			if ( radar.state == eRadarState.DECEL )
			{
				if ( Time() > radar.decel_start_time + radar.decel_time )
				{
					thread TowerLightsOff( tower )

					radar.is_rotating = false
					radar.state = eRadarState.BLEND_TO_ATTACHMENT
					radar.blend_start_time = Time()
					radar.blend_time = 12.0
					radar.blend_accel_decel_time = radar.blend_time * 0.4
				}
				else if ( !radar.is_rotating )
				{
					radar.is_rotating = true

					radar.rotation_angles.y = AngleNormalize( radar.rotation_angles.y + radar.degrees_per_second * 0.1 )

					radar.script_mover.NonPhysicsRotateTo( radar.rotation_offset.AnglesCompose( radar.rotation_angles ), radar.decel_time, 0.0, radar.decel_time )
				}
			}

			// BLEND
			if ( radar.state == eRadarState.BLEND_TO_ATTACHMENT )
			{
				if ( Time() > radar.blend_start_time + radar.blend_time )
				{
					radar.state = eRadarState.DONE
				}

				if ( !radar.is_rotating )
				{
					radar.is_rotating = true

					radar.rotation_angles.y = 0.0
					radar.script_mover.NonPhysicsRotateTo( radar.rotation_offset.AnglesCompose( radar.rotation_angles ), radar.blend_time, radar.blend_accel_decel_time, radar.blend_accel_decel_time )
				}
			}
		}

		wait( 0.0 )
	}
}


/*--------------------------------------------------------------------------------------------------------*\
|
|											LEVIATHANS
|
\*--------------------------------------------------------------------------------------------------------*/

function LeviathanMiscCreated( ent )
{
	AddAnimEvent( ent, "LeviathanFootstep", LeviathanFootstep )
	AddAnimEvent( ent, "LeviathanReactionSmall", LeviathanReactionSmall )
	AddAnimEvent( ent, "LeviathanReactionBig", LeviathanReactionBig )
	AddAnimEvent( ent, "LeviathanDeathVocal", LeviathanDeathVocal )
	AddAnimEvent( ent, "LeviathanBodyfall", LeviathanBodyfall )
	AddAnimEvent( ent, "LeviathanDeathImpact", LeviathanDeathImpact )
}

function LeviathanFootstep( leviathan )
{
	EmitSkyboxSoundAtPosition( leviathan.GetOrigin(), "Leviathan_Footstep" )
}

function LeviathanDeathVocal( leviathan )
{
	EmitSkyboxSoundAtPosition( leviathan.GetOrigin(), "Leviathan_DeathVocal" )
}

function LeviathanBodyfall( leviathan )
{
	EmitSkyboxSoundAtPosition( leviathan.GetOrigin(), "Leviathan_DeathVocal" )
}

function LeviathanReactionSmall( leviathan )
{
	EmitSkyboxSoundAtPosition( leviathan.GetOrigin(), "Leviathan_Reaction_Small" )
}

function LeviathanReactionBig( leviathan )
{
	EmitSkyboxSoundAtPosition( leviathan.GetOrigin(), "Leviathan_Reaction_Big" )
}

function LeviathanDeathImpact( leviathan )
{
	ClientScreenShake( 0.5, 10.0, 5.0, Vector( 0.0, 0.0, 0.0 ) )
}
AMMO_BODYGROUP_COUNT <- 0

function OnWeaponActivate( activateParams )
{
	AMMO_BODYGROUP_COUNT <- min( self.GetWeaponModSetting( "ammo_clip_size" ), 6 )
	UpdateViewmodelAmmo()

	if ( IsServer() )
	{
		if ( !( "deactivationTime" in self.s ) )
		{
			self.s.deactivationTime <- 0
		}
	}

	if ( !( "burstFireCount" in self.s ) )
	{
		self.s.burstFireCount <- 0
	}
	
	SetLoopingWeaponSound_1p3p( "Weapon.XO16_fire_first", "Weapon.XO16_fire_loop", "Weapon.XO16_fire_last",
		                           "Weapon.XO16_fire_first_3P", "Weapon.XO16_fire_loop_3P", "Weapon.XO16_fire_last_3P" )
}

function OnWeaponDeactivate( deactivateParams )
{
	if ( IsServer() )
		self.s.deactivationTime = Time()

	self.ClearLoopingWeaponSound()
	
}

function OnClientAnimEvent( name )
{
	GlobalClientEventHandler( name )
}

function OnWeaponPrimaryAttack( attackParams )
{
	if( !self.IsWeaponAdsButtonPressed() )
		return 0
	
	local damageType = damageTypes.LargeCaliber | DF_STOPS_TITAN_REGEN

	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageType )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	Assert( IsServer() )

	// EXTREMELY HACKY WAY TO GET NPC TITANS TO ACTUALLY USE THE BURST MOD

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )

	local damageType = damageTypes.LargeCaliber | DF_STOPS_TITAN_REGEN

	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageType )
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_X016.ADS_In" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_X016.ADS_Out" )
}

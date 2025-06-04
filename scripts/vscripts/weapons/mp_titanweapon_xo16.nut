
AMMO_BODYGROUP_COUNT <- 6

function OnWeaponActivate( activateParams )
{
	UpdateViewmodelAmmo()

	if ( IsServer() )
	{
		if ( !( "deactivationTime" in self.s ) )
		{
			self.s.deactivationTime <- 0
		}
	}

	if ( !self.HasMod( "accelerator" ) && !self.HasMod( "burst" ) )
	{
		SetLoopingWeaponSound_1p3p( "Weapon.XO16_fire_first", "Weapon.XO16_fire_loop", "Weapon.XO16_fire_last",
		                            "Weapon.XO16_fire_first_3P", "Weapon.XO16_fire_loop_3P", "Weapon.XO16_fire_last_3P" )
	}
}

function OnWeaponDeactivate( deactivateParams )
{
	if ( IsServer() )
		self.s.deactivationTime = Time()

	self.ClearLoopingWeaponSound()
}

function OnWeaponPrimaryAttack( attackParams )
{
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	local damageType = damageTypes.LargeCaliber | DF_STOPS_TITAN_REGEN
	if ( self.HasMod( "burn_mod_titan_xo16" ) )
		damageType = damageType | damageTypes.Electric

	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageType )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )

	Assert( IsServer() );
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.LargeCaliber | DF_STOPS_TITAN_REGEN )
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_X016.ADS_In" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_X016.ADS_Out" )
}

function OnWeaponOwnerChanged( changeParams )
{
	if ( IsClient() )
	{
		if ( changeParams.newOwner != null && changeParams.newOwner == GetLocalViewPlayer() )
			UpdateViewmodelAmmo()
	}
}

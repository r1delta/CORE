AMMO_BODYGROUP_COUNT <- 0
SmartAmmo_SetAllowUnlockedFiring( self, true )
SmartAmmo_SetUnlockAfterBurst( self, false )
function init_smartness()
{
	if( self.HasMod( "smart_core" ) )
	{
		SmartAmmo_SetWarningIndicatorDelay( self, 9999.0 )
	}
}

function OnWeaponActivate( activateParams )
{
	AMMO_BODYGROUP_COUNT <- min( self.GetWeaponModSetting( "ammo_clip_size" ), 6 )
	UpdateViewmodelAmmo()
	SmartAmmo_Start( self )

	if ( IsServer() )
	{
		if ( !( "deactivationTime" in self.s ) )
		{
			self.s.deactivationTime <- 0
		}
	}

	if ( !( "burstFireCount" in self.s ) )
	{
		if ( self.HasMod( "burst" ) )
			self.s.burstFireCount <- self.GetWeaponModSetting( "burst_fire_count" )
		else
			self.s.burstFireCount <- 0
	}

	if( self.HasMod( "smart_core" ) )
	{
		SmartAmmo_Start( self )
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
	if( self.HasMod( "smart_core" ) )
	{
		SmartAmmo_Stop( self )
	}
}

function OnWeaponOwnerChanged( changeParams )
{
	if ( IsClient() )
	{
		if ( changeParams.newOwner != null && changeParams.newOwner == GetLocalViewPlayer() )
			UpdateViewmodelAmmo()
		local viewPlayer = GetLocalViewPlayer() 
		if ( changeParams.newOwner != null && changeParams.newOwner == viewPlayer )
		{
			SmartAmmo_Start( self )
		}
		else if ( changeParams.oldOwner == viewPlayer )
		{
			SmartAmmo_Stop( self, changeParams.oldOwner )
		}		
	}
	else
	{
		if ( changeParams.newOwner != null )
		{
			SmartAmmo_Start( self )
		}
		else
		{
			SmartAmmo_Stop( self, changeParams.oldOwner )
		}
	}
}

function OnClientAnimEvent( name )
{
	GlobalClientEventHandler( name )
}

function OnWeaponPrimaryAttack( attackParams )
{
	local damageType = damageTypes.LargeCaliber | DF_STOPS_TITAN_REGEN
	if ( self.HasMod( "burn_mod_titan_xo16" ) )
		damageType = damageType | damageTypes.Electric
	
	if ( self.HasMod( "smart_core" ) )
	{
		damageType = damageType | damageTypes.Instant
		return SmartAmmo_FireWeapon( self, attackParams, damageType | damageTypes.Bullet )
	}

	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageType )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	Assert( IsServer() )

	// EXTREMELY HACKY WAY TO GET NPC TITANS TO ACTUALLY USE THE BURST MOD
	if ( self.HasMod( "burst" ) )
	{
		if ( "npcNextFireTime" in self.s && Time() < self.s.npcNextFireTime )
			return

		if ( !( "burstShotsRemaining" in self.s ) )
			self.s.burstShotsRemaining <- self.s.burstFireCount

		if ( !( "burstActive" in self.s ) )
			self.s.burstActive <- false
	}

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )

	local damageType = damageTypes.LargeCaliber | DF_STOPS_TITAN_REGEN

	if ( self.HasMod( "burn_mod_titan_xo16" ) )
		damageType = damageType | damageTypes.Electric

	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageType )

	if ( self.HasMod( "burst" ) )
	{
		self.s.burstActive = true
		self.s.burstShotsRemaining--

		if ( self.s.burstShotsRemaining <= 0 )
		{
			self.s.burstActive = false
			self.s.burstShotsRemaining = self.s.burstFireCount
			self.s.npcNextFireTime <- Time() + 0.6
		}
	}
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_X016.ADS_In" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_X016.ADS_Out" )
}

function SmartWeaponFireSound( weapon, target )
{
	//if ( weapon.HasMod( "silencer" ) )
	//{
		//weapon.EmitWeaponSound( "Weapon_SmartPistol.SuppressedFire_Layer1" )
	//}
	//else
	//{
	if ( target == null )
		weapon.EmitWeaponSound( "Weapon_SmartPistol.Fire" )
	else
		weapon.EmitWeaponSound( "Weapon_SmartPistol.Fire" )
	//}
}
init_smartness()
AMMO_BODYGROUP_COUNT <- 6
chargeDownSoundDuration <- 1.0 //"charge_cooldown_time"

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

	/*if ( !self.HasMod( "accelerator" ) && !self.HasMod( "burst" ) )
	{
		SetLoopingWeaponSound_1p3p( "Weapon.XO16_fire_first", "Weapon.XO16_fire_loop", "Weapon.XO16_fire_last",
		                            "Weapon.XO16_fire_first_3P", "Weapon.XO16_fire_loop_3P", "Weapon.XO16_fire_last_3P" )
	}
	*/
}

function OnWeaponDeactivate( deactivateParams )
{
	if ( IsServer() )
		self.s.deactivationTime = Time()

	self.ClearLoopingWeaponSound()

	chargeDownSoundDuration = self.GetWeaponInfoFileKeyField( "charge_cooldown_time" )

}

function OnWeaponPrimaryAttack( attackParams )
{
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	local damageType = damageTypes.Electric | DF_STOPS_TITAN_REGEN

	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.Electric )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )

	Assert( IsServer() );
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.Electric | DF_STOPS_TITAN_REGEN )
}

function OnWeaponChargeBegin( chargeParams )
{
	if ( IsClient() && InPrediction() && !IsFirstTimePredicted() )
		return

	local chargeTime = self.GetWeaponChargeTime()

	StopSoundOnEntity( self, "Weapon_Titan_Sniper_WindDown" )

	if( IsClient() )
		EmitSoundOnEntityWithSeek( self, "Weapon_Titan_Sniper_WindUp", chargeTime )
	
	else
		EmitSoundOnEntityExceptToPlayerWithSeek( self, self.GetWeaponOwner(), "Weapon_Titan_Sniper_WindUp", chargeTime )

}

function OnWeaponChargeEnd( chargeParams )
{
	if ( IsClient() && InPrediction() && !IsFirstTimePredicted() )
		return

	local chargeFraction = self.GetWeaponChargeFraction()
	local seekFrac = chargeDownSoundDuration * chargeFraction
	local seekTime = max( (1 - (seekFrac * chargeDownSoundDuration)), 0 )

	StopSoundOnEntity( self, "Weapon_Titan_Sniper_SustainLoop" )
	StopSoundOnEntity( self, "Weapon_Titan_Sniper_WindUp" )

	if ( IsClient() )
		EmitSoundOnEntityWithSeek( self, "Weapon_Titan_Sniper_WindDown", seekTime )
	else
		EmitSoundOnEntityExceptToPlayerWithSeek( self, self.GetWeaponOwner(), "Weapon_Titan_Sniper_WindDown", seekTime )

}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_40mm.ADS_In" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_40mm.ADS_Out" )
}

function OnWeaponOwnerChanged( changeParams )
{
	if ( IsClient() )
	{
		if ( changeParams.newOwner != null && changeParams.newOwner == GetLocalViewPlayer() )
			UpdateViewmodelAmmo()
	}
}

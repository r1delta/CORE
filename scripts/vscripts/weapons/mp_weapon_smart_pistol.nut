
self.s.damageValue <- self.GetWeaponInfoFileKeyField( "damage_near_value" )
SmartAmmo_SetAllowUnlockedFiring( self, true )
SmartAmmo_SetUnlockAfterBurst( self, (SMART_AMMO_PLAYER_MAX_LOCKS > 1) )
//SmartAmmo_SetWarningIndicatorDelay( self, (SMART_AMMO_PLAYER_MAX_LOCKS - 1) * 0.25 )

// things that
function InitForAllClients()
{
	SmartAmmo_SetWarningIndicatorDelay( self, 0.0 )
}

function OnWeaponActivate( activateParams )
{
    local owner = self.GetWeaponOwner()
    // Only activate the lock-on logic if a player is holding it
    if ( IsValid( owner ) && owner.IsPlayer() )
    {
        SmartAmmo_Start( self )
    }
}

function OnWeaponDeactivate( deactivateParams )
{
	SmartAmmo_Stop( self )
}

function OnWeaponPrimaryAttack( attackParams )
{
	return SmartAmmo_FireWeapon( self, attackParams, damageTypes.Instant | damageTypes.Bullet )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
    self.EmitWeaponSound( "Weapon_SmartPistol.Fire" )
    self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.Instant | damageTypes.Bullet )
    return 1
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_P2011.ADS_In" )
}


function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_P2011.ADS_Out" )
}

function SmartWeaponFireSound( weapon, target )
{
	if ( weapon.HasMod( "silencer" ) )
	{
		weapon.EmitWeaponSound( "Weapon_SmartPistol.SuppressedFire_Layer1" )
	}
	else
	{
		if ( target == null )
			weapon.EmitWeaponSound( "Weapon_SmartPistol.Fire" )
		else
			weapon.EmitWeaponSound( "Weapon_SmartPistol.Fire" )
	}
}

InitForAllClients()


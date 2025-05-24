
function OnWeaponPrimaryAttack( attackParams )
{
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.Bullet )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.Bullet )
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_P2011.ADS_In" )
}


function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_P2011.ADS_Out" )
}

function OnWeaponActivate( activateParams )
{
	if ( self.HasMod( "silencer" ) )
	{
		SetLoopingWeaponSound_1p3p( "Weapon_RE45Auto_FirstShot_1P", "Weapon_RE45Auto_FireLoop_1P", "Weapon_RE45Auto_LoopEnd_1P",
		                            "Weapon_RE45Auto_FirstShot_3P", "Weapon_RE45Auto_FireLoop_3P", "Weapon_RE45Auto_LoopEnd_3P" )
	}
	else
	{
		SetLoopingWeaponSound_1p3p( "Weapon_RE45Auto_FirstShot_1P", "Weapon_RE45Auto_FireLoop_1P", "Weapon_RE45Auto_LoopEnd_1P",
		                            "Weapon_RE45Auto_FirstShot_3P", "Weapon_RE45Auto_FireLoop_3P", "Weapon_RE45Auto_LoopEnd_3P" )
	}
}

function OnWeaponDeactivate( deactivateParams )
{
	self.ClearLoopingWeaponSound()
}

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
	HandleWeaponSoundZoomIn( self, "Weapon_R97.ADS_In" )
}


function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_R97.ADS_Out" )
}

function OnWeaponActivate( activateParams )
{
	local weaponOwner = self.GetWeaponOwner()
	if ( !IsValid_ThisFrame( weaponOwner ) )
		return

	if ( self.HasMod( "silencer" ) )
	{
		SetLoopingWeaponSound_1p3p( "Weapon_R1SMG1.FirstShotSuppressed", "Weapon_R1SMG1.LoopSuppressed", "Weapon_R1SMG1.LoopSuppressedEnd",
		                            "Weapon_R1SMG1.FirstShotSuppressed_3P", "Weapon_R1SMG1.LoopSuppressed_3P", "Weapon_R1SMG1.LoopSuppressedEnd_3P" )
	}
	else
	{
		if( weaponOwner.IsPlayer() )
		{
			SetLoopingWeaponSound_1p3p( "Weapon_CBR101.FirstShot", "Weapon_CBR101.Loop", "Weapon_CBR101.LoopEnd",
		                    	        "Weapon_CBR101.FirstShot_3P", "Weapon_CBR101.Loop_3P", "Weapon_CBR101.LoopEnd_3P" )
		}
		else
		{
			SetLoopingWeaponSound_1p3p( "Weapon_CBR101.FirstShot", "Weapon_CBR101.Loop", "Weapon_CBR101.LoopEnd",
		     	                      	"Weapon_CBR101.FirstShot_NPC", "Weapon_CBR101.Loop_NPC", "Weapon_CBR101.LoopEnd_NPC" )
		}
	}
}

function OnWeaponDeactivate( deactivateParams )
{
	self.ClearLoopingWeaponSound()
}
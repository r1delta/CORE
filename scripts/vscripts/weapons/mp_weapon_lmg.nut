
function OnWeaponPrimaryAttack( attackParams )
{
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	local damageType = damageTypes.Instant | damageTypes.Bullet
	if ( self.HasMod( "burn_mod_lmg" ) )
		damageType = damageType | damageTypes.Gibs
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageType )
}


function OnWeaponNpcPrimaryAttack( attackParams )
{
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.Instant | damageTypes.SmallArms )
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_hemlok.ADS_In" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_hemlok.ADS_Out" )
}

function OnWeaponActivate( activateParams )
{
	local weaponOwner = self.GetWeaponOwner()
	if ( !IsValid_ThisFrame( weaponOwner ) )
		return

	if( self.HasMod( "burn_mod_lmg" ) )
	{
		SetLoopingWeaponSound_1p3p( "Weapon_LMG_FirstShot", "Weapon_LMG_Loop_Fast", "Weapon_LMG_LoopEnd",
		                            "Weapon_LMG_FirstShot_3P", "Weapon_LMG_Loop_Fast_3P", "Weapon_LMG_LoopEnd_3P" )
	}
	else
	{
		//It seems weapon owner can be null if the owner is an NPC.
		if( weaponOwner.IsPlayer() )
		{
			SetLoopingWeaponSound_1p3p( "Weapon_LMG_FirstShot", "Weapon_LMG_Loop", "Weapon_LMG_LoopEnd",
			                            "Weapon_LMG_FirstShot_3P", "Weapon_LMG_Loop_3P", "Weapon_LMG_LoopEnd_3P" )
		}
		else
		{
			SetLoopingWeaponSound_1p3p( "Weapon_LMG_FirstShot", "Weapon_LMG_Loop", "Weapon_LMG_LoopEnd",
			                            "Weapon_LMG_FirstShot_3P_NPC", "Weapon_LMG_Loop_3P_NPC", "Weapon_LMG_LoopEnd_3P_NPC" )
		}
	}
}

function OnWeaponDeactivate( deactivateParams )
{
	self.ClearLoopingWeaponSound()
}
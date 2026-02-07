fire_npc_looping_1p_first <- ["R97_AI_WpnFire_FirstShot_A", "R97_AI_WpnFire_FirstShot_B", "R97_AI_WpnFire_FirstShot_A", "R97_AI_WpnFire_FirstShot_B"]
fire_npc_looping_1p_loop <- ["R97_AI_WpnFire_Loop_A", "R97_AI_WpnFire_Loop_B", "R97_AI_WpnFire_Loop_A", "R97_AI_WpnFire_Loop_B"]
fire_npc_looping_1p_last <- ["R97_AI_WpnFire_Tail_A", "R97_AI_WpnFire_Tail_B", "R97_AI_WpnFire_Tail_A", "R97_AI_WpnFire_Tail_B"]

fire_npc_looping_1p_first_coop <- ["R97_AI_WpnFire_FirstShot_A_Coop", "R97_AI_WpnFire_FirstShot_B_Coop", "R97_AI_WpnFire_FirstShot_A_Coop", "R97_AI_WpnFire_FirstShot_B_Coop"]
fire_npc_looping_1p_loop_coop <- ["R97_AI_WpnFire_Loop_A_Coop", "R97_AI_WpnFire_Loop_B_Coop", "R97_AI_WpnFire_Loop_A_Coop", "R97_AI_WpnFire_Loop_B_Coop"]
fire_npc_looping_1p_last_coop <- ["R97_AI_WpnFire_Tail_A_Coop", "R97_AI_WpnFire_Tail_B_Coop", "R97_AI_WpnFire_Tail_A_Coop", "R97_AI_WpnFire_Tail_B_Coop"]

weaponFireID <- GetWeaponFireID( self )
Assert( weaponFireID < MAX_WEAPON_FIRE_ID )

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
		SetLoopingWeaponSound_1p3p( "Weapon.R97_fire_firstSuppressed", "Weapon.R97_fire_loopSuppressed", "Weapon.R97_fire_lastSuppressed",
		                            "Weapon.R97_fire_firstSuppressed_3P", "Weapon.R97_fire_loopSuppressed_3P", "Weapon.R97_fire_lastSuppressed_3P" )
	}
	else
	{
		if ( weaponOwner.IsPlayer() )
		{
			SetLoopingWeaponSound_1p3p( "Weapon.R97_fire_first", "Weapon.R97_fire_loop", "Weapon.R97_fire_last",
			                            "Weapon.R97_fire_first_3P", "Weapon.R97_fire_loop_3P", "Weapon.R97_fire_last_3P" )
		}
		else
		{
			if ( GAMETYPE == COOPERATIVE )
			{
				SetLoopingWeaponSound_1p3p( fire_npc_looping_1p_first_coop[weaponFireID], fire_npc_looping_1p_loop_coop[weaponFireID], fire_npc_looping_1p_last_coop[weaponFireID],
				                            fire_npc_looping_1p_first_coop[weaponFireID], fire_npc_looping_1p_loop_coop[weaponFireID], fire_npc_looping_1p_last_coop[weaponFireID] )
			}
			else
			{
				SetLoopingWeaponSound_1p3p( fire_npc_looping_1p_first[weaponFireID], fire_npc_looping_1p_loop[weaponFireID], fire_npc_looping_1p_last[weaponFireID],
				                            fire_npc_looping_1p_first[weaponFireID], fire_npc_looping_1p_loop[weaponFireID], fire_npc_looping_1p_last[weaponFireID] )
			}
		}
	}
}

function OnWeaponDeactivate( deactivateParams )
{
	self.ClearLoopingWeaponSound()
}
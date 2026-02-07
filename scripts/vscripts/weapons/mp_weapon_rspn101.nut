fire_npc_looping_1p_first <-  ["R101_AI_WpnFire_FirstShot_A", "R101_AI_WpnFire_FirstShot_B", "R101_AI_WpnFire_FirstShot_C", "R101_AI_WpnFire_FirstShot_D"]
fire_npc_looping_1p_loop <- ["R101_AI_WpnFire_Loop_A", "R101_AI_WpnFire_Loop_B", "R101_AI_WpnFire_Loop_C", "R101_AI_WpnFire_Loop_D"]
fire_npc_looping_1p_last <- ["R101_AI_WpnFire_Tail_A", "R101_AI_WpnFire_Tail_B", "R101_AI_WpnFire_Tail_C", "R101_AI_WpnFire_Tail_D"]

fire_npc_looping_1p_first_coop <-  ["R101_AI_WpnFire_FirstShot_A_Coop", "R101_AI_WpnFire_FirstShot_B_Coop", "R101_AI_WpnFire_FirstShot_C_Coop", "R101_AI_WpnFire_FirstShot_D_Coop"]
fire_npc_looping_1p_loop_coop <- ["R101_AI_WpnFire_Loop_A_Coop", "R101_AI_WpnFire_Loop_B_Coop", "R101_AI_WpnFire_Loop_C_Coop", "R101_AI_WpnFire_Loop_D_Coop"]
fire_npc_looping_1p_last_coop <- ["R101_AI_WpnFire_Tail_A_Coop", "R101_AI_WpnFire_Tail_B_Coop", "R101_AI_WpnFire_Tail_C_Coop", "R101_AI_WpnFire_Tail_D_Coop"]

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
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.SmallArms )
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
	else if ( !self.HasMod( "single_shot" ) || !self.HasMod( "burst" ) )
	{
		if ( weaponOwner.IsPlayer() )
		{
			SetLoopingWeaponSound_1p3p( "Weapon_R1SMG1.FirstShot", "Weapon_R1SMG1.Loop", "Weapon_R1SMG1.LoopEnd",
			                            "Weapon_R1SMG1.FirstShot", "Weapon_R1SMG1.Loop_3P", "Weapon_R1SMG1.LoopEnd_3P" )
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

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon.r1SMG.ADS" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon.r1SMG.ADS" )
}
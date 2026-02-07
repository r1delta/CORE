function OnWeaponPrimaryAttack( attackParams )
{
	local hasTwinSlugMod = self.HasMod( "twin_slug" )
	if( self.HasMod( "silencer" ) )
		self.EmitWeaponSound( "Dragons_Breath.SingleSuppressed" )
	else if ( hasTwinSlugMod )
		self.EmitWeaponSound( "Weapon_R1Shotgun.Double" )
	else if ( self.HasMod( "burn_mod_shotgun" ) )
	{
		if( self.GetShotCount() == 0 )
			self.EmitWeaponSound( "Dragons_Breath.Auto" )
		else
			self.EmitWeaponSound( "Dragons_Breath.Auto" )
	}
	else
		self.EmitWeaponSound( "Dragons_Breath.Single" )

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	ShotgunBlast( attackParams.pos, attackParams.dir, 8, damageTypes.LargeCaliber | DF_SPECTRE_GIB | DF_SHOTGUN )

	if ( hasTwinSlugMod )
		return 2
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	local hasTwinSlugMod = self.HasMod( "twin_slug" )
	if( self.HasMod( "silencer" ) )
		self.EmitWeaponSound( "Dragons_Breath.SingleSuppressed" )
	else if ( hasTwinSlugMod )
		self.EmitWeaponSound( "Weapon_R1Shotgun.Double" )
	else if ( self.HasMod( "burn_mod_shotgun" ) )
	{
		if( self.GetShotCount() == 0 )
			self.EmitWeaponSound( "Dragons_Breath.Auto" )
		else
			self.EmitWeaponSound( "Dragons_Breath.Auto" )
	}
	else
		self.EmitWeaponSound( "Dragons_Breath.Single" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	ShotgunBlast( attackParams.pos, attackParams.dir, 8, damageTypes.LargeCaliber )

	if ( hasTwinSlugMod )
		return 2
}

function OnWeaponBulletHit( hitParams )
{
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_EVA8.ADS_In" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_EVA8.ADS_Out" )
}

function OnWeaponActivate( activateParams )
{

}



function OnWeaponPrimaryAttack( attackParams )
{
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	ShotgunBlast( attackParams.pos, attackParams.dir, 7, damageTypes.LargeCaliber | DF_SPECTRE_GIB | DF_SHOTGUN )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	ShotgunBlast( attackParams.pos, attackParams.dir, 7, damageTypes.LargeCaliber )
}

function OnClientAnimEvent( name )
{
	GlobalClientEventHandler( name )

	if ( name == "shell_eject" )
	{
		thread DelayedCasingsSound( 0.6 )
	}
}

function DelayedCasingsSound( delayTime )
{
	Wait( delayTime )

	if ( !IsValid( self ) )
		return

	self.EmitWeaponSound( "SG_Twin_B.shell_drop" )
}

function OnWeaponBulletHit( hitParams )
{
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "SG_twinB.ADS_In" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "SG_twinB.ADS_Out" )
}

function OnWeaponActivate( activateParams )
{

}

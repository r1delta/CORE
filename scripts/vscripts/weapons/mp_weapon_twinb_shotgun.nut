

function OnWeaponPrimaryAttack( attackParams )
{
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	ShotgunBlast( attackParams.pos, attackParams.dir, 7, damageTypes.LargeCaliber | DF_SPECTRE_GIB | DF_SHOTGUN )

	local owner = self.GetWeaponOwner()
	if ( IsServer() && owner.IsPlayer() )
	{
		local sound = "SG_Twin_B.Fire"
		if ( self.HasModDefined( "silencer" ) && self.HasMod( "silencer" ) )
			sound = "SG_Twin_B.Fire_Suppressed"

		EmitSoundOnEntityExceptToPlayer( owner, owner, sound )
	}
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
	else if ( name == "ammo_update_twinb" )
	{
		HACK_TwinbUpdateViewmodelAmmo()
	}
	else if ( name == "ammo_full_twinb" )
	{
		HACK_TwinbUpdateViewmodelAmmo( true )
	}
}

function DelayedCasingsSound( delayTime )
{
	Wait( delayTime )

	if ( !IsValid( self ) )
		return

	self.EmitWeaponSound( "SG_Twin_B.shell_drop" )
}

// HACK	because index 0 for bodygroup "ammo" MUST be blank, so it disappears when event AE_WPN_CLIPBODYGROUP_HIDE happens
// but that completely messes up the ordering for the rest of the indexes, so we gotta add +1
function HACK_TwinbUpdateViewmodelAmmo( forceFull = false )
{
	if ( !IsClient() )
		return

	if ( !IsValid( self ) )
		return

	if ( !IsLocalViewPlayer( self.GetWeaponOwner() ) )
		return

	local rounds = self.GetWeaponPrimaryClipCount()
	if ( forceFull || ( rounds > AMMO_BODYGROUP_COUNT ) )
		rounds = AMMO_BODYGROUP_COUNT

	rounds += 1

	//printt( "Updating for rounds: " + rounds );
	self.SetViewmodelAmmoModelIndex( rounds )
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
	AMMO_BODYGROUP_COUNT <- min( self.GetWeaponModSetting( "ammo_clip_size" ), 2 )
	HACK_TwinbUpdateViewmodelAmmo()
}

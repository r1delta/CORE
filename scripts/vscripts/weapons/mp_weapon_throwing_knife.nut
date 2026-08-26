
function ThrowingKnifePrecache()
{
	if ( WeaponIsPrecached( self ) )
		return

	if ( IsServer() )
	{
		PrecacheEntity( "npc_grenade_frag" )
	}
}
ThrowingKnifePrecache()

function OnWeaponPrimaryAttack( attackParams )
{
	self.EmitWeaponSound( "Weapon_FragGrenade_Throw" )
	//Grenade_Throw( self, attackParams, 99 )
	Knife_Throw( self, attackParams, 99 )
}

function Knife_Throw( weapon, attackParams, baseFuseTime = DEFAULT_FUSE_TIME )
{
	if ( IsClient() && !weapon.ShouldPredictProjectiles() )
		return

	//TEMP FIX while Deploy anim is added to sprint
	if ( !( "startTime" in weapon.s ) )
		weapon.s.startTime <- null
	self.s.startTime = Time()

	local weaponOwner = weapon.GetWeaponOwner()
	local attackOrigin = weaponOwner.EyePosition() // attackParams.pos
	local attackAngles = attackParams.dir.GetAngles()
	attackAngles.x -= 5
	local forward = attackAngles.AnglesToForward()
	local velocity = (forward) * 1500
	local angularVelocity = Vector( 0, 0, 0 )
	local fuseTime = baseFuseTime - ( Time() - weapon.s.startTime )

	if ( fuseTime <= 0 )
		return 0


	local frag = weapon.FireWeaponGrenade( attackOrigin, velocity, angularVelocity, fuseTime, damageTypes.Ragdoll, damageTypes.Explosive, PROJECTILE_PREDICTED, true, true )

	if ( frag )
	{
		if ( IsServer() )
		{
			Grenade_Init( frag, weapon )
			thread TrapExplodeOnDamage( frag, 20, 0.0, 0.0 )
			thread FakeKnifeHit( attackParams, frag )
		}
		else
		{
			frag.SetTeam( weaponOwner.GetTeam()	)
		}
	}

	weaponOwner.Signal("ThrowGrenade")
	//return 1
}

// Targets that get too close dont get hit by the actual projectile
function FakeKnifeHit( attackParams, frag )
{
	wait 0.25

	if ( !IsValid( self ) )
		return

	local owner = self.GetWeaponOwner()
	if ( !IsValid( owner ) )
		return

	local origin = owner.EyePosition()
	local angles = owner.EyeAngles()
	local forward = angles.AnglesToForward()
	local result = TraceLine( origin, origin + forward * 2000, [owner, self, frag], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

	local ent = result.hitEnt
	if ( ent && ent.IsHumanSized() && Distance( origin, ent.GetOrigin() ) <= 180 )
		ent.TakeDamage( self.GetWeaponModSetting( "damage_near_value" ), owner, owner, { scriptType = DF_RAGDOLL | DF_INSTANT | DF_KILLSHOT, damageSourceId = eDamageSourceId.mp_weapon_mega5 } )
}

function OnWeaponActivate( prepParams )
{
	self.EmitWeaponSound( "Weapon_ThrowingKnife_Draw" )
	if ( !( "startTime" in self.s ) )
		self.s.startTime <- null
	self.s.startTime = Time()

	//Grenade_Deploy( self, prepParams, 99 )
}

function OnWeaponDeactivate( deactivateParams )
{
	Grenade_Deactivate( self, deactivateParams )
}

function OnProjectileCollision( collisionParams )
{
	local bounceDot = 1.0  // sets the dot of the normals it'll stick to
	local result = PlantStickyEntity( self, collisionParams, bounceDot )

	local hitEnt = collisionParams.hitent
	if ( hitEnt != null && IsServer() )
	{
		if ( "playedScans" in self.s )
			return

		EmitSoundOnEntity( self, "Default.WallCling_Attach" )
		//self.SetVelocity( Vector( 0, 0, 0 ) )

		local mods = self.GetMods()
		local owner = self.GetOwner()

		if ( owner && owner.IsPlayer() && ArrayContains( mods, "burn_mod_throwing_knife" ) )
		{
			LeechSurroundingSpectres( self.GetOrigin(), owner )
			//ActivateBurnCardSonar( owner, BURNCARD_AUTO_SONAR_IMAGE_DURATION , true, null )
			//EmitSoundOnEntityToOpponents( owner, "radarpulse_ping" )
		}

		self.s.playedScans <- true
		thread DissolveKnife( self )
	}
}

function DissolveKnife( self )
{
	wait 3.0
	if ( IsValid_ThisFrame( self ) )
	{
		self.Destroy()

		//self.Die( level.worldspawn, level.worldspawn, { scriptType = DF_MELEE, damageSourceId = eDamageSourceId.mp_weapon_smart_pistol } )
		//self.Dissolve( ENTITY_DISSOLVE_CHAR, Vector( 0, 0, 0 ), 0 )
		//EmitSoundAtPosition( self.GetOrigin(), "Object_Dissolve" )
	}
}

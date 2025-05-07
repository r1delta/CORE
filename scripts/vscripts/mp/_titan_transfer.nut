function main()
{
	// these vars transfer from player titan to npc titan and vice versa

	Globalize( PilotBecomesTitan )
	Globalize( TitanBecomesPilot )
	Globalize( TakeAllWeapons )
	Globalize( PlayerStopsBeingTitan )
	Globalize( CreateTitanFromPlayer )
	Globalize( CreateHiddenTitanFromPlayer )
	Globalize( CopyWeapons )
	Globalize( StoreWeaponsToTable )
	Globalize( StorePilotWeapons )
	Globalize( RetrievePilotWeapons )
	Globalize( ApplyTitanColor )

	RegisterSignal( "PlayerEmbarkedTitan" )
	RegisterSignal( "PlayerDisembarkedTitan" )

	AddDeathCallback( "player", OnPlayerDeathStopEngineSound )
	AddSoulTransferFunc( Bind( TitanCoreEffectTransfer ) )
}

function TitanCoreEffectTransfer( soul, titan = null, oldTitan = null )
{
	thread TitanCoreEffectTransfer_threaded( soul, titan, oldTitan )
}
function TitanCoreEffectTransfer_threaded( soul, titan = null, oldTitan = null )
{
	WaitEndFrame() // because the titan aint a titan yet

	if ( !IsValid( soul ) || !IsValid( titan ) )
		return

	if ( !( "coreEffect" in soul.s ) )
		return

	soul.s.coreEffect.ent.Kill()
	soul.s.coreEffect.ent = soul.s.coreEffect.func( titan )
}
Globalize( TitanCoreEffectTransfer_threaded )

function PlayerStopsBeingTitan( titan )
{
	titan.ClearDoomed()
	titan.UnsetUsable()

	//disable rodeo for a bit after turning back into a pilot
	//i.e. through ejecting or disembarking
	titan.rodeoDisabledTime = Time() + 1.25
	titan.lastTitanTime = Time()
}

function CopyWeapons( fromEnt, toEnt )
{
	local weapons = fromEnt.GetMainWeapons()
	foreach ( weapon in weapons )
	{
		toEnt.GiveExistingWeapon( fromEnt.TakeWeapon_NoDelete( weapon.GetClassname() ) )
	}

	local offhandWeapon

	offhandWeapon = fromEnt.TakeOffhandWeapon_NoDelete( 0 )
	if ( offhandWeapon )
		toEnt.GiveExistingOffhandWeapon( offhandWeapon, 0 )

	offhandWeapon = fromEnt.TakeOffhandWeapon_NoDelete( 1 )
	if ( offhandWeapon )
		toEnt.GiveExistingOffhandWeapon( offhandWeapon, 1 )

	offhandWeapon = fromEnt.TakeOffhandWeapon_NoDelete( 2 )
	if ( offhandWeapon )
		toEnt.GiveExistingOffhandWeapon( offhandWeapon, 2 )
}

function GiveWeaponsFromStoredArray( array, ent, GiveFuncName )
{
	// array backwards so we end up with the correct weapon in hand
	// it might not actually work like this though.
//	for ( local i = array.len() - 1; i >= 0; i-- )
	for ( local i = 0; i < array.len(); i++ )
	{
		local weaponTable = array[i]

		switch ( GiveFuncName )
		{
			case "GiveWeapon":
				ent.GiveWeapon( weaponTable.name, weaponTable.mods )
				break

			case "GiveOffhandWeapon":
				ent.GiveOffhandWeapon( weaponTable.name, i, weaponTable.mods )
				local weapon = ent.GetOffhandWeapon( i )
				weapon.SetNextAttackAllowedTime( weaponTable.nextAttackTime )
				break

			default:
				Assert( 0, "Unhandled givefuncname " + GiveFuncName )
		}
	}

	local weapons

	switch ( GiveFuncName )
	{
		case "GiveWeapon":
			weapons = ent.GetMainWeapons()
			break

		case "GiveOffhandWeapon":
			weapons = ent.GetOffhandWeapons()
			break
	}

	foreach ( weapon in weapons )
	{
		for ( local i = 0; i < array.len(); i++ )
		{
			local weaponTable = array[i]

			if ( weaponTable.name != weapon.GetClassname() )
				continue

			weapon.SetWeaponPrimaryAmmoCount( weaponTable.ammoCount )
			if ( GiveFuncName == "GiveWeapon" )
			{
				printt( "[Weapon name]", weaponTable.name )
				weapon.SetWeaponPrimaryClipCount( weaponTable.clipCount )
			}
			break
		}
	}
}

function StoreWeapons( ent )
{
	local table = {}
	local weapons = ent.GetMainWeapons()
	StoreWeaponsToTable( table, weapons, "mainWeapons" )

	table.activeWeapon <- null
	local activeWeapon = ent.GetActiveWeapon()
	if ( activeWeapon )
	{
		local activeName = activeWeapon.GetClassname()
		if ( !Designator( activeName ) )
			table.activeWeapon = activeName
	}

	local weapons = ent.GetOffhandWeapons()
	StoreWeaponsToTable( table, weapons, "offhandWeapons" )

	return table
}

function GiveWeaponsFromStoredTable( ent, table )
{
	GiveWeaponsFromStoredArray( table[ "mainWeapons" ], 	ent,	"GiveWeapon" )
	GiveWeaponsFromStoredArray( table[ "offhandWeapons" ], ent,	"GiveOffhandWeapon" )

	if ( table[ "mainWeapons" ].len() )
		ent.SetActiveWeapon( table[ "mainWeapons" ][0].name )

	if ( table.activeWeapon )
	{
		ent.SetActiveWeapon( table.activeWeapon )
	}
}

function RetrievePilotWeapons( pilot )
{
	Assert( "storedPilotLoadout" in pilot.s, "No stored weapons for pilot" + pilot )

	TakeAllWeapons( pilot )
	GiveWeaponsFromStoredTable( pilot, pilot.s.storedPilotLoadout )
	delete pilot.s.storedPilotLoadout
}

function StorePilotWeapons( pilot )
{
	Assert( pilot.IsHuman() )
	Assert( !( "storedPilotLoadout" in pilot.s ), pilot + " already has storedPilotLoadout" )

	pilot.s.storedPilotLoadout <- StoreWeapons( pilot )

	TakeAllWeapons( pilot )
}

function TakeAllWeapons( pilot )
{
	if ( pilot.IsPlayer() )
	{
		pilot.RemoveAllItems()
		local weapons = pilot.GetMainWeapons()
		foreach ( weapon in weapons )
		{
			Assert( 0, pilot + " still has weapon " + weapon.GetClassname() + " after doing takeallweapons" )
		}
	}
	else
	{
		local weapons = pilot.GetMainWeapons()
		TakeAllWeaponsForArray( pilot, weapons )

		local weapons = pilot.GetOffhandWeapons()
		foreach ( index, weapon in clone weapons )
		{
			pilot.TakeOffhandWeapon( index )
		}
		TakeAllWeaponsForArray( pilot, weapons )
	}
}


function TakeAllWeaponsForArray( ent, weapons )
{
	foreach ( weapon in clone weapons )
	{
		// awkward to cast to string
		ent.TakeWeapon( weapon.GetClassname() )
	}
}

function Designator( name )
{
	switch ( name )
	{
		case "mp_weapon_target_designator":
		case "mp_titanweapon_target_designator":
			return true
	}

	return false
}

function StoreWeaponsToTable( table, weapons, weaponType )
{
	table[ weaponType ] <- []

	local activeIndex = null

	for ( local i = 0; i < weapons.len(); i++ )
	{
		local weapon = weapons[i]
		local weaponTable = {}

		local name = weapon.GetClassname()

		// fix for bad designator connections
		if ( Designator( name ) )
			continue

		weaponTable.mods <- weapon.GetMods()
		weaponTable.name <- name
		weaponTable.clipCount <- weapon.GetWeaponPrimaryClipCount()
		weaponTable.ammoCount <- weapon.GetWeaponPrimaryAmmoCount()

		weaponTable.nextAttackTime <- weapon.GetNextAttackAllowedTime()

		table[ weaponType ].append( weaponTable )
	}
}


function TransferHealth( srcEnt, destEnt )
{
	destEnt.SetHealth( srcEnt.GetHealth() )
	destEnt.SetMaxHealth( srcEnt.GetMaxHealth() )
}

function CreateHiddenTitanFromPlayer( player )
{
	local hidden = true
	return CreateTitanFromPlayer( player, hidden )
}

function CreateTitanFromPlayer( player, hidden = false )
{
	local origin = player.GetOrigin()
	local angles = player.GetAngles()
	angles.x = 0
	local settings = player.GetPlayerSettings()
	local team = player.GetTeam()

	local titan = CreateNPCTitanFromSettings( settings, team, origin, angles, true, hidden )

	SetupAutoTitan( titan, player )
	GiveTitanWeaponsForPlayer( player, titan, true )

	//if ( player.GetDoomedState() )
	//	titan.s.preventOwnerDamage = false

	return titan
}

function ApplyTitanColor( titan, settings )
{
	switch ( settings )
	{
		case "titan_atlas_bronze":
			if ( titan.GetTeam() == TEAM_IMC )
				titan.kv.rendercolor = "255 180 105 255"
			else
				titan.kv.rendercolor = "225 150 85 255"
			break
	}
}

function TitanBecomesPilot( player, titan )
{
	Assert( IsAlive( player ), player + ": Player is not alive" )
	Assert( player.IsTitan(), player + " is not a titan" )

	Assert( IsAlive( titan ), titan + " is not alive." )
	Assert( titan.IsTitan(), titan + " is not alive." )

	printt("TitanBecomesPilot()");

	printtodiag( Time() + ": TitanBecomesPilot(): " + player + "\n" )

	StopSoundOnEntity( player, "titan_engine_loop" )

	// if (GameRules.GetGameMode() != TUTORIAL && GameRules.GetGameMode() != TITAN_TUTORIAL)
	// 	thread SetPlayerActiveObjectiveWithTime( player, "Titan_Status_Auto", 5.0 )

	SetUpNPCTitanCurrentMode( player, eNPCTitanMode.FOLLOW )

	local model = player.GetModelName()
	local skin = player.GetSkin()
	titan.SetModel( model )
	titan.SetSkin( skin )

	local flagEnt

	if ( GameRules.GetGameMode() == CAPTURE_THE_FLAG && PlayerHasEnemyFlag( player ) )
	{
		flagEnt = TakeFlagFromPlayer( player )
		flagEnt.ClearParent()
	}

	TransferHealth( player, titan )
	//Transfer children before player becomes pilot model
	player.TransferChildrenTo( titan )
	local soul = player.GetTitanSoul()
	player.GetTitanSoul().SetSoulOwner( titan )
	player.SetTitanSoul( null )

//	titan.SetModel( player.GetModelName() )
	// this must happen before changing the players settings
	TransferDamageStates( player, titan )

	// cant have a titan passive when you're not a titan
	TakeAllTitanPassives( player )

	player.SetPlayerSettings( player.s.storedPlayerSettings )
	delete player.s.storedPlayerSettings

	// Added via AddCallback_OnTitanBecomesPilot
	foreach ( callbackInfo in level.onTitanBecomesPilotCallbacks )
	{
		callbackInfo.func.acall( [callbackInfo.scope, player, titan ] )
	}

	if ( flagEnt )
	{
		GiveFlagToPlayer( flagEnt, player )
	}

	TakeAllWeapons( titan )
	CopyWeapons( player, titan )

	GiveNPCTitanTacticalAbility( titan )

	RetrievePilotWeapons( player )

	if ( Riff_AmmoLimit() != eAmmoLimit.Default )
	{
		switch( Riff_AmmoLimit() )
		{
			case eAmmoLimit.Limited:
				local weapons = player.GetMainWeapons()
				foreach ( weapon in weapons )
				{
					local clipAmmo = player.GetWeaponAmmoMaxLoaded( weapon )

					if ( clipAmmo > 0 )
						weapon.SetWeaponPrimaryAmmoCount( clipAmmo * 2 )
				}

				local offhand = player.GetOffhandWeapon( 0 )
				if ( offhand )
				{
					local ammoLoaded = player.GetWeaponAmmoMaxLoaded( offhand )
					offhand.SetWeaponPrimaryClipCount( max( 1, ammoLoaded - 2 ) )
				}
				break
		}
	}
	else
	{
		// Pilots who jumped into their Titan get their ammo refilled
		player.RefillAllAmmo()
	}

	// Ensure rodeo doesn't happen straight away, if a nearby Titan runs by
	Rodeo_SetCooldown( player )

	if ( player.cloakedForever )
	{
		// infinite cloak active
		EnableCloakForever( player )
	}
	if ( player.stimmedForever )
	{
		StimPlayer( player, USE_TIME_INFINITE )
	}

	soul.Signal( "PlayerDisembarkedTitan", { player = player } )

	// no longer owned
	if ( soul.capturable )
	{
		if ( GameRules.GetGameMode() == CAPTURE_THE_TITAN )
			ClearFlagCarrierStatus( player, titan )

		soul.ClearBossPlayer()
		titan.ClearBossPlayer()
		titan.SetUsableByGroup( "friendlies pilot" )
		titan.DisableBehavior( "Follow" )
		player.SetPetTitan( null )
		return
	}

	return titan
}

function OnPlayerDeathStopEngineSound( player, damageInfo )
{
	if ( player.IsTitan() )
		StopSoundOnEntity( player, "titan_engine_loop" )
}


function PilotBecomesTitan( player, titan, fullCopy = true )
{
	printtodiag( Time() + ": PilotBecomesTitan(): " + player + "\n" )
	Assert( "titanSettings" in titan.s )

	player.SetPetTitan( null )

	ClearPlayerActiveObjective( player )

	// puts the weapons into a table
	StorePilotWeapons( player )

	if ( fullCopy )
	{
		CopyWeapons( titan, player )
	}

	local soul = titan.GetTitanSoul()
	soul.lastOwner = player

	player.s.storedPlayerSettings <- player.GetPlayerSettings()

	if ( !player.GetParent() )
	{
		player.SetOrigin( titan.GetOrigin() )
		player.SetAngles( titan.GetAngles() )
		player.SetVelocity( Vector( 0,0,0 ) )
	}

	if ( soul.capturable )
	{
		if ( GameRules.GetGameMode() == CAPTURE_THE_TITAN )
		{
			titan.Minimap_AlwaysShow( TEAM_INVALID, null )

			player.Minimap_AlwaysShow( TEAM_IMC, null )
			player.Minimap_AlwaysShow( TEAM_MILITIA, null )
			player.SetForceCrosshairNameDraw( true )
		}
	}

	soul.SetSoulOwner( player )

	if ( soul.GetBossPlayer() != player )
		SoulBecomesOwnedByPlayer( soul, player )

	foreach ( passive, _ in level.titanPassives )
	{
		if ( SoulHasPassive( soul, passive ) )
		{
			GiveTitanPassiveLifeLong( player, passive )
		}
	}

	local model = titan.GetModelName()
	local skin = titan.GetSkin()
	player.SetPlayerSettings( titan.s.titanSettings )

	// Added via AddCallback_OnPilotBecomesTitan
	foreach ( callbackInfo in level.onPilotBecomesTitanCallbacks )
	{
		callbackInfo.func.acall( [callbackInfo.scope, player, titan ] )
	}

	if ( GameRules.GetGameMode() == CAPTURE_THE_FLAG && PlayerHasEnemyFlag( player ) )
	{
		if ( !GetCurrentPlaylistVarInt( "ctf_titan_flag_carry", 0 ) )
			DropFlag( player )
	}

	if ( GameRules.GetGameMode() == CAPTURE_THE_FLAG_PRO && PlayerHasEnemyFlag( player ) )
	{
		if ( !GetCurrentPlaylistVarInt( "ctf_titan_flag_carry", 0 ) )
			DropFlag( player )
	}

	ApplyTitanColor( player, titan.s.titanSettings )

	if ( IsValid( soul.rodeoPanel ) )
		soul.rodeoPanel.SetSkin( skin )
	player.SetModel( model )
	player.SetSkin( skin )

	TransferHealth( titan, player )

	// no cloak titan
	player.SetCloakDuration( 0, 0, 0 )

	player.SetModel( titan.GetModelName() )
	// this must happen after changing the players settings
	TransferDamageStates( titan, player )

	//We parent the player to the titan in the process of embarking
	//Must clear parent when transfering children to avoid parenting the player to himself
	if ( player.GetParent() == titan )
		player.ClearParent()
	//Transfer children after player has become titan model.
	titan.TransferChildrenTo( player )

	soul.Signal( "PlayerEmbarkedTitan", { player = player } )
	// bring this back
//	if ( player.s.titan == titan )
//		delete player.s.titan

}



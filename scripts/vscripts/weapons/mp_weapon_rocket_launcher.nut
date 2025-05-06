
//14 //RUMBLE_FLAT_BOTH
const LOCKON_RUMBLE_INDEX 	= 1 //RUMBLE_PISTOL
const LOCKON_RUMBLE_AMOUNT	= 45
RegisterSignal( "StopLockonRumble" )
RegisterSignal( "StopGuidedLaser" )

function main()
{
	if( IsClient() )
		AddKillReplayEndedCallback( CleanupPilotLauncher )
}

function missileMain()
{
	self.s.missileThinkThread <- Bind( MissileThink )
}


function MissileThink( weapon, missile )
{
	if ( !IsServer() )
		return

	missile.EndSignal( "OnDestroy" )

	local playedWarning = false

	while ( IsValid( missile ) )
	{
		local target = missile.GetTarget()

		if ( IsValid( target ) && target.IsPlayer() )
		{
			local distance = Distance( missile.GetOrigin(), target.GetOrigin() )

			if ( distance < 1536 && !playedWarning )
			{
				EmitSoundOnEntityOnlyToPlayer( target, target, "titan_cockpit_missile_close_warning" )
				playedWarning = true
			}

			if ( target.IsDodging() && Distance( missile.GetOrigin(), target.GetOrigin() ) < 1024.0 )
			{
				local homingSpeed = missile.GetHomingSpeed()
				local homingSpeedAtDodging = missile.GetHomingSpeedAtDodgingPlayer()
				missile.SetHomingSpeeds( homingSpeedAtDodging, homingSpeedAtDodging )
			}
		}

		wait 0
	}
}

function OnWeaponActivate( activateParams )
{
	local hasGuidedMissiles = self.HasMod( "guided_missile" )

	if ( !hasGuidedMissiles )
	{
		SmartAmmo_SetAllowUnlockedFiring( self, false )
		SmartAmmo_SetMissileSpeed( self, 600 )

		if ( self.HasMod( "burn_mod_rocket_launcher" ) )
			SmartAmmo_SetMissileSpeedLimit( self, 500 )
		else
			SmartAmmo_SetMissileSpeedLimit( self, 900 )

		SmartAmmo_SetMissileHomingSpeed( self, 1000 )
		SmartAmmo_SetMissileShouldDropKick( self, false )  // TODO set to true to see drop kick behavior issues
		SmartAmmo_SetUnlockAfterBurst( self, true )
	}

	local weaponOwner = self.GetWeaponOwner()

	if ( hasGuidedMissiles )
	{
		if ( !("guidedLaserPoint" in weaponOwner.s) )
			weaponOwner.s.guidedLaserPoint <- null

		thread CalculateGuidancePoint( weaponOwner )
	}

	if ( IsClient() && GetLocalViewPlayer() == self.GetWeaponOwner() )
	{
		if ( !hasGuidedMissiles && ( GetConVarBool( "smart_ammo_fast_hud" ) == false ) )
		{
			SmartAmmo_SetSound_Locking( self, "Weapon_Archer.ADS_Seeking" )
			thread RumbleWhileLocked()
		}

		InitLauncherScreen( GetLocalViewPlayer() )
	}
}

function OnWeaponDeactivate( deactivateParams )
{
	if ( !self.HasMod( "guided_missile" ) )
		SmartAmmo_Stop( self )
	else
		self.Signal("StopGuidedLaser")
		
	if ( IsClient() && DoesPlayerOwnWeapon( GetLocalViewPlayer(), self ) )
		CleanupPilotLauncher()
}

function OnWeaponOwnerChanged( changeParams )
{
	if ( IsClient() )
	{
		if ( changeParams.oldOwner == GetLocalViewPlayer() )
			CleanupPilotLauncher()
	}
}

function OnWeaponPrimaryAttack( attackParams )
{
	local weaponOwner = self.GetWeaponOwner()

	local angles = VectorToAngles( weaponOwner.GetViewVector() )
	local right = angles.AnglesToRight()
	local up = angles.AnglesToUp()
	if ( IsServer() && weaponOwner.GetTitanSoulBeingRodeoed() != null )
		attackParams.pos = attackParams.pos + up * 20

	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	if ( !self.HasMod( "guided_missile" ) )
	{
		return SmartAmmo_FireWeapon( self, attackParams, damageTypes.ATRocket )
	}
	else
	{
		if( !self.IsWeaponAdsButtonPressed() )
			return 0

		local shouldPredict = self.ShouldPredictProjectiles()
		if ( IsClient() && !shouldPredict )
			return 1

		local speed = 1200
		if ( self.HasMod("titanhammer") )
			speed = 800

		if ( self.HasMod( "guided_missile" ) )
			self.EmitWeaponSound( weaponSounds["fire"] )

		local missile = self.FireWeaponMissile( attackParams.pos, attackParams.dir, speed, damageTypes.ATRocket | DF_IMPACT, damageTypes.ATRocket, false, shouldPredict )

		if ( missile )
		{
			if( "guidedMissileTarget" in self.s && IsValid( self.s.guidedMissileTarget ) )
			{
				missile.SetTarget( self.s.guidedMissileTarget, Vector( 0, 0, 0 ) )
				missile.SetHomingSpeeds( 500, 0 )
			}

			InitializeGuidedMissile( weaponOwner, missile )
		}
	}
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	// NPC can shoot the weapon at non-players, but when shooting at players it must be a titan
	local owner = self.GetWeaponOwner()
	if ( IsValid( owner ) )
	{
		local enemy = owner.GetEnemy()
		if ( IsValid( enemy ) )
		{
			if ( enemy.IsPlayer() && !enemy.IsTitan() )
				return
		}
	}

	self.EmitWeaponSound( "Weapon_Archer.Fire" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	if ( IsServer() )
	{
		local missile = self.FireWeaponMissile( attackParams.pos, attackParams.dir, 1800, damageTypes.ATRocket, damageTypes.ATRocket, false, PROJECTILE_NOT_PREDICTED )
		if ( missile )
		{
			missile.InitMissileForRandomDriftFromWeaponSettings( attackParams.pos, attackParams.dir )
		}
	}
}

function OnWeaponStartZoomIn()
{
	if ( !self.HasMod( "guided_missile" ) )
		SmartAmmo_Start( self )
	HandleWeaponSoundZoomIn( self, "Weapon_Archer.ADS_Up" )
}

function OnWeaponStartZoomOut()
{
	if ( !self.HasMod( "guided_missile" ) )
		SmartAmmo_Stop( self )
	HandleWeaponSoundZoomOut( self, "Weapon_Archer.ADS_Down" )
}

function RumbleWhileLocked()
{
	local player = self.GetWeaponOwner()
	player.Signal( "StopLockonRumble" )

	// TODO end on player type change
	self.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "StopLockonRumble" )

	local lockTargets
	local lockFrac

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) && GetLocalViewPlayer() == player )
				player.RumbleEffect( LOCKON_RUMBLE_INDEX, 0, RUMBLE_FLAG_STOP )
		}
	)

	while ( 1 )
	{
		if ( self.SmartAmmo_IsEnabled() )
		{
			lockTargets = self.SmartAmmo_GetTargets()
			lockFrac = 0
			foreach( targ in lockTargets )
			{
				if ( targ.fraction > lockFrac )
					lockFrac = targ.fraction
			}

			if ( lockFrac >= 1.0 )
			{
				player.RumbleEffect( LOCKON_RUMBLE_INDEX, LOCKON_RUMBLE_AMOUNT, RUMBLE_FLAG_INITIAL_SCALE )
			}
		}
		else
		{
			player.RumbleEffect( LOCKON_RUMBLE_INDEX, 0, RUMBLE_FLAG_STOP )
		}

		wait 0.2
	}
}

function CleanupPilotLauncher()
{
	Assert( IsClient() )

	if ( GetConVarBool( "smart_ammo_fast_hud" ) == true )
		return

	local player = GetLocalViewPlayer()
	player.Signal( "StopLockonRumble" )

	CleanupLauncherScreen( player )
}


// ========== SCREEN VGUI (clientside) ==========
function InitLauncherScreen( player )
{
	Assert( IsClient() )

	if ( GetConVarBool( "smart_ammo_fast_hud" ) == true )
		return

	local player = GetLocalViewPlayer()

	if ( "pilotLauncherHUD" in player.s )
		return

	local vguiName 		= "vgui_pilot_launcher_screen"  // has to match a name set up in vgui_screens.txt
	local modelEnt		= player.GetViewModelEntity()
	local bottomLeft 	= "SCR_BL"
	local topRight 		= "SCR_TR"

	local vgui = CreateLauncherVGUI( vguiName, modelEnt, bottomLeft, topRight )
	if ( !IsValid( vgui ) )
		return
	player.s.pilotLauncherVGUI <- vgui

	local panel = vgui.GetPanel()

	//local elemAmmo			= HudElement( "VGUI_PilotLauncher_Ammo", panel )
	local elemAmmoLabel			= HudElement( "VGUI_PilotLauncher_Ammo_Label", panel )
	local elemLockStatus		= HudElement( "VGUI_PilotLauncher_LockStatus", panel )
	local elemTargetName		= HudElement( "VGUI_PilotLauncher_TargetName", panel )
	local elemRange				= HudElement( "VGUI_PilotLauncher_Range", panel )
	local elemTargetingCircle	= HudElement( "VGUI_PilotLauncher_TargetingCircle", panel )

	local launcherHudGroup = HudElementGroup( "PilotLauncherHUD" )

	//launcherHudGroup.AddElement( elemAmmo )
	launcherHudGroup.AddElement( elemAmmoLabel )
	launcherHudGroup.AddElement( elemLockStatus )
	//launcherHudGroup.AddElement( elemTargetName )
	//launcherHudGroup.AddElement( elemRange )
	launcherHudGroup.AddElement( elemTargetingCircle )

	local elemTargetingRingInner	= HudElement( "VGUI_PilotLauncher_TargetingRing_Inner", panel )
	local elemTargetingRingOuter	= HudElement( "VGUI_PilotLauncher_TargetingRing_Outer", panel )
	local targetingRingGroup 		= HudElementGroup( "PilotLauncherTargetingRings" )
	targetingRingGroup.AddElement( elemTargetingRingInner )
	targetingRingGroup.AddElement( elemTargetingRingOuter )
	launcherHudGroup.AddGroup( targetingRingGroup )

	local elemTicker			= HudElement( "VGUI_PilotLauncher_Ticker", panel )
	local elemTickerExtra		= HudElement( "VGUI_PilotLauncher_Ticker_Extra", panel )

	local launcherTickerGroup = HudElementGroup( "PilotLauncherTickers" )
	launcherTickerGroup.AddElement( elemTicker )
	launcherTickerGroup.AddElement( elemTickerExtra )
	launcherHudGroup.AddGroup( launcherTickerGroup )

	local ammoIcon0				= HudElement( "VGUI_PilotLauncher_AmmoIcon0", panel )
	local ammoIcon1				= HudElement( "VGUI_PilotLauncher_AmmoIcon1", panel )
	local ammoIcon2				= HudElement( "VGUI_PilotLauncher_AmmoIcon2", panel )
	local ammoIcon3				= HudElement( "VGUI_PilotLauncher_AmmoIcon3", panel )
	local ammoIcon4				= HudElement( "VGUI_PilotLauncher_AmmoIcon4", panel )
	local ammoIcon5				= HudElement( "VGUI_PilotLauncher_AmmoIcon5", panel )

	local ammoIconGroup = HudElementGroup( "PilotLauncherAmmoIcons" )
	ammoIconGroup.AddElement( ammoIcon0 )
	ammoIconGroup.AddElement( ammoIcon1 )
	ammoIconGroup.AddElement( ammoIcon2 )
	ammoIconGroup.AddElement( ammoIcon3 )
	ammoIconGroup.AddElement( ammoIcon4 )
	ammoIconGroup.AddElement( ammoIcon5 )
	launcherHudGroup.AddGroup( ammoIconGroup )

	launcherHudGroup.Hide()

	player.s.pilotLauncherHUD 				<- launcherHudGroup
	//player.s.pilotLauncherAmmo 			<- elemAmmo
	player.s.pilotLauncherAmmoLabel 		<- elemAmmoLabel
	player.s.pilotLauncherLockStatus 		<- elemLockStatus
	player.s.pilotLauncherTargetName 		<- elemTargetName
	player.s.pilotLauncherRange 			<- elemRange
	player.s.pilotLauncherTargetingCircle	<- elemTargetingCircle
	player.s.pilotLauncherTargetingRings	<- targetingRingGroup
	player.s.pilotLauncherAmmoIcons 		<- ammoIconGroup
	player.s.pilotLauncherTickers 			<- launcherTickerGroup

	player.s.lastLockBlinkTime <- -1
	player.s.lastLockBlinkColor <- null
	player.s.lastTargetOrigin <- Vector( 0, 0, 0 )
	player.s.lastTargetVel <- Vector( 0, 0, 0 )
}

function CleanupLauncherScreen( player )
{
	Assert( IsClient() )

	if ( !( "pilotLauncherHUD" in player.s ) )
		return

	player.s.pilotLauncherHUD.RemoveAllElements()
	delete player.s.pilotLauncherHUD

	Assert( IsValid( player.s.pilotLauncherVGUI ) )
	player.s.pilotLauncherVGUI.Destroy()
	delete player.s.pilotLauncherVGUI

	//delete player.s.pilotLauncherAmmo
	delete player.s.pilotLauncherAmmoLabel
	delete player.s.pilotLauncherLockStatus
	delete player.s.pilotLauncherTargetName
	delete player.s.pilotLauncherRange
	delete player.s.pilotLauncherTargetingCircle
	delete player.s.pilotLauncherTargetingRings
	delete player.s.pilotLauncherAmmoIcons
	delete player.s.pilotLauncherTickers

	delete player.s.lastLockBlinkTime
	delete player.s.lastLockBlinkColor
}

function CreateLauncherVGUI( vguiName, modelEnt, bottomLeft, topRight )
{
	Assert( IsClient() )

	local player 		= self.GetWeaponOwner()
	local modelEnt		= player.GetViewModelEntity()
	if ( !IsValid( modelEnt ) )
		return null
	local bottomLeftID 	= modelEnt.LookupAttachment( bottomLeft )
	local topRightID 	= modelEnt.LookupAttachment( topRight )

	local size = [ 1.95778, 1.39354 ]

	// JFS: defensive fix for kill replay issues
	if ( bottomLeftID == 0 || topRightID == 0 )
		return null

	local vguiOrg = modelEnt.GetAttachmentOrigin( bottomLeftID )
	local vguiAng = modelEnt.GetAttachmentAngles( bottomLeftID )

	// push the origin "out" slightly, since the tags are coplanar with the modelEnt screen geo
	vguiOrg += vguiAng.AnglesToUp() * 0.01

	local fovScale = GetConVarFloat( "cl_fovScale" )
	local applyScale = GraphCapped( fovScale, 1.0, 1.3, 1.0, 1.45 )

	local vgui = CreateClientsideVGuiScreen( vguiName, VGUI_SCREEN_PASS_VIEWMODEL, vguiOrg, vguiAng, size[0] * applyScale, size[1] * applyScale )
	local panel = vgui.GetPanel()
	vgui.s.panel <- panel
	vgui.SetParent( modelEnt, bottomLeft )
	vgui.SetAttachOffsetOrigin( Vector( 0, 0, 0 ) )
	vgui.SetAttachOffsetAngles( Vector( 0, 0, 0 ) )

	return vgui
}

missileMain()

//GUIDED MISSILE FUNCTIONS
function CalculateGuidancePoint( weaponOwner )
{
	weaponOwner.EndSignal( "OnDestroy" )
	self.EndSignal( "OnDestroy" )
	self.EndSignal( "StopGuidedLaser" )

	local info_target
	if( IsServer() )
	{
		info_target = CreateEntity( "info_target" )
		info_target.SetOrigin( self.GetOrigin() )
		info_target.SetInvulnerable()
		DispatchSpawn( info_target )
		self.s.guidedMissileTarget <- info_target
	}

	OnThreadEnd(
		function() : ( self, info_target )
		{
			if ( IsValid( info_target ) )
			{
				info_target.Kill()
				delete self.s.guidedMissileTarget
			}
		}
	)

	while(1)
	{
		if ( !IsValid_ThisFrame( weaponOwner ) || !IsValid_ThisFrame( self ) )
			return
		weaponOwner.s.guidedLaserPoint = null
		if ( self.IsWeaponInAds())
		{
			local result = GetPlayerViewTrace( weaponOwner )
			weaponOwner.s.guidedLaserPoint = result.endPos
			if( IsServer() )
				info_target.SetOrigin( result.endPos )
		}
		wait 0
	}
}


function InitializeGuidedMissile( weaponOwner, missile )
{
		missile.s.guidedMissile <- true
		if ( "missileInFlight" in weaponOwner.s )
			weaponOwner.s.missileInFlight = true
		else
			weaponOwner.s.missileInFlight <- true

		missile.kv.lifetime = 10

		if ( IsServer() )
		{
			missile.SetOwner( weaponOwner )
			thread playerHasMissileInFlight( weaponOwner, missile )
		}
}

function playerHasMissileInFlight( weaponOwner, missile )
{
	weaponOwner.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( weaponOwner )
		{
			if ( IsValid( weaponOwner ) )
			{
				weaponOwner.s.missileInFlight = false
				//Using a remote call because if this thread is on the client it gets triggered prematurely due to prediction.
				Remote.CallFunction_NonReplay( weaponOwner, "ServerCallback_GuidedMissileDestroyed" )
			}
		}
	)

	WaitSignal( missile, "OnDestroy" )
}

function SmartWeaponFireSound( weapon, target )
{
	if ( weapon.HasMod( "burn_mod_rocket_launcher" ) )
	{
		weapon.EmitWeaponSound( "Weapon_Archer.Fire_Tankbuster" )
	}
	else
	{
		weapon.EmitWeaponSound( "Weapon_Archer.Fire" )
	}
}

AMMO_BODYGROUP_COUNT <- 6
chargeDownSoundDuration <- 1.0 // "charge_cooldown_time"

RegisterSignal( "OnDeactivate" )
const MINIGUN_COOL_DELAY = 0.5     // Seconds before cooling starts after firing
const TITAN_SLOW_SPEED = 0.5       // 50% speed while firing   
const MINIGUN_REGEN_RATE = 20.0

// Disgustingly complicated for a simple rework the minigun... but whatever. It works for now.

function OnWeaponActivate( activateParams )
{
    UpdateViewmodelAmmo()
    // Pre-initialize all struct variables to avoid expensive dictionary checks later
    if ( !( "lastFireTime" in self.s ) ) self.s.lastFireTime <- 0 
    if ( !( "overheatEndTime" in self.s ) ) self.s.overheatEndTime <- 0
    if ( !( "overheatMessageEndTime" in self.s ) ) self.s.overheatMessageEndTime <- 0
    
    if ( !( "lastRegenTime" in self.s ) ) self.s.lastRegenTime <- 0
    if ( !( "partialAmmo" in self.s ) ) self.s.partialAmmo <- 0.0
    if ( !( "overheatNotificationShown" in self.s ) ) self.s.overheatNotificationShown <- false
    if ( !( "clientOverheatNotified" in self.s ) ) self.s.clientOverheatNotified <- false
    if ( !( "wasOverheating" in self.s ) ) self.s.wasOverheating <- false

    thread MinigunMovementThink( self )
}

function OnWeaponDeactivate( deactivateParams )
{
    self.Signal( "OnDeactivate" )

    // Force speed back to normal immediately on holster
    if ( IsServer() )
    {
        local owner = self.GetWeaponOwner()
        if ( IsValid( owner ) )
            owner.SetMoveSpeedScale( 1.0 )
    }

    // Clean up the HUD element so it doesn't get stuck on screen
    if ( IsClient() )
    {
        // Cancel the timer so the message doesn't persist across weapon swaps
        self.s.overheatMessageEndTime <- 0 
        
        local owner = self.GetWeaponOwner()
        if ( IsValid( owner ) && owner == GetLocalViewPlayer() )
        {
            local cockpit = owner.GetCockpit()
            if ( IsValid( cockpit ) && "crosshairHealthLabel" in cockpit.s )
            {
                if ( !owner.GetDoomedState() )
                    cockpit.s.crosshairHealthLabel.Hide()
            }
        }
    }
}

function MinigunMovementThink( weapon )
{
    weapon.EndSignal( "OnDestroy" )
    weapon.EndSignal( "OnDeactivate" )

    // Cache the VM state once outside the loop
    local isServer = IsServer()
    local isClient = IsClient()

    while ( true )
    {
        local owner = weapon.GetWeaponOwner()
        
        // NPC early exit (Server only)
        if ( isServer && IsValid( owner ) && owner.IsNPC() )
        {
            wait 0.025
            continue
        }

        if ( IsValid( owner ) )
        {
            if ( isServer && !owner.IsNPC() )
            {
                ServerMinigunLogic( weapon, owner )
            }
            else if ( isClient && owner == GetLocalViewPlayer() )
            {
                ClientMinigunLogic( weapon, owner )
            }
        }
        
        wait 0.025
    }
}

function ServerMinigunLogic( weapon, owner )
{
    local currentTime = Time()
    local maxAmmo = weapon.HasMod( "extended_ammo" ) ? 120 : 100
    local reloadTime = weapon.HasMod( "extended_ammo" ) ? 6.0 : 5.0
    
    // --- ENFORCED OVERHEAT LOCKOUT ---
    if ( currentTime < weapon.s.overheatEndTime )
    {
        weapon.SetNextAttackAllowedTime( weapon.s.overheatEndTime )
        owner.SetMoveSpeedScale( 1.0 ) 
        
        // Update these two lines to use the new 'reloadTime' variable:
        local timeElapsed = reloadTime - (weapon.s.overheatEndTime - currentTime)
        local fillRatio = timeElapsed / reloadTime
        local visualAmmo = max( 0, (fillRatio * maxAmmo).tointeger() )
        
        weapon.SetWeaponPrimaryClipCount( visualAmmo )
        weapon.s.wasOverheating = true
        
        if ( !weapon.s.overheatNotificationShown )
        {
            EmitSoundOnEntity( owner, "titan_dryfire" ) 
            weapon.s.overheatNotificationShown = true
        }
        return // Skip normal operation logic entirely while overheated
    }

    // --- NORMAL OPERATION ---
    weapon.s.overheatNotificationShown = false 
    
    local isFiring = (currentTime - weapon.s.lastFireTime < 0.25)
    local timeSinceLastFire = currentTime - weapon.s.lastFireTime
    local currentAmmo = weapon.GetWeaponPrimaryClipCount()

    if ( isFiring )
    {
        owner.SetMoveSpeedScale( TITAN_SLOW_SPEED )
    }
    else
    {
        owner.SetMoveSpeedScale( 1.0 )
        
        if ( currentAmmo < maxAmmo && timeSinceLastFire > MINIGUN_COOL_DELAY )
        {
            local deltaTime = currentTime - weapon.s.lastRegenTime
            weapon.s.lastRegenTime = currentTime
            
            weapon.s.partialAmmo += (deltaTime * MINIGUN_REGEN_RATE)
            local ammoToAdd = weapon.s.partialAmmo.tointeger()
            
            if ( ammoToAdd > 0 )
            {
                local newAmmo = currentAmmo + ammoToAdd
                if ( newAmmo > maxAmmo ) newAmmo = maxAmmo
                weapon.SetWeaponPrimaryClipCount( newAmmo )
                weapon.s.partialAmmo -= ammoToAdd
            }
        }
        else
        {
            weapon.s.lastRegenTime = currentTime
            weapon.s.partialAmmo = 0.0
        }
    }
}

function ClientMinigunLogic( weapon, owner )
{
    local cockpit = owner.GetCockpit()
    
    // Guard clause to exit early if the UI elements aren't valid
    if ( !IsValid( cockpit ) || !("crosshairHealthLabel" in cockpit.s) || owner.GetDoomedState() )
        return

    local currentTime = Time()
    
    if ( currentTime < weapon.s.overheatEndTime )
    {
        // ONE-SHOT NOTIFICATION
        if ( !weapon.s.clientOverheatNotified ) 
        {           
            // Moved inside the toggle so it only executes once
            cockpit.s.crosshairHealthLabel.SetText( "[WEAPON OVERHEATED]" ) 
            cockpit.s.crosshairHealthLabel.SetColor( 255, 50, 50, 255 )
            cockpit.s.crosshairHealthLabel.Show() 
            
            weapon.s.clientOverheatNotified = true 
        }
    }
    else
    {
        // Only trigger the Hide() function if it was previously visible
        if ( weapon.s.clientOverheatNotified )
        {
            weapon.s.clientOverheatNotified = false 
            cockpit.s.crosshairHealthLabel.Hide() 
        }
    }
}

function OnWeaponPrimaryAttack( attackParams )
{
    local clip = self.GetWeaponPrimaryClipCount()
    self.s.lastFireTime = Time()

    self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.Electric | DF_STOPS_TITAN_REGEN )

    if ( clip <= 1 )
    {
        local reloadTime = self.HasMod( "extended_ammo" ) ? 6.0 : 5.0
        self.s.overheatEndTime = Time() + reloadTime
        
        if ( IsServer() )
        {
            self.SetNextAttackAllowedTime( self.s.overheatEndTime )
            self.SetWeaponPrimaryClipCount( 0 )
        }
    }
}


function OnWeaponNpcPrimaryAttack( attackParams )
{
    self.s.lastFireTime = Time()
    self.SetNextAttackAllowedTime( Time() + (1.0 / 15.0) )

    self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1 )

    local clip = self.GetWeaponPrimaryClipCount()
    if ( clip > 0 )
    {
        self.SetWeaponPrimaryClipCount( clip - 1 )
    }
}

function OnWeaponChargeBegin( chargeParams )
{
    local chargeTime = self.GetWeaponChargeTime() 
    StopSoundOnEntity( self, "Weapon_Titan_Sniper_WindDown" ) 
    
    if( IsClient() )
        EmitSoundOnEntityWithSeek( self, "Weapon_Titan_Sniper_WindUp", chargeTime ) 
}

function OnWeaponChargeEnd( chargeParams )
{
    StopSoundOnEntity( self, "Weapon_Titan_Sniper_SustainLoop" ) 
    StopSoundOnEntity( self, "Weapon_Titan_Sniper_WindUp" ) 
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_40mm.ADS_In" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_40mm.ADS_Out" )
}

function OnWeaponOwnerChanged( changeParams )
{
	if ( IsClient() )
	{
		if ( changeParams.newOwner != null && changeParams.newOwner == GetLocalViewPlayer() )
			UpdateViewmodelAmmo()
	}
}

function main()
{
	Globalize( SniperVGUI_AddPlayer )
	Globalize( CreateSniperVGUI )
	Globalize( DestroySniperVGUI )

	RegisterSignal( "UpdateSniperVGUI" )

	AddDestroyCallback( "mp_weapon_dmr", ClientDestroyCallback_DMR )

	PrecacheHUDMaterial( "hud/hit_confirm_bg" )
	PrecacheHUDMaterial( "hud/hit_confirm_head" )
	PrecacheHUDMaterial( "hud/hit_confirm_torso" )
	PrecacheHUDMaterial( "hud/hit_confirm_arm_left" )
	PrecacheHUDMaterial( "hud/hit_confirm_arm_right" )
	PrecacheHUDMaterial( "hud/hit_confirm_leg_left" )
	PrecacheHUDMaterial( "hud/hit_confirm_leg_right" )
}

function SniperVGUI_AddPlayer( player )
{
}


function SniperVGUI_Think( player, weapon )
{
	weapon.s.sniperVGUI.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDestroy" )
	weapon.EndSignal( "OnDestroy" )

	while ( true )
	{
		local results = player.WaitSignal( "UpdateSniperVGUI" )

		thread SniperVGUI_ShowHit( player, weapon, results.hitGroup )
	}
}


function SniperVGUI_ShowHit( player, weapon, hitGroup )
{
    if( IsDelta() ) 
        return

	local t = weapon.s.sniperVGUI.s

	t.nextUpdateTime = Time() + t.confirmationTime
	t.hitConfirmBG.Show()

	t.hitConfirmPoints[hitGroup].Show()
	t.hitConfirmPoints[hitGroup].SetColor( 255, 80, 40, 255 )
	t.hitConfirmPoints[hitGroup].FadeOverTimeDelayed( 0, t.confirmationTime / 2, t.confirmationTime / 2 )

	t.confidenceLabel.SetText( "#WPN_DMR_HIT_CONFIRMED" )
	t.confidenceLabel.FadeOverTimeDelayed( 0, t.confirmationTime / 2, t.confirmationTime / 2 )
}


function SniperVGUI_PotentialHitThink( player, weapon )
{
	weapon.s.sniperVGUI.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDestroy" )
	weapon.EndSignal( "OnDestroy" )

	local t = weapon.s.sniperVGUI.s

	while ( true )
	{
		local results = player.WaitSignal( "CrosshairTargetChanged" )

		local newTarget = results.newTarget

		if ( !IsValid( newTarget ) )
			continue

		if ( newTarget.GetTeam() == player.GetTeam() )
			continue

		local entClass = results.newTarget.GetSignifierName()

		if ( (entClass != "npc_soldier" && entClass != "player") || results.newTarget.IsTitan() )
			continue

		thread SniperVGUI_UpdateTargetData( player, results.newTarget, weapon )
	}
}


function SniperVGUI_UpdateTargetData( player, crosshairTarget, weapon )
{
	weapon.s.sniperVGUI.EndSignal( "OnDestroy" )
	player.EndSignal( "CrosshairTargetChanged" )
	player.EndSignal( "OnDestroy" )

	local t = weapon.s.sniperVGUI.s
	local farDist = weapon.GetWeaponInfoFileKeyField( "damage_far_distance" )

	while ( true )
	{
		if ( player.GetAdsFraction() == 1.0 && Time() >= t.nextUpdateTime )
		{
			local traceResults = TraceLineHighDetail( player.EyePosition(), player.EyePosition() + (player.CameraAngles().AnglesToForward() * farDist ), player, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS), TRACE_COLLISION_GROUP_NONE )

			local target = traceResults.hitEnt

			if ( !IsValid( target ) || target != crosshairTarget )
			{
				wait 0
				continue
			}

			local entClass = target.GetSignifierName()

			if ( entClass == "npc_soldier" || entClass == "player" && !target.IsTitan() )
			{
				local hitGroup = traceResults.hitGroup

				local hitData = GetHitProbabilityData( player, target, hitGroup )

				t.confidenceLabel.SetAlpha( 255 )

				local hit = format( "%.1f", hitData.confidence * 100 )
				local dist = format( "%.2f", hitData.distance / 39.3701 )
				local speed = format( "%.2f", hitData.speed / 39.3701 )
				t.confidenceLabel.SetText( "#WPN_DMR_DATA", hit, dist, speed )

				t.confidenceLabel.FadeOverTime( 0, 0.3 )

				t.hitConfirmPoints[hitGroup].Show()
				t.hitConfirmPoints[hitGroup].SetColor( 255, 255, 255, 255 )
				t.hitConfirmPoints[hitGroup].FadeOverTime( 0, 0.032 )
			}
		}

		wait 0
	}

}

function CreateSniperVGUI( player, weapon, isKraber = false )
{
	Assert( IsClient() )

	if ( weapon.GetWeaponOwner() != player )
		return

	local vguiName 		= "vgui_sniper"
	local modelEnt		= player.GetViewModelEntity()
	if ( !IsValid( modelEnt ) )
		return

	local bottomLeftAttachment = "SCR_BL_SCOPE8X"
	local topRightAttachment = "SCR_TR_SCOPE8X"
	local fixedSize = [ 1.5, 1.5 ]
	local fixedOffsets = [ 0.1, 0.0, 0 ]

	if ( weapon.HasModDefined( "aog" ) && weapon.HasMod( "aog" ) )
	{
		bottomLeftAttachment = "SCR_BL_AOG"
		topRightAttachment = "SCR_TR_AOG"
		fixedSize = [ 3.0, 3.0 ]
		fixedOffsets = [ -0.7, -0.5, 0 ]

	}
	else if ( weapon.HasModDefined( "scope_8x" ) && weapon.HasMod( "scope_8x" ) )
	{
		bottomLeftAttachment = "SCR_BL_SCOPE12X"
		topRightAttachment = "SCR_TR_SCOPE12X"
		fixedSize = [ 1.6, 1.6 ]
		fixedOffsets = [ 0.1, -0.0, 0 ]
	}

	local bottomLeftID 	= modelEnt.LookupAttachment( bottomLeftAttachment )
	local topRightID 	= modelEnt.LookupAttachment( topRightAttachment )

	// JFS: defensive fix for kill replay issues
	if ( bottomLeftID == 0 || topRightID == 0 )
		return

	local fovScale = GetConVarFloat( "cl_fovScale" )
	local applyScale = GraphCapped( fovScale, 1.0, 1.3, 1.0, 1.45 )

	local vgui = CreateClientsideVGuiScreen( vguiName, VGUI_SCREEN_PASS_VIEWMODEL, Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), fixedSize[0] * applyScale, fixedSize[1] * applyScale )
	local panel = vgui.GetPanel()
	vgui.s.panel <- panel
	vgui.SetParent( modelEnt, bottomLeftAttachment )
	vgui.SetAttachOffsetOrigin( Vector( isKraber ? -0.25 : 0, 0, 0 ) )
	vgui.SetAttachOffsetOrigin( Vector( fixedOffsets[0], fixedOffsets[1], fixedOffsets[2] ) )
	vgui.SetAttachOffsetAngles( Vector( 0, 0, 0 ) )

	vgui.s.hitConfirmBG <- HudElement( "HitConfirmBG", panel )
	vgui.s.hitConfirmPoints <- {}
	vgui.s.hitConfirmPoints[HITGROUP_CHEST] <- HudElement( "HitConfirmTorso", panel )
	vgui.s.hitConfirmPoints[HITGROUP_GENERIC] <- vgui.s.hitConfirmPoints[HITGROUP_CHEST]
	vgui.s.hitConfirmPoints[HITGROUP_STOMACH] <- vgui.s.hitConfirmPoints[HITGROUP_CHEST]
	vgui.s.hitConfirmPoints[HITGROUP_GEAR] <- vgui.s.hitConfirmPoints[HITGROUP_CHEST]
	vgui.s.hitConfirmPoints[HITGROUP_HEAD] <- HudElement( "HitConfirmHead", panel )
	vgui.s.hitConfirmPoints[HITGROUP_LEFTARM] <- HudElement( "HitConfirmArmLeft", panel )
	vgui.s.hitConfirmPoints[HITGROUP_RIGHTARM] <- HudElement( "HitConfirmArmRight", panel )
	vgui.s.hitConfirmPoints[HITGROUP_LEFTLEG] <- HudElement( "HitConfirmLegLeft", panel )
	vgui.s.hitConfirmPoints[HITGROUP_RIGHTLEG] <- HudElement( "HitConfirmLegRight", panel )

	vgui.s.confidenceLabel <- HudElement( "ConfidenceLabel", panel )

	weapon.s.sniperVGUI <- vgui
	weapon.s.sniperVGUI.s.nextUpdateTime <- 0

	if ( weapon.GetWeaponInfoFileKeyField( "rechamber_time" ) != null )
		weapon.s.sniperVGUI.s.confirmationTime <- weapon.GetWeaponInfoFileKeyField( "rechamber_time" )
	else
		weapon.s.sniperVGUI.s.confirmationTime <- weapon.GetWeaponInfoFileKeyField( "fire_rate" )

	if ( !isKraber )
		thread SniperVGUI_PotentialHitThink( player, weapon )

	thread SniperVGUI_Think( player, weapon )
}


function DestroySniperVGUI( weapon )
{
	if ( "sniperVGUI" in weapon.s )
	{
		weapon.s.sniperVGUI.Destroy()
		delete weapon.s.sniperVGUI
	}
}


hitGroupProbabilityModifier <- {}
hitGroupProbabilityModifier[HITGROUP_CHEST] <- 1.0
hitGroupProbabilityModifier[HITGROUP_GENERIC] <- 1.0
hitGroupProbabilityModifier[HITGROUP_STOMACH] <- 0.98
hitGroupProbabilityModifier[HITGROUP_GEAR] <- 1.0
hitGroupProbabilityModifier[HITGROUP_HEAD] <- 0.97
hitGroupProbabilityModifier[HITGROUP_LEFTARM] <- 0.96
hitGroupProbabilityModifier[HITGROUP_RIGHTARM] <- 0.96
hitGroupProbabilityModifier[HITGROUP_LEFTLEG] <- 0.94
hitGroupProbabilityModifier[HITGROUP_RIGHTLEG] <- 0.94


function GetHitProbabilityData( player, target, hitGroup )
{
	local targetSpeed = target.GetVelocity().Length()
	local targetDist = Distance( target.GetOrigin(), player.GetOrigin() )

	local confidence = 1.0
	confidence *= GraphCapped( targetDist, 2000, 4000, 0.99, 0.60 )
	confidence *= GraphCapped( targetSpeed, 10, 250, 0.99, 0.60 )
	confidence *= hitGroupProbabilityModifier[hitGroup]

	return { confidence = confidence, distance = targetDist, speed = targetSpeed }
}

function ClientDestroyCallback_DMR( entity )
{
	DestroySniperVGUI( entity )
}
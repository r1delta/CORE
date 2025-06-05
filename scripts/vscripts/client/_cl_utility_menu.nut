_visGroupStates <- {}


RegisterSignal( "AnnoucementPurge" )
RegisterSignal( "SetEventNotification" )

const EN_SHOW_OVER_SCREENFADE = 0x00000001

function VisGroup_Create()
{
	return CreateVisGroup()
}

function VisGroup_IsVisible( visGroupID )
{
	if ( visGroupID == 0 )
		return GetLocalViewPlayer().hudVisible

	return IsVisGroupVisible()
}

function VisGroup_SetVisible( visGroupID, state )
{
}

level.hudElements <- {}

class VisGroup
{
	visGroupID = null
	_hudElements = null

	constructor( name, ownerHud = Hud )
	{
		_hudElements = {}

		visGroupID = VisGroup_Create()
	}

	function Show()
	{
		//if ( VisGroup_IsVisible( visGroupID ) )
		//	return

		VisGroup_SetVisible( visGroupID, true )

		foreach ( hudElement in _hudElements )
			hudElement.UpdateVisibility()
	}

	function Hide()
	{
		//if ( !VisGroup_IsVisible( visGroupID ) )
		//	return

		VisGroup_SetVisible( visGroupID, false )

		foreach ( hudElement in _hudElements )
			hudElement.UpdateVisibility()
	}

	function AddElement( hudElement )
	{
		//Assert( hudElem instanceof HudElement )
		Assert( hudElement.GetVisGroupID() <= 0 )

		local name = hudElement.GetName()

		Assert( !(name in _hudElements), name + " already in menu!" )
		_hudElements[name] <- hudElement

		hudElement.SetVisGroupID( visGroupID )
		hudElement.UpdateVisibility()
	}

	function AddElementGroup( hudElementGroup )
	{
		Assert( hudElementGroup instanceof HudElementGroup )
		local hudElements = hudElementGroup.GetElements()

		hudElementGroup.parentMenu = visGroupID

		foreach ( hudElement in hudElements )
		{
			AddElement( hudElement )
		}
	}
}

// make the default visgroup
level.menuVisGroup <- VisGroup( "player" )

class CHudMenu
{
	player = null
	name = null
	isVisible = null
	elements = null
	ownerHud = null

	visGroupID = null

	constructor( player, name, ownerHud = Hud )
	{
		this.player = player
		this.name = name

		this.isVisible = true

		this.ownerHud = Hud

		elements = {}

		visGroupID = VisGroup_Create()
	}

	function GetElement( name )
	{
		return elements[name]
	}

	function GetElements()
	{
		return elements
	}

	function HudThink()
	{
	}

	function Show()
	{
		if ( isVisible )
			return

		isVisible = true

		foreach ( element in elements )
			element.UpdateVisibility()
	}

	function Hide()
	{
		if ( !isVisible )
			return

		isVisible = false

		foreach ( element in elements )
			element.UpdateVisibility()
	}

	function AddElement( hudElem )
	{
		//Assert( hudElem instanceof HudElement )
		Assert( hudElem.GetVisGroupID() == -1 )

		local name = hudElem.GetName()

		Assert( !(name in elements), name + " already in menu!" )
		elements[name] <- hudElem

		//hudElem.Hide() // force state to match until we can query visible state from code

		hudElem.SetVisGroupID( visGroupID )
		hudElem.UpdateVisibility()
	}

	function RemoveAllElements()
	{
		elements = {}
	}

	function AddElementGroup( hudElemGroup )
	{
		Assert( hudElemGroup instanceof HudElementGroup )
		local elems = hudElemGroup.GetElements()
		foreach ( elem in elems )
			AddElement( elem )
	}

	function CreateElement( name, _ownerHud = null )
	{
		if ( _ownerHud == null )
			_ownerHud = ownerHud
		Assert( !(name in elements) )
		elements[name] <- HudElement( name, _ownerHud )

		//ownerHud.Hide( name ) // force state to match until we can query visible state from code

		hudElem.SetVisGroupID( visGroupID )
		hudElem.UpdateVisibility()

		return elements[name]
	}

	function IsVisible()
	{
		return isVisible
	}
}

function RegisterMenu( player, menu )
{
	player.s._menus[menu.name] <- menu
}

function HudElement( name, ownerHud = Hud )
{
	if ( ownerHud == Hud )
	{
		if ( name in level.hudElements )
		{
			return level.hudElements[name]
		}

		level.hudElements[name] <- ownerHud.HudElement( name )
		return level.hudElements[name]
	}
	else
	{
		return ownerHud.HudElement( name )
	}
}



class HudElementGroup
{
	groupName = null
	elements = null
	elementsArray = null
	isVisible = null
	ownerHud = null
	parentMenu = null	// the CMenu or CHudMenu that owns us; if this is non-null "Show()" and "Hide()" behave differently
	hideWithMenus = null

	constructor( groupName, ownerHud = Hud )
	{
		this.groupName = groupName
		this.ownerHud = ownerHud

		elements = {}
		elementsArray = []

		this.isVisible = false

		this.parentMenu = -1
	}

	function SetVisGroupID( visParentID )
	{
		this.parentMenu = visParentID
	}

	function HideWithMenus( state )
	{
		hideWithMenus = state

		if ( !hideWithMenus && groupName in level.menuHideGroups )
		{
			delete level.menuHideGroups[groupName]
			parentMenu = null
		}
		else if ( hideWithMenus && !(groupName in level.menuHideGroups) )
		{
			level.menuHideGroups[groupName] <- this
			parentMenu = GetLocalViewPlayer()
		}
	}

	function AddElement( hudElem )
	{
		//Assert( hudElem instanceof HudElement )
		//Assert( hudElem.ownerHud == ownerHud )

		local name = hudElem.GetName()

		Assert( !(name in elements) )
		elements[name] <- hudElem
		elementsArray.append( hudElem )

		if ( parentMenu != -1 )
		{
			hudElem.SetVisGroupID( parentMenu )
			hudElem.UpdateVisibility()
		}
	}

	function RemoveAllElements()
	{
		elements = {}
		elementsArray = []
	}

	function AddGroup( group )
	{
		Assert( group instanceof HudElementGroup )
		local elems = group.GetElements()
		foreach ( elem in elems )
		{
			//Assert( elem.ownerHud == ownerHud )
			AddElement( elem )
		}
	}

	function CreateElement( name, _ownerHud = null )
	{
		if ( _ownerHud == null )
			_ownerHud = ownerHud
		Assert( !(name in elements), "hud element already exists " + name )
		elements[name] <- HudElement( name, _ownerHud )
		elementsArray.append( elements[name] )

		if ( parentMenu != -1 )
		{
			elements[name].SetVisGroupID( parentMenu )
			elements[name].UpdateVisibility()
		}

		return elements[name]
	}

	function GetOrCreateElement( name, _ownerHud = null )
	{
		if ( _ownerHud == null )
			_ownerHud = ownerHud
		Assert( !(name in elements), "hud element already exists " + name )
		elements[name] <- _ownerHud.GetOrCreateHudElement( name )
		elementsArray.append( elements[name] )

		if ( parentMenu != -1 )
		{
			elements[name].SetVisGroupID( parentMenu )
			elements[name].UpdateVisibility()
		}

		return elements[name]
	}

	function SetClampToScreen( state )
	{
		foreach ( element in elements )
			element.SetClampToScreen( state )
	}

	function SetWorldSpaceScale( minScale, maxScale, minScaleDist, maxScaleDist )
	{
		foreach ( element in elements )
			element.SetWorldSpaceScale( minScale, maxScale, minScaleDist, maxScaleDist )
	}

	function SetADSFade( mindot, maxdot, minAlpha, maxAlpha )
	{
		foreach ( element in elements )
			element.SetADSFade( mindot, maxdot, minAlpha, maxAlpha )
	}

	function SetFOVFade( mindot, maxdot, minAlpha, maxAlpha )
	{
		foreach ( element in elements )
			element.SetFOVFade( mindot, maxdot, minAlpha, maxAlpha )
	}

	function SetPulsate( minAlpha, maxAlpha, frequency )
	{
		foreach ( element in elements )
			element.SetPulsate( minAlpha, maxAlpha, frequency )
	}

	function ClearPulsate()
	{
		foreach ( element in elements )
			element.ClearPulsate()
	}


	function SetEntity( entity, offset = Vector( 0, 0, 0 ), screenXOffset = 0, screenYOffset = 0 )
	{
		foreach ( element in elements )
			element.SetEntity( entity, offset, screenXOffset, screenYOffset )
	}

	function SetEntityOverhead( entity, offset = Vector( 0, 0, 0 ), screenXOffset = 0, screenYOffset = 0 )
	{
		foreach ( element in elements )
			element.SetEntityOverhead( entity, offset, screenXOffset, screenYOffset )
	}

	function Show()
	{
		foreach ( element in elements )
			element.Show()
	}


	function Hide()
	{
		foreach ( element in elements )
		{
			element.Hide()
		}
	}

	function UpdateVisibility()
	{
		foreach ( element in elements )
			element.UpdateVisibility()
	}

	function IsVisible()
	{
		foreach ( element in elements )
			return element.IsVisible()
	}

	function GetBaseAlpha()
	{
		foreach ( element in elements )
			return element.GetBaseAlpha()
	}

	function GetBaseSize()
	{
		foreach ( element in elements )
			return element.GetBaseSize()
	}

	function GetBaseHeight()
	{
		foreach ( element in elements )
			return element.GetBaseHeight()
	}

	function GetBaseWidth()
	{
		foreach ( element in elements )
			return element.GetBaseWidth()
	}

	function GetBaseX()
	{
		foreach ( element in elements )
			return element.GetBaseX()
	}

	function GetBaseY()
	{
		foreach ( element in elements )
			return element.GetBaseY()
	}

	function GetX()
	{
		foreach ( element in elements )
			return element.GetX()
	}

	function GetY()
	{
		foreach ( element in elements )
			return element.GetY()
	}

	function GetAbsX()
	{
		foreach ( element in elements )
			return element.GetAbsX()
	}

	function GetAbsY()
	{
		foreach ( element in elements )
			return element.GetAbsY()
	}

	function SetColor( arg0 = null, arg1 = null, arg2 = null, arg3 = null )
	{
		if ( ( arg0 != null ) && ( arg1 == null ) && ( arg2 == null ) && ( arg3 == null ) )
		{
			foreach ( element in elements )
				element.SetColor( arg0 )
		}
		else if ( ( arg0 != null ) && ( arg1 != null ) && ( arg2 != null ) && ( arg3 != null ) )
		{
			local args = [arg0, arg1, arg2, arg3]

			foreach ( element in elements )
				element.SetColor( args )
		}
		else
		{
			Assert( 0, "Wrong number of arguments" )
		}
	}

	function SetText( text, arg0=null, arg1=null, arg2=null, arg3=null, arg4=null )
	{
		foreach ( element in elements )
			element.SetText( text, arg0, arg1, arg2, arg3, arg4 )
	}

	function SetTextTypeWriter( text, duration )
	{
		foreach ( element in elements )
			element.SetTextTypeWriter( text, duration )
	}

	function SetSize( width, height )
	{
		foreach ( element in elements )
			element.SetSize( width, height )
	}

	function SetSizeRelative( width, height )
	{
		foreach ( element in elements )
			element.SetSizeRelative( width, height )
	}

	function SetScale( wScale, hScale )
	{
		foreach ( element in elements )
			element.SetScale( wScale, hScale )
	}

	function GetTextWidth()
	{
		// just returns the width of the first element in the group
		foreach ( element in elements )
			return element.GetTextWidth()
	}

	function SetPosRelative( x, y )
	{
		foreach ( element in elements )
			element.SetPosRelative( x, y )
	}

	function SetPos( x, y )
	{
		foreach ( element in elements )
			element.SetPos( x, y )
	}

	function SetBasePos( x, y )
	{
		foreach ( element in elements )
			element.SetBasePos( x, y )
	}

	function SetX( x )
	{
		foreach ( element in elements )
			element.SetX( x )
	}

	function SetY( y )
	{
		foreach ( element in elements )
			element.SetY( y )
	}

	function SetBaseSize( width, height )
	{
		foreach ( element in elements )
			element.SetBaseSize( width, height )
	}

	function GetBasePos()
	{
		// just returns the position of the first element in the group
		foreach ( element in elementsArray )
			return element.GetBasePos()
	}

	function GetWidth()
	{
		// just returns the width of the first element in the group
		foreach ( element in elementsArray )
			return element.GetWidth()
	}

	function GetHeight()
	{
		// just returns the width of the first element in the group
		foreach ( element in elementsArray )
			return element.GetHeight()
	}

	function GetPos()
	{
		// just returns the position of the first element in the group
		foreach ( element in elementsArray )
			return element.GetPos()
	}

	function GetAbsPos()
	{
		foreach ( element in elements )
			return element.GetAbsPos()
	}

	function ReturnToBasePos()
	{
		foreach ( element in elements )
			element.ReturnToBasePos()
	}

	function ReturnToBaseSize()
	{
		foreach ( element in elements )
			element.ReturnToBaseSize()
	}

	function ReturnToBaseColor()
	{
		foreach ( element in elements )
			element.ReturnToBaseColor()
	}

	function SetAlpha( alpha )
	{
		foreach ( element in elements )
			element.SetAlpha( alpha )
	}

	function GetElement( name )
	{
		return elements[name]
	}

	function GetElements()
	{
		return elements
	}

	function GetElementsArray()
	{
		return elementsArray
	}

	function SetOrigin( origin )
	{
		foreach ( element in elements )
			element.SetOrigin( origin )
	}

	function MoveOverTime( x, y, duration, interpolator = 0 )
	{
		foreach ( element in elements )
			element.MoveOverTime( x, y, duration, interpolator )
	}

	function OffsetYOverTime( y, duration, interpolator = 0 )
	{
		foreach ( element in elements )
			element.MoveOverTime( element.GetBaseX(), element.GetBaseY() + y, duration, interpolator )
	}

	function FadeOverTime( alpha, duration, interpolator = 0 )
	{
		foreach ( element in elements )
			element.FadeOverTime( alpha, duration, interpolator )
	}

	function HideOverTime( duration, interpolator = 0 )
	{
		local func = GetInterpolationFunc( interpolator )

		foreach ( element in elements )
			element.HideOverTime( duration, func )
	}

	function FadeOverTimeDelayed( alpha, duration, delay )
	{
		foreach ( element in elements )
			element.FadeOverTimeDelayed( alpha, duration, delay )
	}

	function OffsetX( offset )
	{
		foreach ( element in elements )
			element.OffsetX( offset )
	}

	function OffsetY( offset )
	{
		foreach ( element in elements )
			element.OffsetY( offset )
	}

	function SetImage( material )
	{
		foreach ( element in elements )
			element.SetImage( material )
	}

	function SetBaseColor( r, g, b, a )
	{
		foreach ( element in elements )
			element.SetBaseColor( r, g, b, a )
	}

	function SetBaseAlpha( a )
	{
		foreach ( element in elements )
			element.SetBaseAlpha( a )
	}

	function SetPanelAlpha( a )
	{
		foreach ( element in elements )
			element.SetPanelAlpha( a )
	}

	function FadePanelOverTime( a, duration )
	{
		foreach ( element in elements )
			element.FadePanelOverTime( a, duration )
	}
}

function ClientCodeCallback_CreateHudElementGroup( name )
{
	return HudElementGroup( name )
}

function GetContentScaleFactor( ownerHud = Hud )
{
	local screenSize = ownerHud.GetScreenSize()
	local screenSizeX = screenSize[0].tofloat()
	local screenSizeY = screenSize[1].tofloat()
	local aspectRatio = screenSizeX / screenSizeY
	local scaleFactor = {}
	scaleFactor[0] <- screenSizeX / ( 480.0 * aspectRatio )
	scaleFactor[1] <- screenSizeY / 480.0
	return scaleFactor
}

function ClientCodeCallback_GetContentScaleFactor()
{
	return GetContentScaleFactor()
}

function ContentScaledX( val )
{
	return (val * GetContentScaleFactor()[0])
}


function ContentScaledY( val )
{
	return (val * GetContentScaleFactor()[1])
}


enum Interpolators_e
{
	INTERPOLATOR_LINEAR,
	INTERPOLATOR_ACCEL,
	INTERPOLATOR_DEACCEL,
	INTERPOLATOR_PULSE,
	INTERPOLATOR_FLICKER,
	INTERPOLATOR_SIMPLESPLINE, // ease in / out
	INTERPOLATOR_BOUNCE,	   // gravitational bounce

	INTERPOLATOR_COUNT,
}

function GetInterpolationFunc( interpolator )
{
	switch ( interpolator )
	{
		case Interpolators_e.INTERPOLATOR_LINEAR:
			return Anim_Linear
		case Interpolators_e.INTERPOLATOR_ACCEL:
			return Anim_EaseIn
		case Interpolators_e.INTERPOLATOR_DEACCEL:
			return Anim_EaseOut
		case Interpolators_e.INTERPOLATOR_PULSE:
			return Anim_Linear
		case Interpolators_e.INTERPOLATOR_FLICKER:
			return Anim_Linear
		case Interpolators_e.INTERPOLATOR_SIMPLESPLINE:
			return Anim_SCurve
		case Interpolators_e.INTERPOLATOR_BOUNCE:
			return Anim_Linear
		default:
			break
	}
}


function Anim_Linear( x )
{
	return x
}

function Anim_EaseInSlow( x )
{
	x = x - 1
	return 1 - (pow( x, 2 ))
}

function Anim_EaseIn( x )
{
	x = x - 1
	return 1 - (pow( x, 6 ))
}

function Anim_EaseOut( x )
{
	return pow( x, 6 )
}

function Anim_SCurve( x )
{
	return x*x*(3 - 2*x)
}

function Anim_SCurve2( x )
{
	return x*x*x*(10 + x*(6*x - 15))
}

function Anim_Sin( x )
{
	return (1 - cos( PI*x )) / 2
}

function HUD_VisibleForParent( parentObj )
{
	if ( type( parentObj ) == "integer" )
		return _visParents[parentObj].IsVisible()
	else if ( parentObj instanceof CHudMenu )
		return parentObj.IsVisible()
	else if ( parentObj instanceof HudElementGroup )
		return parentObj.IsVisible()
	else if ( parentObj instanceof C_BaseEntity )
		return parentObj.IsHUDVisible()
	else
		Assert( 0, "Invalid parent specified for HudElement" )

	return null
}

function ComputeSizeForAttachments( ent, bottomLeftID, topRightID, viewmodelNoFovAdjust )
{
	local blOrigin
	local trOrigin

	if ( viewmodelNoFovAdjust )
	{
		blOrigin = ent.GetAttachmentOrigin_ViewModelNoFOVAdjust( bottomLeftID )
		trOrigin = ent.GetAttachmentOrigin_ViewModelNoFOVAdjust( topRightID )
	}
	else
	{
		blOrigin = ent.GetAttachmentOrigin( bottomLeftID )
		trOrigin = ent.GetAttachmentOrigin( topRightID )
	}

	local blAngles = ent.GetAttachmentAngles( bottomLeftID )

	local thingToDot = trOrigin - blOrigin

	local height = -thingToDot.Dot( blAngles.AnglesToRight() )
	local width = thingToDot.Dot( blAngles.AnglesToForward() )

	return [ width, height ]
}


function GetEntityScreenHeight( entity, padding = 0 )
{
	local bounds = player.GetEntScreenSpaceBounds( entity, padding )
	return (bounds[3] - bounds[1])
}


function ServerCallback_TimedEventNotification( duration, eventID, eHandle, eventVal )
{

}


function ServerCallback_EventNotification( eventID, eHandle, eventVal )
{
	local entity = null
	if ( eHandle )
		entity = GetEntityFromEncodedEHandle( eHandle )

	EventNotification( eventID, entity, eventVal )
}

function EventNotification( eventID, entity, eventVal = null )
{
	local player = GetLocalClientPlayer()

	switch ( eventID )
	{
		case eEventNotifications.PlayerHasEnemyFlag:
			if ( entity )
				SetTimedEventNotification( 3.0, "#GAMEMODE_PLAYER_HAS_ENEMY_FLAG", entity.GetPlayerName(), eventVal )
			break

		case eEventNotifications.PlayerCapturedEnemyFlag:
			if ( entity )
				SetTimedEventNotification( 3.0, "#GAMEMODE_PLAYER_CAPTURED_ENEMY_FLAG", entity.GetPlayerName(), eventVal )
			break

		case eEventNotifications.PlayerReturnedEnemyFlag:
			if ( entity )
				SetTimedEventNotification( 3.0, "#GAMEMODE_PLAYER_RETURNED_ENEMY_FLAG", entity.GetPlayerName(), eventVal )
			break

		case eEventNotifications.PlayerDroppedEnemyFlag:
			if ( entity )
				SetTimedEventNotification( 3.0, "#GAMEMODE_PLAYER_DROPPED_ENEMY_FLAG", entity.GetPlayerName(), eventVal )
			break

		case eEventNotifications.PlayerHasFriendlyFlag:
			if ( entity )
				SetTimedEventNotification( 3.0, "#GAMEMODE_PLAYER_HAS_FRIENDLY_FLAG", entity.GetPlayerName(), eventVal )
			break

		case eEventNotifications.PlayerCapturedFriendlyFlag:
			if ( entity )
				SetTimedEventNotification( 3.0, "#GAMEMODE_PLAYER_CAPTURED_FRIENDLY_FLAG", entity.GetPlayerName(), eventVal )
			break

		case eEventNotifications.PlayerReturnedFriendlyFlag:
			if ( entity )
				SetTimedEventNotification( 3.0, "#GAMEMODE_PLAYER_RETURNED_FRIENDLY_FLAG", entity.GetPlayerName(), eventVal )
			break

		case eEventNotifications.PlayerDroppedFriendlyFlag:
			if ( entity )
				SetTimedEventNotification( 3.0, "#GAMEMODE_PLAYER_DROPPED_FRIENDLY_FLAG", entity.GetPlayerName(), eventVal )
			break

		case eEventNotifications.ReturnedFriendlyFlag:
			SetTimedEventNotification( 3.0, "#GAMEMODE_RETURNED_FRIENDLY_FLAG" )
			break

		case eEventNotifications.ReturnedEnemyFlag:
			SetTimedEventNotification( 3.0, "#GAMEMODE_RETURNED_ENEMY_FLAG" )
			break

		case eEventNotifications.BurnCardRematch:
			if ( entity )
				SetTimedEventNotification( 3.0, "#BURNCARD_REMATCH_WARNING", entity.GetPlayerName() )
			break

		case eEventNotifications.MarkedForDeathWaitingForMarkedToSpawn:
			SetEventNotification( "#MARKED_FOR_DEATH_WAITING_FOR_MARKED_TO_SPAWN" )
			break

		case eEventNotifications.MarkedForDeathMarkedDisconnected:
			SetTimedEventNotification( 3.0, "#MARKED_FOR_DEATH_MARKED_DISCONNECTED" )
			break

		case eEventNotifications.MarkedForDeathYouWillBeMarkedNext:
			if ( eventVal - Time() > 2.0 )
			{
				thread MarkedForDeathCountdownSound( eventVal, "UI_InGame_MarkedForDeath_CountdownToYouAreMarked" )
				local announcement = CAnnouncement( "#MARKED_FOR_DEATH_YOU_ARE_THE_NEXT_TARGET" )
				announcement.SetPurge( true )
				announcement.SetPriority( 200 ) //Be higher priority than Titanfall ready indicator etc
				AnnouncementFromClass( player, announcement )
				SetTimedEventNotificationHATT( (eventVal - Time()) - 1.0, "#MARKED_FOR_DEATH_YOU_WILL_BE_MARKED_NEXT", HATT_GAME_COUNTDOWN_SECONDS, eventVal )
			}
			break

		case eEventNotifications.MarkedForDeathCountdownToNextMarked:
			if ( eventVal - Time() > 2.0 )
			{
				SetTimedEventNotificationHATT( (eventVal - Time()) - 1.0, "#MARKED_FOR_DEATH_COUNTDOWN_TO_NEXT_MARKED", HATT_GAME_COUNTDOWN_SECONDS, eventVal )
				thread MarkedForDeathCountdownSound( eventVal, "UI_InGame_MarkedForDeath_CountdownToMarked" )
			}
			break

		case eEventNotifications.MarkedForDeathKill:

			if ( !entity )
				return

			local attacker = null
			local attackerName

			if ( eventVal )
				attacker = GetEntityFromEncodedEHandle( eventVal )

			if ( IsValid( attacker ) && attacker.IsPlayer() )
			{
				attackerName = attacker.GetPlayerName()
			}

			local timeToDisplay = 3.0
			local msg
			local friendly = entity.GetTeam() == GetLocalClientPlayer().GetTeam()
			if ( attackerName )
			{
				if ( friendly )
					msg = "#GAMEMODE_MARKED_ENEMY_KILLED_MARKED"
				else
					msg = "#GAMEMODE_MARKED_FRIENDLY_KILLED_MARKED"
				SetTimedEventNotification( timeToDisplay, msg, attackerName, entity.GetPlayerName(), EN_SHOW_OVER_SCREENFADE )
			}
			else
			{
				if ( friendly )
					msg = "#GAMEMODE_MARKED_FRIENDLY_MARKED_DIED"
				else
					msg = "#GAMEMODE_MARKED_ENEMY_MARKED_DIED"
				SetTimedEventNotification( timeToDisplay, msg, entity.GetPlayerName(), null, EN_SHOW_OVER_SCREENFADE )
			}

		//	if ( !eventVal )
		//		return

		//	local killer = GetEntityFromEncodedEHandle( eventVal )
		//	if ( !IsValid( killer ) )
		//		return

		//	if ( entity == killer )
		//		SetTimedEventNotification( 3.0, "#GAMEMODE_MARKED_FOR_DEATH_SUICIDE", entity.GetPlayerName() )
		//	else
		//		SetTimedEventNotification( 3.0, "#GAMEMODE_MARKED_FOR_DEATH_KILLED", killer.GetPlayerName(), entity.GetPlayerName() )
			break

		case eEventNotifications.PlayerFirstStrike:
			if ( entity )
			{
				local attacker = GetEntityFromEncodedEHandle( eventVal )
				local attackerName
				if ( IsValid( attacker ) && attacker.IsPlayer() )
				{
					attackerName = attacker.GetPlayerName()
					if ( attacker.GetTeam() == GetLocalViewPlayer().GetTeam() )
						SetTimedEventNotification( 3.0, "#EVENTNOTIFY_FIRST_STRIKE_FRIENDLY", attackerName, entity.GetPlayerName() )
					else
						SetTimedEventNotification( 3.0, "#EVENTNOTIFY_FIRST_STRIKE_ENEMY", attackerName, entity.GetPlayerName() )
				}
			}
			break

		case eEventNotifications.YouHaveTheEnemyFlag:
			SetEventNotification( "#GAMEMODE_YOU_HAVE_THE_ENEMY_FLAG" )
			break

		case eEventNotifications.YouDroppedTheEnemyFlag:
			SetTimedEventNotification( 3.0, "#GAMEMODE_YOU_DROPPED_THE_ENEMY_FLAG" )
			break

		case eEventNotifications.YouReturnedFriendlyFlag:
			SetTimedEventNotification( 3.0, "#GAMEMODE_YOU_RETURNED_THE_FRIENDLY_FLAG" )
			break

		case eEventNotifications.YouCapturedTheEnemyFlag:
			SetTimedEventNotification( 3.0, "#GAMEMODE_YOU_CAPTURED_THE_ENEMY_FLAG" )
			break

		case eEventNotifications.WipedOut:
			SetTimedEventNotification( 3.0, "Your squad was wiped out." )
			break

		case eEventNotifications.BeingRevived:
			SetTimedEventNotificationHATT( 0.0, "Revived in %s1", HATT_GAME_COUNTDOWN_SECONDS_MILLISECONDS, eventVal )
			break

		case eEventNotifications.NeedRevive:
			thread TryReviveEventNotice( eventVal )
			break

		case eEventNotifications.YouHaveTheTitan:
			SetTimedEventNotificationHATT( 5.0, "#GAMEMODE_YOU_HAVE_THE_TITAN_IN", HATT_GAME_COUNTDOWN_SECONDS_MILLISECONDS, eventVal )
			break

		case eEventNotifications.FriendlyPlayerHasTheTitan:
			SetTimedEventNotification( 3.0, "#GAMEMODE_FRIENDLY_PLAYER_HAS_THE_TITAN", entity.GetPlayerName(), eventVal )
			break

		case eEventNotifications.EnemyPlayerHasTheTitan:
			SetTimedEventNotification( 3.0, "#GAMEMODE_ENEMY_PLAYER_HAS_THE_TITAN", entity.GetPlayerName(), eventVal )
			break

		case eEventNotifications.YouWillRespawnIn:
			if ( eventVal - Time() > 2.0 )
			{
				if ( GetWaveSpawnType() == eWaveSpawnType.DISABLED )
					SetTimedEventNotificationHATT( (eventVal - Time()) - 1.0, "#GAMEMODE_RESPAWNING_IN_N", HATT_GAME_COUNTDOWN_SECONDS, eventVal )
				else
					SetTimedEventNotificationHATT( (eventVal - Time()) - 1.0, "#GAMEMODE_DEPLOYING_IN_N", HATT_GAME_COUNTDOWN_SECONDS, eventVal )
			}
			break

		case eEventNotifications.PlayerLeftTheTitan:
			if ( entity )
			{
				if ( entity == GetLocalClientPlayer() )
					ClearEventNotification()
					/*
				else if ( entity.GetTeam() == GetLocalClientPlayer().GetTeam() )
					SetTimedEventNotification( 3.0, "#GAMEMODE_PLAYER_LEFT_ENEMY_TITAN", entity.GetPlayerName(), eventVal )
				else
					SetTimedEventNotification( 3.0, "#GAMEMODE_PLAYER_LEFT_FRIENDLY_TITAN", entity.GetPlayerName(), eventVal )
					*/
			}
			break

		case eEventNotifications.PlayerHasTheTitan:
			if ( entity )
			{
				if ( entity == GetLocalClientPlayer() )
				{
					// if ( HasEnemyRiderEnt( entity ) )
					// 	SetEventNotification( "#GAMEMODE_YOU_HAVE_THE_TITAN_RODEO" )
					// else
					// 	SetEventNotification( "#GAMEMODE_YOU_HAVE_THE_TITAN" )
				}
				else if ( entity.GetTeam() == GetLocalClientPlayer().GetTeam() )
				{
					SetTimedEventNotification( 3.0, "#GAMEMODE_PLAYER_HAS_ENEMY_TITAN", entity.GetPlayerName(), eventVal )
				}
				else
				{
					SetTimedEventNotification( 3.0, "#GAMEMODE_PLAYER_HAS_FRIENDLY_TITAN", entity.GetPlayerName(), eventVal )
				}
			}
			break

		case eEventNotifications.PlayerDestroyedTheTitan:
			if ( entity )
			{
				if ( entity == GetLocalClientPlayer() )
					SetTimedEventNotification( 3.0, "#GAMEMODE_YOU_DESTROYED_THE_TITAN" )
				else if ( entity.GetTeam() == GetLocalClientPlayer().GetTeam() )
					SetTimedEventNotification( 3.0, "#GAMEMODE_PLAYER_DESTROYED_FRIENDLY_TITAN", entity.GetPlayerName(), eventVal )
				else
					SetTimedEventNotification( 3.0, "#GAMEMODE_PLAYER_DESTROYED_ENEMY_TITAN", entity.GetPlayerName(), eventVal )
			}
			break

		case eEventNotifications.PlayerCapturedTheTitan:
			if ( entity )
			{
				if ( entity == GetLocalClientPlayer() )
					SetTimedEventNotification( 3.0, "#GAMEMODE_YOU_CAPTURED_THE_TITAN" )
				else if ( entity.GetTeam() == GetLocalClientPlayer().GetTeam() )
					SetTimedEventNotification( 3.0, "#GAMEMODE_PLAYER_CAPTURED_ENEMY_TITAN", entity.GetPlayerName(), eventVal )
				else
					SetTimedEventNotification( 3.0, "#GAMEMODE_PLAYER_CAPTURED_FRIENDLY_TITAN", entity.GetPlayerName(), eventVal )
			}
			break

		case eEventNotifications.CoopTDStart:
				local announcement = CAnnouncement( "#GAMEMODE_COOP" )
				announcement.SetSubText( "#GAMEMODE_COOP_HINT" )
				announcement.SetPurge( true )
				AnnouncementFromClass( player, announcement )
			break

		case eEventNotifications.CoopTDWon:
				local announcement = CAnnouncement( "#COOP_TOTAL_VICTORY" )
				announcement.SetSubText( "#COOP_TOTAL_VICTORY_HINT" )
				announcement.SetPurge( true )
				announcement.SetPriority( 200 )
				announcement.SetHideOnDeath( false )
				announcement.SetSoundAlias( "UI_InGame_CoOp_Victory" )
				announcement.SetDuration( COOP_VICTORY_ANNOUNCEMENT_LENGTH )
				AnnouncementFromClass( player, announcement )
			break

		case eEventNotifications.CoopTDWaveLost:
			local announcement = CAnnouncement( "#COOP_WAVE_FAILED" )
			announcement.SetSubText( "" )
			announcement.SetPurge( true )
			announcement.SetSoundAlias( "UI_InGame_CoOp_HarvesterDefenseFailed" )
			announcement.SetDuration( 8.0 )
			AnnouncementFromClass( player, announcement )
		break

		case eEventNotifications.CoopTDLost:
				local announcement = CAnnouncement( "#COOP_TOTAL_DEFEAT" )
				announcement.SetSubText( "#COOP_TOTAL_DEFEAT_HINT" )
				announcement.SetPurge( true )
				announcement.SetPriority( 200 )
				announcement.SetSoundAlias( "UI_InGame_Coop_Defeat" )
				announcement.SetHideOnDeath( false )
				announcement.SetDuration( COOP_DEFEAT_ANNOUNCEMENT_LENGTH )
				AnnouncementFromClass( player, announcement )
			break

		case eEventNotifications.CoopTDWaveRestart:
				local announcement = CAnnouncement( "#COOP_WAVE_RESTARTING" )
				announcement.SetSubText( "#COOP_WAVE_RESTARTING_HINT" )
				announcement.SetPurge( true )
				announcement.SetSoundAlias( "UI_InGame_CoOp_TryAgain" )
				announcement.SetDuration( 3.5 )
				AnnouncementFromClass( player, announcement )
			break

		case eEventNotifications.CoopAmmoRefilled:
				local announcement = CAnnouncement( "" )
				announcement.SetSubText( "#LOADOUT_CRATE_AMMO_REFILLED" )
				announcement.SetPurge( false )
				AnnouncementFromClass( player, announcement )
			break

		case eEventNotifications.TurretAvailable:
				local announcement = CAnnouncement( "#SENTRY_TURRET_AVAILABLE_SPLASH" )

				if ( player.IsTitan() )
					announcement.SetSubText( "#SENTRY_TURRET_AVAILABLE_SPLASH_HINT_TITAN" )
				else
					announcement.SetSubText( "#SENTRY_TURRET_AVAILABLE_SPLASH_HINT" )

				announcement.SetPurge( false )
				announcement.SetDuration( 4.0 )
				announcement.SetSoundAlias( "UI_InGame_CoOp_SentryGunAvailable" )
				AnnouncementFromClass( player, announcement )
			break

		case eEventNotifications.MaxTurretsPlaced:
				local announcement = CAnnouncement( "" )
				announcement.SetSubText( "#SENTRY_TURRET_MAX_PLACED_SPLASH_HINT" )

				announcement.SetPurge( true )
				announcement.SetDuration( 4.0 )
				announcement.SetSoundAlias( "coop_sentrygun_deploymentdeniedbeep" )
				AnnouncementFromClass( player, announcement )
			break

		case eEventNotifications.CoopPlayerDisconnected:
				local announcement = CAnnouncement( "#COOP_DIFFICULTY_DOWN" )

				announcement.SetPurge( false )
				announcement.SetDuration( 2.5 )
				//announcement.SetSoundAlias( "coop_sentrygun_deploymentdeniedbeep" )
				AnnouncementFromClass( player, announcement )
			break

		case eEventNotifications.CoopPlayerConnected:
				local announcement = CAnnouncement( "#COOP_DIFFICULTY_UP" )

				announcement.SetPurge( false )
				announcement.SetDuration( 2.5 )
				//announcement.SetSoundAlias( "coop_sentrygun_deploymentdeniedbeep" )
				AnnouncementFromClass( player, announcement )
			break

		case eEventNotifications.CoopDifficultyDown:
				local announcement = CAnnouncement( "#COOP_DIFFICULTY_DOWN" )
				announcement.SetSubText( "#COOP_DIFFICULTY_BALANCE_HINT" )

				announcement.SetPurge( false )
				announcement.SetDuration( 4.0 )
				//announcement.SetSoundAlias( "coop_sentrygun_deploymentdeniedbeep" )
				AnnouncementFromClass( player, announcement )
			break

		case eEventNotifications.CoopDifficultyUp:
				local announcement = CAnnouncement( "#COOP_DIFFICULTY_UP" )
				announcement.SetSubText( "#COOP_DIFFICULTY_BALANCE_HINT" )

				announcement.SetPurge( false )
				announcement.SetDuration( 4.0 )
				//announcement.SetSoundAlias( "coop_sentrygun_deploymentdeniedbeep" )
				AnnouncementFromClass( player, announcement )
			break

		case  eEventNotifications.RoundWinningKillReplayCancelled:
			SetTimedEventNotification( 5.0, "#ROUND_WINNING_KILL_REPLAY_CANCELLED", null, null, EN_SHOW_OVER_SCREENFADE )
			break


		default:
			ClearEventNotification()
			break
	}
}

function SetEventNotificationHATT( eventText, eventHATT = null, eventVal = 0, flags = 0 )
{
	SetTimedEventNotification( 0, eventText, eventHATT, eventVal )
}


function SetTimedEventNotificationHATT( duration, eventText, eventHATT, eventVal = 0, flags = 0 )
{
	local player = GetLocalClientPlayer()

	if ( eventText != player.cv.hud.s.lastEventNotificationText )
	{
		player.cv.hud.s.eventNotification.SetAlpha( 0 )
		player.cv.hud.s.eventNotification.FadeOverTime( 255, 1.0 )
	}
	else
	{
		player.cv.hud.s.eventNotification.SetAlpha( 255 )
	}
	player.cv.hud.s.eventNotification.Show()

	player.cv.hud.s.eventNotification.SetAutoText( eventText, eventHATT, eventVal )
	player.cv.hud.s.lastEventNotificationText = eventText

	if ( !player.cv.hud.s.eventNotification.IsAutoText() )
		player.cv.hud.s.eventNotification.EnableAutoText()

	player.Signal( "SetEventNotification" )

	local zPos = 1000 // there is no base Z in code, this value should match the default in HudScripted_mp.res
	if ( flags & EN_SHOW_OVER_SCREENFADE )
		zPos = 3501

	player.cv.hud.s.eventNotification.SetZ( zPos )

	if ( duration )
		thread HideEventNotification( duration )
}

function SetEventNotification( eventText, eventArg1 = null, eventArg2 = null, flags = 0 )
{
	SetTimedEventNotification( 0, eventText, eventArg1, eventArg2, flags )
}


function SetTimedEventNotification( duration, eventText, eventArg1 = null, eventArg2 = null, flags = 0 )
{
	local player = GetLocalClientPlayer()

	if ( eventText != player.cv.hud.s.lastEventNotificationText )
	{
		player.cv.hud.s.eventNotification.SetAlpha( 0 )
		player.cv.hud.s.eventNotification.FadeOverTime( 255, 1.0 )
	}
	else
	{
		player.cv.hud.s.eventNotification.SetAlpha( 255 )
	}
	player.cv.hud.s.eventNotification.Show()

	if ( player.cv.hud.s.eventNotification.IsAutoText() )
		player.cv.hud.s.eventNotification.DisableAutoText()

	player.cv.hud.s.eventNotification.SetText( eventText, eventArg1, eventArg2 )
	player.cv.hud.s.lastEventNotificationText = eventText

	player.Signal( "SetEventNotification" )

	local zPos = 1000 // there is no base Z in code, this value should match the default in HudScripted_mp.res
	if ( flags & EN_SHOW_OVER_SCREENFADE )
		zPos = 3501

	player.cv.hud.s.eventNotification.SetZ( zPos )

	if ( duration )
		thread HideEventNotification( duration )
}


function HideEventNotification( duration )
{
	local player = GetLocalClientPlayer()

	player.Signal( "SetEventNotification" )
	player.EndSignal( "SetEventNotification" )

	wait duration

	ClearEventNotification()

	if ( !IsWatchingKillReplay() )
	{
		// permanent event notifications go here
		local player = GetLocalClientPlayer()
		switch ( GAMETYPE )
		{
			case CAPTURE_THE_FLAG:
				if ( PlayerHasEnemyFlag( player ) )
				{
					SetEventNotification( "#GAMEMODE_YOU_HAVE_THE_ENEMY_FLAG" )
				}
				else if ( player.IsTitan() && HasSoul( player ) )
				{
					local rider = GetFriendlyRodeoPlayer( player )

					if ( IsValid( rider ) && PlayerHasEnemyFlag( rider ) )
					{
						SetEventNotification( "#GAMEMODE_RODEO_PILOT_HAS_THE_ENEMY_FLAG" )
					}
				}

				break

			case MARKED_FOR_DEATH:
			case MARKED_FOR_DEATH_PRO:
				if ( GetMarked( player.GetTeam() ) == player && IsAlive( player ) )
					SetEventNotification( "#MARKED_FOR_DEATH_YOU_ARE_MARKED_REMINDER" )
				break
		}
	}


	thread TryReviveEventNotice()
}

function TryReviveEventNotice( reviveTime = null )
{
	Assert( IsNewThread(), "Must be threaded off" )

	local player = GetLocalViewPlayer()
	if ( !PlayerMustRevive( player ) )
		return

	if ( player != GetLocalClientPlayer() )
		return
	if ( IsAlive( player ) )
		return

	local timeRemaining = ( player.cv.killReplayTimeOfDeath + REVIVE_DEATH_TIME ) - Time()
	if ( timeRemaining > 0 )
		wait timeRemaining

	if ( IsAlive( player ) )
		return

	if ( reviveTime == null )
		reviveTime = player.cv.killReplayTimeOfDeath + REVIVE_BLEED_OUT_TIME

	SetTimedEventNotificationHATT( 0.0, "#REVIVE_BLEED_OUT", HATT_GAME_COUNTDOWN_SECONDS, reviveTime )
}

function ClearEventNotification()
{
	local player = GetLocalClientPlayer()
	if ( !"playerScriptsInitialized" in player.s )
		return
	player.cv.hud.s.eventNotification.FadeOverTime( 0, 1.0)
}

function AnnouncementMessage( player, messageText, subText = "", titleColor = [255, 255, 255], optionalTextArgs = [null, null, null, null, null], optionalSubTextArgs = [null, null, null, null, null], soundAlias = null )
{
	if ( player != GetLocalClientPlayer() )
		return

	local announcement = CAnnouncement( messageText )
	announcement.SetSubText( subText )
	announcement.SetTitleColor( titleColor )
	announcement.SetOptionalTextArgsArray( optionalTextArgs )
	announcement.SetOptionalSubTextArgsArray( optionalSubTextArgs )
	announcement.SetSoundAlias( soundAlias )

	player.cv.announcementQueue.append( announcement )

	if ( player.cv.announcementActive )
		return

	thread AnnouncementMessage_Display( player, announcement )
}

function AnnouncementFromClass( player, announcement )
{
	if ( player != GetLocalClientPlayer() )
		return

	Assert( announcement instanceof CAnnouncement )

	if ( announcement.GetPurge() )
	{
		local activeAnnouncement = player.cv.announcementActive

		if ( !activeAnnouncement || activeAnnouncement.GetPriority() <= announcement.GetPriority() )
		{
			level.ent.Signal( "AnnoucementPurge" )

			if ( player.cv.announcementActive )
				player.cv.announcementQueue.resize( 1 )
			else
				player.cv.announcementQueue = []
		}
	}

	player.cv.announcementQueue.append( announcement )

	if ( player.cv.announcementActive )
		return

	thread AnnouncementMessage_Display( player, announcement )
}

function AnnouncementProcessQueue( player )
{
	if ( !IsValid( player ) )
		return

	if ( player.cv.announcementActive )
		return

	if ( !player.cv.announcementQueue.len() )
		return

	local announcement = player.cv.announcementQueue[0]
	thread AnnouncementMessage_Display( player, announcement )
}


function AnnouncementMessage_Display( player, announcement )
{
	// defensive fix for 52941
	if ( !("announcementAnchor" in GetLocalClientPlayer().cv.hud.s ) )
		return

	//Don't display announcements when they can't be read during coop.
	local ceFlags = player.GetCinematicEventFlags()
	if ( ceFlags & CE_FLAG_EOG_STAT_DISPLAY )
		return

	OnThreadEnd(
		function() : ()
		{
			GetLocalClientPlayer().cv.announcementActive = null
			thread AnnouncementProcessQueue( GetLocalClientPlayer() )
		}
	)

	GetLocalClientPlayer().cv.announcementActive = announcement

	waitthread AnnouncementMessage_DisplayOnHud( GetLocalClientPlayer().cv.hud, announcement )

	GetLocalClientPlayer().cv.announcementQueue.remove( 0 )
}


function AnnouncementMessage_DisplayOnHud( vgui, announcement )
{
	if ( vgui instanceof C_VGuiScreen )
		vgui.EndSignal( "OnDestroy" )

	local player = GetLocalClientPlayer()
	level.ent.EndSignal( "AnnoucementPurge" )

	local text = vgui.s.announcementText
	local textBG = vgui.s.announcementTextBG
	local subtext = vgui.s.announcementSubText
	local subtext2 = vgui.s.announcementSubText2
	local subtext2Large = vgui.s.AnnouncementSubText2Large
	local subtext2LargeBG = vgui.s.AnnouncementSubText2LargeBG
	local scan = vgui.s.announcementScan
	local icon = vgui.s.announcementIcon
	local iconLabel = vgui.s.announcementIconLabel

	local leftIcon = vgui.s.announcementLeftIcon
	local rightIcon = vgui.s.announcementRightIcon
	local leftText = vgui.s.announcementLeftText
	local rightText = vgui.s.announcementRightText

	local notificationMoveY = 0
	local notificationMoveTime = 0.15
	if ( announcement.GetIcon() )
	{
		notificationMoveY = icon.GetHeight() * 0.9
	}

	vgui.s.eventNotification.MoveOverTime( 0, notificationMoveY, notificationMoveTime, INTERPOLATOR_DEACCEL )

	local hideOnDeath = announcement.GetHideOnDeath()
	if ( hideOnDeath )
	{
		player.EndSignal( "OnDeath" )
		player.EndSignal( "OnDestroy" )
	}

	local package = {
		text = text,
		textBG = textBG,
		subtext = subtext,
		subtext2 = subtext2,
		subtext2Large = subtext2Large,
		subtext2LargeBG = subtext2LargeBG,
		scan = scan,
		hideOnDeath = hideOnDeath,
		finished = false
		eventNotification = vgui.s.eventNotification
		leftIcon = leftIcon
		rightIcon = rightIcon
		leftText = leftText
		rightText = rightText
		icon = icon
		iconLabel = iconLabel
	}

	OnThreadEnd(
		function() : ( package )
		{
			local player = GetLocalClientPlayer()

			if ( !package.hideOnDeath && package.finished )
				return
			else if ( package.hideOnDeath && IsAlive( player ) && package.finished )
				return

			package.text.Hide()
			package.textBG.Hide()
			package.subtext.Hide()
			package.subtext2.Hide()
			package.subtext2Large.Hide()
			package.subtext2LargeBG.Hide()
			package.scan.Hide()
			package.icon.Hide()
			package.iconLabel.Hide()

			package.leftIcon.Hide()
			package.rightIcon.Hide()
			package.leftText.Hide()
			package.rightText.Hide()

			local baseY = package.eventNotification.GetBaseY()
			package.eventNotification.MoveOverTime( 0, baseY, 0.15, INTERPOLATOR_DEACCEL)
		}
	)

	local titleColor 			= announcement.GetTitleColor()
	local optionalTextArgs 		= announcement.GetOptionalTextArgs()
	local optionalSubTextArgs 	= announcement.GetOptionalSubTextArgs()

	text.Show()
	text.SetText( announcement.GetMessageText(), optionalTextArgs[0], optionalTextArgs[1], optionalTextArgs[2], optionalTextArgs[3], optionalTextArgs[4] )
	text.SetColor( titleColor[0], titleColor[1], titleColor[2], 0 )
	text.FadeOverTime( 255, 0.15, INTERPOLATOR_ACCEL )

	textBG.Show()
	textBG.SetText( announcement.GetMessageText(), optionalTextArgs[0], optionalTextArgs[1], optionalTextArgs[2], optionalTextArgs[3], optionalTextArgs[4] )
	textBG.SetColor( 0, 0, 0, 0 )
	textBG.FadeOverTime( 255, 0.15, INTERPOLATOR_ACCEL )

	subtext.Show()
	subtext.SetText( announcement.GetSubText(), optionalSubTextArgs[0], optionalSubTextArgs[1], optionalSubTextArgs[2], optionalSubTextArgs[3], optionalSubTextArgs[4] )
	subtext.SetColor( 255, 255, 255, 0 )
	subtext.FadeOverTime( 255, 0.15, INTERPOLATOR_ACCEL )

	if ( announcement.GetIcon() )
	{
		icon.ReturnToBasePos()
		icon.Show()
		icon.SetColor( 255, 255, 255, 0 )
		icon.FadeOverTime( 255, 0.15, INTERPOLATOR_ACCEL )
		icon.SetImage( announcement.GetIcon() )
	}
	else
	{
		icon.Hide()
	}

	local fx = announcement.GetCockpitFX()
	if ( fx != null )
	{
		local viewPlayer = GetLocalViewPlayer()
		local cockpit = viewPlayer.GetCockpit()
		if ( IsValid( cockpit ) )
			StartParticleEffectOnEntity( cockpit, GetParticleSystemIndex( fx ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	}

	local soundAlias = announcement.GetSoundAlias()
	if ( soundAlias != null )
		EmitSoundOnEntity( GetLocalClientPlayer(), soundAlias )

	local duration = announcement.GetDuration()

	wait( announcement.GetSubText2AndIconDelay() )
	duration -= announcement.GetSubText2AndIconDelay()

	subtext2.Show()
	local subText2array = announcement.GetSubText2()
	subtext2.SetText( subText2array[0], subText2array[1], subText2array[2], subText2array[3], subText2array[4], subText2array[5] )
	subtext2.SetColor( 180, 180, 180, 0 )
	subtext2.FadeOverTime( 255, 0.15, INTERPOLATOR_ACCEL )

	subtext2Large.Show()
	local subtext2Largearray = announcement.GetSubText2Large()
	subtext2Large.SetText( subtext2Largearray[0], subtext2Largearray[1], subtext2Largearray[2], subtext2Largearray[3], subtext2Largearray[4], subtext2Largearray[5] )
	subtext2Large.SetColor( titleColor )
	subtext2Large.FadeOverTime( 255, 0.15, INTERPOLATOR_ACCEL )

	subtext2LargeBG.Show()
	subtext2LargeBG.SetText( subtext2Largearray[0], subtext2Largearray[1], subtext2Largearray[2], subtext2Largearray[3], subtext2Largearray[4], subtext2Largearray[5] )
	subtext2LargeBG.SetColor( 0, 0, 0, 0 )
	subtext2LargeBG.FadeOverTime( 255, 0.15, INTERPOLATOR_ACCEL )

	if ( announcement.GetOptionalFunc() != null )
	{
		local funcTable = announcement.GetOptionalFunc()
		funcTable.func.acall( [ funcTable.scope, announcement, vgui ] )
	}

	if ( announcement.GetIconText()[0] != "" )
	{
		iconLabel.Show()
		iconLabel.SetColor( 255, 255, 255, 0 )
		iconLabel.FadeOverTime( 255, 0.15, INTERPOLATOR_ACCEL )
		local text = announcement.GetIconText()
		iconLabel.SetText( text[0], text[1], text[2], text[3], text[4], text[5] )
	}
	else
	{
		iconLabel.Hide()
	}

	if ( announcement.GetLeftIcon() )
	{
		leftIcon.Show()
		leftIcon.SetColor( 255, 255, 255, 0 )
		leftIcon.FadeOverTime( 255, 0.15, INTERPOLATOR_ACCEL )
		leftIcon.SetImage( announcement.GetLeftIcon() )

		local text = announcement.GetLeftText()
		leftText.Show()
		leftText.SetColor( 255, 255, 255, 0 )
		leftText.SetText( text[0], text[1], text[2], text[3], text[4], text[5] )
		leftText.FadeOverTime( 255, 0.15, INTERPOLATOR_ACCEL )
	}
	else
	{
		leftIcon.Hide()
		leftText.Hide()
	}

	if ( announcement.GetRightIcon() )
	{
		rightIcon.Show()
		rightIcon.SetColor( 255, 255, 255, 0 )
		rightIcon.FadeOverTime( 255, 0.15, INTERPOLATOR_ACCEL )
		rightIcon.SetImage( announcement.GetRightIcon() )

		local text = announcement.GetRightText()
		rightText.Show()
		rightText.SetColor( 255, 255, 255, 0 )
		rightText.SetText( text[0], text[1], text[2], text[3], text[4], text[5] )
		rightText.FadeOverTime( 255, 0.15, INTERPOLATOR_ACCEL )
	}
	else
	{
		rightIcon.Hide()
		rightText.Hide()
	}

	local size = text.GetSize()

	if ( announcement.GetScanImage() )
		scan.SetImage( announcement.GetScanImage() )
	else
		scan.SetImage( "HUD/flare_announcement" ) // default blue

	scan.Show()
	scan.ReturnToBasePos()
	scan.SetBaseSize( size[0], size[1] )
	scan.SetSize( 0, 0 )
	scan.SetColor( 255, 255, 255, 0 )
	scan.FadeOverTime( 255, 0.5, INTERPOLATOR_ACCEL )
	scan.ScaleOverTime( 2.0, 3.0, 0.25, INTERPOLATOR_ACCEL )
	scan.OffsetOverTime( size[0] * 0.2, 0.0, 0.25, INTERPOLATOR_ACCEL )
	wait 0.25

	duration -= 0.25
	scan.ScaleOverTime( 0.75, 1.5, 0.25, INTERPOLATOR_DEACCEL )
	scan.ColorOverTime( 64, 64, 64, 64, 0.5, INTERPOLATOR_LINEAR )
	scan.OffsetOverTime( -size[0] * 0.3, 0, duration, INTERPOLATOR_DEACCEL )
	wait 0.25
	duration -= 0.25
	text.RunAnimationCommand( "FgColor", 0, duration, 0.5, INTERPOLATOR_FLICKER, 0.15 )
	textBG.RunAnimationCommand( "FgColor", 0, duration, 0.5, INTERPOLATOR_FLICKER, 0.15 )
	subtext.RunAnimationCommand( "FgColor", 0, duration, 0.5, INTERPOLATOR_FLICKER, 0.15 )
	subtext2.RunAnimationCommand( "FgColor", 0, duration, 0.5, INTERPOLATOR_FLICKER, 0.15 )
	subtext2Large.RunAnimationCommand( "FgColor", 0, duration, 0.5, INTERPOLATOR_FLICKER, 0.15 )
	subtext2LargeBG.RunAnimationCommand( "FgColor", 0, duration, 0.5, INTERPOLATOR_FLICKER, 0.15 )
	leftIcon.RunAnimationCommand( "FgColor", 0, duration, 0.5, INTERPOLATOR_FLICKER, 0.15 )
	leftText.RunAnimationCommand( "FgColor", 0, duration, 0.5, INTERPOLATOR_FLICKER, 0.15 )
	rightIcon.RunAnimationCommand( "FgColor", 0, duration, 0.5, INTERPOLATOR_FLICKER, 0.15 )
	rightText.RunAnimationCommand( "FgColor", 0, duration, 0.5, INTERPOLATOR_FLICKER, 0.15 )

	if ( announcement.GetIcon() )
		icon.RunAnimationCommand( "FgColor", 0, duration, 0.5, INTERPOLATOR_FLICKER, 0.15 )

	if ( announcement.GetIconText()[0] != "" )
		iconLabel.RunAnimationCommand( "FgColor", 0, duration, 0.5, INTERPOLATOR_FLICKER, 0.15 )

	wait 0.25
	duration -= 0.25

	scan.ColorOverTime( 255, 255, 255, 255, duration, INTERPOLATOR_ACCEL )
	wait duration - 0.75

	local moveDest = announcement.moveDest
	if ( moveDest != null )
	{
		local width = level.safeArea.GetWidth()
		local height = level.safeArea.GetHeight()
		local pos = icon.GetPos()
		pos[0] += width * moveDest.safeAreaOffest_x
		pos[1] += height * moveDest.safeAreaOffest_y

		icon.MoveOverTime( pos[0], pos[1], moveDest.time, moveDest.interp )
		if ( moveDest.doFadeOut )
			icon.FadeOverTime( 0, moveDest.time, moveDest.interp )
	}

	scan.FadeOverTime( 0, 1.5, INTERPOLATOR_ACCEL )
	scan.OffsetOverTime( -size[0], 0, 0.75, INTERPOLATOR_ACCEL )
	scan.ScaleOverTime( 0.0, 0.0, 0.75, INTERPOLATOR_ACCEL )

	wait 1.35

	package.finished = true

	local baseY = vgui.s.eventNotification.GetBaseY()
	if ( announcement.GetIcon() )
		notificationMoveTime = 1.0  //( Move downwards slower than moving upwards)

	vgui.s.eventNotification.MoveOverTime( 0, baseY, notificationMoveTime, INTERPOLATOR_DEACCEL )
}


class CAnnouncement
{
	messageText = null
	subText = null
	subText2 = null
	subtext2Large = null
	titleColor = null
	hideOnDeath = null
	duration = null
	purge = null
	optionalTextArgs = null
	optionalSubTextArgs = null
	soundAlias = null
	priority = null

	scanImage = null
	icon = null
	iconText = null

	leftIcon = null
	rightIcon = null
	leftText = null
	rightText = null

	subText2AndIconDelay = null
	optionalFunc = null
	cockpitFX = null
	moveDest = null

	constructor( messageText )
	{
		this.messageText = messageText
		this.subText = ""
		this.subText2 = ["", null, null, null, null, null]
		this.subtext2Large = ["", null, null, null, null, null]
		this.leftText = ["", null, null, null, null, null]
		this.rightText = ["", null, null, null, null, null]
		this.iconText = ["", null, null, null, null, null]
		this.titleColor = [255, 255, 255]
		this.hideOnDeath = true
		this.duration = 3.0
		this.purge = false
		this.optionalTextArgs = [null, null, null, null, null]      // SetText() has 5 optional args, so let's match it
		this.optionalSubTextArgs = [null, null, null, null, null]   // SetText() has 5 optional args, so let's match it
		this.priority = 0
		this.icon = null
		this.subText2AndIconDelay = 0.0
		this.optionalFunc = null
		this.cockpitFX = null
		this.moveDest = null
	}

	function SetOptionalFunc( func )
	{
		this.optionalFunc = func
	}

	function SetCockpitFX( fx )
	{
		this.cockpitFX = fx
	}

	function SetMoveDest( safeAreaOffest_x, safeAreaOffest_y, time, interp )
	{
		this.moveDest = { safeAreaOffest_x = safeAreaOffest_x, safeAreaOffest_y = safeAreaOffest_y, time = time, interp = interp, doFadeOut = false }
	}

	function SetMoveDestFadeOut( safeAreaOffest_x, safeAreaOffest_y, time, interp )
	{
		this.moveDest = { safeAreaOffest_x = safeAreaOffest_x, safeAreaOffest_y = safeAreaOffest_y, time = time, interp = interp, doFadeOut = true }
	}

	function GetMoveDest()
	{
		return this.moveDest
	}

	function GetOptionalFunc()
	{
		return this.optionalFunc
	}

	function GetCockpitFX()
	{
		return this.cockpitFX
	}

	function SetPurge( state )
	{
		purge = state
	}

	function GetPurge()
	{
		return purge
	}

	function SetPriority( priority )
	{
		this.priority = priority
	}

	function GetPriority()
	{
		return this.priority
	}

	function SetMessageText( messageText )
	{
		Assert( type( messageText ) == "string" )
		this.messageText = messageText
	}

	function SetSubText( subText )
	{
		Assert( type( subText ) == "string" )
		this.subText = subText
	}

	function SetSubText2( ... )
	{
		Assert( vargc >= 1 )
		Assert( type( vargv[0] ) == "string", type( vargv[0] ) )
		this.subText2 = ["", null, null, null, null, null]
		for ( local i = 0; i < vargc && i < this.subText2.len(); i++ )
		{
			this.subText2[i] = vargv[i]
		}
	}

	function SetSubText2Large( ... )
	{
		Assert( vargc >= 1 )
		Assert( type( vargv[0] ) == "string", type( vargv[0] ) )
		this.subtext2Large = ["", null, null, null, null, null]
		for ( local i = 0; i < vargc && i < this.subtext2Large.len(); i++ )
		{
			this.subtext2Large[i] = vargv[i]
		}
	}

	function SetTitleColor( titleColor )
	{
		Assert( type( titleColor ) == "array" )
		Assert( titleColor.len() == 3 )
		this.titleColor = titleColor
	}

	function SetHideOnDeath( state )
	{
		Assert( type( state ) == "bool" )
		this.hideOnDeath = state
	}

	function SetDuration( duration )
	{
		Assert( type( duration ) == "integer" || type( duration ) == "float" )
		this.duration = max( duration, 3.0 )
	}

	function SetSoundAlias( alias )
	{
		this.soundAlias = alias
	}

	function SetOptionalTextArgsArray( args )
	{
		Assert( type( args ) == "array" )

		// Set these to null just in case someone passes in an array with less than 5 args
		for( local i = 0; i < optionalTextArgs.len(); i++ )
			this.optionalTextArgs[ i ] = null

		for( local i = 0; i < args.len(); i++ )
			this.optionalTextArgs[ i ] = args[ i ]
	}

	function SetOptionalSubTextArgsArray( args )
	{
		Assert( type( args ) == "array" )

		// Set these to null just in case someone passes in an array with less than 5 args
		for( local i = 0; i < optionalSubTextArgs.len(); i++ )
			this.optionalSubTextArgs[ i ] = null

		for( local i = 0; i < args.len(); i++ )
			this.optionalSubTextArgs[ i ] = args[ i ]
	}

	function SetLeftText( ... )
	{
		Assert( vargc >= 1 )
		Assert( type( vargv[0] ) == "string", type( vargv[0] ) )
		leftText = [null, null, null, null, null, null]
		for ( local i = 0; i< vargc; i++ )
		{
			leftText[i] = vargv[i]
		}
	}

	function SetRightText( ... )
	{
		Assert( vargc >= 1 )
		Assert( type( vargv[0] ) == "string", type( vargv[0] ) )
		rightText = [null, null, null, null, null, null]
		for ( local i = 0; i< vargc; i++ )
		{
			rightText[i] = vargv[i]
		}
	}

	function SetIconText( ... )
	{
		Assert( vargc >= 1 )
		Assert( type( vargv[0] ) == "string", type( vargv[0] ) )
		rightText = [null, null, null, null, null, null]
		for ( local i = 0; i< vargc; i++ )
		{
			iconText[i] = vargv[i]
		}
	}

	function SetLeftIcon( image )
	{
		Assert( type( image ) == "string" )
		this.leftIcon = image
	}

	function SetRightIcon( image )
	{
		Assert( type( image ) == "string" )
		this.rightIcon = image
	}

	function SetScanImage( image )
	{
		Assert( type( image ) == "string" )
		this.scanImage = image
	}

	function SetIcon( image )
	{
		Assert( type( image ) == "string" )
		this.icon = image
	}

	function SetSubText2AndIconDelay( delay )
	{
		Assert( type( delay ) == "integer" || type( delay ) == "float" )
		this.subText2AndIconDelay = delay
	}

	function GetMessageText()
	{
		return messageText
	}

	function GetOptionalTextArgs()
	{
		return optionalTextArgs
	}

	function GetOptionalSubTextArgs()
	{
		return optionalSubTextArgs
	}

	function GetSubText()
	{
		return subText
	}

	function GetSubText2()
	{
		return subText2
	}

	function GetSubText2Large()
	{
		return subtext2Large
	}

	function GetSoundAlias()
	{
		return soundAlias
	}

	function GetTitleColor()
	{
		return titleColor
	}

	function GetHideOnDeath()
	{
		return hideOnDeath
	}

	function GetDuration()
	{
		return duration
	}

	function GetLeftText()
	{
		return leftText
	}

	function GetRightText()
	{
		return rightText
	}

	function GetLeftIcon()
	{
		return leftIcon
	}

	function GetRightIcon()
	{
		return rightIcon
	}

	function GetScanImage()
	{
		return scanImage
	}

	function GetIcon()
	{
		return icon
	}

	function GetIconText()
	{
		return iconText
	}

	function GetSubText2AndIconDelay()
	{
		return subText2AndIconDelay
	}
}

class CNotAVGUI
{
	s = null
	panel = null

	constructor( panelHandle = null )
	{
		s = {}
		panel = panelHandle

	}

	function GetPanel()
	{
		return panel
	}

	function EndSignal( signalName )
	{
		::EndSignal( this, signalName )
	}
}

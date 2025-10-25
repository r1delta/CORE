

function GetCurrentPlaylistVarFloat( val, useVal )
{
	local result = GetCurrentPlaylistVarOrUseValue( val, useVal + "" )
	if ( result == null || result == "" )
		return 0

	return result.tofloat()
}

/* Assert is now in code!
function Assert( expr, msg = "", offset = 0 )
{
	if ( expr )
		return;

	// Don't change this header without also changing the error-reporting code that depends on it:
	local messageHeader = "[" + Time() + "] Message  : "

	throw ("\n\n    SCRIPT ASSERTION FAILED\n    " + messageHeader + msg + "\n    File     : " + getstackinfos(2+offset)["src"] + " [" + getstackinfos(2+offset)["line"] + "]\n    Function : " + getstackinfos(2+offset)["func"] + "()\n\n")
}
*/

function PlayerMustRevive( player )
{
	return Flag( "PlayersMustRevive" )
}

function SetSkinForTeam( entity, team )
{
	if ( team == TEAM_IMC )
		entity.SetSkin( 0 )
	else if( team == TEAM_MILITIA )
		entity.SetSkin( 1 )
}

function TableDump( table, depth = 0 )
{
	if ( depth > 4 )
		return

	foreach ( k, v in table )
	{
		printl( "Key: " + k + " Value: " + v )
		if ( type( v ) == "table" && depth )
			TableDump( v, depth + 1 )
	}
}

function GetVortexWeapon( player )
{
	for ( local weaponIndex = 0; weaponIndex < 2; weaponIndex++ )
	{
		local weapon = player.GetOffhandWeapon( weaponIndex )
		if ( !IsValid( weapon ) )
			continue
		if ( weapon.GetClassname() != "mp_titanweapon_vortex_shield" )
			continue
		return weapon
	}
}

function GetClosest( array, origin, maxdist = null )
{
	Assert( typeof array == "array" )
	Assert( array.len() > 0, "Empty array!" )

	local ent = array[ 0 ]
	local distSqr = ( ent.GetOrigin() - origin ).LengthSqr()

	local newEnt
	local newDistSqr
	for ( local i = 1; i < array.len(); i++ )
	{
		newEnt = array[ i ]
		newDistSqr = ( newEnt.GetOrigin() - origin ).LengthSqr()

		if ( newDistSqr < distSqr )
		{
			ent = newEnt
			distSqr = newDistSqr
		}
	}

	if ( maxdist )
	{
		maxdist = maxdist * maxdist

		if ( distSqr > maxdist )
			return null
	}

	return ent
}

function GetClosest2D( array, origin, maxdist = null )
{
	Assert( typeof array == "array" )
	Assert( array.len() > 0, "Empty array!" )

	local ent = array[ 0 ]
	local distSqr = ( ent.GetOrigin() - origin ).Length2DSqr()

	local newEnt
	local newDistSqr
	for ( local i = 1; i < array.len(); i++ )
	{
		newEnt = array[ i ]
		newDistSqr = ( newEnt.GetOrigin() - origin ).Length2DSqr()

		if ( newDistSqr < distSqr )
		{
			ent = newEnt
			distSqr = newDistSqr
		}
	}

	if ( maxdist )
	{
		maxdist = maxdist * maxdist

		if ( distSqr > maxdist )
			return null
	}

	return ent
}

function GameModeHasCapturePoints()
{
	switch ( GAMETYPE )
	{
		case CAPTURE_POINT:
		case COOPERATIVE:
		case UPLINK:
			return true
	}
	return false
}


function GetFarthest( array, origin )
{
	Assert( typeof array == "array" )
	Assert( array.len() > 0, "Empty array!" )

	local ent = array[ 0 ]
	local distSqr = ( ent.GetOrigin() - origin ).LengthSqr()

	local newEnt
	local newDistSqr
	for ( local i = 1; i < array.len(); i++ )
	{
		newEnt = array[ i ]
		newDistSqr = ( newEnt.GetOrigin() - origin ).LengthSqr()

		if ( newDistSqr > distSqr )
		{
			ent = newEnt
			distSqr = newDistSqr
		}
	}

	return ent
}

function GetClosestIndex( array, origin )
{
	Assert( typeof array == "array" )
	Assert( array.len() > 0 )

	local index = 0
	local distSqr = ( array[ index ].GetOrigin() - origin ).LengthSqr()

	local newEnt
	local newDistSqr
	for ( local i = 1; i < array.len(); i++ )
	{
		newEnt = array[ i ]
		newDistSqr = ( newEnt.GetOrigin() - origin ).LengthSqr()

		if ( newDistSqr < distSqr )
		{
			index = i
			distSqr = newDistSqr
		}
	}

	return index
}

// nothing in the game uses the format "table.r/g/b/a"... wtf is the point of this function
function StringToColors( colorString, delimiter = " " )
{
	PerfStart( PerfIndexShared.StringToColors + SharedPerfIndexStart )
	local tokens = split( colorString, delimiter )

	Assert( tokens.len() >= 3 )

	local table = {}
	table.r <- tokens[0].tointeger()
	table.g <- tokens[1].tointeger()
	table.b <- tokens[2].tointeger()

	if ( tokens.len() == 4 )
		table.a <- tokens[3].tointeger()
	else
		table.a <- 255

	PerfEnd( PerfIndexShared.StringToColors + SharedPerfIndexStart )
	return table
}


function ColorStringToArray( colorString )
{
	local tokens = split( colorString, " " )

	Assert( tokens.len() >= 3 && tokens.len() <= 4 )

	local colorArray = []
	foreach ( token in tokens )
		colorArray.append( token.tointeger() )

	return colorArray
}

// Evaluate a generic order (vargc -1 ) polynomial
// e.g. to evaluate (Ax + B), call EvaluatePolynomial(x, A, B)
// Note that EvaluatePolynomial(x) returns 0 and
// EvaluatePolynomial(x, A) returns A, which are technically correct
// but perhaps not what you expect
function EvaluatePolynomial( x, ... )
{
	local sum = 0
	for( local i = 0; i < vargc - 1; ++i )
	{
		sum += vargv[ i ] * pow( x, vargc - 1 - i )
	}
	if ( vargc >= 1 )
	{
		sum += vargv[ vargc - 1 ]
	}
	return sum
}


// graphing function.
// If you want to map a variable that can be 0-1 to a range of 300-500,
// the function would be:
//
//	Graph( variable, 0, 1, 300, 500 )
//

/*
// Moved to code
function Graph( val, A, B, C, D )
{
	if ( A == B )
		return fsel( ( val - B ).tofloat(), D, C )

	local cVal = (val - A).tofloat() / (B - A).tofloat()

	return C + (D - C) * cVal
}

function GraphCapped( val, A, B, C, D )
{
	if ( A == B )
		return fsel( ( val - B ).tofloat(), D, C )

	local cVal = (val - A).tofloat() / (B - A).tofloat()

	cVal = clamp( cVal, 0.0, 1.0 )
	return C + (D - C) * cVal
}
*/

function Merge( progress, start, end )
{
	return end * ( 1.0 - progress ) + start * progress
}


function WrapVector( vector )
{
	// range -180 -- 180
	vector.x = ( ( vector.x + 540 ) % 360 ) - 180
	vector.y = ( ( vector.y + 540 ) % 360 ) - 180
	vector.z = ( ( vector.z + 540 ) % 360 ) - 180
	return vector
}

/*
function CubicHermite( time, start, end, move1, move2 )
{
   local time2 = ( time * time )
   local time3 = ( time2 * time )
   return ( 2 * time3 - 3 * time2 + 1 ) * start +
			( -2 * time3 + 3 * time2 ) * end +
			( time3 - 2 * time2 + time ) * move1 +
			( time3 - time2 ) * move2
}

function Interpolate( startTime, moveTime, easeIn = 0, easeOut = 0 )
{
	if ( Time() <= startTime )
	{
		return 0
	}

	if ( Time() > startTime + moveTime )
	{
		return 1
	}

	startTime = startTime.tofloat()
	moveTime = moveTime.tofloat()
	easeIn = easeIn.tofloat()
	easeOut = easeOut.tofloat()

	if ( easeOut == moveTime )
		easeOut *= 0.99
	if ( easeIn == moveTime )
		easeIn *= 0.99

	moveTime -= ( easeIn + easeOut )
	Assert( moveTime > 0, "EaseIn + easeOut exceeded total movetime!" )

	local t = Time() - startTime

    local x1, x2, x3
	local v
	local x = 1

    v = x / ( easeIn / 2 + moveTime + easeOut / 2 )
    x1 = v * easeIn / 2
    x2 = v * moveTime
    x3 = v * easeOut / 2

	local result
	if ( t <= easeIn )
	{
		result = CubicHermite( t / easeIn, 0, x1, 0, x2 / moveTime * easeIn )
	}
	else
	{
		if ( t <= easeIn + moveTime )
		{
			result = x1 + x2 * ( t - easeIn ) / moveTime
		}
		else
		{
			result = CubicHermite( ( t - easeIn - moveTime ) / easeOut, x1 + x2, x, x2 / moveTime * easeOut, 0 )
		}
	}

	if ( result < 0 )
		result = 0
	else
	if ( result > 1 )
		result = 1

	return result
}
*/

function SortAlphabetize( a, b )
{
	if ( a > b )
		return 1

	if ( a < b )
		return -1

	return 0
}

function WaitForever()
{
	level.ent.WaitSignal( "forever" )
}

function CopyComplexRecursive( src, dest )
{
	foreach ( k, v in src )
	{
		if ( type( v ) == "table" )
		{
			if ( type( dest ) == "array" )
				dest[k] = {}
			else
				dest[k] <- {}

			CopyComplexRecursive( v, dest[k] )
		}
		else if ( type( v ) == "array" )
		{
			if ( type( dest ) == "array" )
				dest[k] = []
			else
				dest[k] <- []

			dest[k].resize( v.len() )

			CopyComplexRecursive( v, dest[k] )
		}
		else
		{
			if ( type( dest ) == "array" )
				dest[k] = v
			else
				dest[k] <- v
		}
	}
}

function DrawArrow( origin, angles = null, time = 5, scale = 50, rgb = null )
{
	if ( angles == null )
		angles = Vector(0,0,0)
	local forward = angles.AnglesToForward()
	local right = angles.AnglesToRight()
	local up = angles.AnglesToUp()

	if ( rgb != null )
	{
		DebugDrawLine( origin, origin + forward * scale, 	rgb.r,rgb.g,rgb.b, true, time )
		DebugDrawLine( origin, origin + up * scale, 		rgb.r,rgb.g,rgb.b, true, time )
		DebugDrawLine( origin, origin + right * scale, 		rgb.r,rgb.g,rgb.b, true, time )
	}
	else
	{
		DebugDrawLine( origin, origin + forward * scale, 	0, 255, 0, true, time )
		DebugDrawLine( origin, origin + up * scale, 		255, 0, 0, true, time )
		DebugDrawLine( origin, origin + right * scale, 		0, 0, 255, true, time )
	}
}

function ShouldDoReplay( player, attacker, replayTime )
{
	local minimumReplayTime = replayTime * 2

	if ( !IsValid( player ) )
		return false

	if ( !IsValid( attacker ) )
		return false

	if ( attacker == player )
		return false

	if ( !( "connectTime" in player ) || !( "connectTime" in attacker ) )
		return false

	if ( Time() - player.connectTime <= minimumReplayTime || Time() - attacker.connectTime <= minimumReplayTime )
		return false

	if ( level.nv.replayDisabled )
		return false

	return ( player != attacker && AttackerShouldTriggerReplay( attacker ) && !player.IsBot() )
}

// Don't let things like killbrushes show replays
function AttackerShouldTriggerReplay( attacker )
{
	if ( !IsValid( attacker ) )
		return false

	if ( attacker.IsPlayer() )
		return true

	if ( attacker.IsNPC() )
		return true

	return false
}

function RandomVec( range )
{
	// could rewrite so it doesnt make a box of random.
	local vec
	vec = Vector( 0, 0, 0 )
	vec.x = RandomFloat( -range, range )
	vec.y = RandomFloat( -range, range )
	vec.z = RandomFloat( -range, range )
	return vec
}

function ArrayValuesToTableKeys( arr )
{
	Assert( type( arr ) == "array", "Not an array" )

	local resultTable = {}
	for ( local i = 0; i < arr.len(); ++ i)
	{
		resultTable[ arr[ i ] ] <- 1
	}

	return resultTable
}

function ArrayValuesToTableValues( arr )
{
	Assert( type( arr ) == "array", "Not an array" )

	local resultTable = {}
	for ( local i = 0; i < arr.len(); ++ i)
	{
		resultTable[ i ] <- arr[ i ]
	}

	return resultTable
}

function TableKeysToArray( tab )
{
	Assert( type( tab ) == "table", "Not a table" )

	local resultArray = []
	resultArray.resize( tab.len() )
	local currentArrayIndex = 0
	foreach( key, val in tab )
	{
		resultArray[ currentArrayIndex ] = key
		++currentArrayIndex
	}

	return resultArray
}

function TableValuesToArray( tab )
{
	Assert( type( tab ) == "table", "Not a table" )

	local resultArray = []
	resultArray.resize( tab.len() )
	local currentArrayIndex = 0
	foreach( key, val in tab )
	{
		resultArray[ currentArrayIndex ] = val
		++currentArrayIndex
	}

	return resultArray
}

function IsTableEmpty( table )
{
	foreach ( _ in table )
	{
		return false
	}

	return true
}

function TableRandom( table )
{
	Assert( type( table ) == "table", "Not a table" )

	local array = []

	foreach ( entry, contents in table )
	{
		array.append( contents )
	}

	return Random( array )
}




// Return a random entry from an array, weighted based on how close to index 0 it is
function RandomWeighted( array )
{
	Assert( type( array ) == "array", "Not an array" )

	local count = array.len()
	if ( count == 0 )
		return null

	return array[ RandomWeightedIndex( array ) ]
}

function RandomWeightedIndex( array )
{
	Assert( type( array ) == "array", "Not an array" )
	local count = array.len()
	if ( count == 0 )
		return null

	local sum = ( count * ( count + 1 ) ) / 2.0		// ( n * ( n + 1 ) ) / 2
	local randInt = RandomInt( 0, sum )
	for( local i = 0 ; i < count ; i++ )
	{
		local rangeForThisIndex = count - i
		if ( randInt < rangeForThisIndex )
			return i
		randInt -= rangeForThisIndex
	}

	Assert( 0 )
}

function ArrayShuffleWeighted( array )
{
	Assert( type( array ) == "array", "Not an array" )
	local count = array.len()
	if ( count <= 1 )
		return array

	local sortedArray = []
	local rand
	local count = array.len()
	for ( local i = 0 ; i < count ; i++ )
	{
		rand = RandomWeightedIndex( array )
		sortedArray.append( array[ rand ] )
		array.remove( rand )
	}
	return sortedArray
}

function IsValid_ThisFrame( entity )
{
	if ( entity == null )
		return false

	return entity.IsValidInternal()
}



function ClassicMP_CreateCallbackTable( func )
{
	local callbackInfo = {}
	callbackInfo.func 	<- func
	callbackInfo.scope 	<- this

	return callbackInfo
}

/* IsValid is now in code!
function IsValid( entity )
{
	if ( entity == null )
		return false

	if ( !entity.IsValidInternal() )
		return false
	return !entity.IsMarkedForDeletion()
}
*/

function VectorCopy( vec, target = null )
{
	if ( target )
	{
		target.x = vec.x
		target.y = vec.y
		target.z = vec.z
		return
	}

	Assert( typeof vec == "Vector" )
	local newVector = Vector( vec.x, vec.y, vec.z )

	return newVector
}

function IsAlive( ent )
{
	if ( ent == null )
		return false
	if ( !ent.IsValidInternal() )
		return false

	return ent.IsEntAlive()
}
RegisterFunctionDesc( "IsAlive", "Returns true if the given ent is not null, and is alive." )

function vduon()
{
	PlayConversationToAll( "TitanReplacement" )
}

function playconvtest( conv )
{
	local player = GetPlayerArray()[0]
	local guys = GetAllSoldiers()
	if ( !guys.len() )
	{
		printt( "No AI!!" )
		return
	}
	local guy = GetClosest( guys, player.GetOrigin() )
	if ( conv in player.s.lastAIConversationTime )
		delete player.s.lastAIConversationTime[ conv ]

	printt( "Play ai conversation " + conv )
	PlaySquadConversationToAll( conv, guy )
}

function FighterExplodes( ship )
{
	local origin = ship.GetOrigin()
	local angles = ship.GetAngles()
	EmitSoundAtPosition( origin, "AngelCity_Scr_RedeyeWeaponExplos" )
	if ( IsServer() )
	{
		PlayFX( FX_HORNET_DEATH, origin )
	}
	else
	{
		local fxid = GetParticleSystemIndex( FX_HORNET_DEATH )
		StartParticleEffectInWorld( fxid, origin, angles )
	}

	//angles.x = -60
	//angles.z = 0
	//local forward = angles.AnglesToForward()
	//forward.Norm()
}

function PositionOffsetFromEnt( ent, offsetX, offsetY, offsetZ )
{
	local angles = ent.GetAngles()
	local origin = ent.GetOrigin()
	origin += angles.AnglesToForward() * offsetX
	origin += angles.AnglesToRight() * offsetY
	origin += angles.AnglesToUp() * offsetZ
	return origin
}

function PositionOffsetFromOriginAngles( origin, angles, offsetX, offsetY, offsetZ )
{
	origin += angles.AnglesToForward() * offsetX
	origin += angles.AnglesToRight() * offsetY
	origin += angles.AnglesToUp() * offsetZ
	return origin
}


function IsMenuLevel()
{
	local mapName = GetMapName()

	if ( mapName == "mp_prelobby" || mapName == "mp_lobby" )
		return true

	return false
}

function CreatePilotTraceBounds()
{
	// checked when a pilot spawns
	level.traceMins[ "pilot" ] <- Vector(-16.000000, -16.000000, 0.000000)
	level.traceMaxs[ "pilot" ] <- Vector(16.000000, 16.000000, 72.000000)
}

function Dump( package, depth = 0 )
{
	if ( depth > 6 )
		return

	foreach ( k, v in package )
	{
		for( local i = 0; i < depth; i++ )
			print( "    ")

		if ( IsTable( package ) )
			printl( "Key: " + k + " Value: " + v )
		if ( IsArray( package ) )
			printl( "Index: " + k + " Value: " + v )

		if ( IsTable( v ) || IsArray( v ) )
			Dump( v, depth + 1 )
	}
}

function GetOtherTeam( guy )
{
	local team
	if ( IsFFABased() )
		return 2

	if ( typeof guy == "integer" )
		team = guy
	else
		team = guy.GetTeam()



	if ( team == 2 )
		return 3

	return 2
}

function VectorDot_PlayerToOrigin( player, targetOrigin )
{
	local playerEyePosition = player.EyePosition()
	local vecToEnt = ( targetOrigin - playerEyePosition )
	vecToEnt.Norm()

	// GetViewVector() only works on the player
	local dotVal = vecToEnt.Dot( player.GetViewVector() )
	return dotVal
}

function VectorDot_DirectionToOrigin( player, direction, targetOrigin )
{
	local playerEyePosition = player.EyePosition()
	local vecToEnt = ( targetOrigin - playerEyePosition )
	vecToEnt.Norm()

	// GetViewVector() only works on the player
	local dotVal = vecToEnt.Dot( direction )
	return dotVal
}

function WaitUntilWithinDistance( player, titan, dist )
{
	local distSqr = dist * dist
	for ( ;; )
	{
		if ( !IsAlive( titan ) )
			return

		if ( IsAlive( player ) )
		{
			if ( DistanceSqr( player.GetOrigin(), titan.GetOrigin() ) <= distSqr )
				return
		}
		wait 0.1
	}
}

function WaitUntilBeyondDistance( player, titan, dist )
{
	local distSqr = dist * dist
	for ( ;; )
	{
		if ( !IsAlive( titan ) )
			return

		if ( IsAlive( player ) )
		{
			if ( DistanceSqr( player.GetOrigin(), titan.GetOrigin() ) > distSqr )
				return
		}
		wait 0.1
	}
}

function IsModelViewer()
{
	return GetMapName() == "model_viewer"
}

if ( !IsMultiplayer() )
{
	function GetCurrentPlaylistVar( var )
	{
		return null
	}

	function GetCurrentPlaylistVarInt( val, useVal )
	{
		return useVal
	}

	function GetCurrentPlaylistVarFloat( val, useVal )
	{
		return useVal
	}

}

function PlayerEnhancement()
{
	return true
}



//----------------------//
//	Tweening functions	//
//	t = current time	//
//	b = start value		//
//	c = change in value	//
//	d = duration		//
//----------------------//

// simple linear tweening - no easing, no acceleration
function Tween_Linear( t, b, c, d )
{
	return c*t/d + b
}

// quadratic easing out - decelerating to zero velocity
function Tween_QuadEaseOut( t, b, c, d )
{
	t /= d
	return -c * t*(t-2) + b
}

// exponential easing out - decelerating to zero velocity
function Tween_ExpoEaseOut( t, b, c, d )
{
	return c * ( -pow( 2, -10 * t/d ) + 1 ) + b
}

function Tween_ExpoEaseIn( t, b, c, d )
{
	return c * pow( 2, 10 * ( t/d - 1 ) ) + b;
}

function CoinFlip()
{
	return RandomInt( 0, 2 )
}

function LegalOrigin( origin )
{
	if ( fabs( origin.x ) > 16000 )
		return false
	if ( fabs( origin.y ) > 16000 )
		return false
	if ( fabs( origin.z ) > 16000 )
		return false
	return true
}

function AnglesOnSurface( surfaceNormal, playerVelocity )
{
	playerVelocity.Norm()
	local right = playerVelocity.Cross( surfaceNormal )
	local forward = surfaceNormal.Cross( right )
	local angles = forward.GetAngles()
	angles.z = ( atan2( right.z, surfaceNormal.z ) * -180 ) / PI

	return angles
}

function ClampToWorldspace( origin )
{
	// temp solution for start positions that are outside the world bounds
	origin.x = clamp( origin.x, -16000, 16000 )
	origin.y = clamp( origin.y, -16000, 16000 )
	origin.z = clamp( origin.z, -16000, 16000 )
}

function UseReturnTrue( user, usee )
{
	return true
}

function ControlPanel_CanUseFunction( playerUser, controlPanel )
{
	// Does a simple cone FOV check from the screen to the player's eyes
	local maxAngleToAxisAllowedDegrees = 60

	local playerEyePos = playerUser.EyePosition()
	local attachmentIndex = controlPanel.LookupAttachment( "PANEL_SCREEN_MIDDLE" )

	Assert( attachmentIndex != 0 )
	local controlPanelScreenPosition = controlPanel.GetAttachmentOrigin( attachmentIndex )
	local controlPanelScreenAngles = controlPanel.GetAttachmentAngles( attachmentIndex )
	local controlPanelScreenForward = controlPanelScreenAngles.AnglesToForward()

	local screenToPlayerEyes = playerEyePos - controlPanelScreenPosition
	screenToPlayerEyes.Normalize()

	return screenToPlayerEyes.Dot( controlPanelScreenForward ) > deg_cos( maxAngleToAxisAllowedDegrees )
}

function ArrayRemoveInvalid( array )
{
	Assert( type( array ) == "array" )

	for ( local i = 0; i < array.len(); )
	{
		if ( !IsValid( array[ i ] ) )
		{
			array.remove( i )
		}
		else
		{
			//Increment i here instead of in the for loop declaration
			//because after a call to array.remove, array[i] will point to
			//the next element in the array yet to be examined.
			i++
		}
	}
}

function SkipCinematicStart() //Doesn't quite work as advertised for now.
{
	return IsTrainingLevel()
}

function SetIsTrainingLevel()
{
	level.isTrainingLevel <- GetMapName() == "mp_trainer" || GetMapName() == "mp_npe"
}

function IsFirstCampaignLevel()
{
	local levelname = GetMapName()
	if ( !levelname )
		return false

	return levelname == "mp_fracture"
}

function HasDamageStates( ent )
{
	if ( !IsValid( ent ) )
		return false
	return ( "damageStateInfo" in ent.s )
}

function HasHitData( ent )
{
	return ( "hasHitData" in ent.s && ent.s.hasHitData )
}

function IncludeTitanEmbark()
{
	IncludeFile( "_titan_embark" )
}

function GetFrontRightDots( baseEnt, relativeEnt, optionalTag = null )
{
	if ( optionalTag )
	{
		local attachIndex = baseEnt.LookupAttachment( optionalTag )
		local origin = baseEnt.GetAttachmentOrigin( attachIndex )
		local angles = baseEnt.GetAttachmentAngles( attachIndex )
		angles.x = 0
		angles.z = 0
		local forward = angles.AnglesToForward()
		local right = angles.AnglesToRight()

		local targetOrg = relativeEnt.GetOrigin()
		local vecToEnt = ( targetOrg - origin )
//		printt( "vecToEnt ", vecToEnt )
		vecToEnt.z = 0

		vecToEnt.Norm()


		local table = {}
		table.dotForward <- vecToEnt.Dot( forward )
		table.dotRight <- vecToEnt.Dot( right )

		// red: forward for incoming ent
		//DebugDrawLine( origin, origin + vecToEnt * 150, 255, 0, 0, true, 5 )

		// green: tag forward
		//DebugDrawLine( origin, origin + forward * 150, 0, 255, 0, true, 5 )

		// blue: tag right
		//DebugDrawLine( origin, origin + right * 150, 0, 0, 255, true, 5 )
		return table
	}

	local targetOrg = relativeEnt.GetOrigin()
	local origin = baseEnt.GetOrigin()
	local vecToEnt = ( targetOrg - origin )
	vecToEnt.Norm()

	local table = {}
	table.dotForward <- vecToEnt.Dot( baseEnt.GetForwardVector() )
	table.dotRight <- vecToEnt.Dot( baseEnt.GetRightVector() )
	return table
}

RegisterSignal( "devForcedWin" )

function ForceMatchEnd()
{
	local winner = TEAM_IMC
	if ( GameRules.GetTeamScore2( TEAM_MILITIA ) > GameRules.GetTeamScore2( TEAM_IMC ) )
		winner = TEAM_MILITIA

	if ( IsRoundBased() )
	{
		local roundLimit = GetRoundScoreLimit_FromPlaylist()
		GameRules.SetTeamScore2( winner, roundLimit )
	}

	if ( winner == TEAM_MILITIA )
		ForceMilitiaWin()
	else
		ForceIMCWin()
}

function ForceIMCWin()
{
	level.devForcedWin = true
	level.ent.Signal( "devForcedWin" )
	if ( IsRoundBased() )
	{
		SetWinner( TEAM_IMC )
		return
	}
	else
	{
		local scoreLimit = GetScoreLimit_FromPlaylist()
		GameScore.AddTeamScore( TEAM_IMC, scoreLimit )
		ForceTimeLimitDone()
	}
}

function ForceMilitiaWin()
{
	level.devForcedWin = true
	level.ent.Signal( "devForcedWin" )
	if ( IsRoundBased() )
	{
		SetWinner( TEAM_MILITIA )
		return
	}
	else
	{
		local scoreLimit = GetScoreLimit_FromPlaylist()
		GameScore.AddTeamScore( TEAM_MILITIA, scoreLimit )
		ForceTimeLimitDone()
	}
}

function ForceDraw()
{
	level.devForcedWin = true
	level.ent.Signal( "devForcedWin" )
	if ( !IsRoundBased() )
	{
		local scoreLimit =  GetScoreLimit_FromPlaylist()
		GameScore.SetTeamScore( TEAM_MILITIA, scoreLimit )
		GameScore.SetTeamScore( TEAM_IMC, scoreLimit )
	}

	ForceTimeLimitDone()
}

function ForceTimeLimitDone()
{
	level.devForcedWin = true
	level.ent.Signal( "devForcedWin" )
	ServerCommand( "mp_enabletimelimit 1" )
	ServerCommand( "mp_enablematchending 1" )
	if ( IsRoundBased() )
		GetRoundTimeLimit_ForGameMode = GetTimeLimit_ForGameModeGameOver
	else
		GetTimeLimit_ForGameMode = GetTimeLimit_ForGameModeGameOver
}

function GetTimeLimit_ForGameModeGameOver()
{
	return 0.1
}


function GetRoundScoreLimit_FromPlaylist()
{
	switch ( GAMETYPE )
	{
		case CAPTURE_POINT:
			return GetCurrentPlaylistVarInt( "CP_roundscorelimit", 10 )

		case ATTRITION:
			return GetCurrentPlaylistVarInt( "AT_roundscorelimit", 50 )

		case CAPTURE_THE_FLAG:
			return GetCurrentPlaylistVarInt( "CTF_roundscorelimit", 6 )

		case CAPTURE_THE_FLAG_PRO:
			return GetCurrentPlaylistVarInt( "CTFP_roundscorelimit", 6 )

		case HEIST:
			return GetCurrentPlaylistVarInt( "HEIST_roundscorelimit", 4 )

		case BIG_BROTHER:
			return GetCurrentPlaylistVarInt( "BB_roundscorelimit", 4 )

		case COOPERATIVE:
			return GetCurrentPlaylistVarInt( "COOP_roundscorelimit", COOP_RESTARTS )

		default:
			if ( !GameMode_IsDefined( GAMETYPE ) )
				return GetCurrentPlaylistVarInt( "TDM_roundscorelimit", 10 )
			else
				return GameMode_GetRoundScoreLimit( GAMETYPE )
	}
}


function GetScoreLimit_FromPlaylist()
{
	switch ( GAMETYPE )
	{
		case CAPTURE_POINT:
			return GetCurrentPlaylistVarInt( "CP_scorelimit", 10 )
			break

		case ATTRITION:
			return GetCurrentPlaylistVarInt( "AT_scorelimit", 50 )
			break

		case CAPTURE_THE_FLAG:
			return GetCurrentPlaylistVarInt( "CTF_scorelimit", 10 )
			break

		case PILOT_SKIRMISH:
			return GetCurrentPlaylistVarInt( "PS_scorelimit", 100 )

		case HEIST:
			return GetCurrentPlaylistVarInt( "HEIST_scorelimit", 0 )

		case BIG_BROTHER:
			return GetCurrentPlaylistVarInt( "BB_scorelimit", 0 )

		default:
			if ( !GameMode_IsDefined( GAMETYPE ) )
				return GetCurrentPlaylistVarInt( "TDM_scorelimit", 10 )
			else
				return GameMode_GetScoreLimit( GAMETYPE )
	}
}


function GetTimeLimit_ForGameMode()
{
	local timeLimit
	switch ( GAMETYPE )
	{
		case CAPTURE_POINT:
			timeLimit = GetCurrentPlaylistVarInt( "CP_timelimit", 10 )
			break

		case ATTRITION:
			timeLimit = GetCurrentPlaylistVarInt( "AT_timelimit", 10 )
			break

		case CAPTURE_THE_FLAG:
			timeLimit = GetCurrentPlaylistVarInt( "CTF_timelimit", 10 )
			break

		case PILOT_SKIRMISH:
			timeLimit = GetCurrentPlaylistVarInt( "PS_timelimit", 15 )
			break

		case HEIST:
			return GetCurrentPlaylistVarInt( "HEIST_timelimit", 6 )
			break

		case BIG_BROTHER:
			return GetCurrentPlaylistVarInt( "BB_timelimit", 6 )
			break

		case SCAVENGER:
			return GetCurrentPlaylistVarInt( "SCV_timelimit", 10 )
			break // no real need to break after a return, but eh...

		default:
			if ( !GameMode_IsDefined( GAMETYPE ) )
				return GetCurrentPlaylistVarInt( "TDM_timelimit", 10 )
			else
				return GameMode_GetTimeLimit( GAMETYPE )
	}

	if ( IsRoundBased() )
	{
		local scoreLimit = GetScoreLimit_FromPlaylist()
		if ( scoreLimit )
			timeLimit *= (scoreLimit * 2)
	}
	else if ( IsSwitchSidesBased() )
	{
		timeLimit *= 0.5
	}

	return timeLimit
}

function GetRoundTimeLimit_ForGameMode()
{
	local timeLimit
	switch ( GAMETYPE )
	{
		case BIG_BROTHER:
			timeLimit = GetCurrentPlaylistVarInt( "BB_roundtimelimit", 5 )
			break

		case HEIST:
			timeLimit = GetCurrentPlaylistVarInt( "HEIST_roundtimelimit", 5 )
			break

		default:
			if ( !GameMode_IsDefined( GAMETYPE ) )
				return GetCurrentPlaylistVarInt( "TDM_roundtimelimit", 10 )
			else
				return GameMode_GetRoundTimeLimit( GAMETYPE )
	}

	return timeLimit
}

function GetSuddenDeathTimeLimit_ForGameMode()
{
	switch ( GAMETYPE )
	{
		case CAPTURE_THE_FLAG:
			return GetCurrentPlaylistVarInt( "CTF_suddendeath_timelimit", 4 )

		case TEAM_DEATHMATCH:
			return GetCurrentPlaylistVarInt( "TDM_suddendeath_timelimit", 4 )

		default:
			return 4
	}
}

function GetAllPointsOnBezier( points, numSegments, debugDrawTime = null )
{
	Assert( points.len() >= 2 )
	Assert( numSegments > 0 )
	local curvePoints = []

	// Debug draw the points used for the curve
	if ( debugDrawTime != null )
	{
		for( local i = 0 ; i < points.len() - 1 ; i++ )
			DebugDrawLine( points[i], points[i + 1], 150, 150, 150, true, debugDrawTime )
	}

	for( local i = 0 ; i < numSegments ; i++ )
	{
		local t = ( i.tofloat() / ( numSegments.tofloat() - 1.0 ) ).tofloat()
		curvePoints.append( GetSinglePointOnBezier( points, t) )
	}

	return curvePoints
}

function GetSinglePointOnBezier( points, t )
{
	// evaluate a point on a bezier-curve. t goes from 0 to 1.0

	local numPoints = points.len()

	local lastPoints = clone points
	for(;;)
	{
		local newPoints = []
		for ( local i = 0 ; i < lastPoints.len() - 1 ; i++ )
			newPoints.append( lastPoints[i] + ( lastPoints[i+1] - lastPoints[i] ) * t )

		if ( newPoints.len() == 1 )
			return newPoints[0]

		lastPoints = newPoints
	}

	return dest
}

if ( !reloadingScripts && IsMultiplayer() )
{
	__GetCurrentPlaylistVar <- GetCurrentPlaylistVar
	function GetCurrentPlaylistVar( val, opVal = null )
	{
		if ( opVal == null )
			return __GetCurrentPlaylistVar( val )

		if ( IsClient() && !IsConnected() )
			return opVal

		return GetCurrentPlaylistVarOrUseValue( val, opVal )
	}

	__GetCurrentPlaylistVarOrUseValue <- GetCurrentPlaylistVarOrUseValue
	function GetCurrentPlaylistVarOrUseValue( val, opVal )
	{
		if ( typeof opVal != "string" )
		{
			opVal += ""
		}

		if ( IsClient() && !IsConnected() )
			return opVal

		return __GetCurrentPlaylistVarOrUseValue( val, opVal )
	}
}


function TitanCoreInUse( player )
{
	Assert( player.IsTitan() )

	if ( !IsAlive( player ) )
		return false

	return Time() < player.GetTitanSoul().GetCoreChargeExpireTime()
}



function AddCallback_Generic( levelVarName, callbackFunc, scope )
{
	Assert( levelVarName in level )
	Assert( type( this ) == "table", FunctionName() +  " can only be added on a table. " + type( this ) )

	local callbackInfo = {}
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- scope

	level[ levelVarName ].append( callbackInfo )
}


function GetTitanCoreTimeRemaining( player )
{
	if ( !player.IsTitan() )
		return null

	local soul = player.GetTitanSoul()

	if ( !soul )
		return null

	return soul.GetCoreChargeExpireTime() - Time()
}


function GetTitanCoreActiveTime( player )
{
	local coreDuration = TITAN_CORE_ACTIVE_TIME

	if ( PlayerHasPassive( player, PAS_MARATHON_CORE ) )
		coreDuration *= TITAN_CORE_MARATHON_CORE_MULTIPLIER

	return coreDuration

}


function GetTitanBuildTime( player )
{
	if ( IsClient() )
		return player.GetTitanBuildTime()

	if ( !player.titansBuilt )
		return GetCurrentPlaylistVarInt( "titan_build_time", 340 )

	return GetCurrentPlaylistVarInt( "titan_rebuild_time", 150 )
}


function ResetTitanBuildTime( player )
{
	if ( player.IsTitan() )
	{
		player.SetTitanBuildTime( GetCurrentPlaylistVarInt( "titan_core_build_time", TITAN_CORE_BUILD_TIME )  )
		return
	}

	if ( !player.titansBuilt )
		player.SetTitanBuildTime( GetCurrentPlaylistVarInt( "titan_build_time", 340 ) )
	else
		player.SetTitanBuildTime( GetCurrentPlaylistVarInt( "titan_rebuild_time", 150 ) )
}


function GetNuclearPayload( player )
{
	local payload = 0
	if ( PlayerHasPassive( player, PAS_NUCLEAR_CORE ) )
		payload += 2

	if ( PlayerHasPassive( player, PAS_BUILD_UP_NUCLEAR_CORE ) )
		payload += 1

	return payload

//	if ( TitanCoreInUse( player ) )
//		return true
//
//	if ( player.GetNextTitanRespawnAvailable() < 0 )
//		return false
//
//	if ( Time() >= player.GetNextTitanRespawnAvailable() )
//		return true
//
//	return false

}

function DrawLineForPoints( points, color, duration )
{
	Assert( points.len() >= 2 )
	for ( local i = 0 ; i < points.len() - 1 ; i++ )
		DebugDrawLine( points[i], points[i+1], color.r, color.g, color.b, true, duration )
}

function GetCloak( entity )
{
	return GetOffhand( entity, "mp_ability_cloak" )
}

function GetOffhand( entity, classname )
{
	local offhand = entity.GetOffhandWeapon( OFFHAND_LEFT )
	if ( IsValid( offhand ) && offhand.GetClassname() == classname )
		return offhand

	local offhand = entity.GetOffhandWeapon( OFFHAND_RIGHT )
	if ( IsValid( offhand ) && offhand.GetClassname() == classname )
		return offhand

	return null
}

function IsCloaked( entity )
{
	return entity.IsCloaked( true ) //pass true to ignore flicker time -
}

function TimeSpentInCurrentState()
{
	return Time() - level.nv.gameStateChangeTime
}

function DotToAngle( dot )
{
	local angle = acos( dot ) * 180 / PI
	return angle
}

function AngleToDot( angle )
{
	local dot = cos( angle * PI / 180 )
	return dot
}

function DebugDrawCircle( origin, angles, radius, r, g, b, time )
{
	local start 	= null
	local end 		= null
	local firstend 	= null
	local degrees 	= 22.5
	local pointsOnCircle = []

	for( local i = 0; i < 16; i++ )
	{
		local angles2 = angles.AnglesCompose( Vector( 0, degrees * i, 0 ) )
		local forward = angles2.AnglesToForward()
		end = origin + ( forward * radius )

		if( !start )
			firstend = VectorCopy( end )
		if( start )
			DebugDrawLine( start, end, r, g, b, true, time )

		pointsOnCircle.append( end )

		start = end
	}

	DebugDrawLine( end, firstend, r, g, b, true, time )
	return pointsOnCircle
}

function DebugDrawSphere( origin, radius, r, g, b, time )
{
	local degrees 	= 45

	for( local i = 0; i < 8; i++ )
	{
		DebugDrawCircle( origin, Vector( 0, 0, degrees * i ), radius, r, g, b, time )
		DebugDrawCircle( origin, Vector( degrees * i, 0, 0 ), radius, r, g, b, time )
	}
}

function DebugDrawCircleTillSignal( ent, signalName, origin, radius, r, g, b )
{
	EndSignal( ent, signalName )
	while(1)
	{
		thread DebugDrawCircle( origin, Vector( 0,0,0 ), radius, r, g, b, 0.2 )
		wait 0
	}
}

function DebugDrawOriginMovement( ent, r, g, b, time = 9999.0, trailTime = 5.0 )
{
	ent.EndSignal( "OnDeath" )
	ent.EndSignal( "OnDestroy" )

	local startTime = Time()
	local endTime = startTime + time
	local lastPos = ent.GetOrigin()

	while ( Time() < endTime )
	{
		DebugDrawLine( lastPos, ent.GetOrigin(), r, g, b, true, trailTime )
		lastPos = ent.GetOrigin()
		wait( 0.0 )
	}
}

function GetGameState()
{
	return GetServerVar( "gameState" )
}

function GamePlaying()
{
	return GetGameState() == eGameState.Playing
}

function GamePlayingOrSuddenDeath()
{
	local gameState = GetGameState()
	return gameState == eGameState.Playing || gameState == eGameState.SuddenDeath
}

function IsOdd( num )
{
	return ( num % 2 )
}

function IsEven( num )
{
	return !IsOdd( num )
}

function VectorReflectionAcrossNormal( vector, normal )
{
	return ( vector - normal * ( 2 * vector.Dot(normal) ) )
}

// Return an array of entities ordered from farthest to closest to the specified origin
function ArrayFarthest( array, origin )
{
	Assert( type( array ) == "array" )
	local allResults = ArrayDistanceResults( array, origin )

	allResults.sort( DistanceCompareFarthest )

	local returnEntities = []

	foreach ( index, result in allResults )
	{
		returnEntities.insert( index, result.ent )
	}

	// the actual distances aren't returned
	return returnEntities
}

// Return an array of entities ordered from closest to furthest from the specified origin
function ArrayClosest( array, origin )
{
	Assert( type( array ) == "array" )
	local allResults = ArrayDistanceResults( array, origin )

	allResults.sort( DistanceCompareClosest )

	local returnEntities = []

	foreach ( index, result in allResults )
	{
		returnEntities.insert( index, result.ent )
	}

	// the actual distances aren't returned
	return returnEntities
}


function TableRemove( table, entry )
{
	Assert( typeof table == "table" )

	foreach ( index, tableEntry in table )
	{
		if ( tableEntry == entry )
		{
			table[ index ] = null
		}
	}
}

function TableInvert( table )
{
	local invertedTable = {}
	foreach( key, value in table )
		invertedTable[ value ] <- key

	return invertedTable
}

function DistanceCompareClosest( a, b )
{
	if ( a.distanceSqr > b.distanceSqr )
		return 1
	else if ( a.distanceSqr < b.distanceSqr )
		return -1

	return 0;
}

function DistanceCompareFarthest( a, b )
{
	if ( a.distanceSqr < b.distanceSqr )
		return 1
	else if ( a.distanceSqr > b.distanceSqr )
		return -1

	return 0;
}

function ArrayDistanceResults( array, origin )
{
	Assert( type( array ) == "array" )
	local allResults = []

	foreach ( ent in array )
	{
		local results = {}
		local testspot = null

		if ( typeof ent == "Vector" )
			testspot = ent
		else
			testspot = ent.GetOrigin()

		results.distanceSqr <- ( testspot - origin ).LengthSqr()
		results.ent <- ent
		allResults.append( results )
	}

	return allResults
}

function GetGravityLandData( startPos, parentVelocity, objectVelocity, timeLimit, bDrawPath = false, bDrawPathDuration = 0, pathColor = [ 255, 255, 0 ] )
{
	local returnData = {}
	returnData.points <- []
	returnData.traceResults <- null
	returnData.elapsedTime <- 0

	Assert( timeLimit > 0 )

	local MAX_TIME_ELAPSE = 6.0
	local timeElapsePerTrace = 0.1

	local sv_gravity = 750
	local ent_gravity = 1.0
	local gravityScale = 1.0

	local traceStart = VectorCopy( startPos )
	local traceEnd = traceStart
	local traceFrac
	local traceCount = 0

	objectVelocity += parentVelocity

	while( returnData.elapsedTime <= timeLimit )
	{
		objectVelocity.z -= ( ent_gravity * sv_gravity * timeElapsePerTrace * gravityScale )

		traceEnd += objectVelocity * timeElapsePerTrace
		returnData.points.append( traceEnd )
		if ( bDrawPath )
			DebugDrawLine( traceStart, traceEnd, pathColor[0], pathColor[1], pathColor[2], false, bDrawPathDuration )

		traceFrac = TraceLineSimple( traceStart, traceEnd, null )
		traceCount++
		if ( traceFrac < 1.0 )
		{
			local traceResults = TraceLine( traceStart, traceEnd, null, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
			returnData.traceResults = traceResults
			return returnData
		}
		traceStart = traceEnd
		returnData.elapsedTime += timeElapsePerTrace
	}

	return returnData
}

function DrawLineFromEntToEntForTime( ent1, ent2, duration, r = 255, g = 255, b = 0 )
{
	local endTime = Time() + duration
	while( Time() <= endTime )
	{
		if ( !IsValid( ent1 ) || !IsValid( ent2 ) )
			return

		DebugDrawLine( ent1.GetOrigin(), ent2.GetOrigin(), r, g, b, true, 0.05 )
		wait 0
	}
}

function AngleDiff( ang1, ang2 )
{
	local res = ang1 - ang2;

	// wrap to range [0, 360)
	res -= floor( res / 360 ) * 360

	// convert to range [-180, +180)
	if ( res >= 180 )
		res -= 360

	return res
}

function GetPulseFrac( rate = 1, startTime = 0 )
{
	return (1 - cos( ( Time() - startTime ) * (rate * (2*PI)) )) / 2
}

function IsPetTitan( titan )
{
	Assert( titan.IsTitan() )

	return titan.GetTitanSoul().GetBossPlayer()	!= null
}

function GetAllPilots( team = null )
{
	local players
	if ( team != null )
		players = GetPlayerArrayOfTeam( team )
	else
		players = GetPlayerArray()
	local pilots = []

	foreach ( player in players )
	{
		if ( !IsValid( player ) )
			continue

		if ( player.IsTitan() )
			continue

		pilots.append( player )
	}

	return pilots
}

function CalcClosestPointOnLine( P, A, B, clamp = false )
{
	local table = {}
    local AP = P - A
    local AB = B - A

    local ab2 = AB.Dot( AB ) // AB.x*AB.x + AB.y*AB.y
    local ap_ab = AP.Dot( AB ) // AP.x*AB.x + AP.y*AB.y
    local t = ap_ab / ab2

    if ( clamp )
    {
         if ( t < 0.0 )
			t = 0.0
         else
         if ( t > 1.0 )
         	t = 1.0
    }
	table.t <- t

    local closest = A + AB * t
    table.point <- closest
	return table
}

function CalcProgressOnLine( P, A, B )
{
    local AP = P - A
    local AB = B - A

    local ab2 = AB.Dot( AB ) // AB.x*AB.x + AB.y*AB.y
    local ap_ab = AP.Dot( AB ) // AP.x*AB.x + AP.y*AB.y
    local t = ap_ab / ab2
    return t
}

function StringToVector( vecString, delimiter = " " )
{
	local tokens = split( vecString, delimiter )

	Assert( tokens.len() >= 3 )

	return Vector( tokens[0].tofloat(), tokens[1].tofloat(), tokens[2].tofloat() )
}

function GetShieldHealthFrac( titan )
{
	if ( !IsAlive( titan ) )
		return 0.0

	local soul = titan.GetTitanSoul()

	if ( !soul )
		return 0.0

	local shieldHealth = soul.GetShieldHealth()
	local shieldMaxHealth = soul.GetShieldHealthMax()

	if ( !shieldMaxHealth )
		return 0.0

	return shieldHealth.tofloat() / shieldMaxHealth.tofloat()
}

function EvacEnabled()
{
	if ( !IsMultiplayer() )
		return false

	if ( GetCinematicMode() && GetMapName() == "mp_o2" )  //Special case for O2: No evac in campaign mode since EVERYONE DIES
		return false

	if ( GAMETYPE == COOPERATIVE )
		return false

	return true
}

function ShouldRunEvac()
{
	Assert( GetGameState() >= eGameState.WinnerDetermined )

	if ( !EvacEnabled() )
		return false

	if ( !level.evacEnabled )
		return false

	if ( level.privateMatchForcedEnd )
		return false

	// If we cant exit titans, dont bother
	if ( Riff_TitanExitIsDisabled() )
		return false

	local gamemode = GameRules.GetGameMode()

	if ( gamemode == EXFILTRATION )
		return false

	if ( gamemode == MARKED_FOR_DEATH_PRO )
		return false

	if ( gamemode == CAPTURE_THE_FLAG_PRO )
		return false

	if ( gamemode == LAST_TITAN_STANDING || gamemode == WINGMAN_LAST_TITAN_STANDING )
	{
		if ( IsPilotEliminationBased() )
			return false
	}

	local winningTeam = GetWinningTeam()
	if ( winningTeam == TEAM_UNASSIGNED )
		return false

	if ( !GetCurrentPlaylistVarInt( "run_evac", 0 ) ) //If playlist var to always run evac don't do check for players being on both team
	{
		// We don't care about player count when playing coop
		if ( GameRules.GetGameMode() == COOPERATIVE )
			return true

		//Return false if there are no players connected on either team
		local losingTeam = GetOtherTeam( winningTeam )

		if ( GetPlayerArrayOfTeam( winningTeam ).len() == 0 )
			return false

		if ( GetPlayerArrayOfTeam( losingTeam ).len() == 0 )
			return false

		if ( IsPilotEliminationBased() && IsTeamEliminated( losingTeam ) && GameTeams.GetNumLivingPlayers( losingTeam ) == 0 )
			return false
	}

	return true
}


function HackGetDeltaToRef( origin, angles, ent, anim )
{
	local animStartPos = ent.Anim_GetStartForRefPoint( anim, origin, angles )
	local delta = origin - animStartPos.origin
	return origin + delta
}

function GetPlayerViewTrace( player )
{
	local traceStart = player.EyePosition()
	local traceEnd = traceStart + (player.GetViewVector() * 56756) // longest possible trace given our map size limits
	local ignoreEnts = [ player ]
	return TraceLine( traceStart, traceEnd, ignoreEnts, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
}

function IsAttritionMode()
{
	return GameRules.GetGameMode() == ATTRITION
}

function IsTDMMode()
{
	return GameRules.GetGameMode() == TEAM_DEATHMATCH
}

function IsCaptureMode()
{
	return GameRules.GetGameMode() == CAPTURE_POINT
}

function GetModSourceID( modString )
{
	foreach ( name, id in getconsttable().eModSourceId )
	{
		if ( name.tostring() == modString )
			return id
	}

	return null
}

function ArrayRemoveDead( array )
{
	Assert( type( array ) == "array" )
	for( local i = 0; i < array.len(); )
	{
		if ( !IsAlive( array[ i ] ) )
		{
			array.remove( i )
			continue // don't increment i
		}
		i++
	}
}

function GetSortedPlayers( compareFunc, team )
{
	local players

	if ( team )
		players = GetPlayerArrayOfTeam( team )
	else
		players = GetPlayerArray()

	players.sort( compareFunc )

	return players
}


// Sorts by kills and resolves ties in this order: fewest deaths, most titan kills, most assists
function CompareKills( a, b )
{
	local aKills = a.GetKillCount()
	local bKills = b.GetKillCount()

	if ( aKills < bKills )
		return 1
	else if ( aKills > bKills )
		return -1

	local aDeaths = a.GetDeathCount()
	local bDeaths = b.GetDeathCount()

	if ( aDeaths > bDeaths )
		return 1
	else if ( aDeaths < bDeaths )
		return -1

	local aTitanKills = a.GetTitanKillCount()
	local bTitanKills = b.GetTitanKillCount()

	if ( aTitanKills < bTitanKills )
		return 1
	else if ( aTitanKills > bTitanKills )
		return -1

	local aAssists = a.GetAssistCount()
	local bAssists = b.GetAssistCount()

	if ( aAssists < bAssists )
		return 1
	else if ( aAssists > bAssists )
		return -1

	return 0
}

// Sorts by kills and resolves ties in this order: fewest deaths, most titan kills, most assists
function CompareAssaultScore( a, b )
{
	local aVal = a.GetAssaultScore()
	local bVal = b.GetAssaultScore()

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	return 0
}

function CompareScore( a, b )
{
	local aVal = a.GetScore()
	local bVal = b.GetScore()

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	return 0
}

function CompareAssault( a, b )
{
	local aVal = a.GetAssaultScore()
	local bVal = b.GetAssaultScore()

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	return 0
}

function CompareDefense( a, b )
{
	local aVal = a.GetDefenseScore()
	local bVal = b.GetDefenseScore()

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	return 0
}

function CompareLTS( a, b )
{
	local result = CompareTitanKills( a, b )
	if ( result != 0 )
		return result

	return CompareKills( a, b )
}

function CompareCP( a, b )
{
	// Capture Point sorting. Sort priority = assault + defense > pilot kills > titan kills > death

	local aVal = a.GetAssaultScore()
	local bVal = b.GetAssaultScore()

	aVal += a.GetDefenseScore()
	bVal += b.GetDefenseScore()

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	// 3) Pilot Kills
	local aVal = a.GetKillCount()
	local bVal = b.GetKillCount()
	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	// 3) Titan Kills
	aVal = a.GetTitanKillCount()
	bVal = b.GetTitanKillCount()
	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	// 4) Deaths
	aVal = a.GetDeathCount()
	bVal = b.GetDeathCount()
	if ( aVal < bVal )
		return -1
	else if ( aVal > bVal )
		return 1

	return 0
}


function CompareCTF( a, b )
{
	// Capture the flag sorting. Sort priority = flag captures > flag returns > pilot kills > titan kills > death

	// 1) Flag Captures
	local result = CompareAssault( a, b )
	if ( result != 0 )
		return result

	// 2) Flag Returns
	result = CompareDefense( a, b )
	if ( result != 0 )
		return result

	// 3) Pilot Kills
	local aVal = a.GetKillCount()
	local bVal = b.GetKillCount()
	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	// 3) Titan Kills
	aVal = a.GetTitanKillCount()
	bVal = b.GetTitanKillCount()
	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	// 4) Deaths
	aVal = a.GetDeathCount()
	bVal = b.GetDeathCount()
	if ( aVal < bVal )
		return -1
	else if ( aVal > bVal )
		return 1

	return 0
}

function CompareMFD( a,b )
{
	// 1) Marks Killed
	local result = CompareAssault( a, b )
	if ( result != 0 )
		return result

	// 2) Marks Outlasted
 	result = CompareDefense( a, b )
	if ( result != 0 )
		return result

	//3) Pilot Kills
	local aVal = a.GetKillCount()
	local bVal = b.GetKillCount()
	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	// 4) Titan Kills
	aVal = a.GetTitanKillCount()
	bVal = b.GetTitanKillCount()
	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	// 5) Deaths
	aVal = a.GetDeathCount()
	bVal = b.GetDeathCount()
	if ( aVal < bVal )
		return -1
	else if ( aVal > bVal )
		return 1

	return 0
}

function CompareScavenger( a,b )
{
	// 1) Ore Captured
	local result = CompareAssault( a, b )
	if ( result != 0 )
		return result

	// 2) Pilot Kills
	local aVal = a.GetKillCount()
	local bVal = b.GetKillCount()
	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	// 3) Titan Kills
	aVal = a.GetTitanKillCount()
	bVal = b.GetTitanKillCount()
	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	// 4) Deaths
	aVal = a.GetDeathCount()
	bVal = b.GetDeathCount()
	if ( aVal < bVal )
		return -1
	else if ( aVal > bVal )
		return 1

	return 0
}

function CompareTitanKills( a, b )
{
	local aVal = a
	local bVal = b

	if ( IsServer() )
	{
		aVal = a.GetTitanKillCount()
		bVal = b.GetTitanKillCount()
	}
	else
	{
		aVal = a.GetTitanKills()
		bVal = b.GetTitanKills()
	}

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	return 0
}

function GetScoreboardCompareFunc( player = null )
{
	return ScoreboardCompareFuncForGamemode( GameRules.GetGameMode() )
}

function ScoreboardCompareFuncForGamemode( gamemode )
{
	switch ( gamemode )
	{
		case TEAM_DEATHMATCH:
		case PILOT_SKIRMISH:
			return CompareKills
		case CAPTURE_POINT:
			return CompareCP
		case MARKED_FOR_DEATH:
		case MARKED_FOR_DEATH_PRO:
		case TITAN_MFD:
		case TITAN_MFD_PRO:
			return CompareMFD
		case ATTRITION:
		case COOPERATIVE:
			return CompareAssaultScore
		case CAPTURE_THE_FLAG:
		case CAPTURE_THE_FLAG_PRO:
			return CompareCTF
		case LAST_TITAN_STANDING:
		case WINGMAN_LAST_TITAN_STANDING:
		case TITAN_BRAWL:
			return CompareLTS
		case SCAVENGER:
			return CompareScavenger
		case EXFILTRATION:
		case ELIMINATION:
		case ATDM:
		case BIG_BROTHER:
		case HEIST:
		default:
			if ( IsFFABased() )
				return CompareKills

			return CompareScore
	}
}

function IsHitEffective( damageType )
{
	if ( !( damageType & DF_CRITICAL ) && ( damageType & DF_BULLET || damageType & DF_MAX_RANGE ) )
		return false

	return true
}

function CreateFirstPersonSequence()
{
	local sequence = {}
	sequence.firstPersonAnim <- null
	sequence.thirdPersonAnim <- null
	sequence.firstPersonAnimIdle <- null
	sequence.thirdPersonAnimIdle <- null
	sequence.relativeAnim <- null
	sequence.attachment <- null
	sequence.teleport <- null
	sequence.noParent <- null
	sequence.blendTime <- null
	sequence.noViewLerp <- null
	sequence.hideProxy <- null
	sequence.viewConeFunction <- null
	sequence.origin <- null
	sequence.angles <- null
	sequence.enablePlanting <- null
	sequence.newSequence <- null
	sequence.setInitialTime <- null	//set the starting point of the animation in seconds
	sequence.useAnimatedRefAttachment <- false //Position entity using ref every frame instead of using root motion
	sequence.renderWithViewModels <- false
	sequence.gravity			<- null // force gravity command on sequence

	return sequence
}

function IsPilot( ent )
{
	if ( IsValid( ent ) && !ent.IsTitan() && ent.IsPlayer() )
		return true

	return false
}

function HardpointIDToString( id )
{
	local hardpointIDString = [ "a", "b", "c" ]

	if( id >= 0 && id < hardpointIDString.len() )
		return hardpointIDString[ id ]
	else
		return -1
}

function Dev_TeamIDToString( id )
{
	if ( id == TEAM_IMC )
		return "IMC"
	if ( id == TEAM_MILITIA )
		return "MIL"

	return "UNASSIGNED/UNKNOWN TEAM NAME"
}

function ArrayWithin( array, origin, maxDist )
{
	maxDist *= maxDist

	local resultArray = []
	foreach( ent in array )
	{
		local dist = DistanceSqr( origin, ent.GetOrigin() )
		if ( dist <= maxDist )
			resultArray.append( ent )
	}
	return resultArray
}
RegisterFunctionDesc( "ArrayWithin", "Remove ents from array that are out of range" )

// short cut for the console
//script gp()[0].Die( gp()[1])
gp <- GetPlayerArray

function GetTitanChassis( titan )
{
	if ( !("titanChassis" in titan.s ) )
	{
		if ( HasSoul( titan ) )
		{
			local soul = titan.GetTitanSoul()
			titan.s.titanChassis <- GetSoulTitanType( soul )
		}
		else
		{
			return "Invalid Chassis"
		}
	}

	return titan.s.titanChassis
}

function ClampVectorToCube( vecStart, vec, cubeOrigin, cubeSize )
{
	local smallestClampScale = 1.0
	local vecComponents = [ "x", "y", "z" ]
	local min
	local max
	local scale
	local clearance
	local vecEnd = vecStart + vec

	foreach( component in vecComponents )
	{
		//+
		max = cubeOrigin[component] + ( cubeSize * 0.5 )
		clearance = fabs( vecStart[component] - max )
		if ( vecEnd[component] > max )
		{
			scale = fabs( clearance / ( ( vecStart[component] + vec[component] ) - vecStart[component] ) )
			if ( scale > 0 && scale < smallestClampScale )
				smallestClampScale = scale
		}

		//-
		min = cubeOrigin[component] - ( cubeSize * 0.5 )
		clearance = fabs( min - vecStart[component] )
		if ( vecEnd[component] < min )
		{
			scale = fabs( clearance / ( ( vecStart[component] + vec[component] ) - vecStart[component] ) )
			if ( scale > 0 && scale < smallestClampScale )
				smallestClampScale = scale
		}
	}

	return vec * smallestClampScale
}

function DebugDrawCube( cubeCenter, cubeSize, r, g, b, throughGeo, duration )
{
	local corner0 = cubeCenter + Vector( -cubeSize * 0.5, -cubeSize * 0.5, cubeSize * 0.5 )
	local corner1 = cubeCenter + Vector( cubeSize * 0.5, -cubeSize * 0.5, cubeSize * 0.5 )
	local corner2 = cubeCenter + Vector( -cubeSize * 0.5, cubeSize * 0.5, cubeSize * 0.5 )
	local corner3 = cubeCenter + Vector( cubeSize * 0.5, cubeSize * 0.5, cubeSize * 0.5 )
	local corner4 = cubeCenter + Vector( -cubeSize * 0.5, -cubeSize * 0.5, -cubeSize * 0.5 )
	local corner5 = cubeCenter + Vector( cubeSize * 0.5, -cubeSize * 0.5, -cubeSize * 0.5 )
	local corner6 = cubeCenter + Vector( -cubeSize * 0.5, cubeSize * 0.5, -cubeSize * 0.5 )
	local corner7 = cubeCenter + Vector( cubeSize * 0.5, cubeSize * 0.5, -cubeSize * 0.5 )

	// top
	DebugDrawLine( corner0, corner1, r, g, b, throughGeo, duration )
	DebugDrawLine( corner1, corner3, r, g, b, throughGeo, duration )
	DebugDrawLine( corner2, corner0, r, g, b, throughGeo, duration )
	DebugDrawLine( corner3, corner2, r, g, b, throughGeo, duration )

	// bottom
	DebugDrawLine( corner4, corner5, r, g, b, throughGeo, duration )
	DebugDrawLine( corner5, corner7, r, g, b, throughGeo, duration )
	DebugDrawLine( corner6, corner4, r, g, b, throughGeo, duration )
	DebugDrawLine( corner7, corner6, r, g, b, throughGeo, duration )

	// sides
	DebugDrawLine( corner0, corner4, r, g, b, throughGeo, duration )
	DebugDrawLine( corner1, corner5, r, g, b, throughGeo, duration )
	DebugDrawLine( corner2, corner6, r, g, b, throughGeo, duration )
	DebugDrawLine( corner3, corner7, r, g, b, throughGeo, duration )
}

function DebugDrawAngles( position, angles, duration = 9999.0 )
{
	local forward = angles.AnglesToForward()
	local right = angles.AnglesToRight()
	local up = angles.AnglesToUp()

	DebugDrawLine( position, position + ( forward * 100.0 ), 255, 0, 0, true, duration )
	DebugDrawLine( position, position + ( right * 100.0 ), 0, 255, 0, true, duration )
	DebugDrawLine( position, position + ( up * 100.0 ), 0, 0, 255, true, duration )
}

function AngleDiff( ang, targetAng )
{
	local delta = ( targetAng - ang ) % 360.0
	if ( targetAng > ang )
	{
		if ( delta >= 180.0 )
			delta -= 360.0;
	}
	else
	{
		if ( delta <= -180.0 )
			delta += 360.0;
	}
	return delta
}

function ShortestRotation( ang, targetAng )
{
	return Vector( AngleDiff( ang.x, targetAng.x ), AngleDiff( ang.y, targetAng.y ), AngleDiff( ang.z, targetAng.z ) )
}

function GetWinningTeam()
{
	if ( level.nv.winningTeam )
		return level.nv.winningTeam

	if ( GameRules.GetTeamScore( TEAM_IMC ) > GameRules.GetTeamScore( TEAM_MILITIA ) )
		return TEAM_IMC

	if ( GameRules.GetTeamScore( TEAM_MILITIA ) > GameRules.GetTeamScore( TEAM_IMC ) )
		return TEAM_MILITIA

	return TEAM_UNASSIGNED
}

function EmitSkyboxSoundAtPosition( positionInSkybox, sound, skyboxScale = 0.001, clamp = false )
{
	if ( IsServer() )
		clamp = true // sounds cannot play outside 16k limit on server
	local position = SkyboxToWorldPosition( positionInSkybox, skyboxScale, clamp )
	EmitSoundAtPosition( position, sound )
}

function SkyboxToWorldPosition( positionInSkybox, skyboxScale = 0.001, clamp = true )
{
	Assert( skyboxScale > 0 )
	Assert( "skyboxCamOrigin" in level )

	local position = Vector( 0.0, 0.0, 0.0 )
	local skyOrigin = level.skyboxCamOrigin

	if ( IsClient() )
	{

		position = ( positionInSkybox - skyOrigin ) * ( 1.0 / skyboxScale )

		if ( clamp )
		{
			local localViewPlayer = GetLocalViewPlayer()
			Assert( localViewPlayer )
			local localViewPlayerOrg = localViewPlayer.GetOrigin()

			position = localViewPlayerOrg + ClampVectorToCube( localViewPlayerOrg, position - localViewPlayerOrg, Vector( 0.0, 0.0, 0.0 ), 32000.0 )
		}
	}
	else
	{
		position = ( positionInSkybox - skyOrigin ) * ( 1.0 / skyboxScale )

		if ( clamp )
			position = ClampVectorToCube( Vector( 0.0, 0.0, 0.0 ), position, Vector( 0.0, 0.0, 0.0 ), 32000.0 )
	}

	return position
}

function GetRandomKeyFromWeightedTable( table, weightTotal )
{
	local randomValue = RandomFloat( 0, weightTotal )

	foreach ( key, value in table )
	{
		if ( randomValue <= weightTotal && randomValue >= weightTotal - value)
			 return key
		weightTotal -= value
	}
}

function IsMatchOver()
{
	if ( IsRoundBased() && level.nv.gameEndTime )
		return true
	else if ( !IsRoundBased() && level.nv.gameEndTime && Time() > level.nv.gameEndTime )
		return true

	return false
}

function IsRoundBased()
{
	return level.nv.roundBased
}

function IsAttackDefendBased()
{
	return level.attackDefendBased
}

function GetRoundsPlayed()
{
	return level.nv.roundsPlayed
}

function IsEliminationBased()
{
	return Riff_EliminationMode() != eEliminationMode.Default
}

function IsPilotEliminationBased()
{
	return ( Riff_EliminationMode() == eEliminationMode.Pilots || Riff_EliminationMode() == eEliminationMode.PilotsTitans )
}

function IsTitanEliminationBased()
{
	return ( Riff_EliminationMode() == eEliminationMode.Titans || Riff_EliminationMode() == eEliminationMode.PilotsTitans )
}

function IsSuddenDeathGameMode()
{
	if ( GAMETYPE == CAPTURE_THE_FLAG ) //|| GAMETYPE == TEAM_DEATHMATCH )
		return true

	return false
}

function ShouldEnterSuddenDeath( winningTeam )
{
	if ( GetGameState() == eGameState.SuddenDeath )
		return false

	if ( !( winningTeam == null || winningTeam == TEAM_UNASSIGNED ) )
		return false

	if ( !IsSuddenDeathGameMode() )
		return false

	if ( GetTeamPlayerCount( TEAM_MILITIA ) == 0 || GetTeamPlayerCount( TEAM_IMC ) == 0 )
		return false

	return true
}

const ATTRITION_SCORE_TITAN   = 5
const ATTRITION_SCORE_PILOT   = 4
const ATTRITION_SCORE_GRUNT   = 1
const ATTRITION_SCORE_SPECTRE = 1
const ATTRITION_SCORE_MARVIN  = 0

function AttritionScoreValueForVictim( victim )
{
	if ( victim.IsPlayer() )
		return ATTRITION_SCORE_PILOT
	else if ( victim.IsTitan() && !victim.IsPlayer() )
		return ATTRITION_SCORE_TITAN
	else if ( victim.IsNPC() && victim.IsSpectre() )
		return ATTRITION_SCORE_SPECTRE
	else if ( victim.IsNPC() && victim.IsMarvin() )
		return ATTRITION_SCORE_MARVIN
	else if ( victim.IsNPC() )
		return ATTRITION_SCORE_GRUNT
	return 0
}

function GetAttritionScore( attacker, victim )
{
	local scoreVal = 0
	if ( attacker == victim )
		return scoreVal

	if ( IsValid( victim ) )
	{
		return AttritionScoreValueForVictim( victim )
	}

	return scoreVal
}

function __WarpInEffectShared( origin, angles, sfx )
{
	local preWait = 2.0
	local sfxWait = 0.1
	local totalTime = WARPINFXTIME

	if ( sfx == null )
		sfx = "dropship_warpin"

	wait preWait  //this needs to go and the const for warpin fx time needs to change - but not this game - the intro system is too dependent on it

	if ( IsClient() )
	{
		local fxIndex 	= GetParticleSystemIndex( FX_GUNSHIP_CRASH_EXPLOSION_ENTRANCE )
		StartParticleEffectInWorld( fxIndex, origin, angles )
	}
	else
	{
		local fx = PlayFX( FX_GUNSHIP_CRASH_EXPLOSION_ENTRANCE, origin, angles )
		fx.EnableRenderAlways()
	}

	wait sfxWait
	EmitSoundAtPosition( origin, sfx )

	wait totalTime - preWait -sfxWait
}

function __WarpOutEffectShared( dropship )
{
	local attach = dropship.LookupAttachment( "origin" )
	local origin = dropship.GetAttachmentOrigin( attach )
	local angles = dropship.GetAttachmentAngles( attach )

	if ( IsClient() )
	{
		local fxIndex 	= GetParticleSystemIndex( FX_GUNSHIP_CRASH_EXPLOSION_EXIT )
		StartParticleEffectInWorld( fxIndex, origin, angles )
	}
	else
	{
		local fx = PlayFX( FX_GUNSHIP_CRASH_EXPLOSION_EXIT, origin, angles )
		fx.EnableRenderAlways()
	}

	EmitSoundAtPosition( origin, "dropship_warpout" )
}

function IsSwitchSidesBased()
{
	return (level.nv.switchedSides != null)
}

function HasSwitchedSides()
{
	return level.nv.switchedSides
}

function IsFirstRoundAfterSwitchingSides()
{
	if ( !IsSwitchSidesBased() )
		return false

	if ( IsRoundBased() )
		return  level.nv.switchedSides > 0 && GetRoundsPlayed() == level.nv.switchedSides
	else
		return  level.nv.switchedSides > 0
}

function CamBlendFov( cam, oldFov, newFov, transTime, transAccel, transDecel )
{
	if ( !IsValid( cam ) )
		return

	cam.EndSignal( "OnDestroy" )

	local currentTime = Time()
	local startTime = currentTime
	local endTime = startTime + transTime

	while ( endTime > currentTime )
	{
		local interp = Interpolate( startTime, endTime - startTime, transAccel, transDecel )
		cam.SetFOV( GraphCapped( interp, 0.0, 1.0, oldFov, newFov ) )
		wait( 0.0 )
		currentTime = Time()
	}
}

function CamFollowEnt( cam, ent, duration, offset = Vector( 0.0, 0.0, 0.0 ), attachment = "", isInSkybox = false )
{
	if ( !IsValid( cam ) )
		return

	cam.EndSignal( "OnDestroy" )

	local camOrg = Vector( 0.0, 0.0, 0.0 )

	local targetPos = Vector( 0.0, 0.0, 0.0 )
	local currentTime = Time()
	local startTime = currentTime
	local endTime = startTime + duration
	local diff = Vector( 0.0, 0.0, 0.0 )
	local attachID = ent.LookupAttachment( attachment )

	while ( endTime > currentTime )
	{
		camOrg = cam.GetOrigin()

		if ( attachID <= 0 )
			targetPos = ent.GetOrigin()
		else
			targetPos = ent.GetAttachmentOrigin( attachID )

		if ( isInSkybox )
			targetPos = SkyboxToWorldPosition( targetPos )
		diff = ( targetPos + offset ) - camOrg

		cam.SetAngles( VectorToAngles( diff ) )

		wait( 0.0 )

		currentTime = Time()
	}
}

function CamFacePos( cam, pos, duration )
{
	if ( !IsValid( cam ) )
		return

	cam.EndSignal( "OnDestroy" )

	local currentTime = Time()
	local startTime = currentTime
	local endTime = startTime + duration
	local diff = Vector( 0.0, 0.0, 0.0 )

	while ( endTime > currentTime )
	{
		diff = pos - cam.GetOrigin()

		cam.SetAngles( VectorToAngles( diff ) )

		wait( 0.0 )

		currentTime = Time()
	}
}

function CamBlendFromFollowToAng( cam, ent, endAng, transTime, transAccel, transDecel )
{
	if ( !IsValid( cam ) )
		return

	cam.EndSignal( "OnDestroy" )

	local camOrg = cam.GetOrigin()

	local currentTime = Time()
	local startTime = currentTime
	local endTime = startTime + transTime

	while ( endTime > currentTime )
	{
		local diff = ent.GetOrigin() - camOrg
		local anglesToEnt = VectorToAngles( diff )

		local frac = Interpolate( startTime, endTime - startTime, transAccel, transDecel )

		local newAngs = anglesToEnt + ShortestRotation( anglesToEnt, endAng ) * frac

		cam.SetAngles( newAngs )

		wait( 0.0 )

		currentTime = Time()
	}
}

function CamBlendFromPosToPos( cam, startPos, endPos, transTime, transAccel, transDecel )
{
	if ( !IsValid( cam ) )
		return

	cam.EndSignal( "OnDestroy" )

	local currentTime = Time()
	local startTime = currentTime
	local endTime = startTime + transTime
	local diff = endPos - startPos

	while ( endTime > currentTime )
	{
		local frac = Interpolate( startTime, endTime - startTime, transAccel, transDecel )

		local newAngs = startPos + diff * frac

		cam.SetOrigin( newAngs )

		wait( 0.0 )

		currentTime = Time()
	}
}

function CamBlendFromAngToAng( cam, startAng, endAng, transTime, transAccel, transDecel )
{
	if ( !IsValid( cam ) )
		return

	cam.EndSignal( "OnDestroy" )

	local currentTime = Time()
	local startTime = currentTime
	local endTime = startTime + transTime

	while ( endTime > currentTime )
	{
		local frac = Interpolate( startTime, endTime - startTime, transAccel, transDecel )

		local newAngs = startAng + ShortestRotation( startAng, endAng ) * frac

		cam.SetAngles( newAngs )

		wait( 0.0 )

		currentTime = Time()
	}
}

function AddBitMask( bitsExisting, bitsToAdd )
{
	return bitsExisting | bitsToAdd
}

function RemoveBitMask( bitsExisting, bitsToRemove )
{
	return bitsExisting & ( ~bitsToRemove )
}

function HasBitMask( bitsExisting, bitsToCheck )
{
	local bitsCommon = bitsExisting & bitsToCheck
	return bitsCommon == bitsToCheck
}

function GetDeathCamTime( player )
{
	if ( !GamePlayingOrSuddenDeath() )
		return DEATHCAM_TIME_SHORT
	else
		return DEATHCAM_TIME
}

function GetRespawnButtonCamTime( player )
{
	if ( !GamePlayingOrSuddenDeath() )
		return DEATHCAM_TIME_SHORT + RESPAWN_BUTTON_BUFFER
	else
		return DEATHCAM_TIME + RESPAWN_BUTTON_BUFFER
}

function GetKillReplayAfterTime( player )
{
	if ( !GamePlayingOrSuddenDeath() )
		return KILL_REPLAY_AFTER_KILL_TIME_SHORT
	else
		return KILL_REPLAY_AFTER_KILL_TIME
}


function CampaignLevelsComplete_IMC( player )
{
	Assert( IsValid( player ) )
	Assert( player.IsPlayer() )
	local count = 0
	for ( local i = 0 ; i < CAMPAIGN_LEVEL_COUNT ; i++ )
	{
		if ( player.GetPersistentVar( "campaignMapFinishedIMC[" + i + "]" ) )
			count++
	}
	return count
}

function CampaignLevelsComplete_MIL( player )
{
	Assert( IsValid( player ) )
	Assert( player.IsPlayer() )
	local count = 0
	for ( local i = 0 ; i < CAMPAIGN_LEVEL_COUNT ; i++ )
	{
		if ( player.GetPersistentVar( "campaignMapFinishedMCOR[" + i + "]" ) )
			count++
	}
	return count
}

function JustBeatCampaign( player, thisMapIndex )
{
	local team = player.GetTeam()
	if ( team == TEAM_IMC )
	{
		if( CampaignLevelsComplete_IMC( player ) < CAMPAIGN_LEVEL_COUNT )
			return false
	}
	else
	{
		Assert( team == TEAM_MILITIA )
		if( CampaignLevelsComplete_MIL( player ) < CAMPAIGN_LEVEL_COUNT )
			return false
	}

	if ( thisMapIndex != CAMPAIGN_LEVEL_COUNT - 1 )
		return false

	return true
}

function JustBeatFinalCampaignLevel( player, thisMapIndex )
{
	if ( thisMapIndex != CAMPAIGN_LEVEL_COUNT - 1 )
		return false

	return true
}

function IntroPreviewOn()
{
	local bugnum = GetBugReproNum()
	switch( bugnum )
	{
		case 1337:
		case 13371:
		case 13372:
		case 13373:
		case 1338:
		case 13381:
		case 13382:
		case 13383:
			return bugnum

		default:
			return null
	}
}

function GetCPULevelWrapper()
{
	return GetCPULevel()
}

function ResetNewPlayerExperience()
{
	if ( IsClient() )
	{
		local player = GetLocalClientPlayer()
		if ( player != GetLocalViewPlayer() || IsWatchingKillReplay() )
			return

		SetPlayerTrainingResumeChoice( -1 )

		printt( "reset NPE on client" )
	}
	else
	{
		local players = GetPlayerArray()
		if ( GetPlayerArray().len() != 1 )
			return

		local player = players[0]

		local maxIdx = PersistenceGetEnumCount( "trainingModules" )
		for ( local i = 0; i < maxIdx; i++ )
		{
			local setStr = "trainingModulesCompleted[" + i + "]"
			player.SetPersistentVar( setStr, false )
		}

		printt( "reset NPE on server" )
	}
}

function EntHasModelSet( ent )
{
	local modelName = ent.GetModelName()

	if ( modelName == "" )
		return false

	if ( modelName == "?" )
		return false

	return true
}

function UpdateDeaths( player )
{
	if ( IsServer() )
		return player.GetDeathCount()
	return player.GetDeaths()
}

function UpdateKills( player )
{
	if ( IsServer() )
		return player.GetKillCount()
	return player.GetKills()
}

function UpdateNPCKills( player )
{
	if ( IsServer() )
		return player.GetNPCKillCount()
	return player.GetNPCKills()
}

function UpdateTitanKills( player )
{
	if ( IsServer() )
		return player.GetTitanKillCount()
	return player.GetTitanKills()
}

function UpdateAssists( player )
{
	if ( IsServer() )
		return player.GetAssistCount()
	return player.GetAssists()
}

function UpdateScore( player )
{
	return player.GetScore()
}

function UpdateDefense( player )
{
	return player.GetDefenseScore()
}

function UpdateAssault( player )
{
	return player.GetAssaultScore()
}

function UpdateBadRepPresent()
{
	local players = GetPlayerArray()
	local found = false

	foreach ( player in players )
	{
		if ( player.HasBadReputation() )
		{
			found = true
			break
		}
	}

	level.nv.badRepPresent = found
	level.ui.badRepPresent = found
}

function GenerateTitanOSAlias( player, aliasPrefix, aliasSuffix )
{
	local titanOSVoiceIndex = player.GetVoicePackIndex()
	local titanOSEnumItemName = PersistenceGetEnumItemNameForIndex( "titanOS", titanOSVoiceIndex )
	local modifiedAlias = aliasPrefix + TITAN_OS_VOICE_PACK[ titanOSEnumItemName ] + aliasSuffix
	return modifiedAlias
}


function CreateScriptCylinderTrigger( origin, radius, top = null, bottom = null )
{
	local trigger = CreateScriptRef( origin, Vector( 0, 0, 0 ) )

	trigger.s.enabled <- false
	trigger.s.radius <- radius
	trigger.s.players <- {}
	trigger.s.enterCallbacks <- []
	trigger.s.leaveCallbacks <- []
	trigger.s.top <- top
	trigger.s.bottom <- bottom

	thread CylinderTriggerThink( trigger )

	return trigger
}

function ScriptTriggerEnable( trigger, state )
{
	trigger.s.enabled = state
}

function CylinderTriggerThink( triggerEnt )
{
	local wasEnabled = triggerEnt.s.enabled
	local playerOrg = null

	while ( IsValid( triggerEnt ) )
	{
		if ( !triggerEnt.s.enabled )
		{
			if ( wasEnabled )
			{
				local playersToRemove = [] // build an array since looping through a table and removing elements is undefined
				foreach( player in triggerEnt.s.players )
				{
					playersToRemove.append( player )
				}

				foreach ( player in playersToRemove )
				{
					ScriptTriggerRemovePlayer( triggerEnt, player )
				}

				Assert( !triggerEnt.s.players.len() )
			}
		}
		else
		{
			local players = GetPlayerArray()

			foreach ( player in players )
			{
				if ( !IsAlive( player ) )
				{
					if ( player.GetEntIndex() in triggerEnt.s.players )
						ScriptTriggerRemovePlayer( triggerEnt, player )
					continue
				}

				playerOrg = player.GetOrigin()

				if ( Distance2D( playerOrg, triggerEnt.GetOrigin() ) < triggerEnt.s.radius )
				{
					if ( triggerEnt.s.top != null && playerOrg.z > triggerEnt.s.top )
						continue

					if ( triggerEnt.s.bottom != null && playerOrg.z + 72.0 < triggerEnt.s.bottom )
						continue

					if ( !(player.GetEntIndex() in triggerEnt.s.players) )
						ScriptTriggerAddPlayer( triggerEnt, player )
				}
				else if ( player.GetEntIndex() in triggerEnt.s.players )
				{
					ScriptTriggerRemovePlayer( triggerEnt, player )
				}
			}
		}

		wasEnabled = triggerEnt.s.enabled
		wait 0
	}
}

function ScriptTriggerRemovePlayer( triggerEnt, player )
{
	Assert( player.GetEntIndex() in triggerEnt.s.players )

	foreach ( callbackInfo in triggerEnt.s.leaveCallbacks )
	{
		callbackInfo.func.acall( [callbackInfo.scope, triggerEnt, player] )
	}

	delete triggerEnt.s.players[player.GetEntIndex()]
}

function ScriptTriggerAddPlayer( triggerEnt, player )
{
	Assert( !(player.GetEntIndex() in triggerEnt.s.players) )

	triggerEnt.s.players[player.GetEntIndex()] <- player

	foreach ( callbackInfo in triggerEnt.s.enterCallbacks )
	{
		callbackInfo.func.acall( [callbackInfo.scope, triggerEnt, player] )
	}

	thread ScriptTriggerPlayerDisconnectThink( triggerEnt, player )
}

function ScriptTriggerPlayerDisconnectThink( triggerEnt, player )
{
	triggerEnt.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )

	OnThreadEnd(
		function() : ( triggerEnt, player )
		{
			if ( !IsValid( triggerEnt ) )
				return

			if ( !IsValid( player ) )
				return

			if ( player.GetEntIndex() in triggerEnt.s.players )
				ScriptTriggerRemovePlayer( triggerEnt, player )
		}
	)

	player.WaitSignal( "Disconnected" )
}

function AddCallback_ScriptTriggerEnter( trigger, callbackFunc )
{
	local callbackInfo = {}
	callbackInfo.scope <- this
	callbackInfo.func <- callbackFunc

	trigger.s.enterCallbacks.append( callbackInfo )
}

function AddCallback_ScriptTriggerLeave( trigger, callbackFunc )
{
	local callbackInfo = {}
	callbackInfo.scope <- this
	callbackInfo.func <- callbackFunc

	trigger.s.leaveCallbacks.append( callbackInfo )
}

function SetWaveSpawnType( type )
{
	level.waveSpawnType = type
}

function GetWaveSpawnType()
{
	return level.waveSpawnType
}

function IsEMPTitan( npc )
{
	return ( npc.GetSubclass() == eSubClass.empTitan )
}

function IsNukeTitan( npc )
{
	return ( npc.GetSubclass() == eSubClass.nukeTitan )
}

function IsMortarTitan( npc )
{
	return ( npc.GetSubclass() == eSubClass.mortarTitan )
}

function IsSuicideSpectre( npc )
{
	return ( npc.GetSubclass() == eSubClass.suicideSpectre )
}

function IsSniperSpectre( npc )
{
	return ( npc.GetSubclass() == eSubClass.sniperSpectre )
}

function IsBubbleShieldMinion( npc )
{
	if ( npc.GetSubclass() == eSubClass.bubbleShieldGrunt )
		return true

	if ( npc.GetSubclass() == eSubClass.bubbleShieldSpectre )
		return true

	return false
}

function GetTitanSubclassHudIcon( titan )
{
	switch ( titan.GetSubclass() )
	{
		case eSubClass.NONE:
			return "HUD/coop/coop_titan"
			break

		case eSubClass.empTitan:
			return "HUD/coop/coop_emp_titan_square"
			break

		case eSubClass.mortarTitan:
			return "HUD/coop/coop_mortar_titan_square"
			break

		case eSubClass.nukeTitan:
			return "HUD/coop/coop_nuke_titan_square"
			break
	}
}

function GetRoundWinningKillEnabled()
{
	return level.nv.roundWinningKillReplayEnabled
}

function HasRoundScoreLimitBeenReached() //Different from RoundScoreLimit_Complete in that it only checks to see if the score required has been reached. Allows us to use it on the client to cover 90% of the cases we want
{
	if ( !IsRoundBased() )
		return false

	local roundLimit = GetRoundScoreLimit_FromPlaylist()

	if ( !roundLimit )
		return false

	local militiaScore = GameRules.GetTeamScore2( TEAM_MILITIA )
	local imcScore = GameRules.GetTeamScore2( TEAM_IMC )

	if ( ( militiaScore >= roundLimit ) || ( imcScore >= roundLimit ) )
		return true

	return false
}

function PointIsWithinBounds( point, mins, maxs )
{
	Assert( mins.x < maxs.x )
	Assert( mins.y < maxs.y )
	Assert( mins.z < maxs.z )

	return ( ( point.z >= mins.z && point.z <= maxs.z ) &&
			 ( point.x >= mins.x && point.x <= maxs.x ) &&
			 ( point.y >= mins.y && point.y <= maxs.y ) )
}

// Nexon bullshit

function GetTeamIndex(team)
{
	if (team)
	{
		for (local count = 0; count < TEAM_COUNT; ++count)
		{
			if (team & (1 << count))
				return count
		}
	}

	return TEAM_UNASSIGNED
}

function GetOtherTeams( guy )
{
	local team

	if ( typeof guy == "integer" )
		team = guy
	else
		team = 1 << guy.GetTeam()

	if (team & (1 << TEAM_IMC))
		return (1 << TEAM_MILITIA)

	if (team & (1 << TEAM_MILITIA))
		return (1 << TEAM_IMC)

	// if (team & (1 << TEAM_SPECTRE))
	// 	return ((1 << TEAM_SURVIVAL0) | (1 << TEAM_SURVIVAL1) | (1 << TEAM_SURVIVAL2) | (1 << TEAM_SURVIVAL3) | (1 << TEAM_SURVIVAL4) | (1 << TEAM_SURVIVAL5) | (1 << TEAM_SURVIVAL6) | (1 << TEAM_SURVIVAL7))

	// if (team & (1 << TEAM_SURVIVAL0))
	// 	return ((1 << TEAM_SURVIVAL1) | (1 << TEAM_SURVIVAL2) | (1 << TEAM_SURVIVAL3) | (1 << TEAM_SURVIVAL4) | (1 << TEAM_SURVIVAL5) | (1 << TEAM_SURVIVAL6) | (1 << TEAM_SURVIVAL7) | (1 << TEAM_SPECTRE))

	// if (team & (1 << TEAM_SURVIVAL1))
	// 	return ((1 << TEAM_SURVIVAL0) | (1 << TEAM_SURVIVAL2) | (1 << TEAM_SURVIVAL3) | (1 << TEAM_SURVIVAL4) | (1 << TEAM_SURVIVAL5) | (1 << TEAM_SURVIVAL6) | (1 << TEAM_SURVIVAL7) | (1 << TEAM_SPECTRE))

	// if (team & (1 << TEAM_SURVIVAL2))
	// 	return ((1 << TEAM_SURVIVAL0) | (1 << TEAM_SURVIVAL1) | (1 << TEAM_SURVIVAL3) | (1 << TEAM_SURVIVAL4) | (1 << TEAM_SURVIVAL5) | (1 << TEAM_SURVIVAL6) | (1 << TEAM_SURVIVAL7) | (1 << TEAM_SPECTRE))

	// if (team & (1 << TEAM_SURVIVAL3))
	// 	return ((1 << TEAM_SURVIVAL0) | (1 << TEAM_SURVIVAL1) | (1 << TEAM_SURVIVAL2) | (1 << TEAM_SURVIVAL4) | (1 << TEAM_SURVIVAL5) | (1 << TEAM_SURVIVAL6) | (1 << TEAM_SURVIVAL7) | (1 << TEAM_SPECTRE))

	// if (team & (1 << TEAM_SURVIVAL4))
	// 	return ((1 << TEAM_SURVIVAL0) | (1 << TEAM_SURVIVAL1) | (1 << TEAM_SURVIVAL2) | (1 << TEAM_SURVIVAL3) | (1 << TEAM_SURVIVAL5) | (1 << TEAM_SURVIVAL6) | (1 << TEAM_SURVIVAL7) | (1 << TEAM_SPECTRE))

	// if (team & (1 << TEAM_SURVIVAL5))
	// 	return ((1 << TEAM_SURVIVAL0) | (1 << TEAM_SURVIVAL1) | (1 << TEAM_SURVIVAL2) | (1 << TEAM_SURVIVAL3) | (1 << TEAM_SURVIVAL4) | (1 << TEAM_SURVIVAL6) | (1 << TEAM_SURVIVAL7) | (1 << TEAM_SPECTRE))

	// if (team & (1 << TEAM_SURVIVAL6))
	// 	return ((1 << TEAM_SURVIVAL0) | (1 << TEAM_SURVIVAL1) | (1 << TEAM_SURVIVAL2) | (1 << TEAM_SURVIVAL3) | (1 << TEAM_SURVIVAL4) | (1 << TEAM_SURVIVAL5) | (1 << TEAM_SURVIVAL7) | (1 << TEAM_SPECTRE))

	// if (team & (1 << TEAM_SURVIVAL7))
	// 	return ((1 << TEAM_SURVIVAL0) | (1 << TEAM_SURVIVAL1) | (1 << TEAM_SURVIVAL2) | (1 << TEAM_SURVIVAL3) | (1 << TEAM_SURVIVAL4) | (1 << TEAM_SURVIVAL5) | (1 << TEAM_SURVIVAL6) | (1 << TEAM_SPECTRE))

	return (1 << TEAM_UNASSIGNED)
}

function IsWinningTeam(team)
{
	if (!level.nv.winningTeam)
		return false

	if (level.nv.winningTeam == team)
		return true

	return false
}

function GetTitanBuildRule()
{
	return 0
}

function IsShoulderTurret( ent )
{
	if ( IsServer() )
	{
		if ( "isShoulderTurret" in ent.s )
			return true
	}

	if ( !IsTurret( ent ) )
		return false

	return ent.GetName().find( "turret_shoulder" ) != null
}

function ShouldPreventFriendlyFire( victim, attacker )
{
	local victimTeam = victim.GetTeam()
	local attackerTeam = attacker.GetTeam()

	if ( victimTeam == attackerTeam )
	{
		if ( victim == attacker )
			return true

		if ( IsFFABased() )
			return false
		
		return true
	}

	return false
}

// R1Delta script-sync parity check.
//
// Remote functions, server vars, entity vars and registered strings travel as
// registration indices, so client and server must register the same names in
// the same order (_remote_functions.nut). Include this file right before
// _remote_functions and call R1DScriptSync_Publish() right after it: the
// server sends its lists to each R1Delta client, and a client whose lists
// differ is told exactly which names differ (tier0 shared/script_sync_parity.cpp).

// Remote-function names are only kept by the native table, so record them as
// _remote_functions.nut registers them.
::_R1DScriptSyncNativeRemote <- ::Remote
::_R1DScriptSyncRemoteFunctions <- []
::Remote <- {
	BeginRegisteringFunctions = function()
	{
		::_R1DScriptSyncNativeRemote.BeginRegisteringFunctions()
	}
	RegisterFunction = function( name )
	{
		::_R1DScriptSyncRemoteFunctions.append( name )
		::_R1DScriptSyncNativeRemote.RegisterFunction( name )
	}
	EndRegisteringFunctions = function()
	{
		::_R1DScriptSyncNativeRemote.EndRegisteringFunctions()
	}
}

// Handle tables map name -> index on the server and index -> name on the client.
function R1DScriptSync_OrderedNames( handles )
{
	local entries = []
	foreach ( key, value in handles )
	{
		if ( typeof key == "integer" )
			entries.append( [ key, value ] )
		else
			entries.append( [ value, key ] )
	}
	entries.sort( function( a, b )
	{
		if ( a[0] < b[0] )
			return -1
		if ( a[0] > b[0] )
			return 1
		return 0
	} )

	local names = []
	foreach ( entry in entries )
		names.append( entry[1] )
	return names
}

function R1DScriptSync_Join( names )
{
	local text = ""
	foreach ( index, name in names )
	{
		if ( index > 0 )
			text += "\n"
		text += name
	}
	return text
}

function R1DScriptSync_Publish()
{
	::Remote <- ::_R1DScriptSyncNativeRemote

	ScriptSyncPublish(
		R1DScriptSync_Join( ::_R1DScriptSyncRemoteFunctions ),
		R1DScriptSync_Join( R1DScriptSync_OrderedNames( _serverVarHandles ) ),
		R1DScriptSync_Join( R1DScriptSync_OrderedNames( _entityClassVarHandles ) ),
		R1DScriptSync_Join( R1DScriptSync_OrderedNames( ::_stringToIndex ) ) )
}

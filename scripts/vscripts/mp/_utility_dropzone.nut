const DEFAULT_DROPPOD_MODEL = "models/vehicle/droppod_battery/droppod_battery_export.mdl"
const DEFAULT_FIRETEAM_DROP_MODEL = "models/vehicle/droppod_fireteam/droppod_fireteam.mdl"

function main()
{
	Globalize( GetMapCenter )
	Globalize( GetPlayerFromEntity )
}


function GetMapCenter()
{
	local center = GetEnt( "MapCenter" )
	local org

	if ( center != null )
	{
		org = center.GetOrigin()
	}

	org = GetCenter( g_dropZones )

	return org
}


function GetPlayerFromEntity( ent )
{
	local player = null

	if ( ent.IsPlayer() )
	{
		player = ent
	}
	else if ( ent.IsNPC() )
	{
		player = ent.GetOwnerPlayer()
		if ( !player )
		{
			player = ent.GetBossPlayer()
		}
	}
	else
	{
		player = ent.GetOwner()
		if ( !player || !player.IsPlayer() )
			return null
	}

	if ( IsValid_ThisFrame( player ) )
		return player

	return null
}

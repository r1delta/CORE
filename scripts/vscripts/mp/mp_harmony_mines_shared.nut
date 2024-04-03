function main()
{
	if ( reloadingScripts )
		return

	level.WARNING_LIGHT_ON_MODEL		<- "models/lamps/warning_light_ON_orange.mdl"
	level.WARNING_LIGHT_OFF_MODEL 		<- "models/lamps/warning_light_orange.mdl"

	// Precaching models for clientside model swaps only works on the server!
	if ( IsServer() )
	{
		PrecacheModel( level.WARNING_LIGHT_ON_MODEL )
		PrecacheModel( level.WARNING_LIGHT_OFF_MODEL )
	}

	// sets "map owner" for scripting that reacts to hardpoint control
	level.HOME_TEAM <- TEAM_MILITIA
	level.AWAY_TEAM <- TEAM_IMC
}

main()
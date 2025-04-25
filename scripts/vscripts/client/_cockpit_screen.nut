

function main()
{
	file.titanModels <- {}
	file.titanModels[ "models/weapons/arms/atlaspov_cockpit.mdl" ] <- true
	file.titanModels[ "models/weapons/arms/atlaspov_cockpit2.mdl" ] <- true
	file.titanModels[ "models/weapons/arms/ogrepov_cockpit.mdl" ] <- true
	file.titanModels[ "models/weapons/arms/stryderpov_cockpit.mdl" ] <- true	
    file.titanModels[ "models/weapons/arms/destroyer_pov_cockpit.mdl" ] <- true
	Globalize( IsTitanCockpitModelName )
	Globalize( IsHumanCockpitModelName )
}

function IsTitanCockpitModelName( cockpitModelName )
{
	return cockpitModelName in file.titanModels
}

function IsHumanCockpitModelName( cockpitModelName )
{
	return cockpitModelName == "models/weapons/arms/human_pov_cockpit.mdl"
}
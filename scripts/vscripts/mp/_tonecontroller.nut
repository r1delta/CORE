function main()
{
	level.toneController <- CreateEntity( "env_tonemap_controller" )
	DispatchSpawn( level.toneController )

	Globalize( UpdateToneSettings )

	Globalize( SetAutoExposureMin )
	Globalize( SetAutoExposureMax )
	Globalize( SetTonemapScale )
	Globalize( UseDefaultAutoExposure )
	Globalize( SetBloomScale )
	Globalize( SetTonemapRate )
}


function UpdateToneSettings()
{
	local mapName = GetMapName()

	UseDefaultAutoExposure()

	switch ( mapName )
	{
		case "mp_angel_city":
			SetAutoExposureMin( 1.11 )
			SetAutoExposureMax( 1.5 )
			break;
			
		case "mp_boneyard":
			SetAutoExposureMin( 1.3 )
			SetAutoExposureMax( 2.3 )
			break;
						
		case "mp_lagoon":
			SetAutoExposureMin( 0.8 )
			SetAutoExposureMax( 2.0 )
			break;	
				
		case "mp_o2":
			SetAutoExposureMin( 1.0 )
			SetAutoExposureMax( 2.0 )
			break;

		case "mp_fracture":
			SetAutoExposureMin( 1.25 )
			SetAutoExposureMax( 4.0 )
			break;
			
		case "mp_training_ground":
			SetAutoExposureMin( 0.6 )
			SetAutoExposureMax( 2.5 )
			break;
			
		case "mp_relic":
			SetAutoExposureMin( 0.9 )
			SetAutoExposureMax( 2.0 )
			break;
			
		case "mp_smugglers_cove":
			SetAutoExposureMin( 0.5 )
			SetAutoExposureMax( 0.7 )
			break;
			
		case "mp_swampland":
			SetAutoExposureMin( 0.5 )
			SetAutoExposureMax( 0.8 )
			break;			
			
		case "mp_runoff":
			SetAutoExposureMin( 0.5 )
			SetAutoExposureMax( 1.0 )
			break;		

		case "mp_wargames":
			SetAutoExposureMin( 1.0 )
			SetAutoExposureMax( 1.75 )
			break;	
			
		case "mp_harmony_mines":
			SetAutoExposureMin( 1.0 )
			SetAutoExposureMax( 1.75 )
			break;		
			
		case "mp_switchback":
			SetAutoExposureMin( 1.0 )
			SetAutoExposureMax( 1.75 )
			break;					

		case "mp_sandtrap":
			SetAutoExposureMin( 0.5 )
			SetAutoExposureMax( 1.15 )
			break;					

		default:
			UseDefaultAutoExposure()
			break
	}
}


function EntitiesDidLoad()
{
	UpdateToneSettings()
}


function SetAutoExposureMin( value )
{
	Assert( type( value ) == "float" )
	level.toneController.Fire( "SetAutoExposureMin", value.tofloat() )
}

function SetAutoExposureMax( value )
{
	Assert( type( value ) == "float" )
	level.toneController.Fire( "SetAutoExposureMax", value.tofloat() )
}

function SetTonemapScale( value )
{
	Assert( type( value ) == "float" )
	level.toneController.Fire( "SetTonemapScale", value.tofloat() )
}

function UseDefaultAutoExposure()
{
	level.toneController.Fire( "UseDefaultAutoExposure" )
}

function SetBloomScale( value )
{
	Assert( type( value ) == "float" )
	level.toneController.Fire( "SetBloomScale", value.tofloat() )
}

function SetTonemapRate( value )
{
	Assert( type( value ) == "float" )
	level.toneController.Fire( "SetTonemapRate", value.tofloat() )
}

enum eHackedFxType
{
	FX_WARNING_LIGHT,

	FX_EXPLO_ENERGY_1,
	FX_EXPLO_ENERGY_2,

	FX_ENERGY,

	FX_SPARK,
	FX_SPARK_1,
	FX_SPARK_2,
	FX_SPARK_3,
	FX_SPARK_4,

	FX_EXPLO_BUILDING
}

function main()
{
	Globalize( PlayNomalStatusEffect_A )
	Globalize( PlayNomalStatusEffect_B )
	Globalize( StopNormalStatusEffect_A )
	Globalize( StopNormalStatusEffect_B)
	Globalize( PlayHackedEffect_A )
	Globalize( PlayHackedEffect_B )
	Globalize( SetUpHackedFx )
	Globalize( RefreshBigbrotherPanelFx )
	Globalize( AllStopBigbrotherPanelFx )

	level.uniqueIndex <- 0

	level.HackedfxID <- {}
	level.HackedfxID[ eHackedFxType.FX_WARNING_LIGHT ]			<- PrecacheParticleSystem( "Warning_light_orange_blink" )
	level.HackedfxID[ eHackedFxType.FX_EXPLO_ENERGY_1 ]			<- PrecacheParticleSystem( "exp_energy_fx_1" )
	level.HackedfxID[ eHackedFxType.FX_EXPLO_ENERGY_2 ]			<- PrecacheParticleSystem( "exp_energy_fx_2" )
	level.HackedfxID[ eHackedFxType.FX_ENERGY ]					<- PrecacheParticleSystem( "energy_exp" )
	level.HackedfxID[ eHackedFxType.FX_SPARK ]					<- PrecacheParticleSystem( "exp_spark_top_time" )
	level.HackedfxID[ eHackedFxType.FX_SPARK_1 ]				<- PrecacheParticleSystem( "exp_spark_time" )
	level.HackedfxID[ eHackedFxType.FX_SPARK_2 ]				<- PrecacheParticleSystem( "exp_spark_time_2" )
	level.HackedfxID[ eHackedFxType.FX_SPARK_3 ]				<- PrecacheParticleSystem( "exp_spark_3" )
	level.HackedfxID[ eHackedFxType.FX_SPARK_4 ]				<- PrecacheParticleSystem( "exp_spark_4" )
	level.HackedfxID[ eHackedFxType.FX_EXPLO_BUILDING ]			<- PrecacheParticleSystem( "building_exp" )

	PrintTable( level.HackedfxID )


	level.fxWarningLight_A <- []
	level.fxEnergy_A1 <- []
	level.fxEnergy_A2 <- []
	level.fxEnergy_A3 <- []
	level.fxExploSpark_A1 <- []
	level.fxExploSpark_A2 <- []
	level.fxSpark_A1 <- []
	level.fxSpark_A2 <- []
	level.fxSpark_A3 <- []
	level.fxSpark_A4 <- []
	level.fxSpark_A5 <- []
	level.fxSpark_A6 <- []
	level.fxSpark_A7 <- []
	level.fxSpark_A8 <- []

	level.fxWarningLight_B <- []
	level.fxEnergy_B1 <- []
	level.fxEnergy_B2 <- []
	level.fxEnergy_B3 <- []
	level.fxExploSpark_B1 <- []
	level.fxExploSpark_B2 <- []
	level.fxSpark_B1 <- []
	level.fxSpark_B2 <- []
	level.fxSpark_B3 <- []
	level.fxSpark_B4 <- []
	level.fxSpark_B5 <- []
	level.fxSpark_B6 <- []
}

function SetUpHackedFx()
{
	// A Side
	level.fxWarningLight_A = GetClientEntArray( "info_target_clientside", "warning_light_orange_blink_exp_mission_A" )
	PrimeClientsideFxEnts( level.fxWarningLight_A, eHackedFxType.FX_WARNING_LIGHT )

	level.fxEnergy_A1 = GetClientEntArray( "info_target_clientside", "energy_A1" )
	PrimeClientsideFxEnts( level.fxEnergy_A1, eHackedFxType.FX_EXPLO_ENERGY_1 )

	level.fxEnergy_A2 = GetClientEntArray( "info_target_clientside", "energy_A2" )
	PrimeClientsideFxEnts( level.fxEnergy_A2, eHackedFxType.FX_EXPLO_ENERGY_2 )

	level.fxEnergy_A3 = GetClientEntArray( "info_target_clientside", "energy_A3" )
	PrimeClientsideFxEnts( level.fxEnergy_A3, eHackedFxType.FX_ENERGY )

	level.fxExploSpark_A1 = GetClientEntArray( "info_target_clientside", "e_spark_A1" )
	PrimeClientsideFxEnts( level.fxExploSpark_A1, eHackedFxType.FX_SPARK_1 )

	level.fxExploSpark_A2 = GetClientEntArray( "info_target_clientside", "e_spark_A2" )
	PrimeClientsideFxEnts( level.fxExploSpark_A2, eHackedFxType.FX_SPARK_2 )

	level.fxSpark_A1 = GetClientEntArray( "info_target_clientside", "spark_A1" )
	PrimeClientsideFxEnts( level.fxSpark_A1, eHackedFxType.FX_SPARK_4 )
	
	level.fxSpark_A4 = GetClientEntArray( "info_target_clientside", "spark_A4" )
	PrimeClientsideFxEnts( level.fxSpark_A4, eHackedFxType.FX_SPARK )
	
	level.fxSpark_A5 = GetClientEntArray( "info_target_clientside", "spark_A5" )
	PrimeClientsideFxEnts( level.fxSpark_A5, eHackedFxType.FX_SPARK_3 )
	
	level.fxSpark_A6 = GetClientEntArray( "info_target_clientside", "spark_A6" )
	PrimeClientsideFxEnts( level.fxSpark_A6, eHackedFxType.FX_SPARK_3 )
	
	level.fxSpark_A7 = GetClientEntArray( "info_target_clientside", "spark_A7" )
	PrimeClientsideFxEnts( level.fxSpark_A7, eHackedFxType.FX_SPARK )
	
	level.fxSpark_A8 = GetClientEntArray( "info_target_clientside", "spark_A8" )
	PrimeClientsideFxEnts( level.fxSpark_A8, eHackedFxType.FX_SPARK )

	level.fxSpark_A2 = GetClientEntArray( "info_target_clientside", "spark_A2" )
	PrimeClientsideFxEnts( level.fxSpark_A2, eHackedFxType.FX_SPARK_4 )

	level.fxSpark_A3 = GetClientEntArray( "info_target_clientside", "spark_A3" )
	PrimeClientsideFxEnts( level.fxSpark_A3, eHackedFxType.FX_SPARK )
	
	//

	// B Side
	level.fxWarningLight_B = GetClientEntArray( "info_target_clientside", "warning_light_orange_blink_exp_mission_B" )
	PrimeClientsideFxEnts( level.fxWarningLight_B, eHackedFxType.FX_WARNING_LIGHT )

	level.fxEnergy_B1 = GetClientEntArray( "info_target_clientside", "energy_B1" )
	PrimeClientsideFxEnts( level.fxEnergy_B1, eHackedFxType.FX_EXPLO_ENERGY_1 )

	level.fxEnergy_B2 = GetClientEntArray( "info_target_clientside", "energy_B2" )
	PrimeClientsideFxEnts( level.fxEnergy_B2, eHackedFxType.FX_EXPLO_ENERGY_2 )

	level.fxEnergy_B3 = GetClientEntArray( "info_target_clientside", "energy_B3" )
	PrimeClientsideFxEnts( level.fxEnergy_B3, eHackedFxType.FX_ENERGY )

	level.fxExploSpark_B1 = GetClientEntArray( "info_target_clientside", "e_spark_B1" )
	PrimeClientsideFxEnts( level.fxExploSpark_B1, eHackedFxType.FX_SPARK_1 )

	level.fxExploSpark_B2 = GetClientEntArray( "info_target_clientside", "e_spark_B2" )
	PrimeClientsideFxEnts( level.fxExploSpark_B2, eHackedFxType.FX_SPARK_2 )

	level.fxSpark_B1 = GetClientEntArray( "info_target_clientside", "spark_B1" )
	PrimeClientsideFxEnts( level.fxSpark_B1, eHackedFxType.FX_SPARK_3 )

	level.fxSpark_B2 = GetClientEntArray( "info_target_clientside", "spark_B2" )
	PrimeClientsideFxEnts( level.fxSpark_B2, eHackedFxType.FX_SPARK_3 )

	level.fxSpark_B3 = GetClientEntArray( "info_target_clientside", "spark_B3" )
	PrimeClientsideFxEnts( level.fxSpark_B3, eHackedFxType.FX_SPARK_3 )

	level.fxSpark_B4 = GetClientEntArray( "info_target_clientside", "spark_B4" )
	PrimeClientsideFxEnts( level.fxSpark_B4, eHackedFxType.FX_SPARK_3 )

	level.fxSpark_B5 = GetClientEntArray( "info_target_clientside", "spark_B5" )
	PrimeClientsideFxEnts( level.fxSpark_B5, eHackedFxType.FX_SPARK_4 )

	level.fxSpark_B6 = GetClientEntArray( "info_target_clientside", "spark_B6" )
	PrimeClientsideFxEnts( level.fxSpark_B6, eHackedFxType.FX_SPARK )
	//
}

function PairFxWithEntity( entityArray, fxArray, fxID, maxDist = 32 )
{
	local maxDist = pow( maxDist, 2 )

	// find the closest fx to an entity and pair them up
	foreach( entity in entityArray )
	{
		local origin = entity.GetOrigin()
		foreach( index, fxEnt in fxArray )
		{
			if ( DistanceSqr( fxEnt.GetOrigin(), origin ) < maxDist )
			{
				Assert( !( "fxEnt" in entity.s ), "tried to add an fx to a entity that already had one paired with it." )
				entity.s.fxEnt		<- fxEnt
				entity.s.fxID		<- fxID
				entity.s.fxHandle 	<- null
				entity.s.index		<- level.uniqueIndex++
				fxArray.remove( index )
				break
			}
		}
	}
}

function PrimeClientsideFxEnts( FxEntArray, fxTypeID )
{
	foreach( fxEnt in FxEntArray )
	{
		fxEnt.s.fxID		<- level.HackedfxID[ fxTypeID ]
		fxEnt.s.fxHandle	<- null
		fxEnt.s.index		<- level.uniqueIndex++
		fxEnt.s.startSound	<- null
		fxEnt.s.sound		<- null
		fxEnt.s.soundActive	<- false

/*
		if ( fxTypeID in level.fxSoundTableStart )
		{
			local startSound = level.fxSoundTableStart[ fxTypeID ]
			fxEnt.s.startSound = startSound
		}

		if ( fxTypeID in level.fxSoundTable )
		{
			local soundArray = level.fxSoundTable[ fxTypeID ]
			local sound = soundArray[ fxEnt.s.index % soundArray.len() ]
			fxEnt.s.sound = sound
		}
*/
	}
}

function TurnOnFx( fxEnt )
{
	if ( fxEnt.s.fxHandle )
		return

	local origin = fxEnt.GetOrigin()
	local angles = fxEnt.GetAngles()

	fxEnt.s.fxHandle = StartParticleEffectInWorldWithHandle( fxEnt.s.fxID, origin, angles )
	EffectSetDontKillForReplay( fxEnt.s.fxHandle )
}

function TurnOffFx( fxEnt )
{
	if ( fxEnt.s.fxHandle )
	{
		EffectStop( fxEnt.s.fxHandle, false, true )
		fxEnt.s.fxHandle = null
	}
}

// 라운드 시작 시 기본으로 플레이 해야 할 이펙트. 해제시 꺼짐.
function PlayNomalStatusEffect_A()
{
	printt("call PlayNomalStatusEffect_A")
	
	// 시작시 켜져있음. 해제 시 꺼짐. FX_EXPLO_ENERGY_1
	foreach( fxEnt in level.fxEnergy_A1 )
	{
		TurnOnFx( fxEnt )
	}	
}
function PlayNomalStatusEffect_B()
{
	// 시작시 켜져있음. 해제 시 꺼짐. FX_EXPLO_ENERGY_1
	foreach( fxEnt in level.fxEnergy_B1 )
	{
		TurnOnFx( fxEnt )
	}	
}
//

function StopNormalStatusEffect_A()
{
	foreach( fxEnt in level.fxEnergy_A1 )
	{
		TurnOffFx( fxEnt )
	}
}

function StopNormalStatusEffect_B()
{
	foreach( fxEnt in level.fxEnergy_B1 )
	{
		TurnOffFx( fxEnt )
	}
}

// A 패널 이펙트 재생.
function PlayHackedEffect_A( panel )
{
	// 1. FX_WARNING_LIGHT
	foreach( fxEnt in level.fxWarningLight_A )
	{
		TurnOnFx( fxEnt )
	}
	//

	// 2. FX_EXPLO_ENERGY_1 Stop
	StopNormalStatusEffect_A()
	//

	// 3. FX_EXPLO_ENERGY_2
	foreach( fxEnt in level.fxEnergy_A2 )
	{
		TurnOnFx( fxEnt )
	}
	//

	// 4. FX_SPARK
	foreach( fxEnt in level.fxSpark_A3 )
	{
		TurnOnFx( fxEnt )
	}
	//
	

	WaitSignalTimeout( panel, 5, "StopHackedEffect" ) // 5초 후

	// 5. FX_SPARK_4
	foreach( fxEnt in level.fxSpark_A2 )
	{
		TurnOnFx( fxEnt )
	}
	//
	
	WaitSignalTimeout( panel, 2, "StopHackedEffect" ) // 7초 후

	// 6. FX_SPARK
	foreach( fxEnt in level.fxSpark_A4 )
	{
		TurnOnFx( fxEnt )
	}
	//
	
	WaitSignalTimeout( panel, 3, "StopHackedEffect" ) // 10초 후
	
	// 4. FX_SPARK
	foreach( fxEnt in level.fxSpark_A7 )
	{
		TurnOnFx( fxEnt )
	}
	//
	
	WaitSignalTimeout( panel, 5, "StopHackedEffect" ) // 15초 후

	// 6. FX_SPARK_3
	foreach( fxEnt in level.fxSpark_A1 )
	{
		TurnOnFx( fxEnt )
	}
	//
	
	WaitSignalTimeout( panel, 3, "StopHackedEffect" ) // 18초 후

	// 6. FX_SPARK_3
	foreach( fxEnt in level.fxSpark_A5 )
	{
		TurnOnFx( fxEnt )
	}
	
	// 6. FX_SPARK
	foreach( fxEnt in level.fxSpark_A8 )
	{
		TurnOnFx( fxEnt )
	}
	//
	
	WaitSignalTimeout( panel, 2, "StopHackedEffect" ) // 20초 후

	// 6. FX_SPARK_3
	foreach( fxEnt in level.fxSpark_A6 )
	{
		TurnOnFx( fxEnt )
	}
	//
	
	
	WaitSignalTimeout( panel, 30, "StopHackedEffect" ) // 50초 후

	// 7. FX_SPARK_2
	foreach( fxEnt in level.fxExploSpark_A2 )
	{
		TurnOnFx( fxEnt )
	}
	//

	// 8. FX_SPARK_1
	foreach( fxEnt in level.fxExploSpark_A1 )
	{
		TurnOnFx( fxEnt )
	}
	//

	WaitSignalTimeout( panel, 9.5, "StopHackedEffect" ) // 59.5초 후

	// 9. FX_ENERGY
	foreach( fxEnt in level.fxEnergy_A3 )
	{
		TurnOnFx( fxEnt )
	}
	//

}

// B 패널 이펙트 재생.
function PlayHackedEffect_B( panel )
{
	// 1. FX_WARNING_LIGHT
	foreach( fxEnt in level.fxWarningLight_B )
	{
		TurnOnFx( fxEnt )
	}
	
	// 2. FX_EXPLO_ENERGY_1 Stop
	StopNormalStatusEffect_B()
	//

	// 3. FX_EXPLO_ENERGY_2
	foreach( fxEnt in level.fxEnergy_B2 )
	{
		TurnOnFx( fxEnt )
	}

	//
	foreach( fxEnt in level.fxSpark_B6 )
	{
		TurnOnFx( fxEnt )
	}
	// 4. FX_SPARK
	

	WaitSignalTimeout( panel, 5, "StopHackedEffect" ) // 5초 후

	// 5. FX_SPARK_4
	foreach( fxEnt in level.fxSpark_B5 )
	{
		TurnOnFx( fxEnt )
	}
	//

	WaitSignalTimeout( panel, 5, "StopHackedEffect" ) // 10초 후

	// 6. FX_SPARK_3_4
	foreach( fxEnt in level.fxSpark_B4 )
	{
		TurnOnFx( fxEnt )
	}
	//

	WaitSignalTimeout( panel, 10, "StopHackedEffect" ) // 20초 후

	// 7. FX_SPARK_3_3
	foreach( fxEnt in level.fxSpark_B3 )
	{
		TurnOnFx( fxEnt )
	}
	//

	WaitSignalTimeout( panel, 20, "StopHackedEffect" ) // 40초 후

	// 8. FX_SPARK_3_2
	foreach( fxEnt in level.fxSpark_B2 )
	{
		TurnOnFx( fxEnt )
	}
	//

	WaitSignalTimeout( panel, 5, "StopHackedEffect" ) // 45초 후

	// 9. FX_SPARK_3_1
	foreach( fxEnt in level.fxSpark_B1 )
	{
		TurnOnFx( fxEnt )
	}
	//

	WaitSignalTimeout( panel, 5, "StopHackedEffect" ) // 50초 후

	// 10. FX_SPARK_2
	foreach( fxEnt in level.fxExploSpark_B2 )
	{
		TurnOnFx( fxEnt )
	}
	//

	// 11. FX_SPARK_1
	foreach( fxEnt in level.fxExploSpark_B1 )
	{
		TurnOnFx( fxEnt )
	}
	//

	WaitSignalTimeout( panel, 9.5, "StopHackedEffect" ) // 59.5초 후

	// 12. FX_ENERGY
	foreach( fxEnt in level.fxEnergy_B3 )
	{
		TurnOnFx( fxEnt )
	}
	//
}

function RefreshBigbrotherPanelFx()
{
	PlayNomalStatusEffect_A()
	PlayNomalStatusEffect_B()

	local fxEntArray = clone level.fxWarningLight_A
	fxEntArray.extend( level.fxEnergy_A2 )
	fxEntArray.extend( level.fxEnergy_A3 )
	fxEntArray.extend( level.fxExploSpark_A1 )
	fxEntArray.extend( level.fxExploSpark_A2 )
	fxEntArray.extend( level.fxSpark_A1 )
	fxEntArray.extend( level.fxSpark_A2 )
	fxEntArray.extend( level.fxSpark_A3 )
	fxEntArray.extend( level.fxSpark_A4 )
	fxEntArray.extend( level.fxSpark_A5 )
	fxEntArray.extend( level.fxSpark_A6 )
	fxEntArray.extend( level.fxSpark_A7 )
	fxEntArray.extend( level.fxSpark_A8 )
	fxEntArray.extend( level.fxWarningLight_B )
	fxEntArray.extend( level.fxEnergy_B2 )
	fxEntArray.extend( level.fxEnergy_B3 )
	fxEntArray.extend( level.fxExploSpark_B1 )
	fxEntArray.extend( level.fxExploSpark_B2 )
	fxEntArray.extend( level.fxSpark_B1 )
	fxEntArray.extend( level.fxSpark_B2 )
	fxEntArray.extend( level.fxSpark_B3 )
	fxEntArray.extend( level.fxSpark_B4 )
	fxEntArray.extend( level.fxSpark_B5 )
	fxEntArray.extend( level.fxSpark_B6 )

	foreach( fxEnt in fxEntArray )
		TurnOffFx( fxEnt )
}

function AllStopBigbrotherPanelFx()
{
	local fxEntArray = clone level.fxWarningLight_A
	fxEntArray.extend( level.fxEnergy_A1 )
	fxEntArray.extend( level.fxEnergy_A2 )
	fxEntArray.extend( level.fxEnergy_A3 )
	fxEntArray.extend( level.fxExploSpark_A1 )
	fxEntArray.extend( level.fxExploSpark_A2 )
	fxEntArray.extend( level.fxSpark_A1 )
	fxEntArray.extend( level.fxSpark_A2 )
	fxEntArray.extend( level.fxSpark_A3 )
	fxEntArray.extend( level.fxSpark_A4 )
	fxEntArray.extend( level.fxSpark_A5 )
	fxEntArray.extend( level.fxSpark_A6 )
	
	fxEntArray.extend( level.fxEnergy_B1 )
	fxEntArray.extend( level.fxEnergy_B1 )
	fxEntArray.extend( level.fxEnergy_B2 )
	fxEntArray.extend( level.fxEnergy_B3 )
	fxEntArray.extend( level.fxWarningLight_B )
	fxEntArray.extend( level.fxExploSpark_B2 )
	fxEntArray.extend( level.fxSpark_B1 )
	fxEntArray.extend( level.fxSpark_B2 )
	fxEntArray.extend( level.fxSpark_B3 )
	fxEntArray.extend( level.fxSpark_B4 )
	fxEntArray.extend( level.fxSpark_B5 )
	fxEntArray.extend( level.fxSpark_B6 )

	foreach( fxEnt in fxEntArray )
		TurnOffFx( fxEnt )
}
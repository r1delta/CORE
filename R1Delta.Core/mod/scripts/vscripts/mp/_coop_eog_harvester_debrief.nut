const HARVESTERSTATUS_TIMEINTERVAL		= 10

function main()
{
	file.timeIntervalCount <- 0
	file.harvesterHealthStatus_WaveStartOrEnd	<- []
	file.harvesterHealthStatus_TimeInterval 	<- {}
}

function Add_WaveStartOrEnd_HarvesterStatus()
{
	local wave 				= level.nv.TDCurrWave
	local healthRatio		= Generator_GetHealthRatio()
	local time				= Time() - level.nv.coopStartTime

	file.harvesterHealthStatus_WaveStartOrEnd.append( [ time.tointeger(), wave, healthRatio ] )
}
Globalize ( Add_WaveStartOrEnd_HarvesterStatus )

function Add_TimeInterval_HarvesterStatus()
{
	local wave 				= level.nv.TDCurrWave
	local healthRatio		= Generator_GetHealthRatio()
	local time				= file.timeIntervalCount * HARVESTERSTATUS_TIMEINTERVAL
	file.timeIntervalCount++
	file.harvesterHealthStatus_TimeInterval[ time ] <- [ wave, healthRatio ]
}
Globalize ( Add_TimeInterval_HarvesterStatus )

function TrackHarvesterHealthStatusOverTime( delay = 0 )
{
	wait delay
	while( !Coop_IsGameOver() )
	{
		Add_TimeInterval_HarvesterStatus()

		wait HARVESTERSTATUS_TIMEINTERVAL
	}
}
Globalize( TrackHarvesterHealthStatusOverTime )


function GetPrioritizedTimeDataPoints( timeAfterEndOfGame )
{
	local adjustedGameLength = (Time() - level.nv.coopStartTime - timeAfterEndOfGame).tointeger()
	local timeInBetweenRecords = ( adjustedGameLength.tofloat() / HARVESTER_GRAPH_DATA_POINTS )

	local harvesterPointsOverTime = []
	for( local i = 0; i <= HARVESTER_GRAPH_DATA_POINTS; i++ )
	{
		local dataPointTime = ( timeInBetweenRecords * i ).tointeger()
		local remainder = dataPointTime % HARVESTERSTATUS_TIMEINTERVAL
		local lowerBoundTime = 	dataPointTime - remainder
		local lowerBoundRatio = file.harvesterHealthStatus_TimeInterval[ lowerBoundTime ][1]
		local upperBoundTime = dataPointTime + ( HARVESTERSTATUS_TIMEINTERVAL - remainder )
		local upperBoundRatio = file.harvesterHealthStatus_TimeInterval[ upperBoundTime ][1]
		local waveToReport = file.harvesterHealthStatus_TimeInterval[ upperBoundTime ][0]
		if ( upperBoundRatio > lowerBoundRatio )
		{
			harvesterPointsOverTime.append( [ upperBoundTime, waveToReport, upperBoundRatio ] )
		}
		else
		{
			local averageHarvesterHealthRatio = GraphCapped( dataPointTime, lowerBoundTime, upperBoundTime, lowerBoundRatio, upperBoundRatio )
			harvesterPointsOverTime.append( [ dataPointTime, waveToReport, averageHarvesterHealthRatio ] )
		}

	}

	return harvesterPointsOverTime
}
Globalize( GetPrioritizedTimeDataPoints )

function GetWaveDataPointTable()
{
	return file.harvesterHealthStatus_WaveStartOrEnd
}
Globalize( GetWaveDataPointTable )
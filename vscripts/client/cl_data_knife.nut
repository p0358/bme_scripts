const MAX_PROGRESS_BAR = 1000

const KNIFE_STAGE_OUTER = 0
const KNIFE_STAGE_MID = 1
const KNIFE_STAGE_INNER = 2
const KNIFE_STAGES = 3

const RING_FADE_TIME = 0.35

function main()
{
	Globalize( ServerCallback_DataKnifeReset )
	Globalize( ServerCallback_DataKnifeStartLeech )
	Globalize( ServerCallback_DataKnifeCancelLeech )
	Globalize( ServerCallback_DataKnifeStartLeechTimePassed )

	Globalize( VMTCallback_DataKnifeCounterAlpha_Lock   )
	Globalize( VMTCallback_DataKnifeCounterAlpha_Unlock )


	Globalize( VMTCallback_DataKnifeMidCircleAlpha_Lock )
	Globalize( VMTCallback_DataKnifeInnerCircleAlpha_Lock )
	Globalize( VMTCallback_DataKnifeOuterCircleAlpha_Lock )

	Globalize( VMTCallback_DataKnifeMidCircleAlpha_Unlock )
	Globalize( VMTCallback_DataKnifeInnerCircleAlpha_Unlock )
	Globalize( VMTCallback_DataKnifeOuterCircleAlpha_Unlock )

	Globalize( VMTCallback_ProgressionMidBar )
	Globalize( VMTCallback_ProgressionInnerBar )
	Globalize( VMTCallback_ProgressionOuterBar )

	Globalize( VMTCallback_DataKnifeDigit1 )
	Globalize( VMTCallback_DataKnifeDigit10 )
	Globalize( VMTCallback_DataKnifeDigit100 )

	Globalize( VMTCallback_DataKnifeMidCircleColor   )
	Globalize( VMTCallback_DataKnifeInnerCircleColor )
	Globalize( VMTCallback_DataKnifeOuterCircleColor )

	Globalize( VMTCallback_DataKnifeMidDigitColor   )
	Globalize( VMTCallback_DataKnifeInnerDigitColor )
	Globalize( VMTCallback_DataKnifeOuterDigitColor )

	Globalize( VMTCallback_DataKnifeMidCircleBackgroundColor   )
	Globalize( VMTCallback_DataKnifeInnerCircleBackgroundColor )
	Globalize( VMTCallback_DataKnifeOuterCircleBackgroundColor )

	Globalize( VMTCallback_DataKnifeMidCircleAlpha )
	Globalize( VMTCallback_DataKnifeInnerCircleAlpha )
	Globalize( VMTCallback_DataKnifeOuterCircleAlpha )

	Globalize( VMTCallback_DataKnifeMidCircleRotation )
	Globalize( VMTCallback_DataKnifeInnerCircleRotation )
	Globalize( VMTCallback_DataKnifeOuterCircleRotation )

	Globalize( StartLeech )
	Globalize( GetStageProgress )

	RegisterSignal( "DataKnifeCancel" )

	file.active <- false
	file.stageStartTime <- []
	file.stageEndTime <- []
	file.digit <- []
	for ( local i = 0; i < KNIFE_STAGES; i++ )
	{
		file.stageStartTime.append( 0 )
		file.stageEndTime.append( 0 )
		file.digit.append( RandomInt( 10 ) )
	}
}

function VMTCallback_DataKnifeOuterCircleRotation( player )
{
	return DataKnifeCircleRotation( player, KNIFE_STAGE_OUTER )
}

function VMTCallback_DataKnifeMidCircleRotation( player )
{
	return DataKnifeCircleRotation( player, KNIFE_STAGE_MID )
}

function VMTCallback_DataKnifeInnerCircleRotation( player )
{
	return DataKnifeCircleRotation( player, KNIFE_STAGE_INNER )
}

function DataKnifeCircleRotation( player, stage )
{
	if ( !file.active )
		return sin( Time() * 360 )

	local result = DataKnifeProgression( player, stage )
	if ( result > 1 )
		result = 1
	result = 1 - result
//	result = clamp( result, 0, 1 )
	return result * 360

	local progress = GetStageProgress( stage )
	local colorProgress = Vector( 0.5, 0.5, 0.5 )
	local colorDone = Vector( 1.0, 1.0, 1.0 )

	if ( progress <= 0 )
	{
		return 0
	}

	local result = GraphCapped( progress, 1, 0, 0, 360 )
	return result
}

function VMTCallback_DataKnifeOuterCircleBackgroundColor( player )
{
	return DataKnifeCircleBackgroundColor( player, KNIFE_STAGE_OUTER )
}

function VMTCallback_DataKnifeMidCircleBackgroundColor( player )
{
	return DataKnifeCircleBackgroundColor( player, KNIFE_STAGE_MID )
}

function VMTCallback_DataKnifeInnerCircleBackgroundColor( player )
{
	return DataKnifeCircleBackgroundColor( player, KNIFE_STAGE_INNER )
}

function DataKnifeCircleBackgroundColor( player, stage )
{
	return Vector(1,1,1)
}

function VMTCallback_DataKnifeOuterCircleColor( player )
{
	return DataKnifeCircleColor( player, KNIFE_STAGE_OUTER )
}

function VMTCallback_DataKnifeMidCircleColor( player )
{
	return DataKnifeCircleColor( player, KNIFE_STAGE_MID )
}

function VMTCallback_DataKnifeInnerCircleColor( player )
{
	return DataKnifeCircleColor( player, KNIFE_STAGE_INNER )
}

function DataKnifeCircleColor( player, stage )
{
	if ( !file.active )
	{
		return Vector(0,0,0)
	}

	local progress = GetStageProgress( stage )
	local colorProgress = Vector( 1.0, 0.65, 0.2 )
//	local colorProgress = Vector( 0.2, 0.85, 0.85 )
	local colorDone1 = Vector( 0.5, 1.0, 1.0 )
	local colorDone2 = Vector( 1.0, 1.0, 1.0 )

	if ( progress <= 1 )
	{
		return colorProgress
	}
	else
	{
		local startTime = file.stageEndTime[ stage ]
		local endTime = startTime + RING_FADE_TIME
		local dif = GraphCapped( Time(), startTime, endTime, 0, 1 )
		return colorDone1 * dif + colorDone2 * ( 1 - dif )
	}
}

function VMTCallback_DataKnifeOuterDigitColor( player )
{
	return DataKnifeDigitColor( player, KNIFE_STAGE_OUTER )
}

function VMTCallback_DataKnifeMidDigitColor( player )
{
	return DataKnifeDigitColor( player, KNIFE_STAGE_MID )
}

function VMTCallback_DataKnifeInnerDigitColor( player )
{
	return DataKnifeDigitColor( player, KNIFE_STAGE_INNER )
}

function DataKnifeDigitColor( player, stage )
{
	if ( !file.active )
	{
		return Vector(0,0,0)
	}

	local progress = GetStageProgress( stage )
	local innerProgress = GetStageProgress( KNIFE_STAGE_INNER )

	local colorProgress
	local colorDone1
	local colorDone2

	if ( innerProgress < 1.0 )
	{
		// all stages show orange until the end
		colorProgress = Vector( 1.0, 0.65, 0.2 )
		colorDone1 = Vector( 1.0, 0.65, 0.2 )
		colorDone2 = Vector( 1.0, 1.0, 1.0 )
	}
	else
	{
		colorProgress = Vector( 1.0, 0.65, 0.2 )
		colorDone1 = Vector( 0.5, 1.0, 1.0 )
		colorDone2 = Vector( 1.0, 1.0, 1.0 )
	}

	local returnVal
	if ( progress <= 1 )
	{
		returnVal = colorProgress
	}
	else
	{
		local startTime = file.stageEndTime[ stage ]
		local endTime = startTime + RING_FADE_TIME
		local dif = GraphCapped( Time(), startTime, endTime, 0, 1 )
		returnVal = colorDone1 * dif + colorDone2 * ( 1 - dif )
	}

	return returnVal
}


function VMTCallback_DataKnifeOuterCircleAlpha_Lock( player )
{
	return DataKnifeCircleAlpha_Lock( player, KNIFE_STAGE_OUTER )
}

function VMTCallback_DataKnifeMidCircleAlpha_Lock( player )
{
	return DataKnifeCircleAlpha_Lock( player, KNIFE_STAGE_MID )
}

function VMTCallback_DataKnifeInnerCircleAlpha_Lock( player )
{
	return DataKnifeCircleAlpha_Lock( player, KNIFE_STAGE_INNER )
}

function DataKnifeCircleAlpha_Lock( player, stage )
{
	if ( !file.active )
	{
		return 0.5
	}

	local progress = GetStageProgress( stage )
	local colorProgress = 0.5
	local colorDone = 1.0

	if ( progress <= 1 )
	{
		return colorProgress
	}
	else
	{
		return 0
		local startTime = file.stageEndTime[ stage ]
		local endTime = startTime + RING_FADE_TIME
		local dif = GraphCapped( Time(), startTime, endTime, 0, 1 )
		return colorDone * dif + colorProgress * ( 1 - dif )
	}
}

function VMTCallback_DataKnifeCounterAlpha_Unlock( player )
{
	if ( !file.active )
	{
		return 0
	}

	local progress = GetStageProgress( KNIFE_STAGE_INNER )
	local colorProgress = 0.5
	local colorDone = 1.0

	if ( progress <= 1 )
	{
		return 0
	}
	else
	{
		return 1
	}
}

function VMTCallback_DataKnifeCounterAlpha_Lock( player )
{
	if ( !file.active )
	{
		return 0.5
	}

	local progress = GetStageProgress( KNIFE_STAGE_INNER )

	if ( progress <= 1 )
	{
		return 1
	}
	else
	{
		return 0
	}
}



function VMTCallback_DataKnifeOuterCircleAlpha_Unlock( player )
{
	return DataKnifeCircleAlpha_Unlock( player, KNIFE_STAGE_OUTER )
}

function VMTCallback_DataKnifeMidCircleAlpha_Unlock( player )
{
	return DataKnifeCircleAlpha_Unlock( player, KNIFE_STAGE_MID )
}

function VMTCallback_DataKnifeInnerCircleAlpha_Unlock( player )
{
	return DataKnifeCircleAlpha_Unlock( player, KNIFE_STAGE_INNER )
}

function DataKnifeCircleAlpha_Unlock( player, stage )
{
	if ( !file.active )
	{
		return 0
	}

	local progress = GetStageProgress( stage )
	local colorProgress = 0.5
	local colorDone = 1.0

	if ( progress <= 1 )
	{
		return 0
	}
	else
	{
		local startTime = file.stageEndTime[ stage ]
		local endTime = startTime + RING_FADE_TIME
		local dif = GraphCapped( Time(), startTime, endTime, 0, 1 )
		return colorDone * dif + colorProgress * ( 1 - dif )
	}
}


function VMTCallback_DataKnifeOuterCircleAlpha( player )
{
	return DataKnifeCircleAlpha( player, KNIFE_STAGE_OUTER )
}

function VMTCallback_DataKnifeMidCircleAlpha( player )
{
	return DataKnifeCircleAlpha( player, KNIFE_STAGE_MID )
}

function VMTCallback_DataKnifeInnerCircleAlpha( player )
{
	return DataKnifeCircleAlpha( player, KNIFE_STAGE_INNER )
}

function DataKnifeCircleAlpha( player, stage )
{
	if ( !file.active )
	{
		return 0
	}

	local progress = GetStageProgress( stage )
	local alpha
	local progressAlpha = 0.7
//	if ( progress <= 0 )
//	{
//		alpha = 0.0
//	}
//	else
	if ( progress <= 1 )
	{
		alpha = progressAlpha
	}
	else
	{
		local startTime = file.stageEndTime[ stage ] + RING_FADE_TIME
		local endTime = startTime + RING_FADE_TIME
		local dif = GraphCapped( Time(), startTime, endTime, 0, 1 )

		alpha = 0.0 * dif + progressAlpha * ( 1 - dif )
	}

	return alpha
}

function VMTCallback_DataKnifeDigit1( player )
{
	return DataKnifeDigit( player, KNIFE_STAGE_INNER )
}

function VMTCallback_DataKnifeDigit10( player )
{
	return DataKnifeDigit( player, KNIFE_STAGE_MID )
}

function VMTCallback_DataKnifeDigit100( player )
{
	return DataKnifeDigit( player, KNIFE_STAGE_OUTER )
}

function DataKnifeDigit( player, stage )
{
	if ( !file.active )
	{
		return 0
	}

	local result = DataKnifeProgression( player, stage )
//	if ( result <= 0 )
//	{
//		return file.digit[ stage ]
//	}
	if ( result >= 1 )
	{
		return file.digit[ stage ]
	}

	result *= 20
	result = result.tointeger()


	srand( result )
	local value = rand() % 10
	return value
	//return RandomInt( 10 )
}

function VMTCallback_ProgressionOuterBar( player )
{
	local result = DataKnifeProgression( player, KNIFE_STAGE_OUTER )
	return result * MAX_PROGRESS_BAR
}

function VMTCallback_ProgressionMidBar( player )
{
	local result = DataKnifeProgression( player, KNIFE_STAGE_MID )
	return result * MAX_PROGRESS_BAR
}

function VMTCallback_ProgressionInnerBar( player )
{
	local result = DataKnifeProgression( player, KNIFE_STAGE_INNER )
	return result * MAX_PROGRESS_BAR
}

function DataKnifeProgression( player, stage )
{
	if ( !file.active )
		return 0

	local progress = GetStageProgress( stage )
	local boost = ( sin( Time() * 3.0 ) + 2.5 ) * 0.05
	//local extraProgress = progress + 0.25 // boost
	local extraProgress = progress + boost

	// blend variance in for the center part of the progress
	local blendGap = 0.25
	local finalProgress

//	if ( progress <= 0 )
//	{
//		finalProgress = 0
//	}
//	else
	if ( progress < blendGap )
	{
		finalProgress = Graph( progress, 0, blendGap, progress, extraProgress )
	}
	else
	if ( progress < 1.0 - blendGap )
	{
		finalProgress = extraProgress
	}
	else
	if ( progress < 1.0 )
	{
		finalProgress = Graph( progress, 1.0 - blendGap, 1.0, extraProgress, progress )
	}
	else
	{
		finalProgress = progress
	}
//	else
//	if ( progress < 2.0 )
//	{
//		finalProgress = progress
//	}
//	else
//	{
//		finalProgress = 0
//	}


	return finalProgress
}

function ClearLeech()
{
	file.active = false
}

function ServerCallback_DataKnifeReset()
{
	ClearLeech()
}

function ServerCallback_DataKnifeStartLeech( time )
{
	thread StartLeech( time )
}

function ServerCallback_DataKnifeStartLeechTimePassed( time, timePassed )
{
	thread StartLeech( time, timePassed )
}

function ServerCallback_DataKnifeCancelLeech()
{
	local player = GetLocalViewPlayer()
	player.Signal( "DataKnifeCancel" )

}

function DataKnifeSounds( stageTime )
{
	local player = GetLocalViewPlayer()
	player.EndSignal( "DataKnifeCancel" )
	player.EndSignal( "OnDeath" )

	local beepLoop = "dataknife_loopable_beep"

	OnThreadEnd(
		function() : ( player, beepLoop )
		{
			if ( IsValid( player ) )
			{
				StopSoundOnEntity( player, beepLoop )
			}
		}
	)

//"dataknife_stab"
	local sounds = []
	sounds.append( "dataknife_ring1" )
	sounds.append( "dataknife_ring2" )
	sounds.append( "dataknife_complete" )

	EmitSoundOnEntity( player, beepLoop )
	for ( local i = 0; i < stageTime.len(); i++ )
	{
		local time = stageTime[i]
		wait time
		EmitSoundOnEntity( player, sounds[i] )
	}
}


function StartLeech( time = null, timePassed = 0 )
{
	file.active = true
	local stageTime = []

	function LessThan( a, b )
	{
		if ( a > b )
			return 1
		else
			return -1
	}

	if ( time == null )
	{
		for ( local i = 0; i < KNIFE_STAGES; i++ )
		{
			stageTime.append( RandomFloat( 0.8, 1.4 ) )
		}
	}
	else
	{
		time -= RING_FADE_TIME

		// each gets a random amount of randomSpread, but the total take from
		// random spread is equal to the total of randomSpread
		local randomSpread = 0.4

		// each gets an even share of baseSpread
		local baseSpread = 1.0 - randomSpread

		randomSpread *= KNIFE_STAGES

		local remainders = []
		remainders.append( 0 )
		for ( local i = 0; i < KNIFE_STAGES - 1; i++ )
		{
			remainders.append( RandomFloat( 0.0, 1.0 ) )
		}
		remainders.append( 1.0 )
		remainders.sort( LessThan )


		local total = 0
		for ( local i = 0; i < KNIFE_STAGES; i++ )
		{
			local val = baseSpread
			local remainder = remainders[i+1] - remainders[i]
			val += remainder * randomSpread

			val /= KNIFE_STAGES
			val *= time

			stageTime.append( val )
			total += val
		}
	}

	thread DataKnifeSounds( stageTime )

	local startTime = Time() - timePassed
	for ( local i = 0; i < KNIFE_STAGES; i++ )
	{
		file.stageStartTime[i] = startTime
		file.stageEndTime[i] = file.stageStartTime[i] + stageTime[i]
		file.digit[i] = RandomInt( 10 )
		startTime += stageTime[i]
	}
}

function GetTimeSeed( stage )
{
	local timeSeed = Time() - file.stageStartTime[ stage ]
	return timeSeed
}

function GetStageProgress( stage )
{
	local progress = Graph( Time(), file.stageStartTime[ stage ], file.stageEndTime[ stage ], 0, 1 )
	return progress
}
function main()
{
	level.timers <- {}
}

function TimerInit( timerAlias, timerLimit )
{
	Assert( !( timerAlias in level.timers ), "Timer already set up: " + timerAlias )

	local timer = {}
	timer.lastResetTime <- -1
	timer.limit 		<- timerLimit

	level.timers[ timerAlias ] <- timer
}
Globalize( TimerInit )


function TimerCheck( timerAlias )
{
	Assert( timerAlias in level.timers, "Timer not set up: " + timerAlias )

	local timer = level.timers[ timerAlias ]

	if ( timer.lastResetTime == -1 )
		return true

	return ( Time() - timer.lastResetTime >= timer.limit )
}
Globalize( TimerCheck )


function TimerReset( timerAlias )
{
	Assert( timerAlias in level.timers, "Timer not set up: " + timerAlias )

	level.timers[ timerAlias ].lastResetTime = Time()
}
Globalize( TimerReset )

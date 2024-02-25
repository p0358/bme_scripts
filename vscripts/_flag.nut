function main()
{
	Globalize( FlagInit )
	Globalize( FlagSet )
	Globalize( FlagClear )
	Globalize( Flag )
	Globalize( FlagWait )
	Globalize( FlagWaitWithTimeout )
	Globalize( FlagToggle )
	Globalize( FlagWaitAll )
	Globalize( FlagWaitAny )
	Globalize( FlagWaitClear )
	Globalize( FlagWaitClearAll )
	Globalize( FlagWaitClearAny )
	Globalize( GetFlagsFromString )
	Globalize( SetTriggerEnableFromFlag )
	Globalize( GetFlagsFromField )
	Globalize( GetFlagEnt )
	Globalize( GetFlagEnts )
	Globalize( SetFlagOnAllDead )
	Globalize( FlagEnd )
	Globalize( FlagClearEnd )

	Globalize( FlagExists )
	Globalize( FlagSetOnFlag )
	Globalize( FlagClearOnFlag )

	RegisterSignal( "deathflag" )

}

function FlagInit( msg, isSet = false )
{
	Assert( "flags" in level, "level.flags not initilized yet" )

	// gets init'd from the map too, so not an assert
	if ( msg in level.flags )
		return

	Assert( !( msg.find( " " ) ), "Can not have spaces in the name of a flag: " + msg )
	level.flags[ msg ] <- isSet
	RegisterSignal( msg )
}

function FlagSet( msg )
{
//	printl( "set flag " + msg )
	Assert( "flags" in level, "level.flags not initialized yet" )
	Assert( msg in level.flags, "flag " + msg + " not initialized yet" )

	if ( "flagHistory" in level )
	{
		if ( !Flag( msg ) )
			level.flagHistory[ msg ] <- true
	}
	__FlagSetValue( msg, true )
}

function FlagClear( msg )
{
	Assert( "flags" in level, "level.flags not initilized yet" )
	Assert( msg in level.flags, "flag " + msg + " not initialized yet" )

	__FlagSetValue( msg, false )
}

function FlagEnd( msg )
{
	Assert( "flags" in level, "level.flags not initialized yet" )
	Assert( msg in level.flags, "flag " + msg + " not initialized yet" )
	Assert( !Flag( msg ), "Flag " + msg + " was already set!!" )

	level.ent.EndSignal( msg )
}

function FlagClearEnd( msg )
{
	Assert( "flags" in level, "level.flags not initialized yet" )
	Assert( msg in level.flags, "flag " + msg + " not initialized yet" )
	Assert( Flag( msg ), "Flag " + msg + " is not already set!!" )

	level.ent.EndSignal( msg )
}

function Flag( msg )
{
	Assert( "flags" in level, "level.flags not initialized yet" )
	Assert( msg in level.flags, "flag " + msg + " not initialized yet" )

	return level.flags[ msg ]
}

function FlagToggle( msg )
{
	if ( Flag( msg ) )
	{
		FlagClear( msg )
	}
	else
	{
		FlagSet( msg )
	}
}

function GetFlagEnt( flag )
{
	local triggers = level.triggersWithFlags[ flag ]
	local trigger
	foreach ( ent, set in triggers )
	{
		Assert( !trigger )
		trigger = ent
	}

	return trigger
}

function GetFlagEnts( flag )
{
	local array = []
	foreach ( ent, set in level.triggersWithFlags[ flag ] )
	{
		array.append( ent )
	}

	return array
}

//this function only works in threaded functions
function FlagWait( msg )
{
	Assert( "flags" in level, "level.flags not initilized yet" )
	Assert( msg in level.flags, "flag " + msg + " not initialized yet" )

	while ( !level.flags[ msg ] )
	{
		level.ent.WaitSignal( msg )
	}
}

//this function only works in threaded functions
function FlagWaitAll( ... )
{
	local args = []
	for ( local i = 0; i< vargc; i++ )
		args.append( vargv[i] )

	local loop = true

	while ( loop )
	{
		foreach ( msg in args )
			FlagWait( msg )

		loop = false

		//extra check to make sure one didn't get cleared after a wait
		foreach ( i, msg in args )
		{
			if ( Flag( msg ) )
				continue

			loop = true
			break
		}
	}
}

//this function only works in threaded functions
function FlagWaitWithTimeout( flag, timeout )
{
	local newFlag = "FlagWaitAny" + UniqueString()
	FlagInit( newFlag )
	thread __FlagWaitAny( flag, newFlag )
	thread __FlagWaitTime( timeout, newFlag )

	FlagWait( newFlag )
}

function __FlagWaitTime( timeout, newFlag )
{
	level.ent.EndSignal( newFlag )

	Wait( timeout )

	FlagSet( newFlag )
}

//this function only works in threaded functions
function FlagWaitAny( ... )
{
	local newFlag = "FlagWaitAny" + UniqueString()
	FlagInit( newFlag )

	local args = []
	for ( local i = 0; i < vargc; i++ )
		args.append( vargv[i] )

	foreach ( msg in args )
		thread __FlagWaitAny( msg, newFlag )

	FlagWait( newFlag )
}

//this function only works in threaded functions
function FlagWaitClear( msg )
{
	Assert( "flags" in level, "level.flags not initilized yet" )
	Assert( msg in level.flags, "flag " + msg + " not initialized yet" )

	while ( level.flags[ msg ] )
	{
		level.ent.WaitSignal( msg )
	}
}

//this function only works in threaded functions
function FlagWaitClearAll( ... )
{
	local args = []
	for ( local i = 0; i < vargc; i++ )
		args.append( vargv[i] )

	local loop = true

	while ( loop )
	{
		foreach ( msg in args )
			FlagWaitClear( msg )

		loop = false

		//extra check to make sure one didn't get cleared after a wait
		foreach ( msg in args )
		{
			if ( !Flag( msg ) )
				continue

			loop = true
			break
		}
	}
}

//this function only works in threaded functions
function FlagWaitClearAny( ... )
{
	local newFlag = "FlagWaitAny" + UniqueString()
	FlagInit( newFlag )

	local args = []
	for ( local i = 0; i < vargc; i++ )
	{
		args.append( vargv[i] )
	}

	foreach ( msg in args )
	{
		thread __FlagWaitClearAny( msg, newFlag )
	}

	FlagWait( newFlag )
}

function __FlagWaitAny( msg, newFlag )
{
	level.ent.EndSignal( newFlag )

	FlagWait( msg )

	FlagSet( newFlag )
}

function __FlagWaitClearAny( msg, newFlag )
{
	EndSignal( level.ent, newFlag )

	FlagWaitClear( msg )

	FlagSet( newFlag )
}

function __FlagSetValue( msg, val )
{
	if ( level.flags[ msg ] == val )
		return

	level.flags[ msg ] = val

	// enable or disable triggers based on flag esttings
	if ( msg in level.triggersWithFlags )
	{
		foreach ( trigger, _ in level.triggersWithFlags[ msg ] )
		{
			SetTriggerEnableFromFlag( trigger )
		}
	}

	level.ent.Signal( msg )
}

function GetFlagsFromString( ent, string )
{
	return split( string, " " )
}


function SetTriggerEnableFromFlag( trigger )
{
	local flags
	local enabled

//	printl( "\nUpdating trigger " + trigger )

	if ( trigger.HasKey( "scr_flagTrueAny" ) )
	{
		flags = GetFlagsFromField( trigger, "scr_flagTrueAny" )

		enabled = false
		foreach ( msg in flags )
		{
			if ( Flag( msg ) )
			{
				enabled = true
				break
			}
		}

		if ( !enabled )
		{
//			printl( trigger + " disabled1!" )
			trigger.Fire( "Disable" )
			return
		}
	}

	if ( trigger.HasKey( "scr_flagTrueAll" ) )
	{
		flags = GetFlagsFromField( trigger, "scr_flagTrueAll" )

		enabled = true
		foreach ( msg in flags )
		{
			if ( !Flag( msg ) )
			{
				enabled = false
				break
			}
		}

		if ( !enabled )
		{
//			printl( trigger + " disabled2!" )
			trigger.Fire( "Disable" )
			return
		}
	}

	if ( trigger.HasKey( "scr_flagFalseAny" ) )
	{
		flags = GetFlagsFromField( trigger, "scr_flagFalseAny" )

		enabled = false
		foreach ( msg in flags )
		{
			if ( !Flag( msg ) )
			{
				enabled = true
				break
			}
		}

		if ( !enabled )
		{
//			printl( trigger + " disabled3!" )
			trigger.Fire( "Disable" )
			return
		}
	}

	if ( trigger.HasKey( "scr_flagFalseAll" ) )
	{
		flags = GetFlagsFromField( trigger, "scr_flagFalseAll" )

		enabled = true
		foreach ( msg in flags )
		{
			if ( Flag( msg ) )
			{
				enabled = false
				break
			}
		}

		if ( !enabled )
		{
//			printl( trigger + " disabled4!" )
			trigger.Fire( "Disable" )
			return
		}
	}

//	printl( trigger + " enabled!" )
	trigger.Fire( "Enable" )
}

function GetFlagsFromField( ent, field )
{
	return split( ent.kv[ field ], " " )
}

function SetFlagOnAllDead( entities, flag )
{
	local info_target = CreateEntity( "info_target" )

	info_target.s.ents <- {}

	foreach ( ent in entities )
	{
		if ( IsAlive( ent ) )
		{
			info_target.s.ents[ ent ] <- true
			thread DeathFlagCheck( ent, info_target )
		}
	}


	local hasEnt
	for ( ;; )
	{
		info_target.WaitSignal( "OnDeath" )

		hasEnt = false
		foreach ( ent, _ in info_target.s.ents )
		{
			if ( IsAlive( ent ) )
			{
				hasEnt = true
			}
		}

		if ( !hasEnt )
		{
			FlagSet( flag )

			info_target.Kill()
			return
		}
	}
}

function DeathFlagCheck( ent, info_target )
{
	info_target.EndSignal( "OnDestroy" )
	ent.WaitSignal( "OnDeath" )
	info_target.Signal( "OnDeath" )
	delete info_target.s.ents[ ent ]
}


function FlagExists( msg )
{
	Assert( "flags" in level, "level.flags not initilized yet" )

	// gets init'd from the map too, so not an assert
	if ( msg in level.flags )
		return true

	return false
}


function FlagSetOnFlag( flagset, flagwait )
{
	thread _ThreadFlagSetOnFlag( flagset, flagwait )
}

function _ThreadFlagSetOnFlag( flagset, flagwait )
{
	FlagWait( flagwait )
	FlagSet( flagset )
}


function FlagClearOnFlag( flagclear, flagwait )
{
	thread _ThreadFlagClearOnFlag( flagclear, flagwait )
}

function _ThreadFlagClearOnFlag( flagclear, flagwait )
{
	FlagWait( flagwait )
	FlagClear( flagclear )
}

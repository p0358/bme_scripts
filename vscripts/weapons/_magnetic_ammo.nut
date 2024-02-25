// moved to code
/*

function main()
{
	level.magneticTargetClassnames <- {}
	level.magneticTargetClassnames[ "npc_turret_mega" ] 	<- 100
	level.magneticTargetClassnames[ "npc_turret_sentry" ] 	<- 100
	level.magneticTargetClassnames[ "npc_dropship" ] 		<- 210
	level.magneticTargetClassnames[ "npc_spectre" ] 		<- 100
	level.magneticTargetClassnames[ "npc_cscanner" ] 		<- 100
	level.magneticTargetClassnames[ "npc_titan" ] 			<- 210
	level.magneticTargetClassnames[ "npc_marvin" ] 			<- 100
	level.magneticTargetClassnames[ "player" ] 				<- 210

	// Store the max range so that we use it as the default search radius when looking for magnetic targets
	level.highestMagneticRange <- 0
	foreach ( name, range in level.magneticTargetClassnames )
	{
		if ( level.highestMagneticRange < range )
			level.highestMagneticRange = range
	}

	Globalize( AddToMagneticTargets )
	Globalize( GetMagneticClassnames )
	Globalize( GetMagneticRangeForTargetType )
	Globalize( GetHighestMagneticRange )

	if ( IsServer() )
		level._magneticTargetsArrayID <- CreateScriptManagedEntArray()
}

function AddToMagneticTargets( ent )
{
	local range = level.magneticTargetClassnames[ ent.GetClassname() ]
	ent.s.magneticTargetRange <- range

	if ( IsServer() )
		AddToScriptManagedEntArray( level._magneticTargetsArrayID, ent );
}

function GetMagneticClassnames()
{
	return level.magneticTargetClassnames
}

function GetMagneticRangeForTargetType( target )
{
	Assert( "magneticTargetRange" in target.s )
	return target.s.magneticTargetRange
}

function GetHighestMagneticRange()
{
	return level.highestMagneticRange;
}

*/
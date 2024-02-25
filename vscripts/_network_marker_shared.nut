//list of specific markers for gamemodes or levels
const MARKER_TOWERDEFENSEGENERATOR = "TowerDefenseGeneratorEnt"

function RegisterNetworkMarkers()
{
	RegisterMarker( MARKER_TOWERDEFENSEGENERATOR )

	RegisterMarker( "LoadoutCrateMarker0" )
	RegisterMarker( "LoadoutCrateMarker1" )
	RegisterMarker( "LoadoutCrateMarker2" )
}




/************************************************************************************\
							DO NOT EDIT BELOW THIS LINE
\************************************************************************************/
const MARKER_ENT_CLASSNAME = "script_ref"
function main()
{
	Globalize( GetMarkedEntity )
	Globalize( RegisterMarker )

	level.NetworkMarkedEnts <- {}
	level.MarkerRegistryIndex <- 0

	if ( IsServer() )
	{
		Globalize( SetMarker )
		Globalize( ClearMarker )

		level.RegisteredServerMarkers <- {}
	}
	else if ( IsClient() )
	{
		Globalize( AddMarkerChangeCallback )
		Globalize( ServerCallback_UpdateMarker )
		AddCreateCallback( MARKER_ENT_CLASSNAME, __OnMarkerCreated )

		level.RegisteredClientMarkers <- {}
		level.ClientFuncsForMarkedEnts <- {}
	}

	RegisterNetworkMarkers()
}

/* SERVER */
if ( IsServer() )
{
	function SetMarker( name, ent )
	{
		if ( !__MarkerExists( name ) )
		{
			__CreateMarker( name, ent )
			return
		}

		__UpdateMarker( name, ent )
	}
	function ClearMarker( name )
	{
		if ( !__MarkerExists( name ) )
			return

		__UpdateMarker( name, null )
	}
	function __UpdateMarker( name, value )
	{
		local marker = __GetMarker( name )
		marker.SetOwner( value )
		__UpdateMarkerForClients( name )
	}

	function __CreateMarker( name, ent )
	{
		Assert( name != "" )
		local marker = CreateEntity( MARKER_ENT_CLASSNAME )
		marker.SetOrigin( Vector(0,0,0) )
		marker.SetName( name )
		marker.kv.spawnflags = 3 //Transmit to client
		marker.s.IsSCMarker <- true

		marker.SetOwner( ent )

		__AddMarkerToList( marker )
		DispatchSpawn( marker, true )

		return marker
	}
	function __UpdateMarkerForClients( name )
	{
		local players = GetPlayerArray()
		local index = GetRegisteredIndexFromMarkerName( name )

		foreach( player in players )
			Remote.CallFunction_NonReplay( player, "ServerCallback_UpdateMarker", index )
	}

	function __IsMarker( marker )
	{
		return marker.GetClassname() == MARKER_ENT_CLASSNAME
	}

	function RegisterMarker( name )
	{
		level.RegisteredServerMarkers[ name ] <- level.MarkerRegistryIndex
		level.MarkerRegistryIndex++
	}
	function GetRegisteredIndexFromMarkerName( name )
	{
		Assert( name in level.RegisteredServerMarkers )
		return level.RegisteredServerMarkers[ name ]
	}
}

/* CLIENT */
else if ( IsClient() )
{
	function __IsMarker( marker )
	{
		return marker.GetSignifierName() == MARKER_ENT_CLASSNAME
	}
	function RegisterMarker( name )
	{
		level.RegisteredClientMarkers[ level.MarkerRegistryIndex ] <- name
		level.MarkerRegistryIndex++
	}
	function GetRegisteredNameFromMarkerIndex( index )
	{
		Assert( index in level.RegisteredClientMarkers )
		return level.RegisteredClientMarkers[ index ]
	}

	function AddMarkerChangeCallback( name, func )
	{
		Assert( !( name in level.ClientFuncsForMarkedEnts ) )
		level.ClientFuncsForMarkedEnts[ name ] <- func
	}

	function __OnMarkerCreated( marker, isRecreate )
	{
		if ( !__IsMarker( marker ) )
			return

		local name = marker.GetName()
		if ( name == "" )
			return

		__AddMarkerToList( marker )	//this will be bloated for now - but when __IsMarker() is a real function instead of just checking for "script_ref", this will be streamlined
		__UpdateMarkerOnClient( name )
	}

	function ServerCallback_UpdateMarker( index )
	{
		local name = GetRegisteredNameFromMarkerIndex( index )
		__UpdateMarkerOnClient( name )
	}

	function __UpdateMarkerOnClient( name )
	{
		if ( !( name in level.ClientFuncsForMarkedEnts ) )
			return

		local func = level.ClientFuncsForMarkedEnts[ name ]
		local markedEntity = GetMarkedEntity( name )
		thread func( markedEntity, name )
	}
}

/* SHARED */
function NetworkMarkerIsValid( marker )
{
	if ( !__MarkerExists( marker ) )
		return false

	local markerEnt = __GetMarker( marker )
	if ( !IsValid( markerEnt ) )
		return false

	return true
}
Globalize( NetworkMarkerIsValid )


function __MarkerExists( name )
{
	return ( name in level.NetworkMarkedEnts )
}

function GetMarkedEntity( name )
{
	local maker = __GetMarker( name )
	if ( maker )
		return maker.GetOwner()

	return null
}


function __GetMarker( name )
{
	if ( __MarkerExists( name ) )
	{
		local ent = level.NetworkMarkedEnts[ name ]
		if ( IsValid( ent ) )
			return ent
	}

	return null
}

function __AddMarkerToList( marker )
{
	local name = marker.GetName()
	Assert( name != "" )

	//this allows overwrites of the same intended marked ent
	if ( !__MarkerExists( name ) )
		level.NetworkMarkedEnts[ name ] <- null

	level.NetworkMarkedEnts[ name ] = marker
}







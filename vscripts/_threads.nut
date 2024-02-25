//********************************************************************************************
// _threads.nut
//********************************************************************************************
function RegisterFunctionDesc( funcName, description, returnType = "void" )
{
	if ( developer() > 0 )
	{
		local signature = GetFunctionSignature( ::getroottable()[funcName], funcName )
		signature = returnType + signature.slice( "function".len() )

		RegisterFunctionDocumentation( null, funcName, signature, description )
	}
}

function RegisterClassFunctionDesc( baseClass, funcName, description, returnType = "void" )
{
	if ( developer() > 0 )
	{
		local signature = GetFunctionSignature( baseClass[funcName], baseClass.ClassName + "::" + funcName )
		signature = returnType + signature.slice( "function".len() )

		RegisterFunctionDocumentation( null, baseClass.ClassName + "::" + funcName, signature, description )
	}
}

function IsTable( var ) {
	return (type( var ) == "table")
}

function IsArray( var ) {
	return (type( var ) == "array")
}

function IsNumber( var ) {
	return (type( var ) == "float" || type( var ) == "integer")
}

function IsFunction( var ) {
	return (type( var ) == "function")
}

function IsString( var ) {
	return (type( var ) == "string")
}

function IsDeadCoroutine( co ) {
	return (co.getstatus() == "idle" || co.getstatus() == "error")
}

function printt( ... )
{
	if ( vargc <= 0 )
		return

	local msg = vargv[0]
	for ( local i = 1; i < vargc; i++ )
		msg = (msg + " " + vargv[i])

	printl( msg )
}

function PrintFunc( val = null )
{
	if ( val != null )
	{
		printt( val + "PrintFunc:", getstackinfos( 2 ).func )
	}
	else
	{
		printt( "PrintFunc:", getstackinfos( 2 ).func )
	}
}

function printt_spamLog( ... )
{
	if ( vargc <= 0 )
		return

	local msg = vargv[0]
	for ( local i = 1; i < vargc; i++ )
		msg = (msg + " " + vargv[i])

	SpamLog( format( "[%.3f] %s\n", Time(), msg ) )
}

function printl_spamLog( msg )
{
	SpamLog( format( "%s\n", msg ) )
}

getcurrentthread <- getthread

g_debugThreads <- true

//////////////////////////////////////////////////////////////////////////////
const YIELDRESULT_WAITNEXTFRAME = 1001
const YIELDRESULT_WAITENDFRAME = 1005
const YIELDRESULT_WAIT = 2002
const YIELDRESULT_WAITSIGNAL = 3003
const YIELDRESULT_ENDTHREAD = 4004
const YIELDRESULT_BLOCKEDBYCHILD = 5005

const NONBLOCKING = 0
const BLOCKING = 1
const BLOCKING_SOLO = 2 // blocking but doesn't inherit endsignals

SIG <- {}
reloadingScripts <- false

function InitThreads()
{
	local rootTable = getroottable()
	rootTable.__fileScopes <- {}
}

////////////////////////////////
// API
InitThreads()

/*
function RunThreadsFrame( simTime )
{
	threads.RunFrame( simTime )
}
*/

function Globalize( func )
{
	local rootTable = getroottable()
	local funcInfos = func.getinfos()

	Assert( this != rootTable, "Can't run Globalize from an IncludeScript" )

	if ( !reloadingScripts )
	{
		Assert( !(rootTable.rawin( funcInfos.name )), "Function " + funcInfos.name + " is already in root table!"  )
	}

	rootTable[funcInfos.name] <- func.bindenv( this )
}

function IsFuncGlobal( func )
{
	local rootTable = getroottable()
	local funcInfos = func.getinfos()

	return rootTable.rawin( funcInfos.name )
}

function IncludeFileAllowMultipleLoads( name )
{
	local rootTable = getroottable()

	if ( !(rootTable.rawin( "__fileScopes" )) )
		rootTable.__fileScopes <- {}

	local fileScopes = rootTable.__fileScopes
	if ( name in fileScopes )
	{
		printt( "skipped already loaded " + name )
		return
	}
	printt( "loading " + name )
	IncludeFile( name )
}

function IncludeFile( name )
{
	local rootTable = getroottable()

	if ( !(rootTable.rawin( "__fileScopes" )) )
		rootTable.__fileScopes <- {}

	local fileScopes = rootTable.__fileScopes

	local fileScopeDelegate = delegate getroottable() : {
		function _tostring():(name)
		{
			return format( "file: %s", name )
		}
	}

	local newFileScope = delegate fileScopeDelegate : {}
	::DoIncludeScript( name, newFileScope )

	if ( reloadingScripts )
	{
		if ( fileScopes.rawin( name ) )
		{
			foreach ( k, v in newFileScope )
			{
				if ( type( v ) != "function" )
					continue

				fileScopes[name][k] <- v

				if ( IsFuncGlobal( v ) )
					fileScopes[name].Globalize( v ) // re-bind the globalized function to the original table
			}

			return
		}
	}
	else
	{
		Assert( !(fileScopes.rawin( name )), "Already loaded file named " + name )
	}

	Assert( !( "file" in newFileScope ), "Already has file in scope!" )
	newFileScope[ "file" ] <- {}

	fileScopes[name] <- newFileScope

	if ( !reloadingScripts )
	{
		// only do the main on first load
		if ( newFileScope.rawin( "main" ) )
		{
			SpinOff.bindenv( newFileScope )( newFileScope.main )
		}
		Assert( !( newFileScope.rawin( "Main" ) ), "File " + name + " used function name Main(). Use main(), it is called automatically." )
	}
}

function RunFunctionInAllFileScopes( name )
{
	local fileScopes = getroottable().__fileScopes
	foreach ( scope in fileScopes )
	{
		if ( scope.rawin( name ) )
		{
			SpinOff.bindenv( scope )( scope[ name ] )
//			printl( "Spun off func " + name + " in " + scope )
		}
	}
}

function FileScopeCall( funcName, ... )
{
	foreach ( scopeName, fileScope in __fileScopes )
	{
		if ( !(fileScope.rawin( funcName )) )
			continue

		local args = [ this, fileScope[funcName] ]

		for ( local i = 0; i< vargc; i++ )
			args.append( vargv[i] )

		SpinOff.acall( args )
	}
}

::_stringToIndex <- {}
::_indexToString <- {}

// start at a high index to easily detect inval indices being use as registered strings
// could also do this by settings a significant bit in the index
const MIN_REGISTERED_STRING_INDEX = 32768
::_currentStringIndex <- MIN_REGISTERED_STRING_INDEX

function RegisterString( string )
{
	Assert( _RegisteringFunctions, "Cannot register string outside of _remote_functions.nut" )
	Assert( type( string ) == "string", "Parameter must be a string (" + type( string ) + ")" )
	Assert( string.find( "#" ) == 0, "Cannot register unlocalized string \"" + string + "\"" )

	local index = ::_currentStringIndex

	::_stringToIndex[string] <- index
	::_indexToString[index] <- string

	::_currentStringIndex++
}


function GetStringID( string )
{
	Assert( type( string ) == "string", "Parameter must be a string (" + type( string ) + ")" )
	Assert( string in ::_stringToIndex, "String \"" + string + "\" has not been registered" )

	return ::_stringToIndex[string]
}


function GetStringFromID( index )
{
	Assert( type( index ) == "integer", "Parameter must be an integer (" + type( index ) + ")" )
	Assert( index >= MIN_REGISTERED_STRING_INDEX, "Index \"" + index + "\" is not a valid registered string index" )
	Assert( index in ::_indexToString )

	return ::_indexToString[index]
}


__levelVarDelegate <- {}
function __levelVarDelegate::_overwriteslot( key, value )
{
	Assert( 0, "Attempted to overwrite slot \"" + key + "\" in level table.  See callstack for further info.\n" )
}

/*
function __levelVarDelegate::_newslot( key, value )
{
//	if ( key == "player" )
//	{
//		printl( "\n\n" )
//		DumpStack()
//	}
	this.rawset( key, value )

	return value
}
*/

function __levelVarDelegate::_typeof()
{
	return "levelTable"
}

// "level" table; use to store global variables on a per level basis
level <- delegate __levelVarDelegate : {}



class NetworkValueInterface
{
	self = null

	constructor( ent )
	{
		self = ent
	}

	function _get( key )
	{
		return ::GetEntityVar( self, key )
	}

	function _set( key, value )
	{
		Assert( ::IsServer() )
		return ::SetEntityVar( self, key, value )
	}

	function hasKey( key )
	{
		return ::GetHasEntityVar( self, key )
	}
}

class ServerValueInterface
{
	function _get( key )
	{
		return ::GetServerVar( key )
	}

	function _set( key, value )
	{
		Assert( ::IsServer() )
		return ::SetServerVar( key, value )
	}
}

level.nv <- ServerValueInterface()

_serverVars <- {}
_serverEntityVars <- {}
_serverVarHandles <- {}
_nextServerVarIndex <- 0
_serverVarChangeCallbacks <- {}

_entityClassVars <- {}
_entityClassVarsIsEnts <- {}
_entityClassVarsSyncToAllClients <- {}
_entityClassVarHandles <- {}
_entityClassVarChangeCallbacks <- {}
_nextEntVarIndex <- 0
_entityVarsByEHandle <- {}

function RegisterEntityVar_AllSynced( className, varName, value, bIsEntities = false )
{
	RegisterEntityVar( className, varName, value, true, bIsEntities )
}

function RegisterEntityVar_AllSyncedEntity( className, varName, value = null )
{
	RegisterEntityVar( className, varName, value, true, true )
}

function RegisterEntityVar_Entity( className, varName, value, bSyncToAllClients = null )
{
	RegisterEntityVar( className, varName, value, bSyncToAllClients, true )
}


// CLIENT/SERVER
function RegisterEntityVar( className, varName, value, bSyncToAllClients = null, bIsEntities = false )
{
	local isPlayer = className == "player"

	if ( !isPlayer )
		Assert( className.find( "npc" ) == 0, "only player and NPC's are supported for networked entity vars" )

	if ( bSyncToAllClients == null )
	{
		if ( isPlayer )
			bSyncToAllClients = false
		else
			bSyncToAllClients = true
	}

	if ( !(className in _entityVarsByEHandle ) )
		_entityVarsByEHandle[className] <- {}

	if ( !(className in _entityClassVars ) )
		_entityClassVars[className] <- {}

	if ( !(className in _entityClassVarsIsEnts ) )
		_entityClassVarsIsEnts[className] <- {}

	if ( !(className in _entityClassVarsSyncToAllClients ) )
		_entityClassVarsSyncToAllClients[className] <- {}

	Assert( !( varName in _entityClassVars[className] ) )
	Assert( !( varName in _entityClassVarsIsEnts[className] ) )
	Assert( !( varName in _entityClassVarsSyncToAllClients[className] ) )

	if ( IsServer() )
		_entityClassVarHandles[varName] <- _nextEntVarIndex
	else
		_entityClassVarHandles[_nextEntVarIndex] <- varName

	_nextEntVarIndex++

	_entityClassVars[className][varName] <- value
	_entityClassVarsIsEnts[className][varName] <- bIsEntities					// means that this variable hold an entity and we should automatically convert eHandles

	Assert( bSyncToAllClients || className == "player", "Non-player vars must sync to all clients" )
	_entityClassVarsSyncToAllClients[className][varName] <- bSyncToAllClients	// only used for vars set on CBasePlayers
}

function RegisterServerVar( varName, value )
{
	Assert( !(varName in _serverVars ) )

	if ( IsServer() )
		_serverVarHandles[varName] <- _nextServerVarIndex
	else
		_serverVarHandles[_nextServerVarIndex] <- varName

	_nextServerVarIndex++

	_serverVars[varName] <- value
}

function RegisterServerEntityVar( varName )
{
	Assert( !(varName in _serverVars ) )

	if ( IsServer() )
		_serverVarHandles[varName] <- _nextServerVarIndex
	else
		_serverVarHandles[_nextServerVarIndex] <- varName

	_nextServerVarIndex++

	_serverVars[varName] <- null
	_serverEntityVars[ varName ] <- true
}

function GetEntityVar( entity, varName )
{
	Assert( varName in _entityClassVars[ IsClient() ? entity.GetSignifierName() : entity.GetClassname() ] )

	return entity._entityVars[varName]
}

function GetHasEntityVar( entity, varName )
{
	local className

	if ( IsClient() )
		className = entity.GetSignifierName()
	else
		className = entity.GetClassname()

	if ( !(className in _entityClassVars) )
		return false

	return( varName in _entityClassVars[className] )
}

function GetServerVar( varName )
{
	Assert( varName in _serverVars )

	return _serverVars[varName]
}


// CLIENT ONLY
function ServerCallback_SetEntityVar( eHandle, varHandle, value )
{
	local varName = _entityClassVarHandles[varHandle]
	if ( eHandle in _entityVarsByEHandle )
	{
		_entityVarsByEHandle[ eHandle ][ varName ] = value
	}

	local entity = GetEntityFromEncodedEHandle( eHandle )

	if ( !IsValid_ThisFrame( entity ) )
		return

	local className = entity.GetSignifierName()
	if ( !( className in _entityVarsByEHandle ) )
	{
		_entityVarsByEHandle[ className ] <- {}
	}

	if ( !( eHandle in _entityVarsByEHandle[ className ] ) )
	{
		_entityVarsByEHandle[ className ][ eHandle ] <- clone entity._entityVars
		entity._entityVars = _entityVarsByEHandle[ className ][ eHandle ]
	}


	Assert( className in _entityClassVars )
	Assert( className in _entityClassVarsIsEnts )

	Assert( ("_entityVars" in entity) )

	if ( _entityClassVarsIsEnts[className][varName] && value != null )
	{
		eHandle = value
		//printl( "NETWORK VAR VALUE IS EHANDLE. FINDING ENTITY" )
		value = GetEntityFromEncodedEHandle( value )
	}

	local oldValue = entity._entityVars[varName]
	entity._entityVars[varName] = value

	//printl( "Set entityVar " + varName + " to " + value )
	CodeCallback_EntityVarChanged( entity, varName, value, oldValue )
}

function InitEntityVars( entity )
{
	Assert( "_entityVars" in entity )

	if ( IsClient() )
	{
		local className = entity.GetSignifierName()
		local foundSelf = false

		if ( className in _entityVarsByEHandle )
		{
			foreach ( eHandle, eHandleVars in _entityVarsByEHandle[ className ] )
			{
				local ent = GetEntityFromEncodedEHandle( eHandle )
				if ( ent != entity )
					continue

				entity._entityVars = _entityVarsByEHandle[ className ][ eHandle ]
				foundSelf = true
			}
		}

		if ( !foundSelf )
		{
			entity._entityVars = {}

			foreach ( varName, value in _entityClassVars[className] )
			{
				entity._entityVars[varName] <- value
			}
		}
	}
	else
	{

		entity._entityVars = {}

		local className = entity.GetClassname()

		foreach ( varName, value in _entityClassVars[className] )
			entity._entityVars[varName] <- value
	}
}

function ServerCallback_SetServerVar( varHandle, value )
{
	local varName = _serverVarHandles[varHandle]

	if ( value != null )
	{
		if ( varName in _serverEntityVars )
			value = GetEntityFromEncodedEHandle( value )
	}

	_serverVars[varName] = value

	//printl( "Set serverVar " + varName + " to " + value )
	CodeCallback_ServerVarChanged( varName )
}

function RegisterServerVarChangeCallback( varName, callbackFunc )
{
	if ( !(varName in _serverVarChangeCallbacks) )
		_serverVarChangeCallbacks[varName] <- []

	_serverVarChangeCallbacks[varName].append( callbackFunc.bindenv( this ) )
}

function RegisterEntityVarChangeCallback( className, varName, callbackFunc )
{
	if ( !(className in _entityClassVarChangeCallbacks) )
		_entityClassVarChangeCallbacks[className] <- {}

	if ( !(varName in _entityClassVarChangeCallbacks[className]) )
		_entityClassVarChangeCallbacks[className][varName] <- []

	Assert( className in _entityClassVars, className + " is not a registered netvar classname." )
	Assert( varName in _entityClassVars[ className ], varName + " is not a registered netvar for classname " + className )
	_entityClassVarChangeCallbacks[className][varName].append( callbackFunc.bindenv( this ) )
}

// SERVER ONLY
function SetEntityVar( entity, varName, value )
{
	Assert( IsServer() )
	Assert( varName in _entityClassVars[entity.GetClassname()], "Entity " + entity + " does not have remote var " + varName )
	Assert( varName in _entityClassVarsIsEnts[entity.GetClassname()] )
	Assert( varName in _entityClassVarsSyncToAllClients[entity.GetClassname()] )
	Assert( typeof value != "string" )

	Assert( "_entityVars" in entity )

	if ( entity._entityVars[varName] == value )
		return

	entity._entityVars[varName] = value

	if ( _entityClassVarsIsEnts[entity.GetClassname()][varName] && value != null )
	{
		//printl( "SET NETWORK ENTITY VAR TO AN ENTITY. GETTING EHANDLE" )
		value = value.GetEncodedEHandle()
	}

	local syncToAllPlayers = _entityClassVarsSyncToAllClients[entity.GetClassname()][varName]

	// only sync "player" variables to that player
	if ( entity.IsPlayer() && !syncToAllPlayers )
	{
		if ( !entity.s.clientScriptInitialized )
			return

		Remote.CallFunction_NonReplay( entity, "ServerCallback_SetEntityVar", entity.GetEncodedEHandle(), _entityClassVarHandles[varName], value )
	}
	else
	{
		local players = GetPlayerArray()
		foreach ( player in players )
		{
			if ( !player.s.clientScriptInitialized )
				continue

			Remote.CallFunction_NonReplay( player, "ServerCallback_SetEntityVar", entity.GetEncodedEHandle(), _entityClassVarHandles[varName], value )
		}
	}
}

function SetServerVar( varName, value )
{
	Assert( IsServer() )
	Assert( varName in _serverVars )
	Assert( typeof value != "string" )

	if ( _serverVars[varName] == value )
		return

	_serverVars[varName] = value

	if ( varName in _serverEntityVars && value != null )
	{
		if ( IsValid( value ) )
			value = value.GetEncodedEHandle()
		else
			value = null
	}

	// Run server script change callback if one exists
	thread ServerVarChangedCallbacks( varName )

	// Update the var on all clients
	local players = GetPlayerArray()
	foreach ( player in players )
	{
		if ( !player.s.clientScriptInitialized )
			continue

		Remote.CallFunction_NonReplay( player, "ServerCallback_SetServerVar", _serverVarHandles[varName], value )
	}
}

function ServerVarChangedCallbacks(varName)
{
	// Run server script change callback if one exists
	if ( !( varName in _serverVarChangeCallbacks ) )
		return

	foreach ( callbackFunc in _serverVarChangeCallbacks[varName] )
		callbackFunc()
}

function SyncServerVars( player )
{
	Assert( IsServer() )

	foreach ( varName, value in _serverVars )
	{
		if ( varName in _serverEntityVars && value != null )
		{
			if ( IsValid( value ) )
				value = value.GetEncodedEHandle()
			else
				value = null
		}

		Remote.CallFunction_NonReplay( player, "ServerCallback_SetServerVar", _serverVarHandles[varName], value )
	}
}

function SyncEntityVars( player )
{
	Assert( IsServer() )

	foreach ( className, _ in _entityClassVars )
	{
		local entities;
		if ( className == "player" )
			entities = GetPlayerArray()
		else
			entities = GetNPCArrayByClass( className )

		foreach ( entity in entities )
		{
			if ( !IsValid( entity ) )
				continue

			foreach( varName, value in _entityClassVars[className] )
			{
				local entValue = entity._entityVars[varName]
				if ( entValue == value )
					continue

				if ( !_entityClassVarsSyncToAllClients[className][varName] && entity != player )
				{
					Assert( className == "player" )
					continue
				}
				//if ( className == "player" && !_entityClassVarsSyncToAllClients[className][varName] )
				//	continue
                //
				if ( _entityClassVarsIsEnts[className][varName] )
				{
					if ( !IsValid( entValue ) )
						continue
					// if this is an entity var, change over to e-handle
					entValue = entValue.GetEncodedEHandle()
				}

				Assert( player.s.clientScriptInitialized )

				Remote.CallFunction_NonReplay( player, "ServerCallback_SetEntityVar", entity.GetEncodedEHandle(), _entityClassVarHandles[varName], entValue )
			}
		}
	}
}



//********************************************************************************************
// _vscript_code.nut
// NOTE: you should not edit this file.
//********************************************************************************************

function __evalBreakpoint( evalString )
{
	local stackInfos = ::getstackinfos( 2 );

	local funcSrc = "return function ("
	local params = [];

	params.append( stackInfos.locals["this"] )
	local first = 1;
	foreach ( i, v in stackInfos.locals )
	{
		if( i != "this" && i[0] != '@' ) //foreach iterators start with @
		{
			if ( !first )
			{
				funcSrc = funcSrc + ", "
			}
			first = null
			params.append( v )
			funcSrc = funcSrc + i
		}
	}
	funcSrc = funcSrc + "){\n"
	funcSrc = funcSrc + "return (" + evalString + ")\n}"

	try
	{
		local evalFunc = ::compilestring( funcSrc )
		return evalFunc().acall( params )
	}
	catch( error )
	{
		::print( "ERROR\n" )
		return false
	}

	return true
}


function __serialize_state()
{
	/*
		see copyright notice in sqrdbg.h
	*/
	local currentscope;
	try
	{
		if ( ::getroottable().parent )
		{
			currentscope = ::getroottable();
			::setroottable( ::getroottable().parent );
		}

		local objs_reg = { maxid=0 ,refs={} }

		complex_types <- {
			["table"] = null,
			["array"] = null,
			["class"] = null,
			["instance"] = null,
			["weakref"] = null,
		}

		function build_refs( t ):( objs_reg )
		{
			if ( t == ::getroottable() )
				return;

			local otype = ::type( t );
			if ( otype in complex_types )
			{
				if ( !(t in objs_reg.refs) )
				{
					objs_reg.refs[t] <- objs_reg.maxid++;

					local iterateFunc = function( o, i, val ):( objs_reg )
									    {
										    build_refs( val );
										    build_refs( i );
									    }

				    iterateobject( t, iterateFunc )
				}
			}
		}

		function getvalue( v ):( objs_reg )
		{
			switch( ::type( v ) )
			{
				case "table":
				case "array":
				case "class":
				case "instance":
					return objs_reg.refs[v].tostring();
				case "integer":
				case "float":
				    return v;
				case "bool":
				    return v.tostring();
				case "string":
					return v;
				case "thread":
					return v.tostring();
				case "null":
				    return "null";
				default:
					return pack_type( ::type( v ) );
			}
		}

		local packed_types=
		{
			["null"]="n",
			["string"]="s",
			["integer"]="i",
			["float"]="f",
			["userdata"]="u",
			["function"]="fn",
			["table"]="t",
			["array"]="a",
			["generator"]="g",
			["thread"]="h",
			["instance"]="x",
			["class"]="y",
			["bool"]="b",
			["weakref"]="w"
		}

		function pack_type( objType ):( packed_types )
		{
			if ( objType in packed_types )
				return packed_types[objType]

			return objType
		}

		function iterateobject( obj, func )
		{
			local objType = ::type( obj );
			if ( objType == "instance" )
			{
				try
				{	//TRY TO USE _nexti
					//::print( "iterate: " + obj + "\n" )
					//local itCount = 0
				    foreach ( idx, val in obj )
				    {
						func( obj, idx, val );
						//itCount++

						//if ( itCount > 5000 )
						//	::print( "To many! " + obj.tostring() + " " + _typeof( obj ) )
				    }
					//::print( "complete\n\n" )
				}
				catch( error )
				{
					foreach ( idx, val in obj.getclass() )
					{
						func( obj, idx, obj[idx] );
					}
					//::print( "fail complete\n\n" )
				}
			}
			else if ( objType == "weakref" )
			{
				iterateobject( obj.ref(), func );
			}
			else
			{
				foreach ( idx, val in obj )
				{
				    func( obj, idx, val );
				}
			}

		}

		function build_tree():( objs_reg )
		{
			foreach ( i, o in objs_reg.refs )
			{
				beginelement( "o" );
				attribute( "type", (i==::getroottable()?"r":pack_type(::type(i))) );

				local _typeof = typeof i;
				if ( _typeof != ::type(i) )
				{
					attribute("typeof",_typeof);
				}

				attribute( "ref",o.tostring() );
				if ( i != ::getroottable() )
				{
					local iterateFunc = function( obj, idx, val )
											{
											// make functions show up in debugger by commenting these lines out
											if ( ::type(val) == "function" )
												return

											if( ::type( obj[idx] ) == "native function" )
												return

											beginelement( "e" )
												emitvalue( "kt", "kv", idx)
												emitvalue( "vt", "v", obj[idx] )
											endelement("e")
										}

					iterateobject( i, iterateFunc )
				}
				endelement( "o" );
			}
		}

		function evaluate_watch( locals, id, expression )
		{
			local func_src = "return function ("
			local params = [];

			params.append( locals["this"] )
			local first = 1;
			foreach ( i, v in locals )
			{
				if( i != "this" && i[0] != '@' ) //foreach iterators start with @
				{
					if ( !first )
					{
						func_src = func_src+","
					}
					first = null
					params.append( v )
					func_src = func_src + i
				}
			}
			func_src = func_src + "){\n"
			func_src = func_src + "return (" + expression + ")\n}"

			try
			{
				local func = ::compilestring( func_src );
				return { status = "ok", val = func().acall( params ) };
			}
			catch( error )
			{
				return { status = "error" }
			}
		}

		function emitvalue( type_attrib, value_attrib, val )
		{
			attribute( type_attrib, pack_type( ::type( val ) ) );
			attribute( value_attrib, getvalue( val ).tostring() );
		}

		/////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////
		local stack = []
		local level = 2;
		local si;

		//ENUMERATE THE STACK WATCHES
		while( si = ::getstackinfos( level ) )
		{
			stack.append( si );
			level++;
		}

		objs_reg.refs[ ::getroottable() ] <- objs_reg.maxid++;

		//EVALUATE ALL WATCHES
		foreach ( i, stackFrame in stack )
		{
			if ( stackFrame.src != "NATIVE" )
			{
				if ( "watches" in this )
				{
					stackFrame.watches <- {}
					foreach( i, watch in watches )
					{
						if( stackFrame.src != "NATIVE" )
						{
							stackFrame.watches[i] <- evaluate_watch( stackFrame.locals, i, watch );
							if( stackFrame.watches[i].status != "error" )
								build_refs( stackFrame.watches[i].val );
						}
						else
						{
							stackFrame.watches[i] <- {status="error"}
						}
						stackFrame.watches[i].exp <- watch;
					}

				}
			}

			foreach( i, l in stackFrame.locals )
			{
				build_refs( l );
			}
		}

		beginelement( "calls" );

		foreach (i, val in stack )
		{
			beginelement( "call" )
			attribute( "fnc", val.func )
			attribute( "src", val.src )
			attribute( "line", val.line.tostring() )

			foreach ( i, v in val.locals )
			{
				beginelement( "l" );
					attribute( "name", getvalue( i ).tostring() );
					emitvalue( "type", "val", v );
				endelement( "l" );
			}
			if( "watches" in val )
			{
				foreach( i, v in val.watches )
				{
					beginelement( "w" );
						attribute( "id", i.tostring() );
						attribute( "exp", v.exp );
						attribute( "status", v.status );
						if ( v.status != "error" )
						{
							emitvalue( "type", "val", v.val );
						}
					endelement( "w" );
				}
			}
			endelement( "call" );

		}
		endelement( "calls" );

		if ( "threads" in getroottable() )
		{
			local threadsList = threads.GetThreads()

			beginelement( "threads" )

			foreach ( threadId, threadObj in threadsList )
			{
				if ( threadObj == getthread() )
					continue

				beginelement( "thread" )
					local stack = []
					local level = 1;
					local si;

					attribute( "id", threadObj.tostring() );
					attribute( "state", threadObj.getstatus() );
					while ( si = threadObj.getstackinfos( level ) )
					{
						stack.append( si );
						level++;
					}

					//objs_reg.refs[::getroottable()] <- objs_reg.maxid++;
					foreach ( i, val in stack )
					{
						foreach ( i, l in val.locals )
							build_refs( l );
						}

					beginelement( "tcalls" );
						foreach ( i, val in stack )
						{
							beginelement( "tcall" );
								attribute( "fnc", val.func );
								attribute( "src", val.src );
								attribute( "line", val.line.tostring() );
								foreach ( i, v in val.locals )
								{
									beginelement( "l" );
										attribute( "name", getvalue(i).tostring() );
										emitvalue( "type", "val", v );
									endelement("l");
								}
							endelement("tcall");
						}
					endelement("tcalls");
				endelement("thread")
			}
			endelement("threads")
		}

		beginelement("objs");
		build_tree();
		endelement("objs");

		objs_reg = null;
		stack = null;

		if ( "collectgarbage" in ::getroottable() )
			::collectgarbage();
	}
	catch( error )
	{
		::print( "DEBUG SERIALIZATION ERROR: "+ error +"\n" );
	}

	if ( currentscope )
	{
		::setroottable( currentscope );
	}
}

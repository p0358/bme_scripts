//=====================================================================================
//
//=====================================================================================

RegisterSignal( "PetTitanModeChanged" )
RegisterSignal( "HardpointStateChanged" )
RegisterSignal( "PlayerAlive" )
RegisterSignal( "PlayerDying" )
RegisterSignal( "PlayerDead" )
RegisterSignal( "PlayerDiscardBody" )
RegisterSignal( "PetTitanChanged" )
RegisterSignal( "KillReplayStarted" )
RegisterSignal( "KillReplayEnded" )

level.onPlayerLifeStateChanged <- {}

function ClientCodeCallback_HotDropImpactTimeChanged( player )
{
	if ( !IsValid( player ) )
		return
	thread HotDropImpactTimeChanged( player )
}

function ClientCodeCallback_DropShipJetWakeFxEnabledChanged( dropship )
{
	if ( !IsValid( dropship ) )
		return
	thread JetwakeFXChanged( dropship )
}

function ClientCodeCallback_TurretPanelChanged( turret )
{
	if ( !IsValid( turret ) )
		return
	thread TurretPanelChanged( turret )
}

function ClientCodeCallback_OutOfBoundsDeadTimeChanged( player )
{
	if ( !IsValid( player ) )
		return
	thread OutOfBoundsDeadTime_Changed( player )
}

function ClientCodeCallback_OnPetTitanChanged( player )
{
	if ( !IsValid( player ) )
		return

	if ( !IsMenuLevel() )
		thread PetTitanChanged( player )

	player.Signal( "PetTitanChanged" )
}


function ClientCodeCallback_OnPetTitanModeChanged( player )
{
	if ( !IsValid( player ) )
		return

	player.Signal( "PetTitanModeChanged" )
}


function ClientCodeCallback_OnShieldHealthChanged( soul )
{
	if ( !IsValid( soul ) )
		return

	UpdateShieldHealth( soul )
	local shieldHealth = soul.GetShieldHealth()
	if ( shieldHealth == 0 && soul.lastShieldHealth )
	{
		PlayShieldBreakEffect( soul )
	}

	soul.lastShieldHealth = soul.GetShieldHealth()
}

function ClientCodeCallback_OnHardpointTerminalChanged( hp )
{
}

function ClientCodeCallback_OnHardpointIDChanged( hp )
{
	local ID = hp.GetHardpointID()
	if ( ID == -1 )
	{
		HideHardpointHUD( hp )
		return
	}

	InitializeHardpoint( hp )
	ShowHardpointHUD( hp )
	HardpointChanged( hp )
}

function ClientCodeCallback_OnHardpointChanged( hardpoint )
{
	if ( !IsValid( hardpoint ) )
		return
	HardpointChanged( hardpoint )
	hardpoint.Signal( "HardpointStateChanged" )
}

function ClientCodeCallback_OnHardpointEntityChanged( player )
{
	if ( !IsValid( player ) )
		return
	HardpointEntityChanged( player )
}

function ClientCodeCallback_OnCinematicEventFlagsChanged( player, oldFlags )
{
	if ( !IsValid( player ) )
		return
	//printt( "ClientCodeCallback_OnCinematicEventFlagsChanged for player: " + player.GetEntIndex() )

	//Strangely enough, even though cinematiceventflag data isn't propagated to other clients,
	//The codecallback for them triggers e.g. when you first connect onto a server.
	if ( player == GetLocalClientPlayer() )
	{
		thread UpdateMainHudFromCEFlags( player )
		thread CinematicEventFlagsChanged( player )
	}

	local playerFlags = player.GetCinematicEventFlags()

	local changedFlag = playerFlags ^ oldFlags //Take XOR of old and new flag to get changed flags
	//printt( "Old flags:" + oldFlags + " , new Flags: " + playerFlags + ", changedFlag " + changedFlag )

	foreach( flag, callbackInfoArray in level.cinematicEventFlagChangedCallback )
	{
		if ( !(changedFlag & flag) )
			continue

		foreach( callbackInfo in callbackInfoArray )
		{
			//printt( "Running callback function: " + callbackInfo.func + " for flag: " + flag )
			callbackInfo.func.acall( [ callbackInfo.scope, player ] )
		}
	}
}

function ClientCodeCallback_OnNextTitanRespawnAvailableChanged( player )
{
	if ( !IsValid( player ) )
		return

	UpdatePlayerStatusCounts()

	if ( player != GetLocalViewPlayer() )
		return

	UpdateTitanModeHUD( player )
}

function ClientCodeCallback_OnNextCoreChargeAvailableChanged( titansoul )
{
	if ( !IsValid( titansoul ) )
		return

	local player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	if ( titansoul != player.GetTitanSoul() )
		return

	local coreTimeRemaining = GetTitanCoreTimeRemaining( player )
	if ( coreTimeRemaining != null )
		player.Signal( "ActivateTitanCore" )

	UpdateTitanModeHUD( player )
}

function ClientCodeCallback_OnCoreChargeExpireTimeChanged( titansoul )
{
	if ( !IsValid( titansoul ) )
		return

	local player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	if ( titansoul != player.GetTitanSoul() )
		return

	UpdateTitanModeHUD( player )
}

function ClientCodeCallback_OnEntityCreation( entity )
{
	if ( IsLobby() )
	{
		if ( entity.GetSignifierName() != "player" )
			return

		if ( entity == GetLocalViewPlayer() )
			thread Lobby_AddPlayer( entity )

        return
	}

	PerfStart( PerfIndexClient.OnEntityCreation )

	local className = entity.GetSignifierName()
	local targetName = entity.GetName()

	if ( className in _entityClassVars )
	{
		if ( !entity._entityVars )
			InitEntityVars( entity )
	}

	if ( !("creationCount" in entity.s) )
	{
		entity.s.creationCount <- 0

		if ( entity instanceof C_BaseAnimating )
		{
			InitModelFX( entity )
			InitDamageData( entity )
			AddClientEventHandling( entity )
			entity.SetDoDestroyCallback( true )
			InitEntityForModel( entity )
		}
	}

	if ( className == "player" )
	{
		if ( GetLocalClientPlayer() == entity )
			entity.cv = level.clientVars

		if ( entity == GetLocalViewPlayer() )
			thread Init_PlayerScripts( entity )

		entity.SetDoDestroyCallback( true )

		// need this for kill replay.. but it doesn't work yet
		//if ( entity.IsTitan() )
		//	HandleDoomedState( GetLocalViewPlayer(), entity )
	}

	if ( className in level.createCallbacks )
	{
		foreach ( callbackInfo in level.createCallbacks[className] )
			callbackInfo.func.acall( [callbackInfo.scope, entity, entity.s.creationCount] )
	}

	if ( targetName in level.createCallbacks && targetName != className )
	{
		foreach ( callbackInfo in level.createCallbacks[targetName] )
			callbackInfo.func.acall( [callbackInfo.scope, entity, entity.s.creationCount] )
	}

	if ( className in level.destroyCallbacks )
		entity.SetDoDestroyCallback( true )

	if ( targetName in level.destroyCallbacks && targetName != className )
		entity.SetDoDestroyCallback( true )

	entity.s.creationCount++

	PerfEnd( PerfIndexClient.OnEntityCreation )
}

function ClientCodeCallback_OnDeath( entity )
{
	// need to set this OnEntityCreation or somewhere
	// entity.DoDeathCallback( true )

	local className = entity.GetSignifierName()
	local targetName = entity.GetName()

	entity.Signal( "OnDeath" )

	if ( className in level.onDeathCallbacks )
	{
		foreach ( callbackInfo in level.onDeathCallbacks[className] )
			callbackInfo.func.acall( [callbackInfo.scope, entity] )
	}

	if ( targetName in level.onDeathCallbacks && targetName != className )
	{
		foreach ( callbackInfo in level.onDeathCallbacks[targetName] )
			callbackInfo.func.acall( [callbackInfo.scope, entity, entity.s.creationCount] )
	}

	__RunOnDeathOrDestroyCallbacks( entity, className, targetName )
}

function __RunOnDeathOrDestroyCallbacks( entity, className, targetName )
{
	//do this so they don't run twice
	if ( ( "ranOnDeathOrDestroyCallbacks" in entity.s ) )
		return

	if ( className in level.onDeathOrDestroyCallbacks )
	{
		foreach ( callbackInfo in level.onDeathOrDestroyCallbacks[className] )
			callbackInfo.func.acall( [callbackInfo.scope, entity] )
	}

	if ( targetName in level.onDeathOrDestroyCallbacks && targetName != className )
	{
		foreach ( callbackInfo in level.onDeathOrDestroyCallbacks[targetName] )
			callbackInfo.func.acall( [callbackInfo.scope, entity, entity.s.creationCount] )
	}

	entity.s.ranOnDeathOrDestroyCallbacks <- true
}

function ClientCodeCallback_OnEntityDestroy( entity )
{
	// need to set this OnEntityCreation or somewhere
	// entity.SetDoDestroyCallback( true )

	local className = entity.GetSignifierName()
	local targetName = entity.GetName()

	entity.Signal( "OnDestroy" )
	entity.Signal( "OnDeath" )

	if ( className in level.destroyCallbacks )
	{
		foreach ( callbackInfo in level.destroyCallbacks[className] )
			callbackInfo.func.acall( [callbackInfo.scope, entity] )
	}

	if ( targetName in level.destroyCallbacks && targetName != className )
	{
		foreach ( callbackInfo in level.destroyCallbacks[targetName] )
			callbackInfo.func.acall( [callbackInfo.scope, entity, entity.s.creationCount] )
	}

	__RunOnDeathOrDestroyCallbacks( entity, className, targetName )
}


function ClientCodeCallback_OnPlayerLifeStateChanged( player, oldLifeState )
{
	//printt( player == GetLocalClientPlayer(), oldLifeState, player.GetLifeState(), IsWatchingKillReplay() )
	//local isWatchingKillReplay = IsWatchingKillReplay()

	local newLifeState = player.GetLifeState()

	// Added via AddCallback_OnPlayerLifeStateChanged
	foreach ( callbackInfo in level.onPlayerLifeStateChanged )
	{
		callbackInfo.func.acall( [callbackInfo.scope, player, oldLifeState, newLifeState] )
	}

	/*
	switch( oldLifeState )
	{
		case LIFE_ALIVE:
			printt( player.GetPlayerName(), "LIFE_ALIVE", IsAlive( player ) )
			if ( player == GetLocalClientPlayer() )
				thread OnClientPlayerAlive( player )
			player.Signal( "PlayerAlive" )
			break
		case LIFE_DYING:
			printt( player.GetPlayerName(), "LIFE_DYING", IsAlive( player ) )
			if ( player == GetLocalClientPlayer() )
				thread OnClientPlayerDying( player )
			player.Signal( "PlayerDying" )
			break
		case LIFE_DEAD:
			printt( player.GetPlayerName(), "LIFE_DEAD", IsAlive( player ) )
			player.Signal( "PlayerDead" )
			break
		case LIFE_DISCARDBODY:
			printt( player.GetPlayerName(), "LIFE_DISCARDBODY", IsAlive( player ) )
			player.Signal( "PlayerDiscardBody" )
			break
	}
	*/
}

function AddCallback_OnPlayerLifeStateChanged( callbackFunc )
{
	Assert( "onPlayerLifeStateChanged" in level )
	Assert( type( this ) == "table", "AddCallback_OnPlayerLifeStateChanged can only be added on a table. " + type( this ) )
	AssertParameters( callbackFunc, 3, "player, oldLifeState, newLifeState" )

	local name = FunctionToString( callbackFunc )
	Assert( !( name in level.onPlayerLifeStateChanged ), "Already added " + name + " with AddCallback_OnPlayerLifeStateChanged" )

	local callbackInfo = {}
	callbackInfo.name <- name
	callbackInfo.func <- callbackFunc
	callbackInfo.scope <- this

	level.onPlayerLifeStateChanged[ name ] <- callbackInfo
}

function ClientCodeCallback_KillReplayStarted()
{
	level.ent.Signal( "KillReplayStarted" )
	thread RunKillReplayStartedCallbacks()
}

function ClientCodeCallback_VoicePackChanged( player )
{
}

function RunKillReplayStartedCallbacks()
{
	wait 0
	foreach ( callbackInfo in level.killReplayStartCallbacks )
		callbackInfo.func.acall( [callbackInfo.scope] )
}

function ClientCodeCallback_KillReplayEnded()
{
	level.ent.Signal( "KillReplayEnded" )
	thread RunKillReplayEndedCallbacks()
}

function RunKillReplayEndedCallbacks()
{
	wait 0
	foreach ( callbackInfo in level.killReplayEndCallbacks )
		callbackInfo.func.acall( [callbackInfo.scope] )
}

function ServerCallback_YouRespawned()
{
	thread OnClientPlayerAlive( GetLocalClientPlayer() )
}


function ServerCallback_YouDied()
{
	local clientPlayer = GetLocalClientPlayer()
	thread OnClientPlayerDying( clientPlayer )
	// Set death time here
	clientPlayer.cv.killReplayTimeOfDeath = Time()

	thread TryReviveEventNotice()
}

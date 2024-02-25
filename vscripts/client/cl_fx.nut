
function main()
{
	Globalize( PlayBreakFX )
	Globalize( PlayDamageFX )
	Globalize( InitModelFX )
	Globalize( InitModelFXGroup )
	Globalize( UpdateModelFX )
	Globalize( PlayFXOnTag )
	Globalize( PlayFXAtPos )
	Globalize( PlayDodgeFX )
	Globalize( PlayDestroyFX )

	Globalize( EnableModelFXGroup )
	Globalize( DisableModelFXGroup )

	Globalize( ClearModelFXData )

	Globalize( BeginModelFXData )
	Globalize( EndModelFXData )
	Globalize( AddTagSpawnFX )
	Globalize( AddTagHealthFX )
	Globalize( AddTagBreakFX )
	Globalize( AddTagBreakSound )
	Globalize( AddDodgeFX )
	Globalize( MagicMissile )

	level.modelFXCurrent <- null
	level.modelFXCurrentModel <- null
	level.modelFXData <- {}

	RegisterSignal( "EndModelFXThink" )
	Assert( IsClient() )

	// links the various fx types with the "active" table that
	// tracks if they are currently active or not
	local table = {}
	table.spawnFX <- "activeSpawnFX"
	table.healthFX <- "activeHealthFX"
	table.healthSounds <- "activeHealthSounds"
	level.fxMappingForActive <- table

	PrecacheTitanImpactEffectTables( "titan_landing", "titan_footstep", "titan_dodge" )
	PrecachePilotImpactEffectTables( "pilot_landing" )
}


function BeginModelFXData( modelFXGroup, modelName, visibleTo = "all" )
{
	Assert( level.modelFXCurrent == null )
	Assert( visibleTo == "all" || visibleTo == "friend" || visibleTo == "foe" )

	if( !(modelName in level.modelFXData) )
		level.modelFXData[modelName] <- { groups = {}, hasDeathFX = false }

	Assert( !(modelFXGroup in level.modelFXData[modelName].groups) )

	PrecacheModel( modelName )

	level.modelFXData[modelName].groups[modelFXGroup] <- { tags = {}, events = {}, visibleTo = visibleTo }

	level.modelFXCurrent = level.modelFXData[modelName].groups[modelFXGroup]
	level.modelFXCurrentModel = modelName

}

function EditModelFXData( modelFXGroup, modelName )
{
	Assert( level.modelFXCurrent == null )
	Assert( modelName in level.modelFXData )
	Assert( modelFXGroup in level.modelFXData[modelName].groups )

	level.modelFXCurrent = level.modelFXData[modelName].groups[modelFXGroup]
	level.modelFXCurrentModel = modelName
}


function IncludeModelFXData( modelFXGroup, modelName )
{
	Assert( level.modelFXCurrent != null )
	Assert( modelName in level.modelFXData )
	Assert( modelFXGroup in level.modelFXData[modelName].groups )

	local modelData = level.modelFXData[modelName].groups[modelFXGroup]

	Assert( level.modelFXCurrent.tags.len() == 0 )

	CopyComplexRecursive( modelData, level.modelFXCurrent )
}


function InitModelFXTag( tagName )
{
	// make a table of empty fx arrays
	local table =
	{
		spawnLoopFX = [],
		breakFX = [],
		breakGibs = [],
		breakSpewGibs = [],
		damageFX = [],
		healthSounds = [],
		breakSounds = [],

		hasHealthDamageFX = false,
	}

	// add the ones that can be "active", and need special updating elsewhere
	foreach ( name, activeName in level.fxMappingForActive )
	{
		table[ name ] <- []
	}

	level.modelFXCurrent.tags[tagName] <- table
}


function AddTagSpawnFX( tagName, fxName )
{
	if ( !(tagName in level.modelFXCurrent.tags) )
		InitModelFXTag( tagName )

	PrecacheParticleSystem( fxName )

	local fxInfo = {}
	fxInfo.name <- fxName
	fxInfo.fxID <- GetParticleSystemIndex( fxName )

	level.modelFXCurrent.tags[tagName].spawnFX.append( fxInfo )
}


function AddTagSpawnLoopFX( tagName, fxName, minDelay, maxDelay )
{
	if ( !(tagName in level.modelFXCurrent.tags) )
		InitModelFXTag( tagName )

	PrecacheParticleSystem( fxName )

	local fxInfo = {}
	fxInfo.name <- fxName
	fxInfo.minDelay <- minDelay
	fxInfo.maxDelay <- maxDelay
	fxInfo.fxID <- GetParticleSystemIndex( fxName )

	level.modelFXCurrent.tags[tagName].spawnLoopFX.append( fxInfo )
}


function AddTagHealthFX( healthFrac, tagName, fxName, oneShotOnly = false, soundName = null )
{
	if ( !(tagName in level.modelFXCurrent.tags) )
		InitModelFXTag( tagName )

	PrecacheParticleSystem( fxName )

	local fxInfo = {}
	fxInfo.name <- fxName
	fxInfo.fxID <- GetParticleSystemIndex( fxName )
	fxInfo.healthFrac <- healthFrac
	fxInfo.soundName <- soundName
	fxInfo.oneShotOnly <- oneShotOnly
	fxInfo.doomed <- false

	level.modelFXCurrent.tags[tagName].healthFX.append( fxInfo )
}


function AddTagBreakFX( stateIndex, tagName, fxName, fxDelay = 0.0, soundName = null )
{
	if ( !fxDelay )
		fxDelay = 0.0

	if ( !(tagName in level.modelFXCurrent.tags) )
		InitModelFXTag( tagName )

	PrecacheParticleSystem( fxName )

	local fxInfo = {}
	fxInfo.name <- fxName
	fxInfo.delay <- fxDelay
	fxInfo.fxID <- GetParticleSystemIndex( fxName )
	fxInfo.stateIndex <- stateIndex

	if ( stateIndex == null || stateIndex == -1 )
		level.modelFXData[level.modelFXCurrentModel].hasDeathFX = true

	level.modelFXCurrent.tags[tagName].breakFX.append( fxInfo )

	if ( soundName )
		AddTagBreakSound( stateIndex, tagName, soundName, fxDelay )
}

function AddTagBreakSound( stateIndex, tagName, soundName, soundDelay = 0.0 )
{
	if ( !(tagName in level.modelFXCurrent.tags) )
		InitModelFXTag( tagName )

	local soundInfo = {}
	soundInfo.name <- soundName
	soundInfo.delay <- soundDelay
	soundInfo.stateIndex <- stateIndex

	level.modelFXCurrent.tags[tagName].breakSounds.append( soundInfo )
}


function AddDodgeFX( surfaceType, trailFxName )
{
	if ( !( "dodgeFx" in level.modelFXCurrent.events ) )
		level.modelFXCurrent.events.dodgeFx <- []

	PrecacheParticleSystem( trailFxName )

	local fxInfo = {}
	fxInfo.trailFxID <- GetParticleSystemIndex( trailFxName )
	fxInfo.surfaceType <- surfaceType

	level.modelFXCurrent.events.dodgeFx.append( fxInfo )
}


function EndModelFXData()
{
	foreach ( tagName, tagData in level.modelFXCurrent.tags )
		tagData.healthFX.sort( HealthFXSort )

	foreach ( tagName, tagData in level.modelFXCurrent.tags )
		tagData.healthSounds.sort( HealthFXSort )

	level.modelFXCurrent = null
	level.modelFXCurrentModel = null
}

function HealthFXSort( fxInfoA, fxInfoB )
{
	if ( fxInfoA.healthFrac > fxInfoB.healthFrac )
		return 1
	else
		return -1
}

function ShoulPlayFXGroup( entity, groupData )
{
	if ( !IsValid( entity ) )
		return false

	if ( !IsValid( GetLocalViewPlayer() ) )
		return false

	if ( groupData.visibleTo == "all" )
		return true

	if ( !IsMultiplayer() )
		return false

	if ( !( "GetTeam" in entity ) )
		return false

	if ( groupData.visibleTo == "friend" )
		return entity.GetTeam() == GetLocalViewPlayer().GetTeam()

	if ( groupData.visibleTo == "foe" )
		return entity.GetTeam() != GetLocalViewPlayer().GetTeam()

	return false
}

function PlayDestroyFX( entity )
{
	local modelName = entity.GetModelName()
	Assert( modelName in level.modelFXData, "model " + modelName + " not found in level.modelFXData" )

	if ( !level.modelFXData[modelName].hasDeathFX )
		return

	if ( entity.GetMaxHealth() <= 0 )
		return

	if ( entity.GetHealth() > 0 )
		return

	foreach ( groupName, groupData in level.modelFXData[modelName].groups )
	{
		if ( !ShoulPlayFXGroup( entity, groupData ) )
			continue

		foreach ( tagName, tagData in groupData.tags )
		{
			// Hack: defensive fix for E3, this func can run before OnModelChanged if titan spawns as it is being destroyed, ie disembark
			if ( !( tagName in entity.s.entityFXData ) )
				continue

			foreach ( fxInfo in tagData.breakFX )
			{
				if ( fxInfo.stateIndex != null && fxInfo.stateIndex > -1 )
					continue

				PlayFXOnTag( entity, fxInfo.fxID, entity.s.entityFXData[tagName].tagID )
			}

			foreach ( soundInfo in tagData.breakSounds )
			{
				if ( soundInfo.stateIndex != null && soundInfo.stateIndex > -1 )
					continue

				if ( soundInfo.delay )
					delaythread( soundInfo.delay ) PlayEntitySound( entity, soundInfo.name )
				else
					PlayEntitySound( entity, soundInfo.name )
			}

			foreach ( fxInfo in groupData.tags[tagName].breakGibs )
			{
				if ( fxInfo.stateIndex != null && fxInfo.stateIndex > -1 )
					continue

				ThrowBreakGibFromTag( entity, fxInfo.name, entity.s.entityFXData[tagName].tagID, fxInfo.fxName, fxInfo.gibType, fxInfo.minVelocity, fxInfo.maxVelocity )
			}

			foreach ( fxInfo in groupData.tags[tagName].breakSpewGibs )
			{
				if ( fxInfo.stateIndex != null && fxInfo.stateIndex > -1 )
					continue

				thread SpewBreakGibsFromTag( entity, fxInfo.set, entity.s.entityFXData[tagName].tagID, fxInfo.count )
			}
		}
	}
}


function PlayBreakFX( entity, tagName, stateIndex )
{
	if ( IsLocalPlayerTitan( entity ) )
		return

	local modelName = entity.GetModelName()
	Assert( modelName in level.modelFXData, "model " + modelName + " not found in level.modelFXData" )

	foreach ( groupName, groupData in level.modelFXData[modelName].groups )
	{
		if ( !(tagName in groupData.tags) )
			continue

		if ( !ShoulPlayFXGroup( entity, groupData ) )
			continue

		foreach ( fxInfo in groupData.tags[tagName].breakFX )
		{
			if ( fxInfo.stateIndex != stateIndex )
				continue

			// TODO: add effect check; we don't want to play looping fx this way
			if ( fxInfo.delay )
				delaythread( fxInfo.delay ) PlayFXOnTag( entity, fxInfo.fxID, entity.s.entityFXData[tagName].tagID )
			else
				PlayFXOnTag( entity, fxInfo.fxID, entity.s.entityFXData[tagName].tagID )
		}

		foreach ( fxInfo in groupData.tags[tagName].breakGibs )
		{
			if ( fxInfo.stateIndex != stateIndex )
				continue

			if ( fxInfo.delay )
				delaythread( fxInfo.delay ) ThrowBreakGibFromTag( entity, fxInfo.name, entity.s.entityFXData[tagName].tagID, fxInfo.fxName, fxInfo.gibType, fxInfo.minVelocity, fxInfo.maxVelocity )
			else
				ThrowBreakGibFromTag( entity, fxInfo.name, entity.s.entityFXData[tagName].tagID, fxInfo.fxName, fxInfo.gibType, fxInfo.minVelocity, fxInfo.maxVelocity )
		}

		foreach ( soundInfo in groupData.tags[tagName].breakSounds )
		{
			if ( soundInfo.stateIndex != stateIndex )
				continue

			if ( soundInfo.delay )
				delaythread( soundInfo.delay ) PlayEntitySound( entity, soundInfo.name )
			else
				PlayEntitySound( entity, soundInfo.name )
		}

		foreach ( fxInfo in groupData.tags[tagName].breakSpewGibs )
		{
			if ( fxInfo.stateIndex != stateIndex )
				continue

			if ( fxInfo.delay )
				delaythread( fxInfo.delay ) SpewBreakGibsFromTag( entity, fxInfo.set, entity.s.entityFXData[tagName].tagID, fxInfo.count )
			else
				thread SpewBreakGibsFromTag( entity, fxInfo.set, entity.s.entityFXData[tagName].tagID, fxInfo.count )
		}
	}
}

function PlayEntitySound( entity, soundName )
{
	if ( !IsValid( entity ) ) // sometimes we call this function with delaythread
		return

	EmitSoundOnEntity( entity, soundName )
}


function UpdateHealthDamageFX( entity )
{
	local modelName = entity.GetModelName()
	Assert( modelName in level.modelFXData )

	if ( !entity.s.damageData )
		return

	foreach ( bodyGroupName, bodyGroupData in entity.s.damageData )
	{
		local stateIndex = bodyGroupData.fxStage

		if ( !stateIndex )
			continue

		foreach ( tagName, tagID in bodyGroupData.tags )
		{
			PlayDamageFX( entity, tagName, stateIndex, true )
		}
	}
}


function PlayDamageFX( entity, tagName, stateIndex, healthUpdate = false )
{
	if ( IsLocalPlayerTitan( entity ) )
		return

	local modelName = entity.GetModelName()
	Assert( modelName in level.modelFXData )

	local curHealthFrac = GetHealthFrac( entity )

	if ( entity.IsTitan() && entity.GetDoomedState() )
		curHealthFrac = 0

	foreach ( groupName, groupData in level.modelFXData[modelName].groups )
	{
		if ( !(tagName in groupData.tags) )
			continue

		if ( !ShoulPlayFXGroup( entity, groupData ) )
			continue

		if ( healthUpdate && !groupData.tags[tagName].hasHealthDamageFX )
			continue

		//if ( groupData.tags[tagName].damageFX.len() )
		//	Signal( entity, "EndDamageFX_" + tagName )

		local bestHealthFXInfo = null

		foreach ( fxInfo in groupData.tags[tagName].damageFX )
		{
			if ( fxInfo.stateIndex != stateIndex )
				continue

			if ( fxInfo.healthFrac != null )
			{
				if ( curHealthFrac > fxInfo.healthFrac )
					continue

				if ( !bestHealthFXInfo || fxInfo.healthFrac < bestHealthFXInfo.healthFrac )
					bestHealthFXInfo = fxInfo

				continue
			}

			if ( !entity.s.entityFXData[tagName].groups[groupName].activeDamageFX[fxInfo.name] )
			{
				Signal( entity, "EndDamageFX_" + tagName )
				foreach ( activeFXName, activeFXState in entity.s.entityFXData[tagName].groups[groupName].activeDamageFX )
					entity.s.entityFXData[tagName].groups[groupName].activeDamageFX[activeFXName] = false

				thread LoopFXOnTag( entity, fxInfo.fxID, entity.s.entityFXData[tagName].tagID, fxInfo.minDelay, fxInfo.maxDelay, fxInfo.soundName, "EndDamageFX_" + tagName )
				entity.s.entityFXData[tagName].groups[groupName].activeDamageFX[fxInfo.name] = true
			}
		}

		if ( bestHealthFXInfo )
		{
			if ( !entity.s.entityFXData[tagName].groups[groupName].activeHealthDamageFX[bestHealthFXInfo.name] )
			{
				Signal( entity, "EndHealthDamageFX_" + tagName )
				foreach ( activeFXName, activeFXState in entity.s.entityFXData[tagName].groups[groupName].activeHealthDamageFX )
					entity.s.entityFXData[tagName].groups[groupName].activeHealthDamageFX[activeFXName] = false

				thread LoopFXOnTag( entity, bestHealthFXInfo.fxID, entity.s.entityFXData[tagName].tagID, bestHealthFXInfo.minDelay, bestHealthFXInfo.maxDelay, bestHealthFXInfo.soundName, "EndHealthDamageFX_" + tagName )
				entity.s.entityFXData[tagName].groups[groupName].activeHealthDamageFX[bestHealthFXInfo.name] = true
			}
		}
	}
}


function PlayDodgeFX( entity, origin, surfaceNormal, surfaceType, fxIDString )
{
	local modelName = entity.GetModelName()

	if ( !( modelName in level.modelFXData ) )
		return

	foreach ( groupName, groupData in level.modelFXData[modelName].groups )
	{
		if ( !( "dodgeFx" in groupData.events) )
			continue

		if ( !ShoulPlayFXGroup( entity, groupData ) )
			continue

		foreach ( fxInfo in groupData.events.dodgeFx )
		{
			if ( fxInfo.surfaceType != surfaceType )
				continue

			local angles = AnglesOnSurface( surfaceNormal, entity.GetVelocity() )
			StartParticleEffectInWorld( fxInfo[ fxIDString ], origin, angles )
		}
	}
}


function InitModelFX( entity )
{
	entity.s.entityFXData <- {}
	entity.s.entityFXGroupState <- {}
	entity.s.lastModel <- null
}


function InitModelFXGroup( entity, modelFXGroup )
{
	local className = entity.GetSignifierName()

	local modelName = entity.GetModelName()
	Assert( modelName in level.modelFXData )
	Assert( modelFXGroup in level.modelFXData[modelName].groups )

	local modelFXGroupData = level.modelFXData[modelName].groups[modelFXGroup]

	entity.s.entityFXGroupState[modelFXGroup] <- true

	foreach ( tagName, tagData in modelFXGroupData.tags )
	{
		if ( !(tagName in entity.s.entityFXData) )
		{
			entity.s.entityFXData[tagName] <- {}
			entity.s.entityFXData[tagName].groups <- {}
			entity.s.entityFXData[tagName].tagID <- entity.LookupAttachment( tagName )
		}

		if ( !(modelFXGroup in entity.s.entityFXData[tagName].groups) )
			entity.s.entityFXData[tagName].groups[modelFXGroup] <- GetNewActiveFXTable()

		foreach ( tagDataGroup, activeFxName in level.fxMappingForActive )
		{
			foreach ( fxInfo in tagData[ tagDataGroup ] )
			{
				entity.s.entityFXData[tagName].groups[modelFXGroup][ activeFxName ][fxInfo.name] <- null
			}
		}

		entity.s.entityFXData[tagName].groups[modelFXGroup].activeDamageFX <- {}
		entity.s.entityFXData[tagName].groups[modelFXGroup].activeHealthDamageFX <- {}

		foreach ( fxInfo in tagData.damageFX )
		{
			if ( fxInfo.healthFrac != null )
				entity.s.entityFXData[tagName].groups[modelFXGroup].activeHealthDamageFX[fxInfo.name] <- null
			else
				entity.s.entityFXData[tagName].groups[modelFXGroup].activeDamageFX[fxInfo.name] <- null
		}
	}

	thread ModelFXThink( entity )
}




function StopAllModelFX( entity )
{
	// when the entity dies, make sure all the FX get stopped correctly
	foreach ( tagName, tagData in entity.s.entityFXData )
	{
		foreach ( groupName, groupData in tagData.groups )
		{
			foreach ( activeFXType, activeFXGroup in groupData )
			{
				foreach ( fxName, fxID in activeFXGroup )
				{
					if ( fxID == null )
						continue

					if ( type(fxID) == "bool" )
					{
						if ( fxID && activeFXType == "activeHealthSounds" )
							StopSoundOnEntity( entity, fxName )
						continue
					}

					if ( !EffectDoesExist( fxID ) )
						continue

					EffectStop( fxID, false, true )
				}
			}
		}
	}
}


function ClearModelFXData( entity )
{
	if ( entity.s.entityFXData )
	{
		foreach ( tagName, tagData in entity.s.entityFXData )
		{
			if ( IsValidSignal( "EndDamageFX_" + tagName ) )
				Signal( entity, "EndDamageFX_" + tagName )

			if ( IsValidSignal( "EndHealthDamageFX_" + tagName ) )
				Signal( entity, "EndHealthDamageFX_" + tagName )

			foreach ( groupName, groupData in tagData.groups )
			{
				foreach ( activeFXType, activeFXGroup in groupData )
				{
					foreach ( fxName, fxID in activeFXGroup )
					{
						if ( fxID == null )
							continue

						if ( type(fxID) == "bool" )
						{
							if ( fxID && activeFXType == "activeHealthSounds" )
								StopSoundOnEntity( entity, fxName )
							continue
						}

						if ( !EffectDoesExist( fxID ) )
							continue

						EffectStop( fxID, true, true )
					}
				}
			}
		}
	}

	entity.s.entityFXData = {}

	Signal( entity, "EndModelFXThink" )
}

function ModelFXThink( entity )
{
	entity.EndSignal( "OnDeath" )
	entity.EndSignal( "OnDestroy" )
	entity.Signal( "EndModelFXThink" )
	entity.EndSignal( "EndModelFXThink" )

	// necessary to prevent the OnThreadEnd below from killing the FX started by UpdateModelFX()
	WaitEndFrame()

	OnThreadEnd(
		function () : ( entity )
		{
			StopAllModelFX( entity )
		}
	)

	entity.EnableHealthChangedCallback()

	UpdateModelFX( entity )
	while ( IsAlive( entity ) )
	{
		UpdateHealthFX( entity )
		entity.WaitSignal( "HealthChanged" )
	}

	if ( !entity.s.entityFXData )
		return
}


function GetOne( ent )
{
	return 1
}


function UpdateModelFX( entity )
{
	local modelName = entity.GetModelName()

	if ( !(modelName in level.modelFXData) )
		return

	foreach ( groupName, groupData in level.modelFXData[modelName].groups )
	{
		UpdateModelFXGroup( entity, groupName )
	}
}


function UpdateModelFXGroup( entity, groupName )
{
	local groupData = level.modelFXData[entity.GetModelName()].groups[groupName]

	if ( !ShoulPlayFXGroup( entity, groupData ) )
		return

	if ( IsLocalPlayerTitan( entity ) )
		return

	local curHealthFrac = GetHealthFrac( entity )

	foreach ( tagName, tagData in entity.s.entityFXData )
	{
		if ( !(groupName in tagData.groups) )
			continue

		if ( !(tagName in groupData.tags ) )
			continue

		foreach ( fxInfo in groupData.tags[tagName].spawnFX )
		{
			local fxName = fxInfo.name

			if ( !entity.s.entityFXGroupState[groupName] )
			{
				local fxID = tagData.groups[groupName].activeSpawnFX[fxName]
				if ( fxID && EffectDoesExist( fxID ) )
					EffectStop( fxID, true, true )
			}
			else
			{
				if ( tagData.groups[groupName].activeSpawnFX[fxName] && EffectDoesExist( tagData.groups[groupName].activeSpawnFX[fxName] ) )
					continue

				tagData.groups[groupName].activeSpawnFX[fxName] = PlayFXOnTag( entity, fxInfo.fxID, tagData.tagID )
			}
		}

		UpdatePlayFxForGroupData( entity, tagName, tagData, groupName, groupData, curHealthFrac )
	}
}


function UpdateHealthFX( entity )
{
	local modelName = entity.GetModelName()

	// not an assert because entities can change models
	if ( !(modelName in level.modelFXData) )
		return

	if ( IsLocalPlayerTitan( entity ) )
		return

	UpdateHealthDamageFX( entity )

	local curHealthFrac = GetHealthFrac( entity )

	foreach ( tagName, tagData in entity.s.entityFXData )
	{
		foreach ( groupName, groupData in level.modelFXData[modelName].groups )
		{
			if ( groupName != "titanHealth" ) // optimization
				continue

			if ( tagName in groupData.tags )
			{
				UpdatePlayFxForGroupData( entity, tagName, tagData, groupName, groupData, curHealthFrac )
			}
		}
	}
}


function UpdatePlayFxForGroupData( entity, tagName, tagData, groupName, groupData, curHealthFrac )
{
	local isDoomed = false

	if ( entity.IsTitan() && entity.GetDoomedState() )
		isDoomed = true

	local minHealthFrac = 0
	foreach ( fxInfo in groupData.tags[tagName].healthFX )
	{
		local fxName = fxInfo.name

		if ( fxInfo.oneShotOnly )
		{
			local fxPlayed = tagData.groups[groupName].activeHealthFX[fxName]

			if ( curHealthFrac <= fxInfo.healthFrac && curHealthFrac >= minHealthFrac && !fxPlayed )
			{
				PlayFXOnTag( entity, fxInfo.fxID, tagData.tagID )
				tagData.groups[groupName].activeHealthFX[fxName] = true
			}
		}
		else
		{
			local fxPlaying = (tagData.groups[groupName].activeHealthFX[fxName] && EffectDoesExist( tagData.groups[groupName].activeHealthFX[fxName] ))

			if ( fxInfo.doomed != isDoomed )
			{
				if ( fxPlaying )
				{
					EffectStop( tagData.groups[groupName].activeHealthFX[fxName], false, true )
					tagData.groups[groupName].activeHealthFX[fxName] = null
				}
			}
			else if ( curHealthFrac <= fxInfo.healthFrac && curHealthFrac >= minHealthFrac )
			{
				if ( !fxPlaying )
				{
					tagData.groups[groupName].activeHealthFX[fxName] = PlayFXOnTag( entity, fxInfo.fxID, tagData.tagID )
				}
			}
			else
			{
				if ( fxPlaying )
				{
					EffectStop( tagData.groups[groupName].activeHealthFX[fxName], false, true )
					tagData.groups[groupName].activeHealthFX[fxName] = null
				}
			}
		}

		if ( fxInfo.doomed == isDoomed )
			minHealthFrac = fxInfo.healthFrac
	}

	local minHealthFrac = 0
	foreach ( fxInfo in groupData.tags[tagName].healthSounds )
	{
		local soundName = fxInfo.name

		local soundPlaying = tagData.groups[groupName].activeHealthSounds[soundName]

		if ( curHealthFrac <= fxInfo.healthFrac && curHealthFrac >= minHealthFrac )
		{
			if ( !soundPlaying )
			{
				EmitSoundOnEntity( entity, soundName )
				tagData.groups[groupName].activeHealthSounds[soundName] = true

				if ( fxInfo.oneShotSoundName )
					EmitSoundOnEntity( entity, fxInfo.oneShotSoundName )
			}
		}
		else
		{
			if ( soundPlaying )
			{
				StopSoundOnEntity( entity, soundName )
				tagData.groups[groupName].activeHealthSounds[soundName] = false
			}
		}

		minHealthFrac = fxInfo.healthFrac
	}
}


function ThrowBreakGibFromTag( entity, modelName, tagID, fxName, gibType, minVelocity, maxVelocity )
{
	if ( !IsValid( entity ) ) // sometimes we call this function with delaythread
		return

	local origin = entity.GetAttachmentOrigin( tagID )
	local angles
	local launchVec
	local angularVel
	local lifetime

	switch ( gibType )
	{
		case GIBTYPE_DEATH:
			launchVec = (origin - entity.GetWorldSpaceCenter())
			launchVec.Normalize()
			angularVel = Vector( RandomInt( -30, 30 ), RandomInt( -30, 30 ), RandomInt( -30, 30 ) )
			angles = Vector( 0, 0, 0 )
			lifetime = 10.0
			break

		default:
			angles = entity.GetAttachmentAngles( tagID )
			launchVec = angles.AnglesToForward()
			angularVel = Vector( RandomInt( -30, 30 ), RandomInt( -30, 30 ), RandomInt( -30, 30 ) )

			lifetime = 10.0
			break
	}

	launchVec *= RandomIntRange( minVelocity, maxVelocity )

	local gib = CreateClientsideGib( modelName, origin, angles, launchVec, angularVel, lifetime, 3000, 1000 )

	if ( !fxName )
		return

	StartParticleEffectOnEntity( gib, GetParticleSystemIndex( fxName ), FX_PATTACH_ABSORIGIN_FOLLOW, 0 )
}


function SpewBreakGibsFromTag( entity, gibSet, tagID, numGibs )
{
	if ( !IsValid( entity ) ) // sometimes we call this function with delaythread
		return

	entity.EndSignal( "OnDestroy" )

	local origin = entity.GetAttachmentOrigin( tagID )
	local angles = entity.GetAttachmentAngles( tagID )

	for ( local i = 0; i < numGibs; i++ )
	{
		local launchVec = Vector( RandomFloat( -1.0, 1.0 ), RandomFloat( -1.0, 1.0 ), 1 )
		launchVec.Normalize()
		launchVec *= RandomIntRange( 200, 600 )

		local angularVel = Vector( RandomInt( -30, 30 ), RandomInt( -30, 30 ), RandomInt( -30, 30 ) )
		CreateClientsideGib( Random( gibSet ), origin, angles, launchVec, angularVel, 10.0, 3000, 500 )
		wait 0
	}
}


function PlayFXOnTag( entity, playFxID, tagID )
{
	if ( !IsValid( entity ) ) // sometimes we call this function with delaythread
		return

	local fxID = StartParticleEffectOnEntity( entity, playFxID, FX_PATTACH_POINT_FOLLOW, tagID )

		// hack to stop error spam
	if ( entity.IsPlayer() )
		thread KillFXOnModelSwap( entity, fxID )

	return fxID
}


function LoopFXOnTag( ent, loopFxID, tagID, minDelay, maxDelay, soundName, endSignalName )
{
	EndSignal( ent, endSignalName )

	while ( IsAlive( ent ) )
	{
		if ( soundName )
			EmitSoundOnEntity( ent, soundName )

		local fxID = StartParticleEffectOnEntity( ent, loopFxID, FX_PATTACH_POINT_FOLLOW, tagID )

		// hack to stop error spam
		if ( ent.IsPlayer() )
			thread KillFXOnModelSwap( ent, fxID )

		wait RandomFloat( minDelay, maxDelay )
	}
}


// hack to stop error spam: code needs to handle killing fx on model swap.
function KillFXOnModelSwap( entity, fxID )
{
	entity.EndSignal( "OnModelChanged" )

	OnThreadEnd( function() : (fxID) {
		if ( !EffectDoesExist( fxID ) )
			return

		EffectStop( fxID, true, false )
	})

	while ( EffectDoesExist( fxID ) )
		wait 0.5
}


function PlayFXAtPos( ent, fxID, origin, angles, delay, setEntAsCP = false )
{
	if ( delay )
		wait delay

	if ( setEntAsCP )
	{
		local instanceID = StartParticleEffectInWorldWithHandle( fxID, origin, angles )
		EffectSetControlPointEntity( instanceID, 1, ent )
	}
	else
	{
		StartParticleEffectInWorld( fxID, origin, angles )
	}
}


function GetModelFXData( modelName )
{
	return level.modelFXData[modelName]
}


function IsLocalPlayerTitan( entity )
{
	local player = GetLocalViewPlayer()

	if ( !player.IsTitan() )
		return false

	return player == entity
}


function GetNewActiveFXTable()
{
	local table = {}
	// this table will be cloned for new Titans
	foreach ( name, activeName in level.fxMappingForActive )
	{
		table[ activeName ] <- {}
	}

	return table
}


function EnableModelFXGroup( entity, groupName )
{
	Assert( groupName in entity.s.entityFXGroupState )

	entity.s.entityFXGroupState[groupName] = true
	UpdateModelFXGroup( entity, groupName )
}


function DisableModelFXGroup( entity, groupName )
{
	Assert( groupName in entity.s.entityFXGroupState )

	entity.s.entityFXGroupState[groupName] = false
	UpdateModelFXGroup( entity, groupName )
}

// Fires a missile from a start to end position.
// Optional: Will track a moving target if homingTarget is provided.
// Optional: If an offset is provided, the rocket will detonate at the offset from the target origin instead of at target origin.
//           This is useful for large models such as ships where you want it to explode on the hull rather than center of the ship model.
function MagicMissile( startPos, endPos, speed, explosionFX, rocketTrailFX, doExplosion = true, homingTarget = null, explosionOffset = null)
{
	local vec 			= startPos - endPos
	local rocket 		= CreateClientsideScriptMover( "models/dev/empty_model.mdl", startPos, VectorToAngles( vec ) )
	local attachID 		= rocket.LookupAttachment( "REF" )
	local fxid 			= GetParticleSystemIndex( rocketTrailFX )
	local trailFX		= StartParticleEffectOnEntity( rocket, fxid, FX_PATTACH_POINT_FOLLOW, attachID )
	local dist 			= 0
	local destroyTime 	= 0
	local travelTime 	= 0

	// Play an explosion when the rocket reaches its destination and dies
	OnThreadEnd(
		function () : ( explosionFX, trailFX, rocket, doExplosion )
		{
			local explosionID 	= GetParticleSystemIndex( explosionFX )
			local attachID 		= rocket.LookupAttachment( "REF" )

			if( doExplosion )
				StartParticleEffectInWorld( explosionID, rocket.GetOrigin(), rocket.GetAngles() )

			if ( EffectDoesExist( trailFX ) )
				EffectStop( trailFX, false, true )

			if ( IsValid( rocket ) )
				rocket.Kill()
		}
	)

	rocket.EndSignal( "OnDeath" )

	for(;;)
	{
		if( !IsAlive( rocket ) )
			break

		if( homingTarget )
			endPos = homingTarget.GetOrigin()

		if( explosionOffset )
			endPos = explosionOffset - endPos

		dist = Distance( rocket.GetOrigin(), endPos )
		travelTime = Graph( dist, 0, speed, 0, 1.0 )
		destroyTime = Time() + travelTime

		if ( travelTime <= 0 )
			break

		rocket.NonPhysicsMoveTo( endPos, travelTime, 0, 0 )

		// getting close?
		if ( travelTime < 0.1 )
		{
			wait travelTime
			return
		}

		wait 0.1
	}

	if ( Time() < destroyTime )
		wait destroyTime - Time()
}

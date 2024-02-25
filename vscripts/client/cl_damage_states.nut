function main()
{
	Globalize( InitDamageData )
	Globalize( ClearDamageData )
	//Globalize( InitModelDamageData )
	//Globalize( DamageStates_UpdateDamageStates )
	//Globalize( DamageStates_UsesBodyGroup )

	Globalize( ChangedAtlasFrontBodygroup )
}


function InitDamageData( ent )
{
	ent.s.damageData <- null
	ent.s.bodyGroupMap <- null
}

/*
function InitModelDamageData( ent )
{
	local entKVs = ent.CreateTableFromModelKeyValues()

	if ( !("hit_data" in entKVs ) )
		return

	Assert( ent.s.damageData == null )
	ent.s.damageData = {}
	ent.s.bodyGroupMap = {}

	foreach ( bodyGroupName, bodyGroupData in entKVs["hit_data"] )
	{
		local bodyGroupID = ent.FindBodyGroup( bodyGroupName )

		ent.s.damageData[bodyGroupName] <- {}
		ent.s.damageData[bodyGroupName].bodygroupID <- bodyGroupID
		ent.s.damageData[bodyGroupName].tags <- {}
		ent.s.damageData[bodyGroupName].fxStage <- 0
		ent.s.damageData[bodyGroupName].activeFX <- {}

		ent.s.bodyGroupMap[bodyGroupID] <- bodyGroupName

		RegisterSignal( "EndFX_" + bodyGroupName )

		foreach ( keyName, v in bodyGroupData )
		{
			if ( keyName.find( "tag" ) != null )
			{
				local tagID = ent.LookupAttachment( v )
				ent.s.damageData[bodyGroupName].tags[v] <- tagID
			}
		}

		DamageStates_UpdateDamageStates( ent, bodyGroupID, ent.GetBodyGroupState( bodyGroupID ), false )
	}
}
*/

function ClearDamageData( entity )
{
	entity.s.damageData = null
	entity.s.bodyGroupMap = null
}

/*
function DamageStates_UpdateDamageStates( ent, bodyGroupID, bodyGroupState, playBreakFX )
{
	if ( ent.IsTitan() && ent.IsPlayer() && ent == GetLocalViewPlayer() )
		return

	local bodyGroupName = ent.s.bodyGroupMap[bodyGroupID]

	if ( ent.s.damageData[bodyGroupName].fxStage == bodyGroupState )
		return

	PerfStart( PerfIndexClient.UpdateDamageStates )

	ent.s.damageData[bodyGroupName].fxStage = bodyGroupState

	foreach ( tagName, tagID in ent.s.damageData[bodyGroupName].tags )
	{
		if ( playBreakFX )
			PlayBreakFX( ent, tagName, bodyGroupState )

		PlayDamageFX( ent, tagName, bodyGroupState )
	}

	PerfEnd( PerfIndexClient.UpdateDamageStates )
}


function DamageStates_UsesBodyGroup( entity, bodyGroupID )
{
	return ( bodyGroupID in entity.s.bodyGroupMap )
}
*/

function ChangedAtlasFrontBodygroup( ent, bodyGroupID, newState, oldState )
{
	Assert( bodyGroupID == 7 )

	// defensive nv workaround
	local soul = ent.GetTitanSoul()
	if ( !IsValid( soul ) )  //JFS Defensive fix
		return

	if ( soul.titanEyeVisibility >= EYE_HIDDEN )
	{
		HideTitanEye( ent )
		return
	}

	// Destroy the eye!
	if ( newState == 1 )
		HideTitanEyeForever( ent )
}

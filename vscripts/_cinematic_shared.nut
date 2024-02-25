
//open for edit - register cinematic functions here

function RegisterCinematicFuncs()
{
	RegisterClientCinematicFunction( "CE_VisualSettingsSpace" )
	RegisterClientCinematicFunction( "CE_VisualSettingsDropshipInterior" )
	RegisterClientCinematicFunction( "CE_ResetVisualSettings" )
	RegisterClientCinematicFunction( "CE_BloomOnRampOpen" )

	switch ( GetMapName() )
	{
		case "mp_fracture":
			RegisterClientCinematicFunction( "CE_FractureVisualSettingsSpace" )
			RegisterClientCinematicFunction( "CE_VisualSettingsDropshipIMC" )
			RegisterClientCinematicFunction( "CE_FractureIMCIntroBogies" )
			break

		case "mp_colony":
			RegisterClientCinematicFunction( "CE_VisualSettingColonyIMC" )
			RegisterClientCinematicFunction( "CE_VisualSettingColonyMCOR" )
			break

		case "mp_relic":
			RegisterClientCinematicFunction( "CE_VisualSettingRelicIMC" )
			RegisterClientCinematicFunction( "CE_VisualSettingRelicMCOR" )
			break

		case "mp_outpost_207":
			RegisterClientCinematicFunction( "CE_VisualSettingOutpostIMC" )
			RegisterClientCinematicFunction( "CE_VisualSettingOutpostMCOR" )
			RegisterClientCinematicFunction( "CE_BloomOnRampOpenOutpostIMC" )
			RegisterClientCinematicFunction( "CE_BloomOnRampOpenOutpostMCOR" )
			break

		case "mp_boneyard":
			RegisterClientCinematicFunction( "CE_VisualSettingBoneyardIMC" )
			RegisterClientCinematicFunction( "CE_VisualSettingBoneyardMCOR" )
			RegisterClientCinematicFunction( "CE_BloomOnRampOpenBoneyardIMC" )
			RegisterClientCinematicFunction( "CE_BloomOnRampOpenBoneyardMCOR" )
			break

		case "mp_airbase":
			RegisterClientCinematicFunction( "CE_VisualSettingAirbaseMCOR" )
			break

		case "mp_o2":
			RegisterClientCinematicFunction( "CE_O2VisualSettingsSpaceIMC" )
			RegisterClientCinematicFunction( "CE_O2VisualSettingsSpaceMCOR" )
			RegisterClientCinematicFunction( "CE_O2VisualSettingsTransition" )
			RegisterClientCinematicFunction( "CE_O2VisualSettingsEvac" )
			RegisterClientCinematicFunction( "CE_O2VisualSettingsWorldIMC" )
			RegisterClientCinematicFunction( "CE_O2VisualSettingsWorldMCOR" )
			RegisterClientCinematicFunction( "CE_O2BloomOnRampOpen" )
			RegisterClientCinematicFunction( "CE_O2BloomOnRampOpenIMC" )
			RegisterClientCinematicFunction( "CE_O2SkyScaleShipOnRampClose" )
			RegisterClientCinematicFunction( "CE_O2VisualSettingsEject" )
			RegisterClientCinematicFunction( "CE_O2SkyScaleShipEnterAtmos" )
			RegisterClientCinematicFunction( "CE_02AirBurstEvents" )
			RegisterClientCinematicFunction( "CE_O2Wakeup" )
			RegisterClientCinematicFunction( "CE_O2SmokePlumes" )
			RegisterClientCinematicFunction( "CE_O2BlackOut" )
			RegisterClientCinematicFunction( "CE_O2CrashVisual" )
			break

		case "mp_corporate":
			RegisterClientCinematicFunction( "CE_VisualSettingCorporateMCOR" )
			RegisterClientCinematicFunction( "CE_VisualSettingCorporateIMC" )
			RegisterClientCinematicFunction( "CE_BloomOnRampOpenCorporateIMC" )
			break
	}



}










//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	STAY ABOVE THIS LINE	^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//												DO NOT EDIT ANYTHING BELOW THIS LINE!


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


function main()
{
	level.clientFuncNames 	<- []
	level.clientFuncHandles	<- {}
	level.fCountClient 		<- 0
	FlagInit( "CinematicFunctionsRegistered" )
	/* why do I not Globalize?
	if ( IsServer() )
		Globalize( GetClientFunctionHandle )
	if ( IsClient() )
		Globalize( GetClientFunctionFromHandle )
	*/

	thread RegisterCinematicFuncsWrapper()
}

function RegisterCinematicFuncsWrapper()
{
	WaitEndFrame()
	RegisterCinematicFuncs()
	FlagSet( "CinematicFunctionsRegistered" )
}

function GetClientFunctionHandle( name )
{
	Assert( IsServer() )
	Assert( name in level.clientFuncHandles, "function " + name + "hasn't been registered" )

	return level.clientFuncHandles[ name ]
}

function GetClientFunctionFromHandle( handle )
{
	Assert( IsClient() )
	Assert( handle in level.clientFuncNames, "function with handle " + handle + "hasn't been registered" )

	local name = level.clientFuncNames[ handle ]
	return this[ name ]
}

function RegisterClientCinematicFunction( name )
{
	if ( IsClient() )
	{
		Assert( name in this, "function " + name + " doesn't exist on the client" )
		level.clientFuncNames.append( name )
	}
	else //server
	{
		level.clientFuncHandles[ name ] <- level.fCountClient
	}

	level.fCountClient++
}

main()
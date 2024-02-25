::COOP_COMBAT_STORE <- 0
::COOP_SURVIVAL_STORE <- 1
::COOP_FORTIFICATION_STORE <- 2

function main()
{
	Globalize( InitCoopUnlocks )
	Globalize( GetCoopUnlockStoresTable )
	Globalize( GetCoopUnlockDataTable )
	Globalize( Coop_AdjustUnlockPointsToPlayer )
	Globalize( ServerCallback_COOP_AdjustUnlockPointTotal )
	Globalize( ServerCallback_CoopStoreOnClientConnected )
	Globalize( GetUnlockFromUnlockRef )
	Globalize( GetCoopPointTotal_UI )

	
	if ( IsUI() )
		coopUnlockPointTotal <- 0
	
	if ( IsServer() )
	{
		level.coopUnlockPointTotals <- {}
		AddCallback_OnClientConnected( CoopStoreOnClientConnected )
		AddClientCommandCallback( "TryToActivateCoopUnlock", TryToActivateCoopUnlock )
	}
}

function InitCoopUnlocks()
{
	coopUnlockStores <- {}
	coopUnlockData <- {}
	
	CreateCoopUnlockStore( COOP_COMBAT_STORE, 			"#COOP_UNLOCK_COMBAT_STORE_NAME", 			"#COOP_UNLOCK_COMBAT_STORE_DESC", 			"../models/titans/custom_decals/decal_pack_01/titan_decal_a_base_imc_menu" )
	CreateCoopUnlockStore( COOP_SURVIVAL_STORE, 		"#COOP_UNLOCK_SURVIVAL_STORE_NAME", 		"#COOP_UNLOCK_SURVIVAL_STORE_DESC",			"../models/titans/custom_decals/decal_pack_01/titan_decal_a_base_imc_menu" )
	CreateCoopUnlockStore( COOP_FORTIFICATION_STORE,	"#COOP_UNLOCK_FORTIFICATION_STORE_NAME",	"#COOP_UNLOCK_FORTIFICATION_STORE_DESC",	"../models/titans/custom_decals/decal_pack_01/titan_decal_a_base_imc_menu" )

	//-------------------------------------------------
	// COMBAT UNLOCKS
	//-------------------------------------------------
	CreateCoopUnlockData( "coop_ordnance_capacity_1",	CreateFunctionCallbackTable( Coop_Purchase_Ordnance_Capacity_1 ),	COOP_COMBAT_STORE, 	1,		"#COOP_ORDNANCE_CAPACITY_1_NAME", 	"#COOP_ORDNANCE_CAPACITY_1_DESC", 	"#COOP_ORDNANCE_CAPACITY_1_REQ", 	"#COOP_ORDNANCE_CAPACITY_1_REQ_UNLOCKED", null, null,							  "../models/titans/custom_decals/decal_pack_01/titan_decal_a_base_imc_menu", 1 )
	CreateCoopUnlockData( "coop_ordnance_capacity_2",	CreateFunctionCallbackTable( Coop_Purchase_Ordnance_Capacity_2 ),	COOP_COMBAT_STORE,	1,		"#COOP_ORDNANCE_CAPACITY_2_NAME", 	"#COOP_ORDNANCE_CAPACITY_2_DESC", 	"#COOP_ORDNANCE_CAPACITY_2_REQ", 	"#COOP_ORDNANCE_CAPACITY_2_REQ_UNLOCKED", null,	SFLAG_COOP_ORDNANCE_CAPACITY_1,   "../models/titans/custom_decals/decal_pack_01/titan_decal_a_base_imc_menu", 1 )

	//-------------------------------------------------
	// SURVIVAL UNLOCKS
	//-------------------------------------------------
	CreateCoopUnlockData( "coop_increasedTitanHealth",	CreateFunctionCallbackTable( Coop_Purchase_Increased_Titan_Health ),	COOP_SURVIVAL_STORE,	1, 	"#COOP_INCREASED_TITAN_HEALTH_NAME", 	"#COOP_INCREASED_TITAN_HEALTH_DESC",	"#COOP_INCREASED_TITAN_HEALTH_REQ", 	"#COOP_INCREASED_TITAN_HEALTH_REQ_UNLOCKED", null, null, "../models/titans/custom_decals/decal_pack_01/titan_decal_a_base_imc_menu", 3 )

	//-------------------------------------------------
	// FORTIFICATION UNLOCKS
	//-------------------------------------------------
	CreateCoopUnlockData( "coop_call_in_turret",		CreateFunctionCallbackTable( Coop_Purchase_Call_In_Turret ),			COOP_FORTIFICATION_STORE, 2,	"#COOP_CALL_IN_TURRET_NAME", 	"#COOP_CALL_IN_TURRET_DESC",	"#COOP_CALL_IN_TURRET_REQ", 	"#COOP_CALL_IN_TURRET_REQ_UNLOCKED", "#COOP_CALL_IN_TURRET_CUSTOM_REQ", null, "../models/titans/custom_decals/decal_pack_01/titan_decal_a_base_imc_menu", -1 )

}

function CreateCoopUnlockStore( ref, name, desc, image )
{
	Assert( !( ref in coopUnlockStores ), "ref " + ref + " being redefined!" )
	
	if ( IsClient() )
		PrecacheHUDMaterial( image )

	coopUnlockStores[ref] <- {}
	coopUnlockStores[ref].ref <- ref
	coopUnlockStores[ref].name <- name
	coopUnlockStores[ref].desc <- desc
	coopUnlockStores[ref].unlockRefs <- {}
	coopUnlockStores[ref].image <- image
}

function CreateCoopUnlockData( ref, purchaseFunctionTable, store, unlockCost, name, desc, unlockReqText, unlockReqUnlockedText, customUnlockReqText, reqSvrFlag, image, amountOfTimesPurchasable )
{
	ref = ref.tolower()
	Assert( !( ref in coopUnlockData ), "ref " + ref + " being redefined!" )
		
	Globalize( purchaseFunctionTable.func )

	if ( IsClient() )
		PrecacheHUDMaterial( image )

	coopUnlockData[ref] <- {}
	coopUnlockData[ref].ref <- ref
	coopUnlockData[ref].purchaseFunctionTable <- purchaseFunctionTable
	coopUnlockData[ref].store <- store
	coopUnlockStores[ store ].unlockRefs[ ref ] <- ref
	coopUnlockData[ref].name <- name
	coopUnlockData[ref].desc <- desc
	coopUnlockData[ref].unlockCost <- unlockCost
	coopUnlockData[ref].unlockReqText <- unlockReqText
	coopUnlockData[ref].unlockReqUnlockedText <- unlockReqUnlockedText
	//Used for displaying scripted locked conditions such as "all turrets placed on map".
	coopUnlockData[ref].customUnlockReqText <- customUnlockReqText
	coopUnlockData[ref].reqSvrFlag <- reqSvrFlag
	coopUnlockData[ref].image <- image
	coopUnlockData[ref].amountOfTimesPurchasable <- amountOfTimesPurchasable
}

function Coop_Purchase_Call_In_Turret( player )
{
	//This doesn't remove properly.
	if ( IsServer() )
	{
		thread ShowTurretUpgradeOptions( player )
		thread HACK_KillOptionsAfterSinglePurchase( player )		
	}
}

function Coop_Purchase_Ordnance_Capacity_1( player )
{
	printt( "PURCHASED ORDNANCE CAPACITY 1" )
}

function Coop_Purchase_Ordnance_Capacity_2( player )
{
	printt( "PURCHASED ORDNANCE CAPACITY 2" )
}

function Coop_Purchase_Increased_Titan_Health( player )
{
	printt( "PURCHASED INCREASED TITAN HEALTH" )	
}

function Coop_Purchase_Increased_Titan_Health1( player )
{
	printt( "PURCHASED INCREASED TITAN HEALTH 1" )	
}
function Coop_Purchase_Increased_Titan_Health2( player )
{
	printt( "PURCHASED INCREASED TITAN HEALTH 2" )	
}
function CreateFunctionCallbackTable( func )
{
	local callbackInfo = {}
	callbackInfo.func 	<- func
	callbackInfo.scope 	<- this

	return callbackInfo
}

function GetCoopUnlockStoresTable()
{
	return coopUnlockStores	
}

function GetCoopUnlockDataTable()
{	
	return coopUnlockData	
}

function Coop_TrackUnlockPointTotal( player )
{
	if ( !( player in level.coopUnlockPointTotals ) )
		level.coopUnlockPointTotals[ player ] <- ( level.nv.TDCurrWave - 1 )
	
	//Remote.CallFunction_Replay( player, "ServerCallback_COOP_AdjustUnlockPointTotal", 0 )
	//Remote.CallFunction_UI( player, "ServerCallback_COOP_AdjustUnlockPointTotal", 0 )
}

function Coop_AdjustUnlockPointsToPlayer( player, points )
{
	level.coopUnlockPointTotals[ player ] += points
}

function ServerCallback_COOP_AdjustUnlockPointTotal( points )
{
	coopUnlockPointTotal += points
/*
	if ( IsUI() )
	{
		coopUnlockPointTotal += points
	}
	else
	{
		local player = GetLocalClientPlayer()
		
		if ( !( player in level.coopUnlockPointTotals ) )
			level.coopUnlockPointTotals[ player ] <- ( level.nv.TDCurrWave - 1 )
			
		level.coopUnlockPointTotals[ player ] += points
		printt( player, " new point total = ", level.coopUnlockPointTotals[ player ] )
	}
*/
}

function GetUnlockFromUnlockRef( itemRef )
{
	return coopUnlockData[itemRef]
}

function GetCoopPointTotal_UI()
{
	Assert( IsUI() )
	return coopUnlockPointTotal
}

function CoopStoreOnClientConnected( player )
{
	Coop_TrackUnlockPointTotal( player )
	Remote.CallFunction_UI( player, "ServerCallback_CoopStoreOnClientConnected" )
}

function ServerCallback_CoopStoreOnClientConnected()
{
	Assert( IsUI )
	ServerCallback_COOP_AdjustUnlockPointTotal( 0 )
	ResetCoopPurchaseHistory()
}

function TryToActivateCoopUnlock( player, unlockRef )
{
	local unlock = GetUnlockFromUnlockRef( unlockRef )
	local callbackInfo = unlock.purchaseFunctionTable
	callbackInfo.func.acall( [ callbackInfo.scope, player ] )
	return true
}
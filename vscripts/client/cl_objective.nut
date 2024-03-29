//Split this out into _objective_shared, _objective and cl_objective once QA gets a chance to hammer at it.
function main()
{
	Globalize( RegisterObjective )
	convIndex <- 0 //Note that objectiveIndex 0 is reserved by code to mean no objective active!

	level.indexToObj <- {}
	level.objectives <- {}

	const OBJECTIVE_SCREEN_FADE_IN_TIME = 1.0
	const OBJECTIVE_SCREEN_FADE_OUT_TIME = 0.5
	const OBJECTIVE_SCREEN_TYPE_TIME = 0.2

	Globalize( MainHud_InitObjective )
	Globalize( ClientCodeCallback_ObjectiveChanged )
	Globalize( CreateClientObjectiveTable )
	Globalize( AddObjective )
	Globalize( AddObjectiveWithAutoText )
	Globalize( AddObjectiveWithObjectiveFunction )
	Globalize( AddObjectiveWithAutoTextAndObjectiveFunction )
	Globalize( HasActiveObjective )

	RegisterSignal( "ObjectiveChanged" )
}

function RegisterObjective( objectiveName )
{
	convIndex++
	level.indexToObj[ convIndex ] <- objectiveName
	level.objectives[ objectiveName ] <- null
}

//This gets called, once per frame, if any of ObjectiveEndTime, ObjectiveEntity, or ObjectiveIndex change
function ClientCodeCallback_ObjectiveChanged( player )
{
	if ( !IsValid( player ) )
		return

	if ( IsWatchingKillReplay() ) //Don't get updates for objectives while replay is happening. Not ideal, but script can't tell the difference when this callback happens due to objectives changing in the past while watching a replay versus objectives changing now.
		return

	if ( player != GetLocalClientPlayer() ) //At the end of kill replay sometimes it looks like ClientCodeCallback_ObjectiveChanged( LocalViewPlayer ) is still called on the LocalClientPlayer
		return

	player.Signal( "ObjectiveChanged" )

	//In here: Let ObjectiveTextThink update the text from within the while loop. Objective Hud elements exist in the Pilot/TitanHud as well as the ClientHud.

	local playerClientHudVGUI = player.cv.clientHud.s.mainVGUI

	//First signal the clientmain hud
	Signal( playerClientHudVGUI, "ObjectiveChanged" )

	//then signal the pilot/titanhud vgui
	local cockpit = player.GetCockpit()

	if ( IsValid( cockpit ) )
	{
		local cockpitVGUI = cockpit.GetMainVGUI()

		if ( IsValid( cockpitVGUI ) )
			Signal( cockpitVGUI, "ObjectiveChanged" )

	}

	RunObjectiveFunc( player ) //Only run this function once when the objective changes, as opposed to letting ObjectiveTextThink handle it (which would result in the objective function getting run multiple times )
}

function CreateClientObjectiveTable( objectiveTitleText, objectiveDescriptiveText, objectiveIsAutoText = false, objectiveFunc = null )
{
	local table = {}
	table.objectiveTitleText <- objectiveTitleText
	table.objectiveDescriptiveText <- objectiveDescriptiveText
	table.objectiveIsAutoText <- objectiveIsAutoText

	if ( objectiveFunc )
		table.objectiveFunc <- objectiveFunc
	else
		table.objectiveFunc <- null

	return table
}

function AddObjective( objectiveName, objectiveTitleText, objectiveDescriptiveText )
{
	AddObjective_Internal( objectiveName, objectiveTitleText, objectiveDescriptiveText )
}

function AddObjectiveWithAutoText( objectiveName, objectiveTitleText, objectiveDescriptiveText )
{
	AddObjective_Internal( objectiveName, objectiveTitleText, objectiveDescriptiveText, true )
}

function AddObjectiveWithObjectiveFunction( objectiveName, objectiveTitleText, objectiveDescriptiveText, objectiveFunction )
{
	AddObjective_Internal( objectiveName, objectiveTitleText, objectiveDescriptiveText, false, objectiveFunction )
}

function AddObjectiveWithAutoTextAndObjectiveFunction( objectiveName, objectiveTitleText, objectiveDescriptiveText, objectiveFunction )
{
	AddObjective_Internal( objectiveName, objectiveTitleText, objectiveDescriptiveText, true, objectiveFunction )
}

function AddObjective_Internal( objectiveName, objectiveTitleText, objectiveDescriptiveText, isAutoText = false,  objectiveFunction = null )
{
	Assert( objectiveName in level.objectives, "Objective " + objectiveName + " does not exist! Check to see if it was registered before" )
	Assert( level.objectives[ objectiveName ] == null, " Objective " + objectiveName + " already has an objectiveTable associated with it" )

	local objectiveTable = CreateClientObjectiveTable( objectiveTitleText, objectiveDescriptiveText, isAutoText, objectiveFunction )

	level.objectives[ objectiveName ] = objectiveTable
}

function ObjectiveTextThink( vgui )
{
	//printt("ObjectiveTexThink with vgui: " + vgui + " and player: "  )
	vgui.EndSignal( "OnDestroy" )


	while ( true )
	{
		WaitSignal( vgui, "ObjectiveChanged" )
		UpdateObjectiveText( vgui, GetLocalClientPlayer() ) //Get Local Client Player again since player might have been destroyed due to replays
	}

}

function UpdateObjectiveText( vgui, player )
{
	local objectiveIndex = player.GetObjectiveIndex()

	if ( objectiveIndex == 0 ) //ObjIndex 0 means no objective
	{
		//printt( "Returning from UpdateObjectiveText because null objIndex" )
		DeactivateObjectiveHud( vgui, player )
		//ShowGameProgressScoreboard_ForPlayer( player )
		return
	}

	local objectiveTimer = player.GetObjectiveEndTime()

	//HideGameProgressScoreboard_ForPlayer( player )
	ActivateObjectiveHud( vgui, objectiveIndex, objectiveTimer )
}

function DeactivateObjectiveHud( vgui, player )
{
	vgui.s.objectiveElem.HideOverTime( OBJECTIVE_SCREEN_FADE_OUT_TIME )
}

function ActivateObjectiveHud( vgui, objectiveIndex, objectiveTimer )
{
	local objectiveElem = vgui.s.objectiveElem
	local objectiveDesc = vgui.s.objectiveDesc
	local objectiveTitle = vgui.s.objectiveTitle

	objectiveElem.SetAlpha( 0 )
	objectiveElem.FadeOverTime( 255, OBJECTIVE_SCREEN_FADE_IN_TIME )
	objectiveElem.Show()

	local objectiveName = level.indexToObj[ objectiveIndex ]
	local objectiveTable = level.objectives[ objectiveName ]
	local objectiveTitleText = objectiveTable.objectiveTitleText
	local objectiveDescriptiveText = objectiveTable.objectiveDescriptiveText
	local objectiveIsAutoText = objectiveTable.objectiveIsAutoText

	//printt( "ActivateObjectiveHud, objectiveName: " + objectiveName + ", objectiveTitleText: "  +  objectiveTitleText + ", objectiveDescriptiveText: " + objectiveDescriptiveText + ", obTimer: " + objectiveTimer )

	objectiveTitle.SetTextTypeWriter( objectiveTitleText, OBJECTIVE_SCREEN_TYPE_TIME )

	if ( !objectiveIsAutoText || objectiveTimer == 0 )
	{
		objectiveDesc.SetAutoText( "", HATT_NONE, 0.0 ) //Need to do this to clear previous auto text objectives. DisableAutoText doesn't work unless it was previously enabled.
		objectiveDesc.SetTextTypeWriter( objectiveDescriptiveText, OBJECTIVE_SCREEN_TYPE_TIME )
	}
	else
	{
		//Assume that if you have a timer the auto text is linked to the timer.Not a bad assumption for now
		//printt( "ActivateObjectiveHud, Has a timer and is autotext" )
		local time = objectiveTimer - 1.0 //HACK not sure why i have to do this now...the code hud seems to be "off"
		local hattID = GetHattID( objectiveDescriptiveText )
		objectiveDesc.SetAutoText( objectiveDescriptiveText, hattID, time )
	}
}


function GetHattID( string )
{
	local result = getconsttable()[ string ]
	//printt( "This is hattID: " + result  )
	return getconsttable()[ string ]
}


function RunObjectiveFunc( player )
{
	local objectiveIndex = player.GetObjectiveIndex()

	if ( objectiveIndex == 0  ) //ObjIndex 0 means no objective
		return

	local objectiveName = level.indexToObj[ objectiveIndex ]
	local objectiveTable = level.objectives[ objectiveName ]

	local objectiveEntity = player.GetObjectiveEntity()
	local objectiveFunction = objectiveTable.objectiveFunc

	if ( objectiveFunction != null && IsValid( objectiveEntity ) )
	{
		thread objectiveFunction( objectiveEntity )
	}
}


function MainHud_InitObjective( vgui, player )
{
	local panel = vgui.GetPanel()

	local objectiveElem = HudElementGroup( "ObjectiveHudElement" )
	objectiveElem.CreateElement( "ObjectiveBarShapeLeft", panel )
	objectiveElem.CreateElement( "ObjectiveBarBGShapeLeft", panel )
	objectiveElem.CreateElement( "ObjectiveBarShapeRight", panel )
	objectiveElem.CreateElement( "ObjectiveBarBGShapeRight", panel )

	local objectiveTitle = HudElement( "ObjectiveTitle", panel )
	local objectiveDesc = HudElement( "ObjectiveDesc", panel )

	objectiveElem.AddElement( objectiveTitle )
	objectiveElem.AddElement( objectiveDesc )

	vgui.s.objectiveElem <- objectiveElem
	vgui.s.objectiveTitle <- objectiveTitle
	vgui.s.objectiveDesc <- objectiveDesc

	if ( player != GetLocalClientPlayer() )
		return

	UpdateObjectiveText( vgui, player )

	thread ObjectiveTextThink( vgui )
}


function HasActiveObjective( player )
{
	return player.GetObjectiveIndex()
}
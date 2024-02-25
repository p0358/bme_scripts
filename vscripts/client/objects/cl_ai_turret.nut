
const RED_GLOW = "runway_light_red"
const BLUE_GLOW = "runway_light_blue"

function main()
{
	PrecacheParticleSystem( RED_GLOW )
	PrecacheParticleSystem( BLUE_GLOW )

	Globalize( TurretPanelChanged )
	Globalize( ServerCallback_TurretRefresh )

	AddCreateCallback( "npc_turret_mega", CreateCallback_HeavyTurret )
	AddCreateCallback( "npc_turret_sentry", CreateCallback_LightTurret )

	AddDestroyCallback( "npc_turret_mega", DestroyCallback_PanelTarget )
	AddDestroyCallback( "npc_turret_sentry", DestroyCallback_PanelTarget )
}

function CreateCallback_HeavyTurret( turret, isRecreate )
{
	turret.s.heavy <- true
	turret.s.turretFriendly <- null
	turret.s.particleEffects <- []
	UpdateParticleSystem( turret )
	thread TurretPanelChanged( turret )
}

function CreateCallback_LightTurret( turret, isRecreate )
{
	turret.s.heavy <- false
	turret.s.turretFriendly <- null
	turret.s.particleEffects <- []
	UpdateParticleSystem( turret )
	thread TurretPanelChanged( turret )
}

function TurretPanelChanged( turret )
{
	local panel = turret.GetControlPanel()
	if ( panel == null )
		return

	turret.EndSignal( "OnDestroy" )

	while( !IsValid( panel ) || !( "initiated" in panel.s ) ) //Need to wait till panel has finished initializeing
	{
		panel = turret.GetControlPanel()  //Don't think is actually necessary, but better safe than sorry...
		wait 0
	}

	if ( turret.s.heavy )
	{
		panel.s.resfile = "control_panel_heavy_turret"
		panel.s.VGUIFunc = Bind( VGUIUpdateHeavyTurret )
		panel.s.VGUISetupFunc = Bind( VGUISetupHeavyTurret )
	}
	else
	{
		panel.s.resfile = "control_panel_generic_screen"
		panel.s.VGUIFunc = Bind( VGUIUpdateLightTurret )
		panel.s.VGUISetupFunc = VGUISetupGeneric
	}

	//printt( "RegisterWithPanel called from TurretPanelChanged" )
	thread RegisterWithPanel( turret )
}

function VGUISetupHeavyTurret( panel )
{
//	panel.s.HudVGUI.s.stateElem <- HudElement( "State", panel.s.HudVGUI.s.panel )
//	panel.s.HudVGUI.s.healthElem <- HudElement( "Health", panel.s.HudVGUI.s.panel )
	panel.s.HudVGUI.s.bgElem <- HudElement( "Background", panel.s.HudVGUI.s.panel )
}

function VGUIUpdateHeavyTurret( panel )
{
	Assert( panel.s.targetArray.len() == 1, "Can only handle one Heavy Turret per control panel! " +  panel.s.targetArray.len() )

	local bgElem = panel.s.HudVGUI.s.bgElem
//	local stateElem = HudElement( "State", panel.s.HudVGUI.s.panel )
//	local healthElem = HudElement( "Health", panel.s.HudVGUI.s.panel )
	local turret = panel.s.targetArray[0]
	local stateIndex = turret.GetTurretState()

	local player = GetLocalViewPlayer()

	local imgName = format( level.TurretBackground[ stateIndex ], "e" )
	if ( player.GetTeam() == panel.GetTeam() )
		imgName = format( level.TurretBackground[ stateIndex ], "f" )
	local bgImage = format( "HUD/control_panel/%s/%s", imgName, imgName )

	bgElem.SetImage( bgImage )

//	stateElem.SetText( level.turretStateStr[ stateIndex ] )

	switch( stateIndex )
	{
		case TURRET_DEAD:
			if ( !( "deathTime" in turret.s ) )
				turret.s.deathTime <- Time()
			local elapsedTime = Time() - turret.s.deathTime
			local percentage = ceil( GraphCapped( ( elapsedTime / MEGA_TURRET_REPAIR_TIME ), 0, 1, 0, 100 ) )
//			healthElem.SetText( format( HEAVY_TURRET_REPAIR_STR, percentage ) )
			break

		case TURRET_RETIRING:
//			healthElem.SetText( HEAVY_TURRET_REBOOT_STR )
			break

		default:
			local maxHealth = turret.GetMaxHealth().tofloat()
			local health = turret.GetHealth().tofloat()
			local percentage = ceil( health / maxHealth * 100 )
//			healthElem.SetText( format( HEAVY_TURRET_HEALTH_STR, percentage ) )
			break
	}
}

function VGUIUpdateLightTurret( panel )
{
	local stateElement = panel.s.HudVGUI.s.state
	local controlledItem = panel.s.HudVGUI.s.controlledItem

	if ( panel.s.targetArray.len() > 1 )
		controlledItem.SetText( "#NPC_TURRETS_LIGHT" )
	else
		controlledItem.SetText( "#NPC_TURRET_LIGHT" )

	local turretsActive = false
	foreach( turret in panel.s.targetArray )
	{
		turretsActive = IsTurretActive( turret )
		if ( turretsActive )
			break
	}

	if ( turretsActive )
		stateElement.SetText( "#CONTROL_PANEL_ACTIVE" )
	else
		stateElement.SetText( "#CONTROL_PANEL_READY" )

	// alternate on and off
	local show = ( ( Time() * 4 ).tointeger() % 2 )
	if ( show )
		stateElement.Show()
	else
		stateElement.Hide()
}

function IsTurretActive( turret )
{
	local turretsActive = turret.GetTurretState() == TURRET_DEPLOYING
	turretsActive = turretsActive || turret.GetTurretState() == TURRET_SEARCHING
	turretsActive = turretsActive || turret.GetTurretState() == TURRET_ACTIVE
	return turretsActive
}

function ServerCallback_TurretRefresh( turretEHandle )
{
	local turret = GetEntityFromEncodedEHandle( turretEHandle )
	if ( !IsValid( turret ) )
		return

	UpdateParticleSystem( turret )
}

//////////////////////////////////////////////////////////////////////
function UpdateParticleSystem( turret )
{
	local turretFriendly = false
	local player = GetLocalViewPlayer()

	if ( turret.GetTeam() == TEAM_UNASSIGNED || !IsAlive( turret ) )
	{
		StopTurretParticleEffects( turret )
		return
	}

	if ( turret.GetTeam() == player.GetTeam() )
		turretFriendly = true

	if ( turretFriendly == turret.s.turretFriendly )
		return

	turret.s.turretFriendly = turretFriendly
	StopTurretParticleEffects( turret )

	local fxID
	if ( turretFriendly )
		fxID = GetParticleSystemIndex( BLUE_GLOW )
	else
		fxID = GetParticleSystemIndex( RED_GLOW )

	if ( turret.s.heavy )
	{
		local tag1ID = turret.LookupAttachment( "glow1" )
		local tag2ID = turret.LookupAttachment( "glow2" )

		if ( tag1ID )
			turret.s.particleEffects.append( PlayFXOnTag( turret, fxID, tag1ID ) )

		if ( tag2ID )
			turret.s.particleEffects.append( PlayFXOnTag( turret, fxID, tag2ID ) )
	}
	else
	{
		local tag1ID = turret.LookupAttachment( "camera_glow" )

		if ( tag1ID )
			turret.s.particleEffects.append( PlayFXOnTag( turret, fxID, tag1ID ) )
	}
}

function StopTurretParticleEffects( turret )
{
	foreach( particle in turret.s.particleEffects )
	{
		if ( EffectDoesExist( particle ) )
			EffectStop( particle, true, false )
	}
	turret.s.particleEffects.clear()
}
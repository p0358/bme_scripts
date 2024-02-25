// ========= Pilot Launcher (LAW/SRAM) screen =========
vgui_pilot_launcher.res
{
	VGUI_PilotLauncher_TargetName
	{
		ControlName			Label
		xpos				0
		ypos				45
		wide				250
		tall				22
		visible				0
		enable				1
		labelText			"[Target Name]"
		font				TechScreenTiny
		textAlignment		west
		zpos				9
	}

	VGUI_PilotLauncher_Range
	{
		ControlName			Label
		xpos				2
		ypos				71
		wide				250
		tall				22
		visible				0
		enable				1
		labelText			"0000m"
		font				TechScreenTiny
		textAlignment		west
		zpos				9
	}

	VGUI_PilotLauncher_LockStatus
	{
		ControlName			Label
		xpos				110
		ypos				400
		wide				400
		tall				40
		visible				0
		enable				1
		labelText			"[LOCK STATUS]"
		font				TechScreenSmall
		textAlignment		center
		zpos				9
	}

	VGUI_PilotLauncher_Ammo_Label
	{
		ControlName			Label
		xpos				0
		ypos				411
		wide				140
		tall				25
		visible				0
		enable				1
		labelText			"[AMMO]"
		font				TechScreenSmall
		textAlignment		center
		zpos				9
	}

	VGUI_PilotLauncher_AmmoIcon0
	{
		ControlName			ImagePanel
		xpos				120
		ypos				383
		wide				32
		tall				64
		visible				1
		image				HUD/sram/sram_rocket_icon
		scaleImage			1
		zpos				9
	}

	VGUI_PilotLauncher_AmmoIcon1
	{
		ControlName			ImagePanel
		xpos				96
		ypos				383
		wide				32
		tall				64
		visible				1
		image				HUD/sram/sram_rocket_icon
		scaleImage			1
		zpos				9
	}

	VGUI_PilotLauncher_AmmoIcon2
	{
		ControlName			ImagePanel
		xpos				72
		ypos				383
		wide				32
		tall				64
		visible				1
		image				HUD/sram/sram_rocket_icon
		scaleImage			1
		zpos				9
	}

	VGUI_PilotLauncher_AmmoIcon3
	{
		ControlName			ImagePanel
		xpos				48
		ypos				383
		wide				32
		tall				64
		visible				1
		image				HUD/sram/sram_rocket_icon
		scaleImage			1
		zpos				9
	}

	VGUI_PilotLauncher_AmmoIcon4
	{
		ControlName			ImagePanel
		xpos				24
		ypos				383
		wide				32
		tall				64
		visible				1
		image				HUD/sram/sram_rocket_icon
		scaleImage			1
		zpos				9
	}

	VGUI_PilotLauncher_AmmoIcon5
	{
		ControlName			ImagePanel
		xpos				0
		ypos				383
		wide				32
		tall				64
		visible				1
		image				HUD/sram/sram_rocket_icon
		scaleImage			1
		zpos				9
	}

	VGUI_PilotLauncher_Ticker
	{
		ControlName			ImagePanel
		xpos				20
		ypos				0
		wide				400
		tall				50
		visible				1
		image				HUD/sram/sram_ticker
		scaleImage			4
		zpos				10
	}

	VGUI_PilotLauncher_Ticker_Extra
	{
		ControlName			ImagePanel
		xpos				420
		ypos				0
		wide				400
		tall				50
		visible				1
		image				HUD/sram/sram_ticker
		scaleImage			4
		zpos				10
	}

	VGUI_PilotLauncher_TargetingCircle
	{
		ControlName			ImagePanel
		xpos				310
		ypos				215
		wide				40
		tall				35
		visible				0
		image				HUD/sram/sram_targeting_circle
		scaleImage			1.0
		zpos				10
	}

	VGUI_PilotLauncher_TargetingRing_Inner
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				150
		tall				150
		visible				0
		image				HUD/sram/sram_targeting_inner_ring
		scaleImage			1.0
		zpos				11
	}

	VGUI_PilotLauncher_TargetingRing_Outer
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				150
		tall				150
		visible				0
		image				HUD/sram/sram_targeting_outer_ring
		scaleImage			1.0
		zpos				11
	}

}
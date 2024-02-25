coop_turret_world_icon.res
{
	CoopPlayerTurretAnchor
	{
		ControlName					Label
		xpos						0
		ypos						0
		wide						%100
		tall						%100
		visible						0
		proportionalToParent		1
	}
	CoopPlayerTurretName
	{
		ControlName					Label
		xpos						12
		ypos						-8
		wide						256
		tall						10
		visible						0
		font						HudFontTiny
		labelText					""
		textAlignment				center
		fgcolor_override 			"255 255 255 255"
		auto_wide_tocontents 		1

		pin_to_sibling				CoopPlayerTurretAnchor
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}
	CoopPlayerTurretCount
	{
		ControlName					Label
		wide						128
		tall						10
		visible						0
		font						HudFontTiny
		labelText					""
		textAlignment				west
		fgcolor_override 			"255 255 255 255"

		pin_to_sibling				CoopPlayerTurretName
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}
	CoopPlayerTurretIcon
	{
		ControlName					ImagePanel
		wide						16
		tall						16
		visible						0
		image						HUD/coop/minimap_coop_turret
		scaleImage					1
		drawColor					"255 255 255 255"

		pin_to_sibling				CoopPlayerTurretName
		pin_corner_to_sibling		5
		pin_to_sibling_corner		7
	}
	CoopPlayerTurretHealth
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				0
		wide				64
		tall				6
		visible				0
		bg_image			HUD/coop/turrethealth_bar_bg
		fg_image			HUD/coop/turrethealth_bar
		change_image		HUD/coop/turrethealth_bar_change
		fgcolor_override	"255 255 255 255"
		bgcolor_override	"255 255 255 255"
		SegmentSize			64
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2
		ChangeStyle			1
		ChangeTime			0.25
		ChangeDir			0

		pin_to_sibling				CoopPlayerTurretName
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}
}
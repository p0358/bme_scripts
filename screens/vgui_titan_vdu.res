// 512x512
vgui_titan_vdu.res
{
	Screen
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				512
		tall				512
		visible				0
		//image				HUD/white
		image				HUD/screen_grid_overlay
		scaleImage			1
		drawColor			"0 0 0 0"

		zpos				1
	}

	VDU_CockpitScreen
	{
		ControlName		ImagePanel
		image			HUD/vdu_hud_monitor

		xpos				0
		ypos				0
		wide				0 // 512
		tall				0 // 512
		visible				1
		scaleImage			1
		zpos				8

		pin_to_sibling				Screen
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	VDU_CockpitScreen_widescreen
	{
		ControlName		ImagePanel
		image			HUD/vdu_hud_monitor_widescreen

		xpos				0
		ypos				0
		wide				0 // 512
		tall				0 // 512
		visible				0
		scaleImage			1
		zpos				8

		pin_to_sibling				Screen
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	VDU_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				0
		tall				0
		visible				0
		image				HUD/minimap_bg
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				4

		pin_to_sibling				VDU_CockpitScreen
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	VDU_FG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				0
		tall				0
		visible				0
		image				HUD/vdu_shape
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				16

		pin_to_sibling				VDU_CockpitScreen
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	VDU_FG_widescreen
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				0
		tall				0
		visible				0
		image				HUD/vdu_shape_widescreen
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				16

		pin_to_sibling				VDU_CockpitScreen
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}
}

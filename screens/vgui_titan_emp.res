vgui_titan_emp.res
{
	Screen
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				852
		tall				480
		visible				1
		image				HUD/white
		scaleImage			1
		drawColor			"0 0 0 0"

		zpos				1
	}

	EMPScreenFX
	{
		ControlName		ImagePanel
		wide			%100
		tall			%100
		visible			1
		scaleImage		1
		image			HUD/titan_flashbang_overlay
		drawColor		"255 255 255 255"

		zpos			9999
	}

	EMPScreenFlash
	{
		ControlName		ImagePanel
		wide			%100
		tall			%100
		visible			0
		scaleImage		1
		image			HUD/white
		drawColor		"32 32 32 255"

		zpos			-1000
	}
}

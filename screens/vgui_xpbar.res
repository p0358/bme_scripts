//"pixelswide"	430
//"pixelshigh"	90

vgui_xpbar.res
{	
	XPBarAnchor
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				430
		tall				90
		visible				1
		scaleImage			1
		image				HUD/white
		fillColor			"0 0 0 0"		
		drawColor			"255 0 255 0"
	}

	xpBarBG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				368
		tall				8
		visible				0
		image				HUD/white
		scaleImage			1
		drawColor			"0 0 0 127"
		
		pin_to_sibling				XPBarAnchor
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4		
	}

	xpBarFG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				368
		tall				8
		visible				0
		image				HUD/white
		scaleImage			1
		drawColor			"255 255 255 100"

		pin_to_sibling				xpBarBG
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0		
	}
}

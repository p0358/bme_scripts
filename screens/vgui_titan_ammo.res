// 142x142
vgui_titan_ammo.res
{
	Background
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				142
		tall				142
		visible				1
		image				HUD/info_rounded_shape_bg
		scaleImage			1
		drawColor			"0 0 0 128"
		
		zpos				0
	}

	Foreground
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				142
		tall				142
		visible				1
		image				HUD/info_rounded_shape
		scaleImage			1
		drawColor			"255 255 255 64"
		
		zpos				299
	}

	Overlay
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				142
		tall				142
		visible				0
		image				HUD/info_rounded_shape_bg
		scaleImage			1
		drawColor			"255 255 255 16" // "255 255 255 16"
		
		zpos				300
	}

	DamageLayer
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				142
		tall				142
		visible				0
		image				HUD/info_rounded_shape
		scaleImage			1
		drawColor			"255 0 0 255"
		
		zpos				10
	}
	
	WeaponName
	{
		ControlName			Label
		xpos				-8
		ypos				-20
		wide				136
		tall				20
		visible				1
		font				CapturePointStatusHUD
		labelText			"[WEAPON NAME]"
		textAlignment		east
		
		zpos				200

		pin_to_sibling				Background
		pin_corner_to_sibling		6
		pin_to_sibling_corner		6
	}

	AmmoCount
	{
		ControlName			Label
		xpos				-8
		ypos				-60
		wide				136
		tall				20
		visible				1
		font				CapturePointStatusHUD
		labelText			"[AMMO COUNT]"
		textAlignment		east
		
		zpos				200

		pin_to_sibling				Background
		pin_corner_to_sibling		6
		pin_to_sibling_corner		6
	}

	AmmoTotal
	{
		ControlName			Label
		xpos				-8
		ypos				-4
		wide				136
		tall				20
		visible				1
		font				CapturePointStatusHUD
		labelText			"[AMMO TOTAL]"
		textAlignment		east
		
		zpos				200

		pin_to_sibling				Background
		pin_corner_to_sibling		6
		pin_to_sibling_corner		6
	}
		
	AmmoBarBackground
	{
		ControlName			Label
		xpos				0
		ypos				-50
		wide				126
		tall				16
		visible				1
		font				CapturePointStatusHUD
		labelText			""
		textAlignment		center
		bgcolor_override	"0 0 0 160"
		
		zpos				199

		pin_to_sibling				Background
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}
	
	AmmoBar
	{
		ControlName			ImagePanel
		xpos				-2
		ypos				0
		wide				122
		tall				12
		visible				1
		image				HUD/white
		scaleImage			1

		drawColor			"160 160 160 128"
		
		zpos				201
		
		pin_to_sibling				AmmoBarBackground
		pin_corner_to_sibling		7
		pin_to_sibling_corner		7
	}

	SuperIconB
	{
		ControlName			ImagePanel
		xpos				-8
		ypos				-8
		wide				32
		tall				32
		visible				1
		image				HUD/white
		scaleImage			1

		drawColor			"255 255 255 160"
		
		zpos				201
		
		pin_to_sibling				Background
		pin_corner_to_sibling		1
		pin_to_sibling_corner		1
	}

	SuperBarBG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				-14
		wide				60
		tall				24
		visible				1
		image				HUD/hud_wedge
		scaleImage			1

		drawColor			"0 0 0 32"
		
		zpos				200
		
		pin_to_sibling				Background
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}

	SuperBarFill
	{
		ControlName			ImagePanel
		xpos				0
		ypos				-14
		wide				60
		tall				24
		visible				1
		image				HUD/hud_wedge_fill
		scaleImage			1

		drawColor			"255 255 255 160"
		
		zpos				201
		
		pin_to_sibling				Background
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}
		
	SuperIconA
	{
		ControlName			ImagePanel
		xpos				-8
		ypos				-8
		wide				32
		tall				32
		visible				1
		image				HUD/white
		scaleImage			1

		drawColor			"255 255 255 160"
		
		zpos				201
		
		pin_to_sibling				Background
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}
}

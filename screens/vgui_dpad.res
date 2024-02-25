//430x190
vgui_dpad.res
{
	Screen
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				400
		tall				400
		visible				1
		scaleImage			1
//		fillColor			"100 0 0 100"
//		drawColor			"100 0 0 100"

		zpos				0
	}

	dpadIcon
	{
		ControlName			ImagePanel
		xpos				0
		ypos				45
		wide				64
		tall				64
		visible				1
		image				HUD/dpad_icon
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Screen
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	dpadRightIconBG
	{
		ControlName			ImagePanel
		xpos				15
		ypos				0
		wide				64
		tall				64
		visible				0
		image				HUD/hud_icons_bg
		scaleImage			0
		drawColor			"255 255 255 0"

		pin_to_sibling				dpadIcon
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5

		zpos				240
	}

	dpadRightIcon
	{
		ControlName			ImagePanel
		xpos				15
		ypos				0
		wide				64
		tall				64
		visible				0
		image				HUD/empty
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				dpadIcon
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5

		zpos				250
	}

	dpadRightTitle
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				128
		tall				64
		visible				0
		font				HudFontExtraLarge
		labelText			"[RIGHT TITLE]"
		textAlignment		north

		fgcolor_override 	"255 255 255 255"

		zpos				260

		pin_to_sibling				dpadRightIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	dpadRightDesc
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				128
		tall				64
		visible				0
		font				HudFontMed
		labelText			"[RIGHT DESC]"
		textAlignment		south

		fgcolor_override 	"255 255 255 255"

		zpos				260

		pin_to_sibling				dpadRightIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}


	dpadLeftIconBG
	{
		ControlName			ImagePanel
		xpos				15
		ypos				0
		wide				64
		tall				64
		visible				0
		image				HUD/hud_icons_bg
		scaleImage			1
		drawColor			"255 255 255 0"

		pin_to_sibling				dpadIcon
		pin_corner_to_sibling		5
		pin_to_sibling_corner		7

		zpos				240
	}

	dpadLeftIcon
	{
		ControlName			ImagePanel
		xpos				15
		ypos				0
		wide				64
		tall				64
		visible				0
		image				HUD/empty
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				dpadIcon
		pin_corner_to_sibling		5
		pin_to_sibling_corner		7

		zpos				250
	}

	dpadLeftTitle
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				128
		tall				64
		visible				0
		font				HudFontExtraLarge
		labelText			"[LEFT TITLE]"
		textAlignment		north

		fgcolor_override 	"255 255 255 255"

		zpos				260

		pin_to_sibling				dpadLeftIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	dpadLeftDesc
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				128
		tall				64
		visible				0
		font				HudFontMed
		labelText			"[LEFT DESC]"
		textAlignment		south

		fgcolor_override 	"255 255 255 255"

		zpos				260

		pin_to_sibling				dpadLeftIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}


	dpadUpIconBG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				15
		wide				64
		tall				64
		visible				0
		image				HUD/hud_icons_bg // HUD/wad/wad_icon_electric_smoke //
		scaleImage			1
		drawColor			"255 255 255 0"

		pin_to_sibling				dpadIcon
		pin_corner_to_sibling		6
		pin_to_sibling_corner		4

		zpos				240
	}

	dpadUpIcon
	{
		ControlName			ImagePanel
		xpos				0
		ypos				15
		wide				64
		tall				64
		visible				0
		image				HUD/empty // HUD/wad/wad_icon_electric_smoke //
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				dpadIcon
		pin_corner_to_sibling		6
		pin_to_sibling_corner		4

		zpos				250
	}

	dpadUpTitle
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				128
		tall				64
		visible				0
		font				HudFontExtraLarge
		labelText			"[UP TITLE]"
		textAlignment		north

		fgcolor_override 	"255 255 255 255"

		zpos				260

		pin_to_sibling				dpadUpIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	dpadUpDesc
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				128
		tall				64
		visible				0
		font				HudFontMed
		labelText			"[UP DESC]"
		textAlignment		south

		fgcolor_override 	"255 255 255 255"

		zpos				260

		pin_to_sibling				dpadUpIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}


	dpadDownIconBG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				15
		wide				64
		tall				64
		visible				0
		image				HUD/hud_icons_bg
		scaleImage			1
		drawColor			"255 255 255 0"

		pin_to_sibling				dpadIcon
		pin_corner_to_sibling		4
		pin_to_sibling_corner		6

		zpos				240
	}

	dpadDownIcon
	{
		ControlName			ImagePanel
		xpos				0
		ypos				15
		wide				64
		tall				64
		visible				0
		image				HUD/empty
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				dpadIcon
		pin_corner_to_sibling		4
		pin_to_sibling_corner		6

		zpos				250
	}

	dpadDownTitle
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				128
		tall				64
		visible				0
		font				HudFontExtraLarge
		labelText			"[DOWN Title]"
		textAlignment		north

		fgcolor_override 	"255 255 255 255"

		zpos				260

		pin_to_sibling				dpadDownIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	dpadDownDesc
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				128
		tall				64
		visible				0
		font				HudFontMed
		labelText			"[DOWN DESC]"
		textAlignment		south

		fgcolor_override 	"255 255 255 255"

		zpos				260

		pin_to_sibling				dpadDownIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}


	titanModeText
	{
		ControlName			Label
		xpos				0
		ypos				-18
		wide				220
		tall				18
		visible				0
		font				HudFontExtraLarge
		labelText			"Titan Follow"
		textAlignment		west
		allCaps				1

		pin_to_sibling				dpadDownIcon
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	titanModeSubText
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				220
		tall				14
		visible				0
		font				HudFontMed
		labelText			"100%"
		textAlignment		west
		allCaps				1

		pin_to_sibling				titanModeText
		pin_corner_to_sibling		4
		pin_to_sibling_corner		6
	}

}

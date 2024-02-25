vgui_jump_quest.res
{	
	Background
	{
		ControlName			ImagePanel
		xpos				5
		ypos				5
		wide				290
		tall				150
		visible				1
		image				HUD/white
		scaleImage			1
		drawColor 			"0 0 0 200"

		zpos				5
	}

	TopTrim
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				299
		tall				5
		visible				1
		image				HUD/white
		scaleImage			1
		drawColor 			"220 220 200 100"

		zpos				5
	}

	BottomTrim
	{
		ControlName			ImagePanel
		xpos				0
		ypos				155
		wide				299
		tall				5
		visible				1
		image				HUD/white
		scaleImage			1
		drawColor 			"220 220 200 100"

		zpos				5
	}

	LeftTrim
	{
		ControlName			ImagePanel
		xpos				0
		ypos				5
		wide				5
		tall				150
		visible				1
		image				HUD/white
		scaleImage			1
		drawColor 			"220 220 200 100"

		zpos				5
	}

	RightTrim
	{
		ControlName			ImagePanel
		xpos				295
		ypos				5
		wide				5
		tall				150
		visible				1
		image				HUD/white
		scaleImage			1
		drawColor 			"220 220 200 100"

		zpos				5
	}

	Star1
	{
		ControlName			ImagePanel
		xpos				25
		ypos				70
		wide				70
		tall				70
		visible				0
		image				HUD/loadout/xbutton
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				10
	}

	Star2
	{
		ControlName			ImagePanel
		xpos				115
		ypos				70
		wide				70
		tall				70
		visible				0
		image				HUD/loadout/xbutton
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				10
	}

	Star3
	{
		ControlName			ImagePanel
		xpos				205
		ypos				70
		wide				70
		tall				70
		visible				0
		image				HUD/loadout/xbutton
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				10
	}

	BestScore
	{
		ControlName			Label
		xpos				190
		ypos				10
		wide				300
		tall				50
		visible				0
		font				HudNumbersSmall
		labelText			""
		textAlignment		west
		drawColor			"255 255 255 255"

		zpos				10
	}

	TrackTitle
	{
		ControlName			Label
		xpos				20
		ypos				10
		wide				300
		tall				50
		visible				0
		font				HudNumbersSmall
		labelText			"Track 3"
		textAlignment		west
		drawColor			"255 255 255 255"

		zpos				10
	}



	JQ_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				180
		tall				120
		visible				0
		image				HUD/minimap_bg
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				4

	}

	JQ_FG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				180
		tall				120
		visible				0
		image				HUD/vdu_shape
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				16
	}



	Points
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				300
		tall				50
		visible				0
		font				HudNumbersSmall
		labelText			"0"
		textAlignment		center
		drawColor			"155 255 255 255"
		alpha				"255"
		pin_to_sibling				JQ_BG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8

		zpos				50
	}
	Points2 // so it'll show up damnit
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				300
		tall				50
		visible				0
		font				HudNumbersSmall
		labelText			"0"
		textAlignment		center
		drawColor			"155 255 255 255"
		pin_to_sibling				JQ_BG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8

		zpos				50
	}

	Mult1
	{
		ControlName			Label
		xpos				-40
		ypos				-20
		wide				300
		tall				50
		visible				0
		font				HudNumbersSmall
		labelText			"X2"
		textAlignment		center
		drawColor			"155 255 255 255"
		pin_to_sibling				JQ_BG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8

		zpos				10
	}

	Mult2
	{
		ControlName			Label
		xpos				40
		ypos				-20
		wide				300
		tall				50
		visible				0
		font				HudNumbersSmall
		labelText			"X2"
		textAlignment		center
		drawColor			"155 255 255 255"
		pin_to_sibling				JQ_BG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8

		zpos				10
	}

	Mult3
	{
		ControlName			Label
		xpos				40
		ypos				20
		wide				300
		tall				50
		visible				0
		font				HudNumbersSmall
		labelText			"X2"
		textAlignment		center
		drawColor			"155 255 255 255"
		pin_to_sibling				JQ_BG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8

		zpos				10
	}

	Mult4
	{
		ControlName			Label
		xpos				-40
		ypos				20
		wide				300
		tall				50
		visible				0
		font				HudNumbersSmall
		labelText			"X2"
		textAlignment		center
		drawColor			"155 255 255 255"
		pin_to_sibling				JQ_BG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8

		zpos				10
	}

}

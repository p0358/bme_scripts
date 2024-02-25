vgui_enemy_tracker.res
{	
	Background
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				200
		tall				250
		visible				0
		image				HUD/white
		scaleImage			1
		drawColor			"0 0 0 255"

		zpos				4

	}

//	Background_viewer
//	{
//		ControlName			ImagePanel
//		xpos				0
//		ypos				0
//		wide				500
//		tall				500
//		visible				1
//		image				HUD/white
//		scaleImage			1
//		drawColor			"0 255 0 55"
//
//		zpos				4
//
//	}


	EnemyIcon
	{
		ControlName			ImagePanel
		xpos				0
		ypos				-13
		wide				100
		tall				100
		visible				1
		image				"../ui/icon_enemy_titan_count"
		scaleImage			1
		drawColor			"255 55 0 255"

		zpos				10

		pin_to_sibling				Background
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	EnemyIconShield
	{
		ControlName			ImagePanel
		xpos				0
		ypos				-13
		wide				100
		tall				100
		visible				0
		image				"../ui/icon_titan_shield"
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				2

		pin_to_sibling				Background
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	EnemyIconBK
	{
		ControlName			ImagePanel
		xpos				9
		ypos				9
		wide				115
		tall				115
		visible				1
		image				"../ui/icon_enemy_titan_count"
		scaleImage			1
		drawColor			"0 0 0 255"

		zpos				9

		pin_to_sibling				EnemyIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	EnemyName
	{
		ControlName			Label
		xpos				0
		ypos				-13
		wide				140
		tall				50
		visible				1
		//autoresize			3
		font				HudNumbersSmall
		labelText			"Names Blah"
		textAlignment		center
		drawColor			"255 255 255 255"

		zpos				10

		pin_to_sibling				EnemyIcon
		pin_corner_to_sibling		4
		pin_to_sibling_corner		6
	}
	
	TargetHealthBar
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				-60
		zpos 				10
		wide				100
		tall				17
		visible				1
		bg_image			HUD/white
		fg_image			HUD/white
		segment_bg_image	HUD/white
		fgcolor_override	"255 95 55 255"
		bgcolor_override	"0 0 0 155"
		SegmentSize			284
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2
		
		pin_to_sibling				Background
		pin_corner_to_sibling		6
		pin_to_sibling_corner		4
	}

	TargetDoomedHealthBar
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				0
		zpos 				0
		wide				100
		tall				17
		visible				1
		bg_image			HUD/titan_doomedbar_bg
		fg_image			HUD/target_doomedbar_fill
		//segment_bg_image	HUD/dpad_bg_shape
		fgcolor_override	"255 255 255 255"
		bgcolor_override	"255 255 255 160"
		SegmentSize			284
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			1

		pin_to_sibling				TargetHealthBar
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}	

}

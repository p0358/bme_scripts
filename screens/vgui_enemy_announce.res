vgui_enemy_announce.res
{
	PreviewCard_background
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				125

		wide				472
		tall				60

		image				"hud/coop/wave_callout_strip"

		scaleImage			1
		drawColor			"255 255 255 255"
	}

	PreviewCard_backgroundOutline
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				126

		wide				472
		tall				60

		image				"hud/coop/wave_callout_strip_lines"

		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				PreviewCard_background
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	PreviewCard_HeaderBackground
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				125

		wide				472
		tall				60

		image				"hud/coop/wave_callout_hazard"

		scaleImage			1
		drawColor			"255 255 255 255"
	}

	PreviewCard_numEnemies
	{
		ControlName			Label
		xpos				-12
		ypos				0

		visible				0
		zpos				136
		wide				55
		tall				200
		labelText			"64"
		allCaps				1
		font				EnemyAnnounceCard_Number
		fgcolor_override 	"190 190 190 255"
		//bgcolor_override 	"120 0 0 255"
		//paintbackground 	1
		centerwrap			0
		textAlignment 		east

		pin_to_sibling				PreviewCard_background
		pin_corner_to_sibling		7
		pin_to_sibling_corner		7
	}

	PreviewCard_icon1
	{
		ControlName			ImagePanel
		xpos				4
		ypos				0
		zpos				135

		wide				56
		tall				56

		image				"../ui/icon_status_titan_burn"

		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				PreviewCard_numEnemies
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5
	}

	// hacky- for "header" cards only this element is used
	PreviewCard_HeaderTitle
	{
		ControlName			Label
		xpos				-30
		ypos				0

		visible				0
		zpos				135
		wide				256
		tall				64
		labelText			"HEADER TITLE"
		allCaps				1
		font				EnemyAnnounceCard_ListHeader
		fgcolor_override 	"235 235 235 235"
		centerwrap			0
		textAlignment 		west

		pin_to_sibling				PreviewCard_background
		pin_corner_to_sibling		7
		pin_to_sibling_corner		7
	}

	// hacky- for "footer" cards only this element is used
	PreviewCard_FooterTitle
	{
		ControlName				Label
		xpos					0
		ypos					0

		visible					0
		zpos					135
		//wide					250
		auto_wide_tocontents 	1
		textinsetx				12
		use_proportional_insets	1
		tall					28
		labelText				"#NEW_ENEMY_ANNOUNCE_HINT"
		allCaps					1
		font					EnemyAnnounceCard_EnemyDesc
		fgcolor_override 		"190 190 190 235"
		bgcolor_override 		"0 0 0 150"
		paintbackground 		1
		centerwrap				0
		textAlignment 			center

		pin_to_sibling			PreviewCard_icon1
		pin_corner_to_sibling	7
		pin_to_sibling_corner	5
	}

	PreviewCard_title
	{
		ControlName			Label
		xpos				4
		ypos				0

		visible				0
		zpos				135
		wide				330
		tall				24
		labelText			"TITLE"
		allCaps				1
		font				EnemyAnnounceCard_EnemyName
		fgcolor_override 	"157 196 219 255"
		//bgcolor_override 	"0 120 0  255"
		//paintbackground 	1
		centerwrap			0
		textAlignment 		southwest

		pin_to_sibling				PreviewCard_icon1
		pin_corner_to_sibling		2
		pin_to_sibling_corner		5
	}

	PreviewCard_description
	{
		ControlName			Label
		xpos				4
		ypos				0

		visible				0
		zpos				135
		wide				330
		tall				24
		labelText			"TITLE"
		allCaps				0
		font				EnemyAnnounceCard_EnemyDesc
		fgcolor_override 	"190 190 190 235"
		//bgcolor_override 	"120 0 0  255"
		//paintbackground 	1
		centerwrap			0
		textAlignment 		northwest

		pin_to_sibling				PreviewCard_icon1
		pin_corner_to_sibling		0
		pin_to_sibling_corner		5
	}

}

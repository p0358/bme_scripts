vgui_burn_card_shop.res
{
	PreviewCard_background
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				125

		wide				180
		tall				251

		image				burncards/burncard_large_back

		scaleImage			1
		drawColor			"255 255 255 255"
	}

	PreviewCard_outline
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				250

		wide				180
		tall				251
		visible				0

		image				burncards/burncard_large_outline_highlight

		scaleImage			1
		drawColor			"255 255 255 255"
	}

	PreviewCard_topbottom_brackets
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				127

		wide				180
		tall				251


		image				burncards/burncard_large_header_common

		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				PreviewCard_background
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}

	PreviewCard_title
	{
		ControlName			Label
		xpos				17
		ypos				-7

		visible				0
		zpos				135
		wide				127
		tall				39
		labelText			"TITLE"
		allCaps				1
		font				RespawnPreviewTitle_Medium
		fgcolor_override 	"255 255 255 255"
		centerwrap			1

		pin_to_sibling				PreviewCard_topbottom_brackets
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}

	PreviewCard_image
	{
		ControlName			ImagePanel
		xpos				0
		ypos				-45
		zpos				130

		wide				180
		tall				93

		image				burncards/burncard_art_spectre_virus

		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				PreviewCard_background
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}

	PreviewCard_new
	{
		ControlName			Label
		xpos				-7
		ypos				0

		visible				0
		zpos				235
		wide				159
		tall				24
		labelText			"#NEW"
		allCaps				1
		font				RespawnPreviewTitle_Medium
		fgcolor_override 	"100 255 100 255"
		textAlignment		west

		pin_to_sibling				PreviewCard_image
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	PreviewCard_text_brackets
	{
		ControlName			ImagePanel
		xpos				0
		ypos				-20
		zpos				130

		wide				169
		tall				43
		visible				0

		image				burncards/burncard_text_brackets

		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				PreviewCard_background
		pin_corner_to_sibling		6
		pin_to_sibling_corner		6
	}

	PreviewCard_flavorText
	{
		ControlName			Label
		xpos				-7
		ypos				0 // -4
		zpos				133

		wide				144
		tall				39

		allCaps				0
		labelText			"The enemy of my enemy.. is a deadly horde of reprogrammed robots."
		font				RespawnPreviewFlavorText_Medium
		centerwrap			1
		fgcolor_override 	"255 255 255 255" // overwritten in script
		textAlignment		center


		pin_to_sibling				PreviewCard_text_brackets
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	PreviewCard_flavorText_owner
	{
		ControlName			Label
		xpos				-15
		ypos				0
		zpos				133

		wide				169
		tall				8

		allCaps				0
		labelText			"-MacAllan"
		font				RespawnPreviewFlavorText_Medium
		fgcolor_override 	"255 255 255 255" // overwritten in script
		textAlignment		south-east


		pin_to_sibling				PreviewCard_flavorText
		pin_corner_to_sibling		1
		pin_to_sibling_corner		3
	}

	PreviewCard_number
	{
		ControlName			Label
		xpos				-1
		ypos				-4
		zpos				134

		wide				16
		tall				8

		allCaps				0
		labelText			"00"
		font				RespawnPreviewFlavorText_Medium
		fgcolor_override 	"48 48 48 255" // overwritten in script
		textAlignment		south-east


		pin_to_sibling				PreviewCard_background
		pin_corner_to_sibling		2
		pin_to_sibling_corner		2
	}

	PreviewCard_icon1
	{
		ControlName			ImagePanel
		xpos				-6
		ypos				-6
		zpos				138

		wide				24
		tall				24

		image				burncards/burncard_icon_spectre_virus

		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				PreviewCard_background
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	PreviewCard_icon2
	{
		ControlName			ImagePanel
		xpos				-6
		ypos				-6
		zpos				138

		wide				24
		tall				24

		image				burncards/burncard_icon_spectre_virus

		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				PreviewCard_background
		pin_corner_to_sibling		3
		pin_to_sibling_corner		3
	}


	PreviewCard_star
	{
		ControlName			ImagePanel
		xpos				0
		ypos				-46
		zpos				130

		wide				58
		tall				58

		image				HUD/instamission_star_on
		//image				../models/fx/energy_pulse_alpha_1

		scaleImage			1
		visible				0
		drawColor			"255 255 255 255"

		pin_to_sibling				PreviewCard_background
		pin_corner_to_sibling		6
		pin_to_sibling_corner		6

		//wide				200
		//tall				160
	}

	PreviewCard_description
	{
		ControlName			Label
		xpos				0
		ypos				-21
		zpos				133

		wide				158
		tall				127

		allCaps				0
		labelText			"wall of description text wall of description text"
		font				RespawnPreviewDescription_Medium
		centerwrap			1
		fgcolor_override 	"0 0 0 255"
		textAlignment		center

		pin_to_sibling				PreviewCard_background
		pin_corner_to_sibling		6
		pin_to_sibling_corner		6
	}

}